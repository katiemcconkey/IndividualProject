import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_game/main.dart';
import '../homepage.dart';
import '../nav_bar.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  Future signout() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.signOut().then((value) => Navigator.of(context)
        .pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => FirstPage()),
            (route) => false));
  }

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
                    },
                  )),
          Builder(
              builder: (context) => IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const MyApp()));
                  },
                  icon: const Icon(Icons.home)))
        ],
        backgroundColor: Colors.purple,
        title: const Text('Mobile App'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Sign out"),
          onPressed: () {
            signout();
          },
        ),
      ),
    ));
  }
}
