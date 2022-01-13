// ignore_for_file: camel_case_types

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mobile_game/dao.dart';
import 'package:mobile_game/main.dart';
import 'package:wifi_iot/wifi_iot.dart';
import '../nav_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  gallery_state createState() => gallery_state();
}

class gallery_state extends State<Gallery> {
  final pic = Dao();
  late int i;
  List<String> wifis = [];
  late List<String> data = [];
  final db = FirebaseDatabase.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  late dynamic query;
  late dynamic query2;
  late String k = "";
  late String m = "";
  static List<WifiNetwork> _wifiNetworks = <WifiNetwork>[];
  late List<String> wifi = [];
  late List<String> names = [];
  var info = {};
  late PageController _pageController;

  Map<String, List<String>> infos = {};
  DatabaseReference ref = FirebaseDatabase.instance.ref("photos");
  

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
  }

  static Future<List<WifiNetwork>> getListOfWifis() async {
    try {
      _wifiNetworks = await WiFiForIoTPlugin.loadWifiList();
    } on PlatformException {
      _wifiNetworks = <WifiNetwork>[];
    }
    return Future.value(_wifiNetworks);
  }

  check() async {
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    values.forEach((key, values) {
      k = values["name"];
      m = values["wifi"];
      m = m.replaceAll(' ', '');
      wifis = m.split(",");
      infos[k] = wifis;
    });
    //});
  }

  Future<List<Map<String, dynamic>>> _loadImages() async {
    FirebaseAuth.instance.signInAnonymously();
    List<Map<String, dynamic>> files = [];

    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();
      files.add({
        "url": fileUrl,
        "path": file.fullPath,
      });
    });

    return files;
  }

  List<String> wificheck(List<WifiNetwork> _wifiNetworks) {
    getListOfWifis();
    for (var b in _wifiNetworks) {
      if (b.level! > -80) {
        data.add(b.bssid.toString());
      }
    }
    return data;
  }

  checkWifi(String name) {
    check();
    wificheck(_wifiNetworks);
    dynamic n;
    dynamic m;
    int i = 0;
    infos.forEach((key, value) {
      if (key == name) {
        for (n in value) {
          for (m in data) {
            if (n == m) {
              i++;
            }
          }
        }
      }
    });
    if (i > (wifis.length * 0.75)) {
      showDialog(
          context: context,
          builder: (ctx) => const AlertDialog(
              title: Text("Location Check"),
              content: Text("You are in the right location")));
    } else {
      showDialog(
          context: context,
          builder: (ctx) => const AlertDialog(
              title: Text("Location Check"),
              content: Text("You are in the wrong location")));
    }
  }

  printAlert(String name) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
            title: const Text("Location Check"), content: Text(name)));
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
                                                //printAlert(image['path'])
                                                checkWifi(image['path'])
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
                        })),
              ],
            ))
         
        );
  }
}
