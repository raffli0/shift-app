import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shift/core/services/location_service.dart';
import '../services/attendance_api.dart';
import 'package:latlong2/latlong.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final LocationService _locationService;
  StreamSubscription? _locationSubscription;
  Timer? _clockTimer;

  DateTime? _lastGeocodeTime;
  LatLng? _lastGeocodeLatLng;
  static const Duration _geoCacheDuration = Duration(seconds: 30);
  static const double _geoCacheDistanceMeter = 30;

  AttendanceBloc({required LocationService locationService})
    : _locationService = locationService,
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
    final isInside = _locationService.isInsideOffice(event.location);
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

      final success = await AttendanceApi.checkIn(
        employeeId: "EMP-123", // Mock ID
        latitude: state.userLatLng!.latitude,
        longitude: state.userLatLng!.longitude,
        address: state.currentAddress,
        insideOffice: state.isInsideOffice,
      );

      if (success) {
        emit(
          state.copyWith(
            status: AttendanceStatus.success,
            mainStatus: AttendanceMainStatus.checkin,
            breakStatus: BreakStatus.none,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AttendanceStatus.error,
            errorMessage: "Check-in failed on server.",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onCheckOut(
    AttendanceCheckOutRequested event,
    Emitter<AttendanceState> emit,
  ) {
    emit(
      state.copyWith(
        mainStatus: AttendanceMainStatus.none,
        breakStatus: BreakStatus.none,
      ),
    );
  }

  void _onBreak(AttendanceBreakRequested event, Emitter<AttendanceState> emit) {
    emit(state.copyWith(breakStatus: BreakStatus.onBreak));
  }

  void _onOffBreak(
    AttendanceOffBreakRequested event,
    Emitter<AttendanceState> emit,
  ) {
    emit(state.copyWith(breakStatus: BreakStatus.offBreak));
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _clockTimer?.cancel();
    return super.close();
  }
}
