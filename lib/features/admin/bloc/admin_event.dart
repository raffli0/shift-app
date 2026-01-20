import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../models/admin_models.dart';

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

class AdminUserAdded extends AdminEvent {
  final AdminUser user;
  const AdminUserAdded(this.user);
  @override
  List<Object?> get props => [user];
}

class AdminUserUpdated extends AdminEvent {
  final AdminUser user;
  const AdminUserUpdated(this.user);
  @override
  List<Object?> get props => [user];
}

class AdminUserDeleted extends AdminEvent {
  final AdminUser user;
  const AdminUserDeleted(this.user);
  @override
  List<Object?> get props => [user];
}
