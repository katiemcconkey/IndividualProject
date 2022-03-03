import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_game/screens/homepage.dart';
import 'package:mobile_game/screens/account.dart';
import 'package:mobile_game/screens/choose.dart';
import 'package:mobile_game/screens/upload.dart';
import 'package:mobile_game/screens/leaderboard.dart';
import 'package:wifi_iot/wifi_iot.dart';

class GuessText extends StatefulWidget {
  const GuessText({Key? key}) : super(key: key);

  @override
  _GuessTextState createState() => _GuessTextState();
}

class _GuessTextState extends State<GuessText> {
  final List _screens = const [
    MyApp(),
    GuessScreen(),
    ChooseScreen(),
    Account(),
    Leader()
  ];

  List<String> data = [];
  List<String> wifis = [];
  String m = "";
  Map<String, List<String>> infos = {};
  String j = "";
  List<WifiNetwork> _wifiNetworks = [];
  String id = "";
  String n = "";
  List<String> i = [];
  int points = 0;
  int c = 0;
  int k = 0;

  List<String> alreadyGuessed = [];
  String guessed = " ";

  DatabaseReference ref = FirebaseDatabase.instance.ref("locationText");

  final FirebaseAuth auth = FirebaseAuth.instance;

  void inputData() {
    id = auth.currentUser!.uid;
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

  updateUploadersPoints(int i, String guess) async {
    inputData();
    DatabaseReference reff = FirebaseDatabase.instance.ref("data");
    DatabaseEvent event = await reff.once();
    dynamic values = event.snapshot.value;
    DatabaseReference _ref = FirebaseDatabase.instance.ref("locationText");
    DatabaseEvent _event = await _ref.once();
    dynamic _values = _event.snapshot.value;
    values.forEach((key, values) {
      if (values["uid"] != id) {
        int x = values["points"];
        _values.forEach((k, v) {
          if (_values["uid"] == values["uid"] && _values["text"] == guess) {
            ref.child(key).update({"points": x + i});
          }
        });
      }
    });
  }

  getListOfWifis() async {
    try {
      _wifiNetworks = await WiFiForIoTPlugin.loadWifiList();
    } on PlatformException {
      _wifiNetworks = <WifiNetwork>[];
    }
    return Future.value(_wifiNetworks);
  }

  wificheck() async {
    await getListOfWifis();
    data = [];
    for (var b in _wifiNetworks) {
      if (b.level! > -75) {
        data.add(b.bssid.toString());
      }
    }
  }

  printAlert(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
            title: const Text("Location Check"), content: Text(message)));
  }

  Future<dynamic> _getText() async {
    inputData();
    wifis = [];
    i = [];
    infos = {};
    String nospace = "";
    await getAlreadyGuessed();
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    values.forEach((key, values) {
      if (values["uid"] != id) {
        j = values["text"];
        nospace = j.replaceAll(" ", "");

        if (!alreadyGuessed.contains(nospace)) {
          i.add(values["text"]);
        }
        n = values["wifi"];
        n = n.replaceAll(' ', '');
        wifis = n.split(",");
        wifis.remove(" ");
        wifis.remove("");
        infos[j] = wifis;
      }
    });

    return i;
  }

  getAlreadyGuessed() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("data");
    inputData();
    alreadyGuessed = [];
    guessed = " ";
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    values.forEach((key, values) {
      if (values['uid'] == id) {
        guessed = values['alreadyGuessed'];
      }

      guessed = guessed.replaceAll(' ', '');
      alreadyGuessed = guessed.split(",");
    });
  }

  checkWifi(String guess) async {
    await wificheck();
    await _getText();
    double x = 0;
    double y = 0;
    k = 0;
    bool test = false;
    int size = 0;

    bool text = false;
    infos.forEach((key, value) {
      if (key == guess) {
        size = value.length;
        for (var w in value) {
          print(w);
          if (data.contains(w)) {
            k++;
          }
        }
      }
    });

    if (size > 400) {
      x = 0.2;
      y = 1.8;
    } else if (size > 200 && size < 399) {
      x = 0.3;
      y = 1.7;
    } else if ((size < 199 && size > 150)) {
      x = 0.4;
      y = 1.6;
    } else if ((size < 149 && size > 100) || (size > 0 && size < 5)) {
      x = 0.5;
      y = 1.5;
    } else if (size < 99 && size > 50) {
      x = 0.6;
      y = 1.4;
    } else {
      x = 0.7;
      y = 1.3;
    }

    if (k > (size * x) && k < (size * y)) {
      if (points == 0) {
        updatePoints(10);
        updateUploadersPoints(8, guess);
        printAlert("You got it first try, 10 points added");
        text = true;
      } else if (points == 1) {
        updatePoints(5);
        updateUploadersPoints(4, guess);
        printAlert("Second try! 5 points added");
        text = true;
      } else if (points == 2) {
        updatePoints(2);
        updateUploadersPoints(2, guess);
        printAlert("Third try! Well done");
        text = true;
      }
    } else {
      points += 1;
      if (points == 1) {
        printAlert("You have 2 tries left, you only matched " +
            k.toString() +
            " out of " +
            size.toString() +
            " and scanned " +
            data.length.toString() +
            " wifi networks");
      }
      if (points == 2) {
        printAlert("You have 1 try left, you only matched " +
            k.toString() +
            " out of " +
            size.toString() +
            " and scanned " +
            data.length.toString() +
            " wifi networks");
      }
      if (points >= 3) {
        printAlert("Out of tries, no points, you only matched " +
            k.toString() +
            " out of " +
            size.toString() +
            " and scanned " +
            data.length.toString() +
            " wifi networks");
        text = true;
      }
    }

    if (text == true) {
      if (!alreadyGuessed.contains(guess)) {
        test = true;
      }
    }
    if (test == true) {
      DatabaseReference ref = FirebaseDatabase.instance.ref("data");
      DatabaseEvent event = await ref.once();
      dynamic values = event.snapshot.value;
      values.forEach((key, values) {
        if (values['uid'] == id) {
          if (!alreadyGuessed.contains(guess)) {
            alreadyGuessed.add(guess + ",");
          }
          guessed = alreadyGuessed.join(",");
          if (values["uid"] == id) {
            ref.child(key).update({"alreadyGuessed": guessed});
          }
        }
      });
      setState(() {
        points = 0;
        test = false;
        i.remove(guess);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => (const GuessText())));
      });
    }
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
            body: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              ),
              Expanded(
                  child: FutureBuilder(
                      future: _getText(),
                      builder: (context, AsyncSnapshot<dynamic> snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color.fromARGB(255, 221, 198, 227))));
                        } else {
                          return Center(
                              child: SingleChildScrollView(
                                  child: Column(
                                      children: List.generate(
                                          i.length,
                                          (index) => Column(children: <Widget>[
                                                SizedBox(
                                                    height: 70,
                                                    width: 370,
                                                    child: Card(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25)),
                                                        margin: const EdgeInsets
                                                            .all(8.0),
                                                        borderOnForeground:
                                                            true,
                                                        elevation: 20.0,
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                              primary: const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  221,
                                                                  198,
                                                                  227),
                                                              onPrimary:
                                                                  Colors.white,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25.0))),
                                                          onPressed: () {
                                                            checkWifi(i[index]);
                                                          },
                                                          child: Text(
                                                            i[index],
                                                            style: const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        )))
                                              ])))));
                        }
                      }))
            ])));
  }
}
