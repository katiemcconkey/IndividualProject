import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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
  DatabaseReference _ref = FirebaseDatabase.instance.ref("photos");
  late String k;
  late int m;
  int i = 0;
  List nums = [];
  int index = 0;

  getSortedMap() async {
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    values.forEach((key, values) {
      m = values["points"];
      k = values["uid"];
      infos[k] = m;
    });

    var sort = infos.entries.toList()
      ..sort((x, y) {
        var diff = x.value.compareTo(y.value);
        return diff;
      });
    sortedMap = Map<String, int>.fromEntries(sort.reversed);
  }

  topTenValues() {
    nums = [];
    getSortedMap();
    for (var e in sortedMap.values) {
      if (!nums.contains(e)) {
        nums.add(e);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    topTenValues();
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
                          Null;
                        },
                        icon: const Icon(Icons.home)))
              ],
              backgroundColor: Colors.purple,
              title: const Text('Mobile App'),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                children: List.generate(
                    nums.length,
                    (index) => Container(
                          margin: EdgeInsets.all(0),
                          child: Table(
                            border: TableBorder.all(),
                            children: [
                              TableRow(
                                children: [
                                  Column(
                                    children: [Text((index + 1).toString())],
                                  ),
                                  Column(
                                    children: [Text(nums[index].toString())],
                                  ),
                                  Column(
                                    children: [
                                      Text(sortedMap.keys
                                          .firstWhere((n) =>
                                              sortedMap[n] == nums[index])
                                          .toString())
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        )),
              ),
            )));
  }
}
