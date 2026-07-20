import 'dart:async';
import 'dart:io';

import 'package:dnpwc/config/app_config.dart';
import 'package:flutter/foundation.dart';

/// Describes the current connectivity state.
enum ConnectivityState { connected, disconnected }

/// Singleton that continuously monitors internet connectivity.
///
/// Periodically resolves the API hostname to determine if the device
/// can reach the backend. Exposes a [ValueNotifier] so widgets can
/// listen and react to connectivity changes.
///
/// Call [start()] once (e.g. from `main.dart`) and [dispose()] when
/// the app shuts down.
class ConnectivityMonitor {
  // ── Singleton ───────────────────────────────────────────────────
  ConnectivityMonitor._();
  static final ConnectivityMonitor _instance = ConnectivityMonitor._();
  static ConnectivityMonitor get instance => _instance;

  // ── Notifier ────────────────────────────────────────────────────
  final ValueNotifier<ConnectivityState> stateNotifier =
      ValueNotifier(ConnectivityState.connected);

  // ── Internals ───────────────────────────────────────────────────
  Timer? _timer;
  bool _started = false;

  static const Duration _checkInterval = Duration(seconds: 8);

  /// Start periodic connectivity checks. Safe to call multiple times.
  void start() {
    if (_started) return;
    _started = true;

    // Run an immediate check, then every [_checkInterval].
    _checkNow();
    _timer = Timer.periodic(_checkInterval, (_) => _checkNow());
  }

  /// Stop monitoring and release resources.
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _started = false;
    stateNotifier.dispose();
  }

  /// Immediately re-check connectivity. Safe to call anytime.
  Future<void> retryNow() => _checkNow();

  Future<void> _checkNow() async {
    final bool online = await _isReachable();
    if (!_started) return; // disposed in the meantime
    stateNotifier.value =
        online ? ConnectivityState.connected : ConnectivityState.disconnected;
  }

  /// Returns `true` if the API server's hostname resolves.
  Future<bool> _isReachable() async {
    try {
      final uri = Uri.parse(AppConfig.baseUrl);
      final result = await InternetAddress.lookup(uri.host)
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
