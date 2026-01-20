import 'package:equatable/equatable.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

abstract class LivenessEvent extends Equatable {
  const LivenessEvent();

  @override
  List<Object?> get props => [];
}

class LivenessStarted extends LivenessEvent {}

class LivenessCameraInitialized extends LivenessEvent {}

class LivenessFaceDetected extends LivenessEvent {
  final Face? face;
  final bool isFaceInFrame;

  const LivenessFaceDetected({this.face, required this.isFaceInFrame});

  @override
  List<Object?> get props => [face, isFaceInFrame];
}

class LivenessResetNeutral extends LivenessEvent {}

class LivenessPermissionDenied extends LivenessEvent {}
