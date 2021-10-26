import 'package:mobile_game/map.dart';
import 'package:mobile_game/nav_bar.dart';
import 'package:flutter/material.dart';
import 'map.dart';

void main() => runApp(
      const MyApp(),
    );

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
  }


class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        drawer: const NavBar(),
        appBar: AppBar(
          actions: [
            Builder(builder: (context) =>IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const maps()));
              },
            )),
            Builder(builder: (context) =>IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyApp()));
                },
                icon: const Icon(Icons.home)))
          ],
          backgroundColor: Colors.purple,
          title: const Text('Mobile App'),
          centerTitle: true,
        ),
      ),
      
    );
  }
}
