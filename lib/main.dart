import 'dart:async';
import 'package:dnpwc/screen/home.dart';
import 'package:dnpwc/screen/login.dart';
import 'package:dnpwc/services/auth_service.dart';
import 'package:dnpwc/services/connectivity_monitor.dart';
import 'package:dnpwc/widget/connectivity_banner.dart';
import 'package:flutter/material.dart';

void
main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Start the global connectivity monitor.
  ConnectivityMonitor.instance.start();
  runApp(
    const MyApp(),
  );
}

class MyApp
    extends
        StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget
  build(
    BuildContext
    context,
  ) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      // ─── Global overlay for the connectivity banner ───
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            // Positioned at the very top of the screen.
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ConnectivityBanner(),
            ),
          ],
        );
      },
    );
  }
}

class SplashScreen
    extends
        StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<
    SplashScreen
  >
  createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends
        State<
          SplashScreen
        > {
  @override
  void
  initState() {
    super.initState();
    _routeAfterSplash();
  }

  Future<
    void
  >
  _routeAfterSplash() async {
    await Future.delayed(
      const Duration(
        seconds: 2,
      ),
    );

    if (!mounted) {
      return;
    }

    final isLoggedIn =
        await AuthService.isLoggedIn();
    final token =
        await AuthService.getToken();
    final Widget
    nextPage =
        isLoggedIn &&
            token !=
                null &&
            token.isNotEmpty
        ? const HomePage()
        : const LoginPage();

    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (
              context,
            ) => nextPage,
      ),
    );
  }

  @override
  Widget
  build(
    BuildContext
    context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          "assets/images/dnpwc.webp",
          width: 220,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
