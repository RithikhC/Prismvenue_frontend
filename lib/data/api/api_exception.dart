/// The client side of the API's single error envelope.
///
/// The backend never returns a bare string — every failure arrives as
/// `{"error": {code, message, field, correlation_id, retryable}}`. This class
/// is that envelope, plus the two failures that happen before a response
/// exists at all (no network, unreadable body).
///
/// [message] is written by the server to be shown to venue staff verbatim.
/// [code] is the stable machine string to branch on — never branch on
/// [message], it is copy and will change.
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.field,
    this.correlationId,
    this.retryable = false,
  });

  /// Nothing reached the server — offline, wrong host, DNS, TLS.
  factory ApiException.network(Object cause) => ApiException(
        statusCode: 0,
        code: 'network_unreachable',
        message: "Can't reach Prism. Check the connection and try again.",
        retryable: true,
        correlationId: cause.toString(),
      );

  /// A response arrived but was not the envelope we expect.
  factory ApiException.malformed(int statusCode) => ApiException(
        statusCode: statusCode,
        code: 'malformed_response',
        message: 'Something went wrong on our side.',
        retryable: true,
      );

  final int statusCode;
  final String code;
  final String message;
  final String? field;
  final String? correlationId;
  final bool retryable;

  /// 401 — the session is gone. The app signs out rather than retrying.
  bool get isUnauthorized => statusCode == 401;

  /// 403 — signed in, but this role may not do this. Distinct from
  /// [isUnauthorized]: signing out would not help.
  bool get isForbidden => statusCode == 403;

  /// 404 — includes "exists but outside your scope"; the server deliberately
  /// does not distinguish those, so neither can we.
  bool get isNotFound => statusCode == 404;

  @override
  String toString() => 'ApiException($statusCode $code): $message';
}
