import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomeStarted extends HomeEvent {
  final String userId;
  const HomeStarted(this.userId);
  @override
  List<Object?> get props => [userId];
}

class HomeRefreshRequested extends HomeEvent {
  final String userId;
  const HomeRefreshRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}
