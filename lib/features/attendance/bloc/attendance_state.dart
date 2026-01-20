import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

enum AttendanceStatus { initial, loading, success, error }

enum AttendanceMainStatus { none, checkin, checkout }

enum BreakStatus { none, onBreak, offBreak }

class AttendanceState extends Equatable {
  final AttendanceStatus status;
  final AttendanceMainStatus mainStatus;
  final BreakStatus breakStatus;
  final LatLng? userLatLng;
  final String currentAddress;
  final bool isInsideOffice;
  final int tabIndex;
  final DateTime now;
  final String? errorMessage;

  const AttendanceState({
    this.status = AttendanceStatus.initial,
    this.mainStatus = AttendanceMainStatus.none,
    this.breakStatus = BreakStatus.none,
    this.userLatLng,
    this.currentAddress = "",
    this.isInsideOffice = false,
    this.tabIndex = 0,
    required this.now,
    this.errorMessage,
  });

  AttendanceState copyWith({
    AttendanceStatus? status,
    AttendanceMainStatus? mainStatus,
    BreakStatus? breakStatus,
    LatLng? userLatLng,
    String? currentAddress,
    bool? isInsideOffice,
    int? tabIndex,
    DateTime? now,
    String? errorMessage,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      mainStatus: mainStatus ?? this.mainStatus,
      breakStatus: breakStatus ?? this.breakStatus,
      userLatLng: userLatLng ?? this.userLatLng,
      currentAddress: currentAddress ?? this.currentAddress,
      isInsideOffice: isInsideOffice ?? this.isInsideOffice,
      tabIndex: tabIndex ?? this.tabIndex,
      now: now ?? this.now,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    mainStatus,
    breakStatus,
    userLatLng,
    currentAddress,
    isInsideOffice,
    tabIndex,
    now,
    errorMessage,
  ];
}
