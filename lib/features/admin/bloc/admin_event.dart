import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class AdminStarted extends AdminEvent {}

class AdminRefreshRequested extends AdminEvent {}

class AdminUpdateOfficeSettings extends AdminEvent {
  final LatLng location;
  final double radius;

  const AdminUpdateOfficeSettings({
    required this.location,
    required this.radius,
  });

  @override
  List<Object?> get props => [location, radius];
}
