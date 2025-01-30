import 'dart:io';
import 'package:dashbaord/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'dart:convert';

class FaceUploadScreen extends StatefulWidget {
  @override
  _FaceUploadScreenState createState() => _FaceUploadScreenState();
}

class _FaceUploadScreenState extends State<FaceUploadScreen> {
  CameraController? _cameraController;
  bool _isCameraOpen = false;
  XFile? _capturedImage;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(_cameras![_selectedCameraIndex], ResolutionPreset.medium);
      await _cameraController!.initialize();
      setState(() {});
    }
  }

  void _switchCamera() {
    if (_cameras != null && _cameras!.length > 1) {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
      _initializeCamera();
    }
  }

  void _disposeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
  }

  Future<void> _capturePhoto() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      XFile image = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = image;
      });
    }
  }

  @override
  void dispose() {
    _disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a Selfie')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_capturedImage != null) {
                      setState(() {
                        _capturedImage = null;
                        _initializeCamera();
                      });
                    } else {
                      setState(() {
                        _isCameraOpen = !_isCameraOpen;
                      });
                    }
                  },
                  child: Text(_capturedImage != null ? 'Take Again' : (_isCameraOpen ? 'Close Camera' : 'Take Photo')),
                ),
                SizedBox(width: 10),
                if (_isCameraOpen && _capturedImage == null)
                  IconButton(
                    icon: Icon(Icons.switch_camera, size: 30),
                    onPressed: _switchCamera,
                  ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey, width: 2),
              ),
              width: 300,
              height: 300,
              child: _capturedImage == null
                  ? (_isCameraOpen && _cameraController != null && _cameraController!.value.isInitialized
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CameraPreview(_cameraController!),
              )
                  : Container())
                  : ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(File(_capturedImage!.path), fit: BoxFit.cover),
              ),
            ),
            if (_isCameraOpen && _capturedImage == null)
              Column(
                children: [
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _capturePhoto,
                    child: Text('Capture'),
                  ),
                ],
              ),
            if (_capturedImage != null)
              Column(
                children: [
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      ApiServices().uploadPhoto(_capturedImage);
                    },
                    child: Text('Upload'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
