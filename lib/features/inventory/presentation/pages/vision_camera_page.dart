import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:gastronomic_os/core/services/vision_service.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/inventory/presentation/widgets/detected_item_sheet.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gastronomic_os/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/features/inventory/domain/entities/inventory_item.dart';
import 'package:gastronomic_os/core/util/ml_label_mapper.dart';

class VisionCameraPage extends StatefulWidget {
  const VisionCameraPage({super.key});

  @override
  State<VisionCameraPage> createState() => _VisionCameraPageState();
}

class _VisionCameraPageState extends State<VisionCameraPage> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  final VisionService _visionService = VisionService();
  
  // Detection State
  List<ImageLabel> _detectedLabels = [];
  bool _isProcessingImage = false;
  
  // Cart State
  final List<DetectedItem> _itemsInCart = [];
  Timer? _stabilityTimer;
  final Map<String, int> _candidateCounts = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      if (mounted) Navigator.pop(context);
      return;
    }

    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    final camera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );
    
    _visionService.setCameras(_cameras);
    await _visionService.initialize();

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: PlatformUtil.isAndroid 
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      
      await _controller!.startImageStream(_processCameraImage);
      
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessingImage || !mounted) return;
    _isProcessingImage = true;

    try {
      if (_controller == null) return;
      
      final inputImage = _visionService.createInputImageFromCamera(
        image, 
        _controller!.description, 
        DeviceOrientation.portraitUp
      );

      if (inputImage != null) {
          final labels = await _visionService.processInputImage(inputImage);
          if (mounted) {
            setState(() {
              _detectedLabels = labels;
              _analyzeLabels(labels);
            });
          }
      }
    } catch (e) {
      print('Error processing frame: $e');
    } finally {
      _isProcessingImage = false; 
    }
  }
  
  void _analyzeLabels(List<ImageLabel> labels) {
    if (labels.isEmpty) return;
    
    // Simple algorithm: 
    // If we see a high confidence (>85%) Food item, we treat it as a candidate.
    // If we see it 5 times consecutively (or frequently), we add it to the cart.
    // NOTE: ML Kit 'Food' label is generic. We want specific items.
    
    // Valid categories/keywords to avoid "Table", "Room", etc.
    // This is a naive filter. For production, we'd check against a known food DB.
    final ignored = ['Food', 'Vegetable', 'Fruit', 'Tableware', 'Dish', 'Cuisine', 'Ingredient']; 
    
    for (final label in labels) {
      if (label.confidence < 0.85) continue;
      if (ignored.contains(label.label)) continue; // Too generic
      
      // If already in cart, skip
      if (_itemsInCart.any((i) => i.label == label.label)) continue;
      
      _candidateCounts[label.label] = (_candidateCounts[label.label] ?? 0) + 1;
      
      if ((_candidateCounts[label.label] ?? 0) > 5) {
        // Stabilized detection!
        _addToCart(label);
        _candidateCounts[label.label] = 0; // Reset
      }
    }
  }
  
  void _addToCart(ImageLabel label) {
    setState(() {
      _itemsInCart.add(DetectedItem(label: label.label, confidence: label.confidence));
    });
    HapticFeedback.mediumImpact();
    // Show snackbar? No, sheet handles it.
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.stopImageStream();
    _controller?.dispose();
    _visionService.dispose();
    _stabilityTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    if (state == AppLifecycleState.inactive) {
      _controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
         _initializeCamera();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Top label
    final primaryLabel = _detectedLabels.isNotEmpty ? _detectedLabels.first : null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Feed
          Center(
            child: CameraPreview(_controller!),
          ),
          
          // Bounding Box / Reticle (Visual decoration)
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: primaryLabel != null && primaryLabel.confidence > 0.7 ? Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: Colors.black54,
                  child: Text(
                    '${primaryLabel.label} ${(primaryLabel.confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ) : null,
            ),
          ),
          
          // Close Button
          Positioned(
             top: 50,
             left: 20,
             child: IconButton(
               icon: const Icon(Icons.close, color: Colors.white, size: 30),
               onPressed: () => Navigator.pop(context),
             ),
          ),
          
          // Bottom Sheet (Cart)
          Align(
            alignment: Alignment.bottomCenter,
            child: DetectedItemSheet(
              items: _itemsInCart,
              onDelete: (item) {
                setState(() => _itemsInCart.remove(item));
              },
              onAddAll: () {
                final bloc = context.read<InventoryBloc>();
                for (final item in _itemsInCart) {
                  final cleanName = MLLabelMapper.mapLabelToInventoryName(item.label);
                  bloc.add(AddInventoryItem(
                    InventoryItem(
                      id: '', // Generated by Repo
                      name: cleanName, 
                      quantity: 1, 
                      unit: 'unit'
                    )
                  ));
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.visionAddedToInventory(_itemsInCart.length)))
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PlatformUtil {
  static bool get isAndroid => 
    defaultTargetPlatform == TargetPlatform.android;
}
