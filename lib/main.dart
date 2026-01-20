import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/routing/app_router.dart';
import 'core/utils/app_bloc_observer.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/services/auth_service.dart';
import 'features/admin/bloc/admin_bloc.dart';
import 'features/admin/bloc/admin_event.dart';
import 'core/services/office_location.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OfficeConfig.load();
  Bloc.observer = AppBlocObserver();

  // Check onboarding status
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  final initialRoute = seenOnboarding ? AppRouter.login : AppRouter.onboarding;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBloc(authService: AuthService())..add(AuthCheckRequested()),
        ),
        BlocProvider(create: (context) => AdminBloc()..add(AdminStarted())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Shift',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xff5a64d6),
        ),
        initialRoute: initialRoute,
        routes: AppRouter.routes,
      ),
    );
  }
}
