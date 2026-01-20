import 'package:equatable/equatable.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? companyName;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.companyName,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, user, companyName, errorMessage];

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? companyName,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      companyName: companyName ?? this.companyName,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
