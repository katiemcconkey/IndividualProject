import 'package:flutter/material.dart';
import 'package:mobile_game/screens/account.dart';
import 'package:mobile_game/screens/upload_image.dart';
import 'package:mobile_game/screens/choose.dart';
import 'package:mobile_game/screens/leaderboard.dart';
import 'package:mobile_game/screens/upload_text.dart';

import 'homepage.dart';

class GuessScreen extends StatefulWidget {
  const GuessScreen({Key? key}) : super(key: key);

  @override
  _GuessScreenState createState() => _GuessScreenState();
}

class _GuessScreenState extends State<GuessScreen> {
  final List _screens = const [
    MyApp(),
    GuessScreen(),
    ChooseScreen(),
    Account(),
    Leader()
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 203, 162, 211),
              title: const Text('Eye Spy 2.0'),
              centerTitle: true,
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color.fromARGB(255, 203, 162, 211),
              selectedFontSize: 8,
              unselectedFontSize: 8,
              unselectedItemColor: const Color.fromARGB(255, 203, 162, 211),
              iconSize: 30,
              currentIndex: 0,
              onTap: (currentIndex) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => (_screens[currentIndex])));
              },
              items: const [
          BottomNavigationBarItem(
            label: "homepage",
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: "upload item",
            icon: Icon(Icons.camera),
          ),
          BottomNavigationBarItem(
            label: "guess location",
            icon: Icon(Icons.burst_mode_outlined),
          ),
          BottomNavigationBarItem(
            label: "view account",
            icon: Icon(Icons.account_circle_outlined),
          ),
          BottomNavigationBarItem(
            label: "leaderboard",
            icon: Icon(Icons.leaderboard_outlined),
          ),
        ],
            ),
            body: Center(child: Column(
              children : [
                   const SizedBox(height: 200),
                   Card(
                                  margin: const EdgeInsets.all(10.0),
                                  borderOnForeground: false,
                                  elevation: 0.0,
                                  child: ElevatedButton(
                                    child: const Text(
                                        "Upload an image"),
                                    onPressed: () => {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Camera_Screen()))
                                    },
                                    style: ElevatedButton.styleFrom(
                                        primary: const Color.fromARGB(
                                            255, 58, 3, 68),
                                        onPrimary: Colors.white),
                                  )),

                                  const SizedBox(height:80,),
                                  Card(
                                  margin: const EdgeInsets.all(10.0),
                                  borderOnForeground: false,
                                  elevation: 0.0,
                                  child: ElevatedButton(
                                    child: const Text(
                                        "Upload text"),
                                    onPressed: () => {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const TextScreen()))
                                    },
                                    style: ElevatedButton.styleFrom(
                                        primary: const Color.fromARGB(
                                            255, 58, 3, 68),
                                        onPrimary: Colors.white),
                                  )),
                  
              ]
            
            ),
    )));
  }
}
