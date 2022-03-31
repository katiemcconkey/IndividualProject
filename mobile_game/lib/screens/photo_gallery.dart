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
import 'guess_image.dart';

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  gallery_state createState() => gallery_state();
}

class gallery_state extends State<Gallery> {

  //list of screens for the navigation bar 
  // this enables the new screen to be displayed when an icon is pressed
  final List _screens = const [
    MyApp(),
    GuessScreen(),
    ChooseScreen(),
    Account(),
    Leader()
  ];
  // variable to hold user uid
  late String id; 

  // instances of realtime database, storage and authentication
  final db = FirebaseDatabase.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref("photos");
  final DatabaseReference _ref = FirebaseDatabase.instance.ref("data");
  final FirebaseAuth auth = FirebaseAuth.instance;

  //list of map for images
  List<Map<String, dynamic>> files = [];
  // map to hold downloaded wifi information from database
  Map<String, List<String>> infos = {};

  bool update = false;

  //variables to check for images that have already been guessed
  late String guessed = '';
  late List<String> alreadyGuessed = [];
  late String guesses = "";

  
  // function to get the current users uid 
  void inputData() {
    id = auth.currentUser!.uid;
  }

  @override
  void initState() {
    super.initState();
  }

  // function to produce a list of all image urls that have already been attempted
  getAlreadyGuessed() async {
    inputData();
    alreadyGuessed = [];
    guessed = "";
    DatabaseEvent event = await _ref.once();
    dynamic values = event.snapshot.value;
    // loops through all values in the database
    values.forEach((key, values) {
      if (values['uid'] == id) {
        //gets the string of already guessed images
        guessed = values['alreadyGuessed'];
      }
      // remove whitespace
      guessed = guessed.replaceAll(' ', '');
      if (guessed != '') {
        // split into a list at commas
        alreadyGuessed = guessed.split(",");
      } else {
        alreadyGuessed = [];
      }
    });

    return alreadyGuessed;
  }

  // Function to load 10 images and store them in a map
  Future<List<Map<String, dynamic>>> _loadImages() async {
    // counter to keep track of images 
    int counter = 0;
    // get list of already urls
    await getAlreadyGuessed();
    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;
    // loops through all files in storage
    await Future.forEach<Reference>(allFiles, (file) async {
      // get the download url
      final String fileUrl = await file.getDownloadURL();
      // get the customisable metadata
      final FullMetadata custom = await file.getMetadata();
      // ensure uid is not the same as the current uid
      // and check the url has not been already guessed
      // and check counter has not reached 10
      if (custom.customMetadata?['uid'] != id &&
          !alreadyGuessed.contains(fileUrl) &&
          counter < 10) {
            // add tolist of maps with url and path
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
      // app bar to show the name of the app
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 203, 162, 211),
          title: const Text('Eye Spy 2.0'),
          centerTitle: true,
        ),
        // nav bar to switch easily between screens
        bottomNavigationBar: BottomNavigationBar(
          // fixed to bottom
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color.fromARGB(255, 203, 162, 211),
          selectedFontSize: 8,
          unselectedFontSize: 8,
          unselectedItemColor: const Color.fromARGB(255, 203, 162, 211),
          iconSize: 30,
          currentIndex: 0,
          // when tapped change screen 
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
        // body loads a carousel of images 
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                ),
                Expanded(
                    child: FutureBuilder(
                      // loads images
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
                                      // when an image is pressed go to a different screen and display that image alone
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
                          // displays a circular progress indicator until images have loaded
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
