import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'CameraPage.dart';
import 'package:path_provider/path_provider.dart';

import '../main.dart';
import 'CameraPage.dart';
import '../map.dart';

class pictureApp extends StatefulWidget {
  const pictureApp({Key? key}) : super(key: key);

  @override
  _PictureState createState() => _PictureState();
}

class _PictureState extends State<pictureApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            Builder(
                builder: (context) => IconButton(
                      icon: const Icon(Icons.map),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const maps()));
                      },
                    )),
            Builder(
                builder: (context) => IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyApp()));
                    },
                    icon: const Icon(Icons.home)))
          ],
          backgroundColor: Colors.purple,
          title: const Text('Mobile App'),
          centerTitle: true,
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await availableCameras().then(
                (value) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraPage(cameras: value),
                  ),
                ),
              );
            },
            child: const Text('Launch Camera'),
          ),
        ));
  }
}
