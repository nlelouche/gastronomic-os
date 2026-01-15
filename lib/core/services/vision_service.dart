import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // For defaultTargetPlatform
import 'package:gastronomic_os/core/util/app_logger.dart';

class VisionService {
  static final VisionService _instance = VisionService._internal();
  factory VisionService() => _instance;
  VisionService._internal();

  ImageLabeler? _imageLabeler;
  bool _isProcessing = false;
  List<CameraDescription> _cameras = [];

  Future<void> initialize() async {
    if (_imageLabeler != null) return;
    
    // Reverting to Generic Model (Google ML Kit)
    // It's robust, fast, and needs no assets.
    final options = ImageLabelerOptions(confidenceThreshold: 0.7);
    _imageLabeler = ImageLabeler(options: options);
    AppLogger.i('VisionService initialized with Generic ML Kit Model');
  }

  void setCameras(List<CameraDescription> cameras) {
    _cameras = cameras;
  }

  void dispose() {
    _imageLabeler?.close();
    _imageLabeler = null;
  }

  Future<List<ImageLabel>> processInputImage(InputImage inputImage) async {
    if (_imageLabeler == null) return [];
    if (_isProcessing) return [];

    _isProcessing = true;
    try {
      final labels = await _imageLabeler!.processImage(inputImage);
      return labels;
    } catch (e) {
      AppLogger.e('Error processing input image', e);
      return [];
    } finally {
      _isProcessing = false;
    }
  }

  // Helper factory to convert CameraImage to InputImage
  InputImage? createInputImageFromCamera(
    CameraImage image, 
    CameraDescription camera, 
    DeviceOrientation deviceOrientation
  ) {
    final sensorOrientation = camera.sensorOrientation;
    var rotation = InputImageRotation.rotation0deg;

    final rotationCorrection = _getRotationCorrection(sensorOrientation, deviceOrientation, camera.lensDirection == CameraLensDirection.front);
    rotation = InputImageRotationValue.fromRawValue(rotationCorrection) ?? InputImageRotation.rotation0deg;
    
    // Android: nv21, iOS: bgra8888
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    
    if (format == null) return null; // Unsupported format

    // Since we are streaming, we need to concatenate planes for Android (NV21)
    // iOS usually comes as one plane (BGRA) or similar logic.
    if (image.planes.isEmpty) return null;

    return InputImage.fromBytes(
      bytes: _concatenatePlanes(image.planes), 
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }
  
  int _getRotationCorrection(int sensorOrientation, DeviceOrientation deviceOrientation, bool isFrontCamera) {
    var deviceRotation = 0;
    switch (deviceOrientation) {
      case DeviceOrientation.portraitUp:
        deviceRotation = 0;
        break;
      case DeviceOrientation.landscapeLeft:
        deviceRotation = 90;
        break;
      case DeviceOrientation.portraitDown:
        deviceRotation = 180;
        break;
      case DeviceOrientation.landscapeRight:
        deviceRotation = 270;
        break;
    }
    
    if (isFrontCamera) {
      return (sensorOrientation + deviceRotation) % 360;
    } else {
      return (sensorOrientation - deviceRotation + 360) % 360;
    }
  }
}
