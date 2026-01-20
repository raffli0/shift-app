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

class HomeBreakToggled extends HomeEvent {
  final String attendanceId;
  final bool isStarting; // true = start break, false = end break
  const HomeBreakToggled(this.attendanceId, this.isStarting);
  @override
  List<Object?> get props => [attendanceId, isStarting];
}
