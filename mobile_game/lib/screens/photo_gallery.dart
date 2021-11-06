import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'CameraPage.dart';
import 'dart:io';
import 'package:mobile_game/map.dart';
import 'package:mobile_game/nav_bar.dart';
import 'package:mobile_game/main.dart';

class Gallery extends StatelessWidget {
  final String imagePath;
  const Gallery({Key? key, required this.imagePath}) : super(key: key);

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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const MyApp()));
                  },
                  icon: const Icon(Icons.home)))
        ],
        backgroundColor: Colors.purple,
        title: const Text('Mobile App'),
        centerTitle: true,
      ),
      body: Image.file(File(imagePath)),
    );
  }
}
