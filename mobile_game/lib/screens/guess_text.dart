import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_game/screens/homepage.dart';
import 'package:mobile_game/screens/account.dart';
import 'package:mobile_game/screens/choose.dart';
import 'package:mobile_game/screens/upload.dart';
import 'package:mobile_game/screens/leaderboard.dart';
import 'package:wifi_iot/wifi_iot.dart';

class GuessText extends StatefulWidget {
  const GuessText({Key? key}) : super(key: key);

  @override
  _GuessTextState createState() => _GuessTextState();
}

class _GuessTextState extends State<GuessText> {
  // list of screens for navigation bar 
  final List _screens = const [
    MyApp(),
    GuessScreen(),
    ChooseScreen(),
    Account(),
    Leader()
  ];

  List<String> data = [];
  List<String> wifis = [];
  String m = "";
  Map<String, List<String>> infos = {};
  String j = "";
  List<WifiNetwork> _wifiNetworks = []; 
  List<String> i = [];

  
  String id = "";
  String n = "";
  int points = 0;
  int c = 0;
  int k = 0;
  List<String> alreadyGuessed = [];
  String guessed = " ";



  DatabaseReference ref = FirebaseDatabase.instance.ref("locationText");
  final FirebaseAuth auth = FirebaseAuth.instance;

// function to retrieve the current users UID
  void inputData() {
    id = auth.currentUser!.uid;
  }
// function to update the pints 
  updatePoints(int i) async {
    inputData();
    DatabaseReference ref = FirebaseDatabase.instance.ref("data");
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    values.forEach((key, values) {
      // checks current uid matches the stored
      if (values["uid"] == id) {
        int x = values["points"];
        ref.child(key).update({"points": x + i});
      }
    });
  }

