import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:convert';
import 'rumah_sakit.dart';

// Add enum for corner positions
enum CornerPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class CameraScanPage extends StatefulWidget {
  const CameraScanPage({super.key});

  @override
  _CameraScanPageState createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  int _selectedCameraIndex = 0;
  Map<String, dynamic> _predictionResult = {};
  final places = GoogleMapsPlaces(apiKey: 'AIzaSyARYMQ1KUehiWR5C8wRcwsrt4GyENb0Jvo');

  @override
  void initState() {
    super.initState();
    initializeCamera();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    await Geolocator.getCurrentPosition();
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
      _cropAndPredictImage(image.path);
    }
  }

  Future<void> _cropAndPredictImage(String imagePath) async {
    // Load the image
    var image = img.decodeImage(File(imagePath).readAsBytesSync());

    // Calculate the cropping coordinates
    int cropWidth = 300;
    int cropHeight = 300;
    int cropX = (image!.width - cropWidth) ~/ 2;
    int cropY = (image.height - cropHeight) ~/ 2;

    // Crop the image to 300x300
    var croppedImage = img.copyCrop(image, cropX, cropY, cropWidth, cropHeight);

    // Save the cropped image to a temporary file
    var croppedImagePath = '${Directory.systemTemp.path}/cropped_image.png';
    File(croppedImagePath).writeAsBytesSync(img.encodePng(croppedImage));

    // Predict the cropped image
    _predictImage(croppedImagePath);
  }

  Future<void> _predictImage(String imagePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('http://35.238.249.151:8000/api/predict/'));
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    // Get the current location
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    request.fields['latitude'] = position.latitude.toString();
    request.fields['longitude'] = position.longitude.toString();

    // Get the current user's email from Firebase Auth
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      request.fields['email'] = user.email!;
    }
    
    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      setState(() {
        _predictionResult = json.decode(responseData);
      });
      print('Server response: $responseData');

      // Navigate to HospitalListPage if Monkeypox is detected
      if (_predictionResult['predicted_class']?.toLowerCase() == 'monkeypox') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Monkeypox Terdeteksi'),
          content: const Text('Apakah Anda ingin mengecek ke rumah sakit terdekat?'),
          actions: [
            TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
            ),
            TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
            builder: (context) => HospitalListPage(
              places: places,
            ),
              ),
            );
          },
          child: const Text('Ya'),
            ),
          ],
        );
          },
        );
      }
    } else {
      print('Failed to send image to server: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Camera Scan', 
          style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Colors.black87],
          ),
        ),
        child: _isCameraInitialized
            ? Stack(
                children: [
                  // Camera Preview with rounded corners
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CameraPreview(_controller!),
                    ),
                  ),
                  // Enhanced capture frame
                  Center(
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                        Positioned(
                          top: 10,
                          left: 10,
                          child: _buildCorner(position: CornerPosition.topLeft)
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: _buildCorner(position: CornerPosition.topRight)
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: _buildCorner(position: CornerPosition.bottomLeft)
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: _buildCorner(position: CornerPosition.bottomRight)
                        ),
                      ],
                    ),
                    ),
                  ),
                  // Controls and prediction result
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        // Prediction result card
                        _buildPredictionResult(),
                        // Control buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildControlButton(
                                icon: Icons.switch_camera,
                                label: 'Switch',
                                onPressed: _switchCamera,
                              ),
                              _buildCaptureButton(),
                              _buildControlButton(
                                icon: Icons.flash_off,
                                label: 'Flash',
                                onPressed: () {}, // Add flash control functionality
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
        ),
      );
    }

  // Modified _buildCorner method
  Widget _buildCorner({required CornerPosition position}) {
    BorderSide whiteBorder = BorderSide(
      color: Colors.white.withOpacity(0.8),
      width: 3,
    );

    Border getBorder() {
      switch (position) {
        case CornerPosition.topLeft:
          return Border(
            top: whiteBorder,
            left: whiteBorder,
          );
        case CornerPosition.topRight:
          return Border(
            top: whiteBorder,
            right: whiteBorder,
          );
        case CornerPosition.bottomLeft:
          return Border(
            bottom: whiteBorder,
            left: whiteBorder,
          );
        case CornerPosition.bottomRight:
          return Border(
            bottom: whiteBorder,
            right: whiteBorder,
          );
      }
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: getBorder(),
        ),
      );
    }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _takePicture,
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
            ),
          ],
        ),
        child: const Icon(
          Icons.camera,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPredictionResult() {
    if (_predictionResult.isEmpty) return Container();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Prediction: ${_predictionResult['predicted_class']}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          Text(
            'Tingkat Keyakinan: ${_predictionResult['confidence']}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}