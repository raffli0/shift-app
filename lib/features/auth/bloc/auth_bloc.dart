import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
    : _authService = authService,
      super(const AuthState()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    // Artificial delay for splash screen animation
    await Future.delayed(const Duration(seconds: 2));
    try {
      final user = await _authService.checkAuthStatus();
      if (user != null) {
        // Emit authenticated immediately
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));

        // Fetch company name in background
        if (user.companyId != null) {
          final companyName = await _authService.getCompanyName(
            user.companyId!,
          );
          if (!emit.isDone) {
            emit(state.copyWith(companyName: companyName));
          }
        }
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final updatedUser = await _authService.updateProfile(
        fullName: event.fullName,
        email: event.email,
        phone: event.phone,
        department: event.department,
        manager: event.manager,
        companyName: event.companyName,
      );

      String? companyName = state.companyName;
      if (event.companyName != null && event.companyName!.isNotEmpty) {
        companyName = event.companyName;
      } else if (updatedUser.companyId != null && companyName == null) {
        companyName = await _authService.getCompanyName(updatedUser.companyId!);
      }

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: updatedUser,
          companyName: companyName,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authService.login(
        email: event.email,
        password: event.password,
      );

      // Emit authenticated immediately to unblock UI
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));

      // Fetch company name in background if needed update later
      if (user.companyId != null) {
        final companyName = await _authService.getCompanyName(user.companyId!);
        if (!emit.isDone) {
          emit(state.copyWith(companyName: companyName));
        }
      }
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authService.register(
        fullName: event.fullName,
        email: event.email,
        password: event.password,
        companyName: event.companyName,
        role: event.role,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          companyName: event.companyName,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
