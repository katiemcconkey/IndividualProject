import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_game/main.dart';
import 'package:mobile_game/screens/choose.dart';
import 'package:mobile_game/screens/upload.dart';
import 'package:mobile_game/screens/leaderboard.dart';
import 'homepage.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  late String email;
  late List emails;
  late String username;

  final FirebaseAuth auth = FirebaseAuth.instance;

  final List _screens = const [
    MyApp(),
    GuessScreen(),
    ChooseScreen(),
    Account(),
    Leader()
  ];

  void inputData() {
    email = auth.currentUser!.email.toString();
  }

  String getUsername() {
    inputData();
    emails = email.split("@");
    username = emails[0];
    return username;
  }

  Future signout() async {
    //FirebaseAuth _auth = FirebaseAuth.instance;
    await auth.signOut().then((value) => Navigator.of(context)
        .pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const FirstPage()),
            (route) => false));
  }

  @override
  Widget build(BuildContext context) {
    getUsername();
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
      body: Column(
        children: [
      Column(
        children: [
          Card(
              margin: const EdgeInsets.all(20.0),
              borderOnForeground: false,
              elevation: 0.0,
              child: Text(
                "Welcome, " + username,
                style: const TextStyle(
                    color: Color.fromARGB(255, 58, 3, 68),
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              )),
              ]),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: const Color.fromARGB(255, 58, 3, 68),
                onPrimary: Colors.white),
            child: const Text("Sign out"),
            onPressed: () {
              signout();
            },
          )
              ],
            )
          )
        ],)
      )
      
    );
  }
}
