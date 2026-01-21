import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // ANIMASI LOGO (zoom in)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // CHECK ONBOARDING STATUS
    Future.delayed(const Duration(seconds: 2), () async {
      bool seen = false;
      try {
        final prefs = await SharedPreferences.getInstance();
        seen = prefs.getBool('seenOnboarding') ?? false;
      } catch (e) {
        debugPrint("Error reading SharedPreferences: $e");
      }

      if (!mounted) return;
      if (seen) {
        Navigator.pushReplacementNamed(context, "/login");
      } else {
        Navigator.pushReplacementNamed(context, "/onboarding");
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F13), // dark theme matches Admin
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // LOGO
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF7C7FFF), // kAccentColor
                      Color(0xFF9EA1FF),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.scatter_plot_outlined,
                  size: 55,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // NAMA APP
              const Text(
                "Shift",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEDEDED),
                  letterSpacing: 0.8,
                ),
              ),

              const SizedBox(height: 6),

              // SUBTEXT
              const Text(
                "Smart Presence System",
                style: TextStyle(color: Color(0xFF9AA0AA), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
