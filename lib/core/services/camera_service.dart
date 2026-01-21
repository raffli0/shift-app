import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  CameraController? get controller => _controller;

  bool get isInitialized => _controller?.value.isInitialized ?? false;
  double get aspectRatio => _controller?.value.aspectRatio ?? 0.0;

  Future<void> initialize() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
    } catch (e) {
      log("Error initializing camera: $e");
      rethrow;
    }
  }

  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return null;
    return await _controller!.takePicture();
  }

  Future<void> startImageStream(void Function(CameraImage) onImage) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    await _controller!.startImageStream(onImage);
  }

  Future<void> stopImageStream() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      await _controller!.stopImageStream();
    } catch (e) {
      log("Error stopping image stream: $e");
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      log('Error deleting file: $e');
    }
  }

  Future<void> dispose() async {
    if (_controller != null) {
      if (_controller!.value.isStreamingImages) {
        await stopImageStream();
      }
      await _controller!.dispose();
      _controller = null;
    }
  }
}
