import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobile_game/screens/account.dart';
import 'package:mobile_game/screens/choose.dart';
import 'package:mobile_game/screens/upload.dart';
import 'homepage.dart';

class Leader extends StatefulWidget {
  const Leader({Key? key}) : super(key: key);
  @override
  _LeaderState createState() => _LeaderState();
}

class _LeaderState extends State<Leader> {
  // create maps to store information for leaderboard
  Map<String, int> sortedMap = {};
  Map<String, int> infos = {};
  DatabaseReference ref = FirebaseDatabase.instance.ref("data");
  final FirebaseAuth auth = FirebaseAuth.instance;

  late String k;
  late int m;
  List<int> nums = [];
  int index = 0;

  late String id;
  late List<String> emails;
  late String username;

  // list of screens for navigation
  final List _screens = const [
    MyApp(),
    GuessScreen(),
    ChooseScreen(),
    Account(),
    Leader()
  ];
  late String rank;

  // get current users UID
  void inputData() {
    id = auth.currentUser!.uid;
  }

  // create a username by removing second half of email
  String getUsername(String email) {
    emails = email.split("@");
    username = emails[0];
    return username;
  }

  // function to sort the points in a map in descending order
  getSortedMap() async {
    infos = {};
    int diff;
    inputData();
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    // get points and username and put into a map 
    if (values != null) {
      values.forEach((key, values) {
        m = values["points"];
        k = getUsername(values["username"]);
        infos[k] = m;
      });
    }

    // sort the map just created by comparing values, unless values are the same and 
    // then compare keys alphabetically
    var sort = infos.entries.toList()
      ..sort((x, y) {
        diff = x.value.compareTo(y.value);
        if (diff == 0) {
          diff = x.key.compareTo(y.key);
        }
        return diff;
      });

    // reverse the sorted map
    sortedMap = Map<String, int>.fromEntries(sort.reversed);
  }

  printAlert(String message) {
    showDialog(
        context: context,
        builder: (ctx) =>
            AlertDialog(title: const Text("Error"), content: Text(message)));
  }

  // returns top ten values of the sorted map
  Future<List<int>> topTenValues() async {
    // call function to get sorted map
    await getSortedMap();
    int counter = 0;
    nums = [];
    // add points to a list if they are in top ten
    for (var e in sortedMap.values) {
      if (counter < 10) {
        nums.add(e);
        counter++;
      }
    }

    return nums;
  }

  // function to return index plus its appropriate superscript
  String place(int index) {
    int x = (index + 1);
    if (x == 1) {
      rank = x.toString() + "st    ";
    } else if (x == 2) {
      rank = x.toString() + "nd    ";
    } else if (x == 3) {
      rank = x.toString() + "rd    ";
    } else {
      rank = x.toString() + "th    ";
    }

    return rank;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          // app bar showing app name
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 203, 162, 211),
              title: const Text('Eye Spy 2.0'),
              centerTitle: true,
            ),
            // fixed bottom nav bar for moving between screens
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color.fromARGB(255, 203, 162, 211),
              selectedFontSize: 8,
              unselectedFontSize: 8,
              unselectedItemColor: const Color.fromARGB(255, 203, 162, 211),
              iconSize: 30,
              currentIndex: 0,
              // on tap change screens
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
            body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                    ),
                    Expanded(
                        child: FutureBuilder(
                          // get list of top ten values
                            future: topTenValues(),
                            builder:
                                (context, AsyncSnapshot<List<int>> snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  // show circular progress indicator while waiting
                                    child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Color.fromARGB(
                                                    255, 221, 198, 227))));
                              } else {
                                return Center(
                                  // prints out many cards, each card is a position on the leaderboard.
                                  // first place is one big card with 3 mini cards inside to display the correct numbers
                                    child: SingleChildScrollView(
                                        child: Column(
                                            children: List.generate(
                                  nums.length,
                                  (index) => Row(
                                    children: <Widget>[
                                      SizedBox(
                                          height: 70,
                                          width: 370,
                                          child: Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25)),
                                              margin: const EdgeInsets.all(8.0),
                                              borderOnForeground: true,
                                              elevation: 20.0,
                                              child: Row(
                                                children: [
                                                  Card(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              15),
                                                      borderOnForeground: false,
                                                      elevation: 0.0,
                                                      child:
                                                          Text(place(index))),
                                                  Card(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              15),
                                                      borderOnForeground: false,
                                                      elevation: 0.0,
                                                      child: Text(nums[index]
                                                              .toString() +
                                                          "     ")),
                                                  Card(
                                                    margin:
                                                        const EdgeInsets.all(
                                                            15),
                                                    borderOnForeground: false,
                                                    elevation: 0.0,
                                                    child: Text(
                                                      sortedMap.keys
                                                          .elementAt(index)
                                                          .toString(),
                                                    ),
                                                  )
                                                ],
                                              )))
                                    ],
                                  ),
                                ))));
                              }
                            })),
                  ],
                ))));
  }
}
