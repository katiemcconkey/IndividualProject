import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mobile_game/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:mobile_game/main.dart';
import 'package:mobile_game/screens/cameras.dart';
import 'package:mobile_game/screens/leaderboard.dart';
import 'package:mobile_game/screens/photo_gallery.dart';
import 'dao.dart';
import 'data.dart';
import 'screens/account.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_time_patterns.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
    //DateTime y = DateTime.parse(x);

    List ids = [];
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    if (values != null) {
      values.forEach((key, values) {
        ids.add(values["uid"]);
      });
      if (ids.contains(id)) {
      } else {
        final img = Data(counter, points, id, x);
        pic.saveDatas(img);
      }
    } else {
      final img = Data(counter, points, id, x);
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
            int x = values["counter"];
            ref.child(key).update({"counter": 0});
            ref.child(key).update({"time": y});
          }
        });
      }
    }
  }

  getCounter() async {
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    values.forEach((key, values) {
      if (id == values["uid"]) {
        count =  values["counter"];
        x = 10 - count;
      }
    });
    
  }

  @override
  Widget build(BuildContext context) {
    data();
    check();
    updateCounter();
    getCounter();

    return MaterialApp(
        home: Scaffold(
            drawer: const NavBar(),
            appBar: AppBar(
              actions: [
                Builder(
                    builder: (context) => IconButton(
                          icon: const Icon(Icons.map),
                          onPressed: () {
                            // Null;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Login()));
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
                const Card(
                    child: Padding(
                  padding: EdgeInsets.all(0),
                  child: Text('Welcome Back, ',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.purple,
                      )),
                )),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('View your account',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        )),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Account()));
                      },
                      icon: const Icon(Icons.account_circle_outlined),
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        'You have ' + x.toString() + ' images left to upload',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        )),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Camera_Screen()));
                      },
                      icon: const Icon(Icons.switch_camera_outlined),
                    ),
                  ),
                ),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('You still have image locations to guess',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        )),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Gallery(alreadyGuessed: [],)));
                      },
                      icon: const Icon(Icons.picture_in_picture_outlined),
                    ),
                  ),
                ),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Leaderboard',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        )),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Leader()));
                      },
                      icon: const Icon(Icons.leaderboard_outlined),
                    ),
                  ),
                ),
              ],
            )));
  }
}
