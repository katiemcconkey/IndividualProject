// ignore_for_file: file_names

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const CameraPage({this.cameras, Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController controller;
  XFile? pictureFile;
  @override
  void initState() {
    super.initState();
    controller = CameraController(
      widget.cameras![0],
      ResolutionPreset.max,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const SizedBox(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Column(
      children: [
        Padding(padding: const EdgeInsets.all(8.0),
        child: Center(
          child: SizedBox(child: CameraPreview(controller),
          height: 400,
          width: 400
          ,),
        ),
        ),
        Padding(padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(child: const Text('Take Picture'),
        onPressed: () async {
          pictureFile = await controller.takePicture();
          setState(() {});
        },
        ),
        ),
        if(pictureFile != null)
          Image.file(File(pictureFile!.path))
      ],
    );
  }
}
