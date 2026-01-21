import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/location_service.dart';
import '../../auth/ui/login_page.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback? onDone;

  const OnboardingPage({super.key, this.onDone});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  final LocationService _locationService = LocationService();
  int _currentPage = 0;
  bool _isRequestingPermission = false;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Welcome to Shift",
      "subtitle": "Your calm companion for\nproductivity and presence.",
    },
    {
      "title": "Simplicity is Focused",
      "subtitle": "Track your attendance simply.\nNo noise, just clarity.",
    },
    {
      "title": "Location Required",
      "subtitle": "Please activate your GPS.\nWe need it for attendance.",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _locationService.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    } else {
      // Logic for the last page: Request Permission
      setState(() => _isRequestingPermission = true);

      try {
        // Just requesting position triggers the permission dialog
        await _locationService.getCurrentPosition();
        if (mounted) _finishOnboarding();
      } catch (e) {
        if (!mounted) return;
        // Show error but allow user to proceed or retry?
        // Let's show a snackbar and let them try again or maybe proceed anyway if they insist?
        // For now, let's just show the error.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Location permission required: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isRequestingPermission = false);
      }
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    if (!mounted) return;

    // Execute callback if provided
    if (widget.onDone != null) {
      widget.onDone!();
    } else {
      // Fallback behavior (should not be used in main flow)
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 180),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Matches Admin Home background
    const backgroundColor = Color(0xFF0E0F13);
    const kAccentColor = Color(0xFF7C7FFF);
    const kTextPrimary = Color(0xFFEDEDED);
    const kTextSecondary = Color(0xFF9AA0AA);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    final data = _onboardingData[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data["title"]!,
                            style: const TextStyle(
                              color: kTextPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            data["subtitle"]!,
                            style: const TextStyle(
                              color: kTextSecondary,
                              fontSize: 18,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // PAGE INDICATOR
                    Row(
                      children: List.generate(
                        _onboardingData.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 8),
                          height: 6,
                          width: _currentPage == index ? 24 : 6,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? kAccentColor
                                : Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    // NEXT BUTTON (TEXT ONLY, MINIMAL)
                    GestureDetector(
                      onTap: _isRequestingPermission ? null : _onNext,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isRequestingPermission
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: kTextPrimary,
                                ),
                              )
                            : Text(
                                _currentPage == _onboardingData.length - 1
                                    ? "Get Started"
                                    : "Next",
                                style: const TextStyle(
                                  color: kTextPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
