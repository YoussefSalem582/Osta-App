import 'dart:async';

/// Global auth signals emitted by the networking layer.
///
/// The router/auth epics listen to [onSessionExpired] to force logout when a
/// 401 survives the single refresh-and-retry.
class AuthEvents {
  final _sessionExpired = StreamController<void>.broadcast();

  /// Fires when the session is irrecoverably unauthenticated.
  Stream<void> get onSessionExpired => _sessionExpired.stream;

  void emitSessionExpired() => _sessionExpired.add(null);

  /// Wired to get_it's `dispose` callback in `configureDependencies()`.
  Future<void> dispose() => _sessionExpired.close();
}
