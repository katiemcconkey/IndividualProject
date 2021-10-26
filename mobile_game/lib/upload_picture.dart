import 'package:mobile_game/map.dart';
import 'package:mobile_game/nav_bar.dart';
import 'package:flutter/material.dart';
import 'scan_wifi.dart';
import 'map.dart';
import 'main.dart';

class pictureApp extends StatefulWidget {
  const pictureApp({Key? key}) : super(key: key);
  @override
  _MyPicture createState() => _MyPicture();
}

class _MyPicture extends State<pictureApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        drawer: const NavBar(),
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => maps()));
              },
            ),
            IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyApp()));
                },
                icon: const Icon(Icons.home))
          ],
          backgroundColor: Colors.blueAccent,
          title: const Text('Mobile App'),
          centerTitle: true,
        ),
      ),
    );
  }
}
