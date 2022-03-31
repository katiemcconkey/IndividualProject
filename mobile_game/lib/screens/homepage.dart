import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobile_game/screens/choose.dart';
import 'package:mobile_game/screens/upload.dart';
import 'package:mobile_game/screens/leaderboard.dart';
import '../database/dao.dart';
import '../database/data.dart';
import 'account.dart';
import 'package:intl/intl.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final db = FirebaseDatabase.instance; 
  final FirebaseAuth auth = FirebaseAuth.instance;
  
  int counter = 0;
  int points = 0;
  final pic = Dao();

  late String email;
  late String id;
  
  late String k;
  late int count;
  late int x = 0;
  String alreadyGuessed = '';


  // list of screens for navigation bar
  final List _screens = const [
    MyApp(),
    GuessScreen(),
    ChooseScreen(),
    Account(),
    Leader()
  ];


  late DateTime checkTime;
  // format date to be in form year, month, day
  var f = DateFormat("yyyyMMdd");

  // function to get current users email and uid
  void data() {
    if (auth.currentUser!.email != null) {
      email = auth.currentUser!.email.toString();
      id = auth.currentUser!.uid.toString();
    } else {
      email = ' ';
    }
  }

  DatabaseReference ref = FirebaseDatabase.instance.ref("data");
  // function to add a user to the database if they are not already there
  void check() async {
    // formats current time to a string
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
        final img = Data(
          counter,
          points,
          id,
          x,
          alreadyGuessed,
          email,
        );
        pic.saveDatas(img);
      }
    } else {
      final img = Data(
        counter,
        points,
        id,
        x,
        alreadyGuessed,
        email,
      );
      pic.saveDatas(img);
    }
  }

  // function to update counter if it is the first time a user is interacting with the app
  updateCounter() async {
    late DateTime x;
    late String last;
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    if (values != null) {
      values.forEach((key, values) {
        if (values["uid"] == id) {
          // get the current stored date
          last = values["time"];
          // convert to datetime
          x = DateTime.parse(last);
        }
      });
      // get the current time in datetime and string format
      String y = f.format(DateTime.now()).toString();
      DateTime current = DateTime.parse(y);

      // check if current is after stored and if it is rest counter to 0
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
  // function to get the current users counter
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
    // returns the amount
    return x;
  }

  // main screen showing instructions on how to play, a map image and how many items you have left to upload 
  @override
  Widget build(BuildContext context) {
    data();
    check();
    updateCounter();
    return MaterialApp(
        home: Scaffold(
          // top app bar showing app name
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 203, 162, 211),
              title: const Text('Eye Spy 2.0'),
              centerTitle: true,
            ),
            // nav bar to move between screens
            bottomNavigationBar: BottomNavigationBar(
              // fixed to bottom of the screen
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color.fromARGB(255, 203, 162, 211),
              selectedFontSize: 8,
              unselectedFontSize: 8,
              unselectedItemColor: const Color.fromARGB(255, 203, 162, 211),
              iconSize: 30,
              currentIndex: 0,
              //on tap change screen
              onTap: (currentIndex) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => (_screens[currentIndex])));
              },
              // list of screen name and associated icons
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
            //body showing instructions and images
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
                    // uses a future so that the body does not load until the counter is ready
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
                                  child: Text(
                                    "Take and receive up to 10 items per day. When you receive a new item, go and find where you think this was taken and allow the app to check if you're in the correct location. You recieve points for guessing the correct location as well as others guessing your item's location correctly.",
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
                                        " items left to upload today",
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
                                        "Click here to upload an item"),
                                    onPressed: () => {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const GuessScreen()))
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
