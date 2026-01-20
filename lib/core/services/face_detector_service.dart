import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      minFaceSize: 0.3,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  Future<List<Face>> processImage(InputImage inputImage) async {
    return await _faceDetector.processImage(inputImage);
  }

  bool isFaceInFrame(Face face) {
    final boundingBox = face.boundingBox;
    const double frameMargin = 50.0;

    return boundingBox.width > 100 &&
        boundingBox.height > 100 &&
        boundingBox.left > frameMargin &&
        boundingBox.top > frameMargin;
  }

  Future<void> dispose() async {
    await _faceDetector.close();
  }
}
