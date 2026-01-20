import 'package:flutter/material.dart';
import '../../features/auth/ui/login_page.dart';
import '../../features/auth/ui/register_page.dart';
import '../../features/home/ui/notification_page.dart';
import '../../features/home/ui/profile_page.dart';
import '../../features/home/ui/settings_page.dart';
import '../../features/root/ui/main_root_page.dart';
import '../../features/splash/ui/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String notifications = '/notif';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    home: (context) => const MainRootPage(),
    notifications: (context) => const NotificationPage(),
    profile: (context) => const ProfilePage(),
    settings: (context) => const SettingsPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return null;
  }
}
