// ignore_for_file: camel_case_types

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../homepage.dart';
import '../nav_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'imageScreen.dart';

class Gallery extends StatefulWidget {
  final List alreadyGuessed;
  const Gallery({
    Key? key, required this.alreadyGuessed
  }) : super(key: key);

  @override
  gallery_state createState() => gallery_state(alreadyGuessed);
}

class gallery_state extends State<Gallery> {
  List alreadyGuessed;
  gallery_state(this.alreadyGuessed);

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
        drawer: const NavBar(),
        appBar: AppBar(
          actions: [
            Builder(
                builder: (context) => IconButton(
                      icon: const Icon(Icons.map),
                      onPressed: () {
                        Null;
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
                                  return Container(
                                      margin: const EdgeInsets.all(10),
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
                                                //checkWifi(image['path'])
                                              },
                                          child: Image.network(
                                            image['url'],
                                            scale: 3.0,
                                          )));
                                });
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        )
                        ),
              ],
            )));
  }
}
