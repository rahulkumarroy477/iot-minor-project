// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Auto Capture and GitHub Upload',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: CameraScreen(),
//     );
//   }
// }

// class CameraScreen extends StatefulWidget {
//   const CameraScreen({super.key});

//   @override
//   State<CameraScreen> createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   final String esp8266Ip = '192.168.39.15';
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;

//   @override
//   void initState() {
//     _controller = CameraController(
//       const CameraDescription(
//           name: '0',
//           lensDirection: CameraLensDirection.back,
//           sensorOrientation: 1),
//       ResolutionPreset.high,
//     );
//     _initializeControllerFuture = _controller.initialize();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _takePictureAndUpload() async {
//     try {
//       await _initializeControllerFuture;

//       final XFile picture = await _controller.takePicture();

//       File file = File(picture.path);
//       String base64Content = base64Encode(file.readAsBytesSync());

//       const String repoOwner = 'rahulkumarroy477';
//       const String repoName = 'images';
//       const String personalAccessToken = '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'; // Replace with your personal access token

//       final response = await http.put(
//         Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/contents/train/${DateTime.now().millisecondsSinceEpoch}.jpg'),
//         headers: {
//           'Authorization': 'Bearer $personalAccessToken',
//           'Accept': 'application/vnd.github.v3+json',
//         },
//         body: jsonEncode({
//           'message': 'Upload from Flutter app',
//           'content': base64Content,
//         }),
//       );

//       if (response.statusCode == 201) {
//         print('Image uploaded to GitHub successfully');
//       } else {
//         print('Failed to upload image to GitHub: ${response.body}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   // User Interface
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<void>(
//           future: _initializeControllerFuture,
//           builder: ((context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.done) {
//               return CameraPreview(_controller);
//             } else {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }
//           })),
//       floatingActionButton: FloatingActionButton(onPressed: _takePictureAndUpload,
//       child: const Icon(Icons.camera),),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Capture and GitHub Upload',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final String esp8266Ip = '192.168.231.14';
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late bool captureEnabled;

  @override
  void initState() {
    captureEnabled = false; // Initialize capture as disabled
    _controller = CameraController(
      const CameraDescription(
          name: '0',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 1),
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
    super.initState();

    // Start listening for capture messages
    listenForCaptureMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePictureAndUpload() async {
    try {
      await _initializeControllerFuture;

      final XFile picture = await _controller.takePicture();

      File file = File(picture.path);
      String base64Content = base64Encode(file.readAsBytesSync());

      const String repoOwner = 'rahulkumarroy477';
      const String repoName = 'images';
      const String personalAccessToken =
          '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'; // Replace with your personal access token

      final response = await http.put(
        Uri.parse(
            'https://api.github.com/repos/$repoOwner/$repoName/contents/test/person.jpg'),
        headers: {
          'Authorization': 'Bearer $personalAccessToken',
          'Accept': 'application/vnd.github.v3+json',
        },
        body: jsonEncode({
          'message': 'Upload from Flutter app',
          'content': base64Content,
        }),
      );

      if (response.statusCode == 201) {
        print('Image uploaded to GitHub successfully');
        // Delete the local file after successful upload
        file.deleteSync();
        print('Local file deleted.');
      } else {
        print('Failed to upload image to GitHub: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to continuously listen for capture messages
  Future<void> listenForCaptureMessages() async {
    while (true) {
      try {
        final response = await http.get(Uri.parse('http://$esp8266Ip'));

        if (response.statusCode == 200) {
          // Enable capture when a capture message is received
          setState(() {
            captureEnabled = true;
          });

          print('Capture message received. Enabling capture...');
          _takePictureAndUpload(); // Automatically trigger capture
        } else {
          print(
              'Failed to receive capture message. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }

      // Pause for a moment before checking again (adjust the duration as needed)
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  // User Interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          })),
      floatingActionButton: FloatingActionButton(
        onPressed: captureEnabled ? _takePictureAndUpload : null,
        backgroundColor: captureEnabled ? Colors.blue : Colors.grey,
        child: const Icon(Icons.camera),
      ),
    );
  }
}
