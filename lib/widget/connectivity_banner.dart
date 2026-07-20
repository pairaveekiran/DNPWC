import 'package:dnpwc/services/connectivity_monitor.dart';
import 'package:flutter/material.dart';

/// A global top-of-screen banner that slides in when the device goes
/// offline and slides out when connectivity is restored.
///
/// Place this as the top-most widget in a [Stack] (e.g. via
/// `MaterialApp.builder`) so it overlays every screen.
class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  static const double _bannerHeight = 52;

  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  // Track whether we were offline to trigger the "back online" message.
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    // Listen for connectivity changes.
    ConnectivityMonitor.instance.stateNotifier.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    ConnectivityMonitor.instance.stateNotifier.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;

    final state = ConnectivityMonitor.instance.stateNotifier.value;

    if (state == ConnectivityState.disconnected) {
      _wasOffline = true;
      _controller.forward();
    } else if (state == ConnectivityState.connected && _wasOffline) {
      _wasOffline = false;
      // Show "Back online" for 3 seconds, then slide out.
      _controller.forward();
      Future.delayed(const Duration(seconds: 3), () {
        // Only hide if we're still connected (avoid hiding during offline).
        if (!mounted) return;
        final currentState =
            ConnectivityMonitor.instance.stateNotifier.value;
        if (currentState == ConnectivityState.connected) {
          _controller.reverse();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityState = ConnectivityMonitor.instance.stateNotifier.value;
    final bool isOnline = connectivityState == ConnectivityState.connected;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: child!,
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _bannerHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isOnline
                ? [const Color(0xFF2E7D32), const Color(0xFF388E3C)]
                : [const Color(0xFFC62828), const Color(0xFFD32F2F)],
          ),
          boxShadow: [
            BoxShadow(
              color: (isOnline
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828))
                  .withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // ─── Animated icon ───
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    isOnline
                        ? Icons.wifi_rounded
                        : Icons.wifi_off_rounded,
                    key: ValueKey(isOnline),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // ─── Text ───
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      isOnline
                          ? 'Back online'
                          : 'You are currently offline',
                      key: ValueKey(isOnline),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),

                // ─── CTA / dismiss ───
                if (!isOnline)
                  GestureDetector(
                    onTap: () => ConnectivityMonitor.instance.retryNow(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Retry',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (isOnline)
                  GestureDetector(
                    onTap: () => _controller.reverse(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
