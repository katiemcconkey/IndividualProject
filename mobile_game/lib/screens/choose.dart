import 'package:flutter/material.dart';
import 'package:mobile_game/screens/account.dart';
import 'package:mobile_game/screens/guess_text.dart';
import 'package:mobile_game/screens/leaderboard.dart';
import 'package:mobile_game/screens/photo_gallery.dart';

import 'homepage.dart';
import 'upload.dart';

class ChooseScreen extends StatefulWidget {
  const ChooseScreen({Key? key}) : super(key: key);

  @override
  _ChooseScreenState createState() => _ChooseScreenState();
}

class _ChooseScreenState extends State<ChooseScreen> {
  //list of screens for the navigation bar 
  // this enables the new screen to be displayed when an icon is pressed
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
          // app bar to show name of the app
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 203, 162, 211),
              title: const Text('Eye Spy 2.0'),
              centerTitle: true,
            ),
          // bottom nav bar to navigate between screens  
            bottomNavigationBar: BottomNavigationBar(
              // fixes nav bar to bottom of screen
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color.fromARGB(255, 203, 162, 211),
              selectedFontSize: 8,
              unselectedFontSize: 8,
              unselectedItemColor: const Color.fromARGB(255, 203, 162, 211),
              iconSize: 30,
              currentIndex: 0,
              // when a icon is tapped it will open that screen
              onTap: (currentIndex) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => (_screens[currentIndex])));
              },
              // list of items in nav bar and their correspondidng icon
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
            // displays 2 buttons to take a user to guess an image or text tag
            body: Center(
              child: Column(children: [
                const SizedBox(height: 200),
                Card(
                    margin: const EdgeInsets.all(10.0),
                    borderOnForeground: false,
                    elevation: 0.0,
                    child: ElevatedButton(
                      child: const Text("Guess an image"),
                      onPressed: () => {
                        // if button pressed go to the image gallery
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Gallery()))
                      },
                      style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 58, 3, 68),
                          onPrimary: Colors.white),
                    )),
                const SizedBox(
                  height: 80,
                ),
                Card(
                    margin: const EdgeInsets.all(10.0),
                    borderOnForeground: false,
                    elevation: 0.0,
                    child: ElevatedButton(
                      child: const Text("Guess text"),
                      onPressed: () => {
                        // if button pressed go to the text gallery
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const GuessText()))
                      },
                      style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 58, 3, 68),
                          onPrimary: Colors.white),
                    )),
              ]),
            )));
  }
}
