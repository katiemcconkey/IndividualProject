import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_game/screens/photo_gallery.dart';
import 'package:wifi_iot/wifi_iot.dart';

import '../dao.dart';
import '../homepage.dart';
import '../nav_bar.dart';

class ImageScreen extends StatefulWidget {
  final String path;
  final String url;
  const ImageScreen({Key? key, required this.path, required this.url})
      : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  _ImageScreenState createState() => _ImageScreenState(path, url);
}

class _ImageScreenState extends State<ImageScreen> {
  String path;
  String url;
  _ImageScreenState(this.path, this.url);
  int points = 0;
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
  late String id;
  List<Map<String, dynamic>> files = [];
  List alreadyGuessed = [];
  late bool image = false;

  Map<String, List<String>> infos = {};
  DatabaseReference ref = FirebaseDatabase.instance.ref("photos");

  final FirebaseAuth auth = FirebaseAuth.instance;

  void inputData() {
    id = auth.currentUser!.uid;
  }

  getListOfWifis() async {
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
      m.replaceAll("test", '');
      m = m.replaceAll(' ', '');
      wifis = m.split(",");
      infos[k] = wifis;
      //print(infos);
    });
  }

  wificheck() async {
    await getListOfWifis();
    data = [];
    for (var b in _wifiNetworks) {
      if (b.level! > -80) {
        data.add(b.bssid.toString());
      }
    }
  }

  updatePoints(int i) async {
    inputData();
    DatabaseReference ref = FirebaseDatabase.instance.ref("data");
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    values.forEach((key, values) {
      if (values["uid"] == id) {
        int x = values["points"];
        ref.child(key).update({"points": x + i});
      }
    });
  }

  updateUploadersPoints(int i) async {
    inputData();
    DatabaseReference ref = FirebaseDatabase.instance.ref("data");
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;
    await Future.forEach<Reference>(allFiles, (file) async {
      final FullMetadata custom = await file.getMetadata();
      values.forEach((key, values) {
        if (values["uid"] == custom.customMetadata?['uid']) {
          int x = values["points"];
          ref.child(key).update({"points": x + i});
        }
      });
    });
  }

  printAlert(String Message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
            title: const Text("Location Check"), content: Text(Message)));
  }

  checkWifi(String name) async {
    inputData();
    await check();
    await wificheck();
    dynamic n;
    dynamic m;
    int i = 0;
    int k = 0;
    late String fileUrl;
    late FullMetadata custom;
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

    //print(wifis.length);
    //print(i);
    //print(data);
    final ListResult result =
        await storage.ref().list(const ListOptions(maxResults: 10));
    final List<Reference> allFiles = result.items;

    if (i > (wifis.length * 0.70) && i < (wifis.length * 1.30)) {
      if (points == 0) {
        updatePoints(10);
        updateUploadersPoints(8);
        printAlert("You got it first try, 10 points added");
        image = true;
      } else if (points == 1) {
        updatePoints(5);
        updateUploadersPoints(4);
        printAlert("Second try! 5 points added");
        image = true;
      } else if (points == 2) {
        updatePoints(2);
        updateUploadersPoints(2);
        printAlert("Third try! Well done");
        image = true;
      }
    } else {
      points += 1;
      if (points == 1) {
        printAlert("You have 2 tries left");
      }
      if (points == 2) {
        printAlert("You have 1 try left");
      }
      if (points >= 3) {
        printAlert("Out of tries");
        image = true;
      }
    }
    await Future.forEach<Reference>(allFiles, (file) async {
      fileUrl = await file.getDownloadURL();
      custom = await file.getMetadata();
      k++;
      if (custom.customMetadata?['uid'] != id) {
        if (image == true) {
          if (!alreadyGuessed.contains(fileUrl)) {
            alreadyGuessed.add(fileUrl);
          }
          if (alreadyGuessed.contains(fileUrl) &&
              custom.customMetadata?['uid'] != id) {
            points = 0;
            image = false;
          }
        }
      }
    });
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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Card(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    url,
                    scale: 3.0,
                  )),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Card(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    checkWifi(path);
                  },
                  child: const Text("click me"),
                ),
              )),
              Card(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Gallery()));
                  },
                  child: const Text("Go Back to view images"),
                ),
              )),
            ])
          ],
        ));
  }
}
