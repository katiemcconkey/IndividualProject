// ignore_for_file: camel_case_types

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mobile_game/screens/account.dart';
import 'package:mobile_game/screens/choose.dart';
import 'package:mobile_game/screens/upload.dart';
import 'package:mobile_game/screens/leaderboard.dart';
import 'package:path/path.dart' as path;
import 'package:wifi_iot/wifi_iot.dart';
import 'package:firebase_database/firebase_database.dart';
import 'homepage.dart';
import '../database/photo.dart';
import '../database/dao.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
  late List<WifiNetwork> _wifiNetworks = <WifiNetwork>[];
  final db = FirebaseDatabase.instance;
  late String wifi = "";
  late String id;
  int i = 0;
  int counter = 0;
  late String data;
  late List<String> bssids = [];
  var f = DateFormat("yyyyMMdd");
  final List _screens = const [
    MyApp(),
    GuessScreen(),
    ChooseScreen(),
    Account(),
    Leader()
  ];

  List<String> files = [];

  final FirebaseAuth auth = FirebaseAuth.instance;
  void inputData() {
    id = auth.currentUser!.uid;
  }

  getListOfWifis() async {
    //_wifiNetworks = <WifiNetwork>[];
    try {
      _wifiNetworks = await WiFiForIoTPlugin.loadWifiList();
    } on PlatformException {
      _wifiNetworks = <WifiNetwork>[];
    }
    //return Future.value(_wifiNetworks);
  }

  wifis() async {
    //print(_wifiNetworks.length);
    await getListOfWifis();
    //print(_wifiNetworks.length);
    for (var b in _wifiNetworks) {
      if (b.level! > -80 && !bssids.contains(b.bssid.toString())) {
        //print(b.bssid.toString());
        bssids.add(b.bssid.toString() + ",");
        //(wifi + b.bssid.toString() + ",");
      }
    }
    wifi = bssids.join("");
    //print("in wifis method");
    //print(wifi);
    //print(wifi.length);
    //return wifi;
  }

  printAlert(String message) {
    showDialog(
        context: context,
        builder: (ctx) =>
            AlertDialog(title: const Text("Error"), content: Text(message)));
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

  _getCamera() async {
    bssids = [];
    wifis();
    String y = f.format(DateTime.now()).toString();
    XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    setState(() {
      imageFile = File(image!.path);
      imgs.add(Image.file(imageFile));
      files.add(image.path);
      name = path.basename(image.path);
    });
    if (wifi != "") {
      final img = photo(name, wifi, id);
      pic.saveData(img);

      try {
        updateCounter();
        await storage.ref(name).putFile(imageFile,
            SettableMetadata(customMetadata: {'uid': id, 'time': y}));
        setState(() {});
      } on FirebaseException catch (error) {
        // ignore: avoid_print
        print(error);
      }
      i++;
    } else {
      printAlert("There is no detectable wifi near you");
    }
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
          printAlert("You can only upload 10 items a day");
        }
      }
    });
  }

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
      body: Center(
        child: Column(
          children: [
            const Card(
                margin: EdgeInsets.all(20.0),
                borderOnForeground: false,
                elevation: 0.0,
                child: Text(
                  "Scroll to view the image you just uploaded : ",
                  style: TextStyle(
                      color: Color.fromARGB(255, 58, 3, 68),
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                )),
            SizedBox(
              height: 400,
              width: 350,
              child: ListView.builder(
                itemCount: imgs.length,
                itemBuilder: (context, i) => Column(children: [
                  imgs[i],
                  const Divider(
                    height: 2.0,
                  )
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 203, 162, 211),
          child: const Icon(
            Icons.add,
            color: Color.fromARGB(255, 58, 3, 68),
          ),
          onPressed: () async {
            counterLimit();
          }),
    ));
  }
}
