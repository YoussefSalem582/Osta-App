import 'dart:async';

import 'package:flutter/foundation.dart';

/// Adapts a [Stream] (a Cubit's state stream) into the [Listenable] that
/// go_router's `refreshListenable` expects, so the redirect re-runs whenever
/// the session changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
