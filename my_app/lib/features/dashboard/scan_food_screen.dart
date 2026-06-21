import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/api_service.dart';

class ScanFoodScreen extends StatefulWidget {
  const ScanFoodScreen({super.key});

  @override
  State<ScanFoodScreen> createState() => _ScanFoodScreenState();
}

class _ScanFoodScreenState extends State<ScanFoodScreen> {
  CameraController? cameraController;
  Future<void>? cameraInitFuture;
  bool isCapturing = false;
  bool isUploading = false;
  final ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    cameraInitFuture = initializeCamera();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  Future<void> initializeCamera() async {
    final List<CameraDescription> cameras = await availableCameras();

    if (cameras.isEmpty) {
      throw Exception('No camera found on this device');
    }

    final CameraDescription backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final CameraController controller = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller.initialize();

    if (!mounted) {
      await controller.dispose();
      return;
    }

    setState(() {
      cameraController = controller;
    });
  }

  Future<void> captureFood() async {
    final CameraController? controller = cameraController;

    if (controller == null || !controller.value.isInitialized || isCapturing) {
      return;
    }

    setState(() {
      isCapturing = true;
    });

    try {
      final XFile image = await controller.takePicture();
      final bytes = await image.readAsBytes();
      final Map<String, dynamic> result =
          await ApiService.predictFoodImage(bytes, image.name);

      if (!mounted) return;

      result['imageBytes'] = bytes; // Add the captured image bytes for the next screen to display

      context.push(
        '/food-detected',
        extra: result,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isCapturing = false;
        });
      }
    }
  }

  Future<void> uploadFoodPhoto() async {
    if (isUploading || isCapturing) {
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      final bytes = await image.readAsBytes();
      final Map<String, dynamic> result =
          await ApiService.predictFoodImage(bytes, image.name);

      if (!mounted) return;

      result['imageBytes'] = bytes; // Add the uploaded image bytes for the next screen to display

      context.push(
        '/food-detected',
        extra: result,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07152E),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF3B82F6),
                    Color(0xFF1D4ED8),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  const Column(
                    children: [
                      Text(
                        "AI Food Scanner",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Powered by AI",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                              "About Analysis",
                            ),
                            content: const Text(
                              "AI predicts oral health risks based on food ingredients, sugar, acidity, and nutrition.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: FutureBuilder<void>(
                  future: cameraInitFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          snapshot.error
                              .toString()
                              .replaceFirst('Exception: ', ''),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                      );
                    }

                    final CameraController? controller = cameraController;

                    if (controller == null || !controller.value.isInitialized) {
                      return const Center(
                        child: Text(
                          "Camera is not ready",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                      );
                    }

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: CameraPreview(controller),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 84,
                        height: 84,
                        child: FloatingActionButton(
                          heroTag: 'gallery_upload',
                          backgroundColor: Colors.white,
                          onPressed: isUploading ? null : uploadFoodPhoto,
                          tooltip: 'Upload food photo',
                          child: isUploading
                              ? const CircularProgressIndicator()
                              : const Icon(
                                  Icons.photo_library_outlined,
                                  color: Colors.blue,
                                  size: 38,
                                ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: FloatingActionButton(
                          heroTag: 'camera_scan',
                          backgroundColor: Colors.white,
                          onPressed: isCapturing ? null : captureFood,
                          tooltip: 'Scan with camera',
                          child: isCapturing
                              ? const CircularProgressIndicator()
                              : const Icon(
                                  Icons.camera_alt,
                                  color: Colors.blue,
                                  size: 50,
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Scan or upload your food",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
