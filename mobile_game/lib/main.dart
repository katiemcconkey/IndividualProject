import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_game/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  

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
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => const maps()));
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
                  child: Text(' Welcome Back!',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.pink,
                      )),
                ))
              ],
            )));
  }
}
