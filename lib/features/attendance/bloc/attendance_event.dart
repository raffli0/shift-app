import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class AttendanceStarted extends AttendanceEvent {}

class AttendanceLocationUpdated extends AttendanceEvent {
  final LatLng location;
  const AttendanceLocationUpdated(this.location);

  @override
  List<Object?> get props => [location];
}

class AttendanceAddressUpdated extends AttendanceEvent {
  final String address;
  const AttendanceAddressUpdated(this.address);

  @override
  List<Object?> get props => [address];
}

class AttendanceClockTicked extends AttendanceEvent {
  final DateTime now;
  const AttendanceClockTicked(this.now);

  @override
  List<Object?> get props => [now];
}

class AttendanceTabChanged extends AttendanceEvent {
  final int index;
  const AttendanceTabChanged(this.index);

  @override
  List<Object?> get props => [index];
}

class AttendanceCheckInRequested extends AttendanceEvent {
  final File? imageFile;
  const AttendanceCheckInRequested({this.imageFile});

  @override
  List<Object?> get props => [imageFile];
}

class AttendanceCheckOutRequested extends AttendanceEvent {}

class AttendanceBreakRequested extends AttendanceEvent {}

class AttendanceOffBreakRequested extends AttendanceEvent {}
