import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/widgets/app_header.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  String _getErrorMessage(String? error) {
    if (error == null) return "An unknown error occurred";
    // Clean up standard exception prefixes
    final cleanError = error.replaceAll("Exception: ", "");

    if (cleanError.contains("user-not-found")) {
      return "No user found for that email.";
    } else if (cleanError.contains("wrong-password")) {
      return "Wrong password provided.";
    } else if (cleanError.contains("invalid-email")) {
      return "The email address is invalid.";
    } else if (cleanError.contains("user-disabled")) {
      return "This user account has been disabled.";
    } else if (cleanError.contains("too-many-requests")) {
      return "Too many login attempts. Please try again later.";
    } else if (cleanError.contains("network-request-failed")) {
      return "Network error. Check your connection.";
    } else if (cleanError.contains("email-already-in-use")) {
      return "Email is already in use.";
    }

    return cleanError;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state.status == AuthStatus.error) {
          final message = _getErrorMessage(state.errorMessage);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(message)),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0E0F13), // kBgColor
        body: SafeArea(
          child: Column(
            children: [
              const AppHeader(
                title: "Sign In",
                showAvatar: false,
                showBell: false,
              ),
              const SizedBox(height: 5),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151821), // kSurfaceColor
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Icon(
                                Icons.lock_person_rounded,
                                size: 64,
                                color: Color(0xFF7C7FFF), // kAccentColor
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                "Welcome Back",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEDEDED), // kTextPrimary
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Login to your account",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF9AA0AA), // kTextSecondary
                                ),
                              ),
                              const SizedBox(height: 32),
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(
                                  color: Color(0xFFEDEDED),
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'Enter your email',
                                  labelStyle: const TextStyle(
                                    color: Color(0xFF9AA0AA),
                                  ),
                                  helperStyle: const TextStyle(
                                    color: Color(0xFF9AA0AA),
                                  ),
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF4B4F58),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF4B4F58),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF7C7FFF),
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.red.shade400,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.red.shade400,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Invalid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                style: const TextStyle(
                                  color: Color(0xFFEDEDED),
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Enter your password',
                                  labelStyle: const TextStyle(
                                    color: Color(0xFF9AA0AA),
                                  ),
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF4B4F58),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF4B4F58),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF7C7FFF),
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.red.shade400,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.red.shade400,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: const Color(0xFF9AA0AA),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (value.length < 6) {
                                    return 'Too short';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  return SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed:
                                          state.status == AuthStatus.loading
                                          ? null
                                          : _onLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF7C7FFF,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: state.status == AuthStatus.loading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Login',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account? ",
                                    style: TextStyle(color: Color(0xFF9AA0AA)),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const RegisterPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Register",
                                      style: TextStyle(
                                        color: Color(0xFF7C7FFF),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
