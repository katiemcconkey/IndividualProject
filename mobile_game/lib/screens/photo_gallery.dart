// ignore_for_file: camel_case_types

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobile_game/screens/account.dart';
import 'package:mobile_game/screens/choose.dart';
import 'package:mobile_game/screens/upload.dart';
import 'package:mobile_game/screens/leaderboard.dart';
import 'homepage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'guess_image.dart';

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  gallery_state createState() => gallery_state();
}

class gallery_state extends State<Gallery> {
  final List _screens = const [
    MyApp(),
    GuessScreen(),
    ChooseScreen(),
    Account(),
    Leader()
  ];

  final db = FirebaseDatabase.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  late String id;
  List<Map<String, dynamic>> files = [];
  var f = DateFormat("yyyyMMdd");
  bool update = false;

  Map<String, List<String>> infos = {};
  DatabaseReference ref = FirebaseDatabase.instance.ref("photos");
  final DatabaseReference _ref = FirebaseDatabase.instance.ref("data");

  late String guessed = '';
  late List<String> alreadyGuessed = [];
  late String guesses = "";
  late List<String> urls = [];

  final FirebaseAuth auth = FirebaseAuth.instance;

  void inputData() {
    id = auth.currentUser!.uid;
  }

  @override
  void initState() {
    super.initState();
  }

  getAlreadyGuessed() async {
    inputData();
    alreadyGuessed = [];
    guessed = "";
    DatabaseEvent event = await _ref.once();
    dynamic values = event.snapshot.value;
    values.forEach((key, values) {
      if (values['uid'] == id) {
        guessed = values['alreadyGuessed'];
      }

      guessed = guessed.replaceAll(' ', '');
      if (guessed != '') {
        alreadyGuessed = guessed.split(",");
      } else {
        alreadyGuessed = [];
      }
    });

    return alreadyGuessed;
  }

  Future<List<Map<String, dynamic>>> _loadImages() async {
    int counter = 0;
    await getAlreadyGuessed();
    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;
    await Future.forEach<Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();
      final FullMetadata custom = await file.getMetadata();

      if (custom.customMetadata?['uid'] != id &&
          !alreadyGuessed.contains(fileUrl) &&
          counter < 10) {
        files.add({
          "url": fileUrl,
          "path": file.fullPath,
        });
        counter++;
      }
    });
    return files;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                ),
                Expanded(
                    child: FutureBuilder(
                        future: _loadImages(),
                        builder: (context,
                            AsyncSnapshot<List<Map<String, dynamic>>>
                                snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return PageView.builder(
                                itemCount: snapshot.data?.length ?? 0,
                                pageSnapping: true,
                                itemBuilder: (context, index) {
                                  final Map<String, dynamic> image =
                                      snapshot.data![index];
                                  return Column(children: [
                                    const Card(
                                        margin: EdgeInsets.all(20.0),
                                        borderOnForeground: false,
                                        elevation: 0.0,
                                        child: Text(
                                          "Click on an image when you are ready to guess : ",
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 58, 3, 68),
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        )),
                                    SizedBox(
                                        child: GestureDetector(
                                            onTap: () => {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ImageScreen(
                                                                  path: image[
                                                                      'path'],
                                                                  url: image[
                                                                      'url']),
                                                                    ))
                                                },
                                            child: Image.network(
                                              image['url'],
                                              scale: 3.0,
                                            )))
                                  ]);
                                });
                          }
                          return const Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color.fromARGB(255, 221, 198, 227))),
                          );
                        })),
              ],
            )));
  }
}
