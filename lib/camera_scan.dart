import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScanPage extends StatefulWidget {
  const CameraScanPage({Key? key}) : super(key: key);

  @override
  _CameraScanPageState createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras![_selectedCameraIndex], ResolutionPreset.high);
    await _controller?.initialize();
    await _controller?.setFlashMode(FlashMode.off); // Disable flash
    if (!mounted) {
      return;
    }
    setState(() {
      _isCameraInitialized = true;
    });
  }

  void _switchCamera() {
    if (cameras != null && cameras!.length > 1) {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras!.length;
      initializeCamera();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final image = await _controller!.takePicture();
      // Handle the captured image
      print('Picture taken: ${image.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Scan'),
      ),
      body: _isCameraInitialized
          ? Stack(
              children: [
                CameraPreview(_controller!),
                Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _takePicture,
                        child: const Text('Capture Image'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _switchCamera,
                        child: const Text('Switch Camera'),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}