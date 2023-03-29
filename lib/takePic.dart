
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TakePic extends StatefulWidget {
  const TakePic({super.key});

  @override
  TakePicState createState() => TakePicState();
}

class TakePicState extends State<TakePic> {
  List<CameraDescription>? cameras; //list out the camera available
  CameraController? controller; //controller for camera
  XFile? image; //for captured image

  @override
  void initState() {
    loadCamera();
    super.initState();
  }

  loadCamera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller = CameraController(cameras![0], ResolutionPreset.max);
      //cameras[0] = first camera, change to 1 to another camera

      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else {
      print("NO any camera found");
    }
  }

  Future<http.StreamedResponse> postImage(XFile? xFile) async {
    File file = File(xFile!.path);
    // http.MultipartRequest(‘POST’, Uri.parse(urlToInsertImage));
    String url = 'http://10.130.68.0:8000/api/image';
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(http.MultipartFile.fromBytes(
        'image', File(file.path).readAsBytesSync(),
        filename: file.path));
    return await request.send();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Capture Image from Camera"),
        backgroundColor: Colors.teal,
      ),
      body: Column(children: [
        SizedBox(
            height: 300,
            width: 400,
            child: controller == null
                ? const Center(child: Text("Loading Camera..."))
                : !controller!.value.isInitialized
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : CameraPreview(controller!)),
        ElevatedButton.icon(
          //image capture button
          onPressed: () async {
            try {
              if (controller != null) {
                //check if controller is not null
                if (controller!.value.isInitialized) {
                  //check if controller is initialized
                  image = await controller!.takePicture(); //capture image
                  await postImage(image);
                  setState(() {
                    //update UI
                  });
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print(e);
              } //show error
            }
          },
          icon: const Icon(Icons.camera),
          label: const Text("Capture"),
        ),
        Container(
          //show captured image
          padding: const EdgeInsets.all(30),
          child: image == null
              ? const Text("No image captured")
              : Image.file(
                  File(image!.path),
                  height: 300,
                ),
          //display captured image
        )
      ]),
    );
  }
}
