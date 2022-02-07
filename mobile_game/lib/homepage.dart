import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mobile_game/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:mobile_game/main.dart';
import 'dao.dart';
import 'data.dart';

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
    List ids = [];
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    if(values != null){
      values.forEach((key, values) {
      ids.add(values["uid"]);
    });
    if(ids.contains(id)){
      
    }
    else{
      final img = Data(counter, points, id);
      pic.saveDatas(img);
    }
    }
    else{
      final img = Data(counter, points, id);
      pic.saveDatas(img);
    }
    
  }

  @override
  Widget build(BuildContext context) {
    data();
    check();

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
            body:
                //Center(
                Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Card(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Welcome Back, ',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.pink,
                      )),
                ))
              ],
            )));
  }
}
