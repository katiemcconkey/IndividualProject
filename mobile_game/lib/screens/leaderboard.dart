import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../homepage.dart';
import '../nav_bar.dart';

class Leader extends StatefulWidget {
  const Leader({Key? key}) : super(key: key);

  @override
  _LeaderState createState() => _LeaderState();
}

class _LeaderState extends State<Leader> {
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

  void inputData() {
    id = auth.currentUser!.uid;
  }

  String getUsername(String email) {
    emails = email.split("@");
    username = emails[0];
    return username;
  }

  getSortedMap() async {
    infos = {};
    var diff;
    inputData();
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    if (values != null) {
      values.forEach((key, values) {
        m = values["points"];
        //k = values["username"];
        k = getUsername(values["username"]);
        //values["uid"];
        infos[k] = m;
      });
    }

    var sort = infos.entries.toList()
      ..sort((x, y) {
        diff = x.value.compareTo(y.value);
        if (diff == 0) {
          diff = x.key.compareTo(y.key);
        }
        return diff;
      });
    sortedMap = Map<String, int>.fromEntries(sort.reversed);
  }

  Future<List<int>> topTenValues() async {
    await getSortedMap();
    nums = [];
    for (var e in sortedMap.values) {
      nums.add(e);
    }
    return nums;
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyApp()));
                        },
                        icon: const Icon(Icons.home)))
              ],
              backgroundColor: Colors.purple,
              title: const Text('Eye Spy 2.0'),
              centerTitle: true,
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
                            future: topTenValues(),
                            builder:
                                (context, AsyncSnapshot<List<int>> snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else {
                                return Column(
                                    children: List.generate(
                                        nums.length,
                                        (index) => Container(
                                              margin: const EdgeInsets.all(0),
                                              child: Table(
                                                border: TableBorder.all(),
                                                children: [
                                                  TableRow(
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Text((index + 1)
                                                              .toString())
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          Text(nums[index]
                                                              .toString())
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          Text(sortedMap.keys
                                                              .firstWhere((n) =>
                                                                  sortedMap[
                                                                      n] ==
                                                                  nums[index])
                                                              .toString())
                                                        ],
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            )));
                              }
                            })),
                  ],
                ))));
  }
}
