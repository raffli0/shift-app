import 'package:equatable/equatable.dart';
import '../../attendance/models/attendance_model.dart';
// For RecentActivity wrapper if needed, or better define it in model

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final AttendanceModel? todayAttendance;
  final List<AttendanceModel> recentActivity;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.todayAttendance,
    this.recentActivity = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    AttendanceModel? todayAttendance,
    List<AttendanceModel>? recentActivity,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      todayAttendance: todayAttendance ?? this.todayAttendance,
      recentActivity: recentActivity ?? this.recentActivity,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    todayAttendance,
    recentActivity,
    errorMessage,
  ];
}