  // function to increment field in database called guessedCorrectly
  // this ensures there is an easy way to see the confirmed images
  guessedCorrect(String guess) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("locationText");
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    values.forEach((key, values) {
      if (values["text"] == guess) {
        int x = values["guessedCorrectly"];
        ref.child(key).update({"guessedCorrectly": x + 1});
      }
    });
  }

  //update points of original uploader
  updateUploadersPoints(int i, String guess) async {
    inputData();
    DatabaseReference reff = FirebaseDatabase.instance.ref("data");
    DatabaseEvent event = await reff.once();
    dynamic values = event.snapshot.value;
    DatabaseReference _ref = FirebaseDatabase.instance.ref("locationText");
    DatabaseEvent _event = await _ref.once();
    dynamic _values = _event.snapshot.value;
    values.forEach((key, values) {
      // checks the the current uid and the stored ae different 
      if (values["uid"] != id) {
        int x = values["points"];
        _values.forEach((k, v) {
          // checks both uid in different objects of database are the same
          // and that the text is correct
          // updates points
          if (_values["uid"] == values["uid"] && _values["text"] == guess) {
            ref.child(key).update({"points": x + i});
          }
        });
      }
    });
  }

  //function which scans for nearby wifi and stores in list 
  getListOfWifis() async {
    try {
      _wifiNetworks = await WiFiForIoTPlugin.loadWifiList();
    } on PlatformException {
      _wifiNetworks = <WifiNetwork>[];
    }
    return Future.value(_wifiNetworks);
  }

  // function to filter available wifi networks
  wificheck() async {
    // get the nearby wifi scan 
    // uses await to ensure nothing occurs until that is done
    await getListOfWifis();
    data = [];
    // gets the signal strength of each wifi network
    // and only inlcude if its bigger than -75
    for (var b in _wifiNetworks) {
      if (b.level! > -75) {
        data.add(b.bssid.toString());
      }
    }
  }

  // method to print dialog boxes 
  printAlert(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
            title: const Text("Location Check"), content: Text(message)));
  }

  // future to print out text
  Future<dynamic> _getText() async {
    inputData();
    wifis = [];
    i = [];
    infos = {};
    String nospace = "";
    await getAlreadyGuessed();
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    values.forEach((key, values) {
      // get all text from database
      if (values["uid"] != id) {
        j = values["text"];
        // replace whitespace
        nospace = j.replaceAll(" ", "");
        //check it has not been previously guessed
        if (!alreadyGuessed.contains(nospace)) {
          i.add(values["text"]);
        }
        // create a map where the key is the text and the value is the wifi
        n = values["wifi"];
        n = n.replaceAll(' ', '');
        wifis = n.split(",");
        wifis.remove(" ");
        wifis.remove("");
        infos[j] = wifis;
      }
    });

    return i;
  }
  //function to download the already guessed text from the database
  getAlreadyGuessed() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("data");
    inputData();
    alreadyGuessed = [];
    guessed = " ";
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    values.forEach((key, values) {
      if (values['uid'] == id) {
        guessed = values['alreadyGuessed'];
      }

      guessed = guessed.replaceAll(' ', '');
      alreadyGuessed = guessed.split(",");
    });
  }

  // function to compared stored wifi and the wifi scan just taken
  checkWifi(String guess) async {
    // call required functions
    await wificheck();
    await _getText();
    double x = 0;
    double y = 0;
    k = 0;
    bool test = false;
    int size = 0;

    bool text = false;
     // goes through the stored wifi list
    // if a network in that list appears in 
    // the subsequent scan then add 1 to counter
    infos.forEach((key, value) {
      if (key == guess) {
        size = value.length;
        for (var w in value) {
          if (data.contains(w)) {
            k++;
          }
        }
      }
    });
    //depending on the size of the original scan there are different
    //limits for guessing correctly 
    if (size > 400) {
      x = 0.2;
      y = 1.8;
    } else if (size > 200 && size < 399) {
      x = 0.3;
      y = 1.7;
    } else if ((size < 199 && size > 150)) {
      x = 0.4;
      y = 1.6;
    } else if ((size < 149 && size > 100) || (size > 0 && size < 5)) {
      x = 0.5;
      y = 1.5;
    } else if (size < 99 && size > 50) {
      x = 0.6;
      y = 1.4;
    } else {
      x = 0.7;
      y = 1.3;
    }
    // if there are no wifi networks currently available 
    // dialog pops up to try elsewhere 
    if (data.isEmpty) {
      printAlert("Please try somewhere else");
    } else {
      // checks the subsequent scan is meeting the limit
      // adding points depending on the guess number 
      if (k > (size * x) && k < (size * y)) {
        if (points == 0) {
          updatePoints(10);
          guessedCorrect(guess);
          updateUploadersPoints(8, guess);
          printAlert("You got it first try, 10 points added");
          text = true;
        } else if (points == 1) {
          updatePoints(5);
          guessedCorrect(guess);
          updateUploadersPoints(4, guess);
          printAlert("Second try! 5 points added");
          text = true;
        } else if (points == 2) {
          updatePoints(2);
          guessedCorrect(guess);
          updateUploadersPoints(2, guess);
          printAlert("Third try! Well done");
          text = true;
        }
      } else {
                // dialog boxes to show users how many tries they have 

        points += 1;
        if (points == 1) {
          printAlert("You have 2 tries left, you only matched " +
              k.toString() +
              " out of " +
              size.toString() +
              " and scanned " +
              data.length.toString() +
              " wifi networks");
        }
        if (points == 2) {
          printAlert("You have 1 try left, you only matched " +
              k.toString() +
              " out of " +
              size.toString() +
              " and scanned " +
              data.length.toString() +
              " wifi networks");
        }
        if (points >= 3) {
          printAlert("Out of tries, no points, you only matched " +
              k.toString() +
              " out of " +
              size.toString() +
              " and scanned " +
              data.length.toString() +
              " wifi networks");
          text = true;
        }
      }
    }
    
    //checks that the text is not in already guessed
    if (text == true) {
      if (!alreadyGuessed.contains(guess)) {
        test = true;
      }
    }
    // add to already guessed and push to database
    if (test == true) {
      DatabaseReference ref = FirebaseDatabase.instance.ref("data");
      DatabaseEvent event = await ref.once();
      dynamic values = event.snapshot.value;
      values.forEach((key, values) {
        if (values['uid'] == id) {
          if (!alreadyGuessed.contains(guess)) {
            alreadyGuessed.add(guess + ",");
          }
          guessed = alreadyGuessed.join(",");
          if (values["uid"] == id) {
            ref.child(key).update({"alreadyGuessed": guessed});
          }
        }
      });
      // reset screen 
      setState(() {
        points = 0;
        test = false;
        i.remove(guess);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => (const GuessText())));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          // top app bar shows app name
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 203, 162, 211),
              title: const Text('Eye Spy 2.0'),
              centerTitle: true,
            ),
            // nav bar fixed to bottom to move around the app
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color.fromARGB(255, 203, 162, 211),
              selectedFontSize: 8,
              unselectedFontSize: 8,
              unselectedItemColor: const Color.fromARGB(255, 203, 162, 211),
              iconSize: 30,
              currentIndex: 0,
              // on tap changed to specified screen
              onTap: (currentIndex) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => (_screens[currentIndex])));
              },
              // list containing name of screens and associated icons
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
            body: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              ),
              Expanded(
                  child: FutureBuilder(
                    // get the list of text
                      future: _getText(),
                      builder: (context, AsyncSnapshot<dynamic> snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            // while waiting show circular progress indicator
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color.fromARGB(255, 221, 198, 227))));
                        } else {
                          return Center(
                              child: SingleChildScrollView(
                                  child: Column(
                                      children: List.generate(
                                          i.length,
                                          (index) => Column(children: <Widget>[
                                                SizedBox(
                                                    height: 70,
                                                    width: 370,
                                                    child: Card(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25)),
                                                        margin: const EdgeInsets
                                                            .all(8.0),
                                                        borderOnForeground:
                                                            true,
                                                        elevation: 20.0,
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                              primary: const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  221,
                                                                  198,
                                                                  227),
                                                              onPrimary:
                                                                  Colors.white,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25.0))),
                                                          onPressed: () {
                                                            // perform wifi check
                                                            checkWifi(i[index]);
                                                          },
                                                          child: Text(
                                                            // prints the text in a button 
                                                            i[index],
                                                            style: const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        )))
                                              ])))));
                        }
                      }))
            ])));
  }
}
