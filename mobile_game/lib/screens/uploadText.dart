import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_game/homepage.dart';
import 'package:mobile_game/photo.dart';
import 'package:mobile_game/screens/choose.dart';
import 'package:mobile_game/screens/guess.dart';
import 'package:mobile_game/screens/leaderboard.dart';
import 'package:mobile_game/screens/photo_gallery.dart';
import 'package:mobile_game/text.dart';
import 'package:wifi_iot/wifi_iot.dart';

import '../dao.dart';
import 'account.dart';

class TextScreen extends StatefulWidget {
  const TextScreen({Key? key}) : super(key: key);

  @override
  _TextScreenState createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final control = TextEditingController();
  final pic = Dao();
  final List _screens = const [
    MyApp(),
    GuessScreen(),
    ChooseScreen(),
    Account(),
    Leader()
  ];
  DatabaseReference ref = FirebaseDatabase.instance.ref("photos");
  late String id;
  late List<WifiNetwork> _wifiNetworks = <WifiNetwork>[];
  int i = 0;
  int counter = 0;
  late String data;
  late List<String> bssids = [];
  late String wifi = "";
  late String hint = "";
  late List<String> inputs = [];

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

  @override
  dispose() {
    control.dispose();
    super.dispose();
  }

  counterLimit() async {
    inputData();
    wifis();
    DatabaseReference ref = FirebaseDatabase.instance.ref("data");
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    values.forEach((key, values) {
      if (values["uid"] == id) {
        int x = values["counter"];
        if (x < 10) {
          if (wifi != "" && control.text != "") {
            final img = locationText(wifi, id, control.text);
            pic.SaveData(img);
            try {
              updateCounter();
              control.clear();
              setState(() {});
            } on FirebaseException catch (error) {
              // ignore: avoid_print
              print(error);
            }
            i++;
          } else {
            printAlert("There is no detectable wifi near you");
          }
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
      body: Form(
          key: formkey,
          child: Stack(children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 120),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Card(
                        margin: EdgeInsets.all(10.0),
                        borderOnForeground: false,
                        elevation: 0.0,
                        child: Text(
                          "Scroll to view the text you just uploaded : ",
                          style: TextStyle(
                              color: Color.fromARGB(255, 58, 3, 68),
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        )),
                    SizedBox(
                        height: 90,
                        width: 370,
                        child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            child: TextFormField(
                              controller: control,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter your a hint for your location";
                                } else {
                                  hint = value;
                                  print(hint);
                                }
                              },
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                  hintText: 'Where are you?',
                                  prefixIcon: Icon(
                                    Icons.question_answer_rounded,
                                    color: Color.fromARGB(255, 58, 3, 68),
                                  )),
                            ))),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            )
          ])),
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
