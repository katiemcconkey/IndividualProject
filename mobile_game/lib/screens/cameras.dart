// ignore_for_file: camel_case_types

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_game/nav_bar.dart';
import 'package:mobile_game/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:wifi_iot/wifi_iot.dart';
import 'package:firebase_database/firebase_database.dart';
import '../homepage.dart';
import '../photo.dart';
import '../dao.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Camera_Screen extends StatefulWidget {
  const Camera_Screen({Key? key}) : super(key: key);

  @override
  _camera_screenState createState() => _camera_screenState();
}

class _camera_screenState extends State<Camera_Screen> {
  final pic = Dao();
  final ImagePicker _picker = ImagePicker();
  FirebaseStorage storage = FirebaseStorage.instance;
  late File imageFile;
  late List<Image> imgs = [];
  late String name;
  static List<WifiNetwork> _wifiNetworks = <WifiNetwork>[];
  final db = FirebaseDatabase.instance;
  late String wifi = '';
  late String id;
  int i = 0;
  int counter = 0;
  late String data;

  final FirebaseAuth auth = FirebaseAuth.instance;
  void inputData() {
    id = auth.currentUser!.uid;
  }

  static Future<List<WifiNetwork>> getListOfWifis() async {
    try {
      _wifiNetworks = await WiFiForIoTPlugin.loadWifiList();
    } on PlatformException {
      _wifiNetworks = <WifiNetwork>[];
    }
    return Future.value(_wifiNetworks);
  }

  String wifis(List<WifiNetwork> _wifiNetworks) {
    wifi.replaceAll(' ', '');
    for (var b in _wifiNetworks) {
      if (b.level! > -80) {
        wifi = (wifi + b.bssid.toString() + ",");
      }
    }
    return wifi;
  }

  printAlert(String Message) {
    showDialog(
        context: context,
        builder: (ctx) =>
            AlertDialog(title: const Text("Error"), content: Text(Message)));
  }

  updateCounter() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("data");
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    values.forEach((key, values) {
      if (values["uid"] == id) {
        int x = values["counter"];
        ref.child(key).update({"counter": x + 1});
      }
    });
  }

  counterLimit() async {
    inputData();
    //if counter > 9 then remove camera functionality
    DatabaseReference ref = FirebaseDatabase.instance.ref("data");
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    values.forEach((key, values) {
      if (values["uid"] == id) {
        int x = values["counter"];
        if (x < 10) {
          _getCamera();
        } else {
          printAlert("You can only upload 10 images a day");
        }
      }
    });
  }

  _getCamera() async {
    getListOfWifis();
    wifis(_wifiNetworks);
    inputData();
    XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    setState(() {
      imageFile = File(image!.path);
      imgs.add(Image.file(imageFile));
      name = path.basename(image.path);
    });
    final img = photo(name, wifi, id);
    pic.saveData(img);
    try {
      updateCounter();
      await storage
          .ref(name)
          .putFile(imageFile, SettableMetadata(customMetadata: {'uid': id}));
      setState(() {});
    } on FirebaseException catch (error) {
      // ignore: avoid_print
      print(error);
    }
    i++;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const MyApp()));
                  },
                  icon: const Icon(Icons.home)))
        ],
        backgroundColor: Colors.purple,
        title: const Text('Mobile App'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: imgs.length,
        itemBuilder: (context, i) =>
            Column(children: [imgs[i], const Divider()]),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            counterLimit();
          }),
    ));
  }
}
