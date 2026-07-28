/// Build-time configuration.
///
/// Supplied with `--dart-define`, never from a committed file:
///
/// ```
/// flutter run -d chrome --dart-define=PRISM_API_BASE_URL=http://localhost:8000/v1
/// ```
///
/// Nothing secret belongs here. The app never sees a Supabase key, a service
/// role token, or a database URL — it only ever learns where the API lives.
/// Everything sensitive stays in the backend's `.env`.
class Env {
  const Env._();

  /// Base URL including the `/v1` prefix, no trailing slash.
  static const apiBaseUrl = String.fromEnvironment(
    'PRISM_API_BASE_URL',
    defaultValue: 'http://localhost:8000/v1',
  );

  /// When true the app runs entirely on the in-memory mocks, ignoring
  /// [apiBaseUrl]. Useful for design review and for running the widget tests
  /// the way they ran before the backend existed.
  static const useMocks = bool.fromEnvironment('PRISM_USE_MOCKS');
}
