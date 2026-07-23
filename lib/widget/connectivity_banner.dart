import 'dart:async';
import 'package:dnpwc/services/connectivity_monitor.dart';
import 'package:flutter/material.dart';

/// Describes what the banner is currently showing.
enum _BannerMode { hidden, offline, backonline }

/// A global top-of-screen banner that slides in when the device goes
/// offline and slides out after connectivity is restored.
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
  // ─── Dimensions ────────────────────────────────────────────────
  static const double _bannerHeight = 56;

  // ─── Animations ────────────────────────────────────────────────
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  // ─── State ─────────────────────────────────────────────────────
  _BannerMode _mode = _BannerMode.hidden;
  Timer? _autoHideTimer;

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

    // Show immediately if already offline.
    final initial = ConnectivityMonitor.instance.stateNotifier.value;
    if (initial == ConnectivityState.disconnected) {
      _mode = _BannerMode.offline;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    ConnectivityMonitor.instance.stateNotifier.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  // ─── Connectivity listener ─────────────────────────────────────
  void _onStateChanged() {
    if (!mounted) return;

    final state = ConnectivityMonitor.instance.stateNotifier.value;

    if (state == ConnectivityState.disconnected) {
      _handleDisconnected();
    } else {
      _handleConnected();
    }
  }

  void _handleDisconnected() {
    // Cancel any pending "Back online" hide timer.
    _autoHideTimer?.cancel();
    _autoHideTimer = null;

    setState(() {
      _mode = _BannerMode.offline;
    });

    // Slide in if not already visible.
    if (_controller.isDismissed) {
      _controller.forward();
    }
  }

  void _handleConnected() {
    // Only show "Back online" if we were previously showing offline.
    if (_mode != _BannerMode.offline) {
      // Already online and nothing to announce — hide if needed.
      if (_controller.isCompleted && _mode != _BannerMode.backonline) {
        _controller.reverse();
      }
      return;
    }

    // Transition: offline → back online
    setState(() {
      _mode = _BannerMode.backonline;
    });

    // Ensure banner is visible.
    if (_controller.isDismissed) {
      _controller.forward();
    }

    // Schedule auto-hide after 3 seconds.
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 3), _onAutoHideTimer);
  }

  void _onAutoHideTimer() {
    _autoHideTimer = null;
    if (!mounted) return;

    final current = ConnectivityMonitor.instance.stateNotifier.value;

    // Only hide if we're still connected.
    if (current == ConnectivityState.connected) {
      _controller.reverse().then((_) {
        if (mounted) {
          setState(() => _mode = _BannerMode.hidden);
        }
      });
    }
    // If disconnected again, the _handleDisconnected path will keep
    // the banner visible with the correct message.
  }

  void _dismissNow() {
    _autoHideTimer?.cancel();
    _autoHideTimer = null;
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() => _mode = _BannerMode.hidden);
      }
    });
  }

  // ─── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_mode == _BannerMode.hidden && _controller.isDismissed) {
      return const SizedBox.shrink();
    }

    final bool isBackOnline = _mode == _BannerMode.backonline;

    // ─── Colour & content ────────────────────────────────────
    final Color bgColor;
    final Color shadowColor;
    final IconData icon;
    final String text;

    if (isBackOnline) {
      bgColor = const Color(0xFF16A34A); // muted success green
      shadowColor = const Color(0xFF16A34A).withValues(alpha: 0.35);
      icon = Icons.cloud_done_rounded;
      text = 'Back online';
    } else {
      bgColor = const Color(0xFFDC2626); // error red
      shadowColor = const Color(0xFFDC2626).withValues(alpha: 0.30);
      icon = Icons.wifi_off_rounded;
      text = 'You are currently offline';
    }

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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Container(
          height: _bannerHeight,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 14,
                offset: const Offset(0, 5),
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
                  // ─── Icon ─────────────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: Icon(
                      icon,
                      key: ValueKey(isBackOnline),
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ─── Text ─────────────────────────────
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: Text(
                        text,
                        key: ValueKey(isBackOnline),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),

                  // ─── Action button ────────────────────
                  if (!isBackOnline)
                    _buildActionChip(
                      icon: Icons.refresh_rounded,
                      label: 'Retry',
                      onTap: () => ConnectivityMonitor.instance.retryNow(),
                    ),

                  if (isBackOnline)
                    GestureDetector(
                      onTap: _dismissNow,
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
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
