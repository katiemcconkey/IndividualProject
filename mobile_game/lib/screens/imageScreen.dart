import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_game/screens/photo_gallery.dart';
import 'package:wifi_iot/wifi_iot.dart';

import '../dao.dart';

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
  late bool image = false;
  bool test = false;
  Map<String, List<String>> infos = {};
  DatabaseReference ref = FirebaseDatabase.instance.ref("photos");

  DatabaseReference _ref = FirebaseDatabase.instance.ref("data");

  late String guessed = '';
  late List<String> alreadyGuessed = [];

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
      m = m.replaceAll(' ', '');
      wifis = m.split(",");
      infos[k] = wifis;
    });
  }

  getAlreadyGuessed() async {
    inputData();
    alreadyGuessed = [];
    guessed = " ";
    DatabaseEvent event = await _ref.once();
    dynamic values = event.snapshot.value;
    values.forEach((key, values) {
      if (values['uid'] == id) {
        guessed = values['alreadyGuessed'];
      }

      guessed = guessed.replaceAll(' ', '');
      alreadyGuessed = guessed.split(",");
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

  printAlert(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
            title: const Text("Location Check"), content: Text(message)));
  }

  backToGallery() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Gallery()));
  }

  checkWifi(String name) async {
    await getAlreadyGuessed();
    inputData();
    await check();
    await wificheck();
    DatabaseReference ref = FirebaseDatabase.instance.ref("data");
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    dynamic n;
    dynamic m;
    int i = 0;
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

    final ListResult result =
        await storage.ref().list(const ListOptions(maxResults: 10));
    final List<Reference> allFiles = result.items;

    if (i > (wifis.length * 0.50) && i < (wifis.length * 1.50)) {
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
        printAlert("Out of tries, no points.");
        image = true;
      }
    }
    await Future.forEach<Reference>(allFiles, (file) async {
      fileUrl = await file.getDownloadURL();
      custom = await file.getMetadata();
      if (custom.customMetadata?['uid'] != id) {
        if (image == true) {
          if (!alreadyGuessed.contains(url)) {
            test = true;
          }
        }
      }
    });
    if (test == true) {
      values.forEach((key, values) {
        if (values['uid'] == id) {
          if (!alreadyGuessed.contains(url)) {
            alreadyGuessed.add(url + ",");
          }
          guessed = alreadyGuessed.join(",");
          print(guessed);
          if (values["uid"] == id) {
            ref.child(key).update({"alreadyGuessed": guessed});
          }
        }
      });
      points = 0;
      image = false;
      backToGallery();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 203, 162, 211),
          title: const Text('Eye Spy 2.0'),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Card(
              margin: const EdgeInsets.all(10.0),
              borderOnForeground: false,
              elevation: 0.0,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    url,
                    scale: 3.0,
                  )),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Card(
                  margin: const EdgeInsets.all(10.0),
                  borderOnForeground: false,
                  elevation: 0.0,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 58, 3, 68),
                          onPrimary: Colors.white),
                      onPressed: () {
                        checkWifi(path);
                      },
                      child: const Text("Check location"),
                    ),
                  )),
              Card(
                  margin: const EdgeInsets.all(10.0),
                  borderOnForeground: false,
                  elevation: 0.0,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 58, 3, 68),
                          onPrimary: Colors.white),
                      onPressed: () {
                        backToGallery();
                      },
                      child: const Text("Back to gallery"),
                    ),
                  )),
            ])
          ],
        ));
  }
}
