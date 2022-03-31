import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_game/main.dart';
import 'package:mobile_game/screens/choose.dart';
import 'package:mobile_game/screens/upload.dart';
import 'package:mobile_game/screens/leaderboard.dart';
import 'homepage.dart';

// this is the screen for the users account
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
  // list of screens for the navigation bar
  final List _screens = const [
    MyApp(),
    GuessScreen(),
    ChooseScreen(),
    Account(),
    Leader()
  ];

  // function to get the current users email address
  void inputData() {
    email = auth.currentUser!.email.toString();
  }

  // creates a username by removing the second half of the email
  // i.e. test@test.com -> test 
  String getUsername() {
    inputData();
    emails = email.split("@");
    username = emails[0];
    return username;
  }

  // function to sign user out of their account and take them back to the main screen
  Future signout() async {
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
      // top of screen showing the name of app
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 203, 162, 211),
        title: const Text('Eye Spy 2.0'),
        centerTitle: true,
      ),
      // bottom nav bar which allows for navigating between screens
      bottomNavigationBar: BottomNavigationBar(
        // fixed nav bar to bottom of screen
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 203, 162, 211),
        selectedFontSize: 8,
        unselectedFontSize: 8,
        unselectedItemColor: const Color.fromARGB(255, 203, 162, 211),
        iconSize: 30,
        currentIndex: 0,
        // when an icon is tapped it shows that screen
        onTap: (currentIndex) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => (_screens[currentIndex])));
        },
        // list of all items on the nav bar and corresponding icons
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
      // displays text and sign out button
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
              //calls method to sign a user out when pressed
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
