import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobile_game/screens/cameras.dart';
import 'package:mobile_game/screens/leaderboard.dart';
import 'package:mobile_game/screens/photo_gallery.dart';
import 'dao.dart';
import 'data.dart';
import 'screens/account.dart';
import 'package:intl/intl.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  int counter = 0;
  int points = 0;
  final pic = Dao();
  final db = FirebaseDatabase.instance;
  late String email;
  late String id;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late String k;
  late int count;
  late int x = 0;
  final List _screens = const [
    MyApp(),
    Camera_Screen(),
    Gallery(alreadyGuessed: []),
    Account(),
    Leader()
  ];


  late DateTime checkTime;
  var f = DateFormat("yyyyMMdd");

  void data() {
    if (auth.currentUser!.email != null) {
      email = auth.currentUser!.email.toString();
      id = auth.currentUser!.uid.toString();
    } else {
      email = ' ';
    }
  }

  DatabaseReference ref = FirebaseDatabase.instance.ref("data");
  void check() async {
    String x = f.format(DateTime.now()).toString();

    List ids = [];
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    if (values != null) {
      values.forEach((key, values) {
        ids.add(values["uid"]);
      });
      if (ids.contains(id)) {
      } else {
        final img = Data(counter, points, id, x, email);
        pic.saveDatas(img);
      }
    } else {
      final img = Data(counter, points, id, x, email);
      pic.saveDatas(img);
    }
  }

  updateCounter() async {
    // //get current time in database
    // //get current time if it is the next day
    late DateTime x;
    late String last;
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    if (values != null) {
      values.forEach((key, values) {
        if (values["uid"] == id) {
          last = values["time"];
          x = DateTime.parse(last);
        }
      });

      String y = f.format(DateTime.now()).toString();
      DateTime current = DateTime.parse(y);
      //print(x);
      //print(current);
      if (current.isAfter(x)) {
        values.forEach((key, values) {
          if (values["uid"] == id) {
            ref.child(key).update({"counter": 0});
            ref.child(key).update({"time": y});
          }
        });
      }
    }
  }

  Future<int> getCounter() async {
    x = 0;
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    values.forEach((key, values) {
      if (id == values["uid"]) {
        count = values["counter"];
        x = 10 - count;
      }
    });
    return x;
  }

  @override
  Widget build(BuildContext context) {
    data();
    check();
    updateCounter();
    getCounter();
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
                  label: "upload image",
                  icon: Icon(Icons.camera),
                ),
                BottomNavigationBarItem(
                  label: "view gallery",
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
                child: Column(children: [
              const Padding(padding: EdgeInsets.all(10.0)),
              const Text(
                "How to play:",
                style: TextStyle(
                    color: Color.fromARGB(255, 58, 3, 68),
                    fontSize: 27,
                    fontWeight: FontWeight.bold),
              ),
              Expanded(
                  child: FutureBuilder(
                      future: getCounter(),
                      builder: (context, AsyncSnapshot<int> snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color.fromARGB(255, 221, 198, 227))));
                        } else {
                          return Column(
                            children: [
                              const Card(
                                  margin: EdgeInsets.all(10.0),
                                  borderOnForeground: false,
                                  elevation: 0.0,
                                  //color: Color.fromARGB(255, 203, 162, 211),
                                  child: Text(
                                    "Take and receive up to 10 images a day. When you receive a new image, go and find where you think this image was taken and allow the app to check if you're in the correct location using wifi. You recieve points for guessing the correct location as well as others guessing your image correctly.",
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 58, 3, 68),
                                        fontSize: 17,
                                        fontWeight: FontWeight.normal),
                                  )),
                              const Card(
                                  margin: EdgeInsets.all(10.0),
                                  borderOnForeground: false,
                                  elevation: 0.0,
                                  child: Text(
                                    "Get started now : ",
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 58, 3, 68),
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                  )),
                              Card(
                                  margin: const EdgeInsets.all(15.0),
                                  borderOnForeground: false,
                                  elevation: 0.0,
                                  child: Text(
                                    "You have " +
                                        x.toString() +
                                        " images left to upload today",
                                    style: const TextStyle(
                                        color: Color.fromARGB(255, 58, 3, 68),
                                        fontSize: 17,
                                        fontWeight: FontWeight.normal),
                                  )),
                              Card(
                                  margin: const EdgeInsets.all(10.0),
                                  borderOnForeground: false,
                                  elevation: 0.0,
                                  child: ElevatedButton(
                                    child: const Text(
                                        "Click here to upload an image"),
                                    onPressed: () => {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Camera_Screen()))
                                    },
                                    style: ElevatedButton.styleFrom(
                                        primary: const Color.fromARGB(
                                            255, 58, 3, 68),
                                        onPrimary: Colors.white),
                                  )),
                              SizedBox(
                                height: 300,
                                width: 300,
                                child: FittedBox(
                                    child: Image.asset(
                                      'assets/glasgowUni.png',
                                    ),
                                    fit: BoxFit.cover),
                              ),
                            ],
                          );
                        }
                      }))
            ]))));
  }
}
