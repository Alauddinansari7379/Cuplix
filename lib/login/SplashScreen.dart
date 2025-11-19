import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cuplix/dashboard/Dashboard.dart';
import '../utils/SharedPreferences.dart';
import 'Login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  bool _navigated = false; // <- prevents multiple navigations
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Use a timer reference so we can cancel if needed
    _navTimer = Timer(const Duration(milliseconds: 1100), () {
      _waitAndNavigate();
    });
  }

  Future<void> _waitAndNavigate() async {
    if (_navigated) return; // already navigated

    bool loggedIn = false;
    try {
      loggedIn = await SharedPrefs.isLoggedIn();
      // Helpful debug - remove or replace with logger in production
      debugPrint('SplashScreen: isLoggedIn = $loggedIn');
    } catch (e) {
      debugPrint('SplashScreen: error while checking login: $e');
      loggedIn = false;
    }

    if (!mounted) return;

    // guard again and perform single navigation
    if (!_navigated) {
      _navigated = true;
      if (loggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Dashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Login()),
        );
      }
    }
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: _buildLogoBox(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoBox(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = (size.width < 600) ? size.width * 0.5 : 300.0;

    return SizedBox(
      width: logoSize,
      height: logoSize,
      child: Image.asset('lib/assets/logo.jpeg', fit: BoxFit.contain),
    );
  }
}
