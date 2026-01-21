import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shift/core/services/location_service.dart';
import 'package:shift/core/services/config_service.dart';
import '../../auth/services/auth_service.dart';
import '../services/attendance_service.dart';
import 'package:latlong2/latlong.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final LocationService _locationService;
  final ConfigService _configService;
  final AttendanceService _attendanceService;
  final AuthService _authService;
  StreamSubscription? _locationSubscription;
  Timer? _clockTimer;

  DateTime? _lastGeocodeTime;
  LatLng? _lastGeocodeLatLng;
  static const Duration _geoCacheDuration = Duration(seconds: 30);
  static const double _geoCacheDistanceMeter = 30;
  final String companyId;

  AttendanceBloc({
    required LocationService locationService,
    ConfigService? configService,
    AttendanceService? attendanceService,
    AuthService? authService,
    required this.companyId,
  }) : _locationService = locationService,
       _configService = configService ?? ConfigService(),
       _attendanceService = attendanceService ?? AttendanceService(),
       _authService = authService ?? AuthService(),
       super(AttendanceState(now: DateTime.now())) {
    on<AttendanceStarted>(_onStarted);
    on<AttendanceLocationUpdated>(_onLocationUpdated);
    on<AttendanceAddressUpdated>(_onAddressUpdated);
    on<AttendanceClockTicked>(_onClockTicked);
    on<AttendanceTabChanged>(_onTabChanged);
    on<AttendanceCheckInRequested>(_onCheckIn);
    on<AttendanceCheckOutRequested>(_onCheckOut);
    on<AttendanceBreakRequested>(_onBreak);
    on<AttendanceOffBreakRequested>(_onOffBreak);
  }

  Future<void> _onStarted(
    AttendanceStarted event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      // 1. Fetch Office Config from Firestore
      final config = await _configService.getOfficeConfig(companyId);
      final officeLatLng = LatLng(
        (config['latitude'] as num).toDouble(),
        (config['longitude'] as num).toDouble(),
      );
      final radius = (config['radius'] as num).toDouble();

      emit(state.copyWith(officeLocation: officeLatLng, officeRadius: radius));

      // 2. Check Initial Attendance Status
      final user = _authService.currentUser;
      if (user != null) {
        final today = await _attendanceService.getTodayAttendance(user.uid);
        if (today != null) {
          AttendanceMainStatus mainStatus;
          BreakStatus breakStatus = BreakStatus.none;

          if (today.checkOutTime == null) {
            mainStatus = AttendanceMainStatus.checkin;
            // Check if currently on break
            if (today.breaks != null && today.breaks!.isNotEmpty) {
              final lastBreak = today.breaks!.last;
              if (lastBreak['end'] == null) {
                breakStatus = BreakStatus.onBreak;
              }
            }
          } else {
            mainStatus = AttendanceMainStatus.none;
          }

          emit(
            state.copyWith(mainStatus: mainStatus, breakStatus: breakStatus),
          );
        }
      }

      // 3. Start Location Tracking
      final pos = await _locationService.getCurrentPosition();
      final latLng = LatLng(pos.latitude, pos.longitude);
      add(AttendanceLocationUpdated(latLng));

      _locationSubscription = _locationService.getPositionStream().listen((
        pos,
      ) {
        add(AttendanceLocationUpdated(LatLng(pos.latitude, pos.longitude)));
      });

      _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        add(AttendanceClockTicked(DateTime.now()));
      });
    } catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLocationUpdated(
    AttendanceLocationUpdated event,
    Emitter<AttendanceState> emit,
  ) async {
    final officeLoc = state.officeLocation; // May be null initially
    final radius = state.officeRadius;

    bool isInside = false;
    if (officeLoc != null) {
      final distance = const Distance().as(
        LengthUnit.Meter,
        event.location,
        officeLoc,
      );
      isInside = distance <= radius;
    }

    emit(state.copyWith(userLatLng: event.location, isInsideOffice: isInside));

    final now = DateTime.now();
    final shouldGeocode =
        _lastGeocodeTime == null ||
        _lastGeocodeLatLng == null ||
        now.difference(_lastGeocodeTime!) > _geoCacheDuration ||
        const Distance().as(
              LengthUnit.Meter,
              event.location,
              _lastGeocodeLatLng!,
            ) >
            _geoCacheDistanceMeter;

    if (shouldGeocode) {
      try {
        final addr = await _locationService.getAddress(
          event.location.latitude,
          event.location.longitude,
        );
        _lastGeocodeTime = now;
        _lastGeocodeLatLng = event.location;
        add(AttendanceAddressUpdated(addr));
      } catch (e) {
        // Silent fail for geocoding
      }
    }
  }

  void _onAddressUpdated(
    AttendanceAddressUpdated event,
    Emitter<AttendanceState> emit,
  ) {
    emit(state.copyWith(currentAddress: event.address));
  }

  void _onClockTicked(
    AttendanceClockTicked event,
    Emitter<AttendanceState> emit,
  ) {
    emit(state.copyWith(now: event.now));
  }

  void _onTabChanged(
    AttendanceTabChanged event,
    Emitter<AttendanceState> emit,
  ) {
    emit(state.copyWith(tabIndex: event.index));
  }

  Future<void> _onCheckIn(
    AttendanceCheckInRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(status: AttendanceStatus.loading));

    try {
      if (state.userLatLng == null) throw Exception("Location not available");

      final user = _authService.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final locationString = state.currentAddress.isNotEmpty
          ? state.currentAddress
          : "${state.userLatLng!.latitude}, ${state.userLatLng!.longitude}";

      await _attendanceService.checkIn(
        userId: user.uid,
        userName: user.displayName ?? "Employee", // Fallback name
        companyId: companyId,
        location: locationString,
        status: state.now.hour > 9 ? "Late" : "On Time", // Simple logic for now
        imageFile: null, // Image capture not yet implemented in Bloc event
      );

      emit(
        state.copyWith(
          status: AttendanceStatus.success,
          mainStatus: AttendanceMainStatus.checkin,
          breakStatus: BreakStatus.none,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCheckOut(
    AttendanceCheckOutRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(status: AttendanceStatus.loading));
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception("User not authenticated");

      // Get today's attendance to find ID
      final today = await _attendanceService.getTodayAttendance(user.uid);
      if (today == null) throw Exception("No active check-in found");

      final locationString = state.currentAddress.isNotEmpty
          ? state.currentAddress
          : "${state.userLatLng?.latitude ?? 0}, ${state.userLatLng?.longitude ?? 0}";

      await _attendanceService.checkOut(
        attendanceId: today.id,
        location: locationString,
        imageFile: null,
      );

      emit(
        state.copyWith(
          status: AttendanceStatus.success,
          mainStatus: AttendanceMainStatus.none, // Reset check-in cycle
          breakStatus: BreakStatus.none,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onBreak(
    AttendanceBreakRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(status: AttendanceStatus.loading));
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final today = await _attendanceService.getTodayAttendance(user.uid);
      if (today == null) throw Exception("No active attendance found");

      await _attendanceService.startBreak(today.id);

      emit(
        state.copyWith(
          status: AttendanceStatus.success,
          breakStatus: BreakStatus.onBreak,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onOffBreak(
    AttendanceOffBreakRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(status: AttendanceStatus.loading));
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final today = await _attendanceService.getTodayAttendance(user.uid);
      if (today == null) throw Exception("No active attendance found");

      await _attendanceService.endBreak(today.id);

      emit(
        state.copyWith(
          status: AttendanceStatus.success,
          breakStatus:
              BreakStatus.none, // Or offBreak if special styling needed
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _clockTimer?.cancel();
    return super.close();
  }
}
