import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/routing/app_router.dart';
import 'core/utils/app_bloc_observer.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/services/auth_service.dart';
import 'features/admin/bloc/admin_bloc.dart';
import 'features/admin/bloc/admin_event.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        initialRoute: AppRouter.splash,
        routes: AppRouter.routes,
      ),
    );
  }
}
