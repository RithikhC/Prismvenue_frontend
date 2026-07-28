import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:prism_venues/app/roles.dart';
import 'package:prism_venues/data/api/api_auth_repo.dart';
import 'package:prism_venues/data/api/api_client.dart';
import 'package:prism_venues/data/api/api_exception.dart';
import 'package:prism_venues/data/api/token_store.dart';

/// Transport and auth-mapping tests.
///
/// No backend required: `MockClient` stands in for the network, so these prove
/// the contract the Flutter side implements — headers, token lifecycle, error
/// envelope decoding, and the reset-flow token requirement.
void main() {
  const base = 'http://localhost:8000/v1';

  late InMemoryTokenStore tokens;
  late List<http.Request> sent;

  setUp(() {
    tokens = InMemoryTokenStore();
    sent = [];
  });

  /// Replays [responses] in order, recording every request.
  ApiClient clientReturning(
    List<http.Response> responses, {
    void Function()? onSessionLost,
  }) {
    var i = 0;
    return ApiClient(
      baseUrl: base,
      tokens: tokens,
      onSessionLost: onSessionLost,
      httpClient: MockClient((request) async {
        sent.add(request);
        return responses[i++ < responses.length ? i - 1 : responses.length - 1];
      }),
    );
  }

  http.Response json(Object body, [int status = 200]) =>
      http.Response(jsonEncode(body), status,
          headers: {'content-type': 'application/json'});

  const signInBody = {
    'token': 'access-1',
    'refresh_token': 'refresh-1',
    'expires_at': 1800000000,
    'user': {
      'id': 'u-1',
      'name': 'Priya Nair',
      'role': 'manager',
      'initials': 'PN',
      'avatar_color': '#84C44A',
    },
    'context': {
      'venue_id': 'v-1',
      'venue_name': 'Marina Café',
      'zone_id': 'z-1',
      'zone_name': 'Main floor',
    },
  };

  group('ApiClient transport', () {
    test('attaches the bearer token to authenticated requests', () async {
      await tokens.write(accessToken: 'access-1', refreshToken: 'refresh-1');
      final client = clientReturning([json({'ok': true})]);

      await client.get('/auth/me');

      expect(sent.single.headers['Authorization'], 'Bearer access-1');
    });

    test('sends no Authorization header before sign-in', () async {
      final client = clientReturning([json({})]);

      await client.postPublic('/auth/sign-in', body: {'email': 'a@b.c'});

      expect(sent.single.headers.containsKey('Authorization'), isFalse);
    });

    test('puts an Idempotency-Key on POST but not on GET', () async {
      await tokens.write(accessToken: 'access-1', refreshToken: 'r');
      final client = clientReturning([json({}), json({})]);

      await client.post('/zones/z-1/pause', body: {'by': 'Priya'});
      await client.get('/zones/z-1/now');

      expect(sent[0].headers['Idempotency-Key'], isNotEmpty);
      expect(sent[1].headers.containsKey('Idempotency-Key'), isFalse);
    });

    test('reuses the same Idempotency-Key when replaying after a refresh',
        () async {
      // The whole point of the header: the retry must be recognised as the
      // SAME pause, not a second one.
      await tokens.write(accessToken: 'stale', refreshToken: 'refresh-1');
      final client = clientReturning([
        json({
          'error': {'code': 'unauthorized', 'message': 'expired'}
        }, 401),
        json({'token': 'access-2', 'refresh_token': 'refresh-2'}), // refresh
        json({'zone_id': 'z-1'}), // replay
      ]);

      await client.post('/zones/z-1/pause', body: {'by': 'Priya'});

      expect(sent, hasLength(3));
      expect(sent[0].headers['Idempotency-Key'],
          sent[2].headers['Idempotency-Key']);
      // And the replay carries the refreshed token, not the stale one.
      expect(sent[2].headers['Authorization'], 'Bearer access-2');
      expect(await tokens.readAccessToken(), 'access-2');
    });

    test('a failed refresh clears the session exactly once', () async {
      await tokens.write(accessToken: 'stale', refreshToken: 'refresh-1');
      var lost = 0;
      final client = clientReturning(
        [
          json({
            'error': {'code': 'unauthorized', 'message': 'expired'}
          }, 401),
          json({'error': 'invalid_grant'}, 400), // refresh refused
        ],
        onSessionLost: () => lost++,
      );

      await expectLater(
        client.get('/auth/me'),
        throwsA(isA<ApiException>().having((e) => e.isUnauthorized, 'is401', true)),
      );
      expect(lost, 1);
      expect(await tokens.readAccessToken(), isNull);
    });

    test('decodes the error envelope into ApiException', () async {
      final client = clientReturning([
        json({
          'error': {
            'code': 'invalid_reset_code',
            'message': 'That code is wrong or expired.',
            'field': 'code',
            'correlation_id': '0dfc',
            'retryable': true,
          }
        }, 422),
      ]);

      await expectLater(
        client.postPublic('/auth/reset/verify', body: {}),
        throwsA(isA<ApiException>()
            .having((e) => e.code, 'code', 'invalid_reset_code')
            .having((e) => e.field, 'field', 'code')
            .having((e) => e.retryable, 'retryable', true)
            .having((e) => e.message, 'message', contains('wrong or expired'))),
      );
    });

    test('a non-envelope error body does not crash the decoder', () async {
      // An nginx 502 page, a proxy timeout — anything that is not our API.
      final client = clientReturning([http.Response('<html>502</html>', 502)]);

      await expectLater(
        client.get('/auth/me'),
        throwsA(isA<ApiException>()
            .having((e) => e.code, 'code', 'malformed_response')),
      );
    });

    test('a network failure surfaces as a retryable ApiException', () async {
      final client = ApiClient(
        baseUrl: base,
        tokens: tokens,
        httpClient: MockClient((_) => throw const SocketishFailure()),
      );

      await expectLater(
        client.get('/auth/me'),
        throwsA(isA<ApiException>()
            .having((e) => e.code, 'code', 'network_unreachable')
            .having((e) => e.retryable, 'retryable', true)),
      );
    });
  });

  group('ApiAuthRepo', () {
    test('sign-in maps the user, context, and stores both tokens', () async {
      final client = clientReturning([json(signInBody)]);
      final repo = ApiAuthRepo(client, tokens);

      final session = await repo.signIn('priya@marinacafe.com', 'pw');

      expect(session.user.name, 'Priya Nair');
      expect(session.user.role, Role.manager);
      expect(session.user.initials, 'PN');
      // "#84C44A" must survive as an opaque colour, not a transparent one.
      expect(session.user.avatarColor.toARGB32(), 0xFF84C44A);

      expect(session.context.zoneId, 'z-1');
      expect(session.context.venueName, 'Marina Café');

      expect(await tokens.readAccessToken(), 'access-1');
      expect(await tokens.readRefreshToken(), 'refresh-1');
    });

    test('an unrecognised role falls back to the least privilege', () async {
      final body = Map<String, dynamic>.from(signInBody);
      body['user'] = {...signInBody['user'] as Map, 'role': 'regional-manager'};
      final repo = ApiAuthRepo(clientReturning([json(body)]), tokens);

      final session = await repo.signIn('x@y.z', 'pw');

      // Seeing too little is recoverable; seeing too much is not.
      expect(session.user.role, Role.floor);
    });

    test('restoreSession returns null and clears tokens on 401', () async {
      await tokens.write(accessToken: 'dead', refreshToken: '');
      final repo = ApiAuthRepo(
        clientReturning([
          json({
            'error': {'code': 'unauthorized', 'message': 'expired'}
          }, 401)
        ]),
        tokens,
      );

      expect(await repo.restoreSession(), isNull);
      expect(await tokens.readAccessToken(), isNull);
    });

    test('restoreSession returns null without a stored token, no request',
        () async {
      final repo = ApiAuthRepo(clientReturning([json({})]), tokens);

      expect(await repo.restoreSession(), isNull);
      expect(sent, isEmpty);
    });

    test('restoreSession rebuilds the session from a stored token', () async {
      await tokens.write(accessToken: 'access-1', refreshToken: 'refresh-1');
      final repo = ApiAuthRepo(
        clientReturning([
          json({'user': signInBody['user'], 'context': signInBody['context']})
        ]),
        tokens,
      );

      final session = await repo.restoreSession();

      expect(session, isNotNull);
      expect(session!.user.role, Role.manager);
      expect(session.context.zoneId, 'z-1');
    });

    test('verifyResetCode returns the proof token', () async {
      final repo = ApiAuthRepo(
        clientReturning([json({'reset_token': 'proof-1'})]),
        tokens,
      );

      expect(await repo.verifyResetCode('p@m.com', '482913'), 'proof-1');
    });

    test('saveNewPassword sends the reset token', () async {
      // The §5.1 fix, asserted on the wire: without this field the server
      // refuses, and email+password alone must never be enough.
      final repo = ApiAuthRepo(clientReturning([json({})]), tokens);

      await repo.saveNewPassword(
        email: 'p@m.com',
        password: 'a-good-password',
        resetToken: 'proof-1',
      );

      final body = jsonDecode(sent.single.body) as Map<String, dynamic>;
      expect(body['reset_token'], 'proof-1');
      expect(body['password'], 'a-good-password');
    });

    test('signOut clears stored tokens', () async {
      await tokens.write(accessToken: 'a', refreshToken: 'r');
      final repo = ApiAuthRepo(clientReturning([json({})]), tokens);

      await repo.signOut();

      expect(await tokens.readAccessToken(), isNull);
      expect(await tokens.readRefreshToken(), isNull);
    });
  });
}

/// Stands in for a transport-level failure (DNS, TLS, connection refused).
class SocketishFailure implements Exception {
  const SocketishFailure();
}
