import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where the session token lives between launches.
///
/// `BACKEND_INTEGRATION.md` §4 called this out as the one gap that forces a
/// change outside the repositories: the app had no token storage at all, so a
/// restart signed the user out. Venue staff keep this open on an iPad for a
/// whole shift — that had to be fixed before anything else could rely on auth.
///
/// Abstract on purpose. Secure storage needs a platform channel, which widget
/// tests do not have; [InMemoryTokenStore] lets the suite exercise the same
/// code paths without one.
abstract class TokenStore {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> write({required String accessToken, required String refreshToken});
  Future<void> clear();
}

/// Backed by the platform keystore — Keychain on iOS/macOS, EncryptedSharedPreferences
/// on Android, WebCrypto-wrapped localStorage on web.
class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accessKey = 'prism.access_token';
  static const _refreshKey = 'prism.refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccessToken() => _read(_accessKey);

  @override
  Future<String?> readRefreshToken() => _read(_refreshKey);

  /// A keystore read can throw — a wiped Android keystore after a restore, or
  /// a browser with storage blocked. Treating that as "no token" signs the
  /// user in again, which is recoverable. Letting it throw would break launch.
  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _accessKey);
      await _storage.delete(key: _refreshKey);
    } catch (_) {
      // Nothing useful to do; the token is unusable either way.
    }
  }
}

/// For tests and for `--dart-define=PRISM_USE_MOCKS=true`.
class InMemoryTokenStore implements TokenStore {
  String? _access;
  String? _refresh;

  @override
  Future<String?> readAccessToken() async => _access;

  @override
  Future<String?> readRefreshToken() async => _refresh;

  @override
  Future<void> write({
    required String accessToken,
    required String refreshToken,
  }) async {
    _access = accessToken;
    _refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }
}
