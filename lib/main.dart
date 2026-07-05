import 'dart:async';
import 'package:dnpwc/screen/home.dart';
import 'package:dnpwc/screen/login.dart';
import 'package:dnpwc/services/auth_service.dart';
import 'package:flutter/material.dart';

void
main() {
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
          "assets/images/dnpwc.png",
          width: 220,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
