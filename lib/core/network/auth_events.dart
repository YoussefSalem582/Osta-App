import 'dart:async';

import 'package:injectable/injectable.dart';

/// Global auth signals emitted by the networking layer.
///
/// The router/auth epics listen to [onSessionExpired] to force logout when a
/// 401 survives the single refresh-and-retry.
@lazySingleton
class AuthEvents {
  final _sessionExpired = StreamController<void>.broadcast();

  /// Fires when the session is irrecoverably unauthenticated.
  Stream<void> get onSessionExpired => _sessionExpired.stream;

  void emitSessionExpired() => _sessionExpired.add(null);

  @disposeMethod
  Future<void> dispose() => _sessionExpired.close();
}
