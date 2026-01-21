import 'package:flutter/material.dart';

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

    // ANIMASI LOGO (Scale + Fade via Opacity if needed, but Scale is good)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // Longer animation
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5, // Start smaller
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
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
              Image.asset(
                'assets/logo/logo_shift.png',
                width: 120,
                height: 120,
                cacheWidth: 300, // Optimize memory usage
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint("LOGO LOAD ERROR: $error");
                  return const Icon(
                    Icons.scatter_plot_outlined,
                    size: 80,
                    color: Colors.white,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
