import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/routing/app_router.dart';
import 'core/utils/app_bloc_observer.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/services/auth_service.dart';
import 'features/admin/bloc/admin_bloc.dart';
import 'features/admin/bloc/admin_event.dart';
import 'features/admin/ui/admin_root_page.dart';
import 'features/root/ui/main_root_page.dart';
import 'features/auth/ui/login_page.dart';
import 'features/onboarding/ui/onboarding_page.dart';
import 'features/splash/ui/splash_screen.dart';

import 'features/attendance/services/attendance_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Bloc.observer = AppBlocObserver();

  // Check onboarding status
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBloc(authService: AuthService())..add(AuthCheckRequested()),
        ),
      ],
      child: MyApp(seenOnboarding: seenOnboarding),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool seenOnboarding;

  const MyApp({super.key, required this.seenOnboarding});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shift',
      navigatorKey: _navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xff5a64d6),
      ),
      home: AuthWrapper(seenOnboarding: widget.seenOnboarding),
      routes: AppRouter.routes,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final bool seenOnboarding;

  const AuthWrapper({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Optional: Global listeners for error handling
      },
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildScreen(state),
        );
      },
    );
  }

  Widget _buildScreen(AuthState state) {
    if (state.status == AuthStatus.initial ||
        state.status == AuthStatus.loading) {
      return const SplashScreen();
    }

    if (state.status == AuthStatus.authenticated && state.user != null) {
      final isAdmin = state.user!.role == 'admin';
      return MultiBlocProvider(
        key: ValueKey('authenticated_${state.user!.id}'),
        providers: [
          BlocProvider(
            create: (context) => AdminBloc(
              attendanceService: AttendanceService(),
              authService: AuthService(),
              companyId: state.user!.companyId,
            )..add(AdminStarted()),
          ),
        ],
        child: isAdmin ? const AdminRootPage() : const MainRootPage(),
      );
    }

    // Unauthenticated
    if (!seenOnboarding) {
      return const OnboardingPage();
    }

    return const LoginPage();
  }
}
