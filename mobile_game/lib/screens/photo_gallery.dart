// ignore_for_file: camel_case_types

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobile_game/screens/account.dart';
import 'package:mobile_game/screens/cameras.dart';
import 'package:mobile_game/screens/leaderboard.dart';
import '../homepage.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'imageScreen.dart';

class Gallery extends StatefulWidget {
  final List alreadyGuessed;
  const Gallery({Key? key, required this.alreadyGuessed}) : super(key: key);

  @override
  gallery_state createState() => gallery_state(alreadyGuessed);
}

class gallery_state extends State<Gallery> {
  List alreadyGuessed;
  gallery_state(this.alreadyGuessed);

  final List _screens = const [
    MyApp(),
    Camera_Screen(),
    Gallery(alreadyGuessed: []),
    Account(),
    Leader()
  ];

  final db = FirebaseDatabase.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  late PageController _pageController;
  late String id;
  List<Map<String, dynamic>> files = [];

  Map<String, List<String>> infos = {};
  DatabaseReference ref = FirebaseDatabase.instance.ref("photos");

  final FirebaseAuth auth = FirebaseAuth.instance;

  void inputData() {
    id = auth.currentUser!.uid;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
  }

  Future<List<Map<String, dynamic>>> _loadImages() async {
    inputData();

    final ListResult result =
        await storage.ref().list(const ListOptions(maxResults: 10));
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();
      final FullMetadata custom = await file.getMetadata();
      if (custom.customMetadata?['uid'] != id &&
          !alreadyGuessed.contains(fileUrl)) {
        files.add({
          "url": fileUrl,
          "path": file.fullPath,
        });
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
              label: "upload image",
              icon: Icon(Icons.camera),
            ),
            BottomNavigationBarItem(
              label: "view gallery",
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
                                                                      'url'])))
                                                },
                                            child: Image.network(
                                              image['url'],
                                              scale: 3.0,
                                            )))
                                  ]);
                                });
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        })),
              ],
            )));
  }
}
