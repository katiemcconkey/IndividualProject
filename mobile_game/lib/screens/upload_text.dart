import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_game/database/text.dart';
import 'package:mobile_game/screens/homepage.dart';
import 'package:mobile_game/screens/choose.dart';
import 'package:mobile_game/screens/upload.dart';
import 'package:mobile_game/screens/leaderboard.dart';
import 'package:wifi_iot/wifi_iot.dart';
import '../database/dao.dart';
import 'account.dart';

class TextScreen extends StatefulWidget {
  const TextScreen({Key? key}) : super(key: key);

  @override
  _TextScreenState createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  // allows for textboxes for writing
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final control = TextEditingController();
  final pic = Dao();

  //list of screens for navigation
  final List _screens = const [
    MyApp(),
    GuessScreen(),
    ChooseScreen(),
    Account(),
    Leader()
  ];
  DatabaseReference ref = FirebaseDatabase.instance.ref("photos");


  late String id;
  int i = 0;
  int counter = 0;

  late List<WifiNetwork> _wifiNetworks = <WifiNetwork>[];
  late List<String> bssids = [];
  late String data;
  
  late String wifi = "";
  late String hint = "";
  late List<String> inputs = [];

//get current users UID
  final FirebaseAuth auth = FirebaseAuth.instance;
  void inputData() {
    id = auth.currentUser!.uid;
  }

  // function to get the list of all nearby wifis 
  getListOfWifis() async {
    try {
      _wifiNetworks = await WiFiForIoTPlugin.loadWifiList();
    } on PlatformException {
      _wifiNetworks = <WifiNetwork>[];
    }
  }

  //function to take all nearby wifi and filter by signal strength
  wifis() async {
    await getListOfWifis();
    bssids = [];
    for (var b in _wifiNetworks) {
      if (b.level! > -75 && !bssids.contains(b.bssid.toString())) {
        bssids.add(b.bssid.toString() + ",");
      }
    }
    wifi = bssids.join("");
  }

  //function to print dialog alerts
  printAlert(String message) {
    showDialog(
        context: context,
        builder: (ctx) =>
            AlertDialog(title: const Text("Error"), content: Text(message)));
  }

  //function to increment counter by 1 everytime text is uploaded
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

  // check counter is less than 10 and if so take text and upload it
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
          // dont let empty strings be uploaded
          if (wifi != "" && control.text != "") {
            final img = LocationText(wifi, id, control.text, 0);
            //send image
            pic.savedata(img);
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
          // top app bar 
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 203, 162, 211),
        title: const Text('Eye Spy 2.0'),
        centerTitle: true,
      ),
      // fixed bottom nav bar 
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 203, 162, 211),
        selectedFontSize: 8,
        unselectedFontSize: 8,
        unselectedItemColor: const Color.fromARGB(255, 203, 162, 211),
        iconSize: 30,
        currentIndex: 0,
        // on tap change screen
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
            SizedBox(
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
                                // get text form field for typing
                            child: TextFormField(
                              controller: control,
                              // normal key board
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  // if field is empty
                                  return "Please enter your a hint for your location";
                                } else {
                                  // set inputted value to hint
                                  hint = value;
                                }
                              },
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                // text box shows small bit of text
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
          //floating action button to upload code
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 203, 162, 211),
          child: const Icon(
            Icons.add,
            color: Color.fromARGB(255, 58, 3, 68),
          ),
          onPressed: () async {
            // on pressed upload code
            counterLimit();
          }),
    ));
  }
}
