import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_game/screens/photo_gallery.dart';
import 'package:wifi_iot/wifi_iot.dart';

import '../database/dao.dart';

class ImageScreen extends StatefulWidget {
  // this screen is only accessed when a user selects an image 
  // therefore the image path and url are required parameters
  final String path;
  final String url;
  const ImageScreen({Key? key, required this.path, required this.url})
      : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  _ImageScreenState createState() => _ImageScreenState(path, url);
}

class _ImageScreenState extends State<ImageScreen> {
  String path;
  String url;
  _ImageScreenState(this.path, this.url);
    final pic = Dao();

  // variable to keep track of points
  int points = 0;
  // variable which holds the amount of overlap between 2 sans
  int i = 0;
  
  // list of wifinetworks
  static List<WifiNetwork> _wifiNetworks = <WifiNetwork>[];
  // holds string of wifi bssids
  List<String> wifis = [];
  // holds string of wifi bssids
  late List<String> data = [];
   // map holding image name and list of wifis downloaded
  Map<String, List<String>> infos = {};
  late String k = "";
  late String m = "";
  
  
  // list of maps to hold downloaded images
  List<Map<String, dynamic>> files = [];
  late bool image = false;
  bool test = false;
 
  // variable to hold users uid 
  late String id;
  // variable to add image url to already guessed field in database
  late String guessed = '';
  // variable to hold downloaded list of already guessed image url
  late List<String> alreadyGuessed = [];

  // creates instance of real time database, autentication and storage
  DatabaseReference ref = FirebaseDatabase.instance.ref("photos");
  final DatabaseReference _ref = FirebaseDatabase.instance.ref("data");
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  // function to retrieve the current users UID
  void inputData() {
    id = auth.currentUser!.uid;
  }

  // function which scans for nearby wifi and stores in list
  getListOfWifis() async {
    try {
      _wifiNetworks = await WiFiForIoTPlugin.loadWifiList();
    } on PlatformException {
      _wifiNetworks = <WifiNetwork>[];
    }
    return Future.value(_wifiNetworks);
  }

  // get the stored wifi scan and name of image
  check() async {
    wifis = [];
    m = '';
    infos = {};
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    // loop through database 
    values.forEach((key, values) {
      // get the stored name value and wifi value
      k = values["name"];
      m = values["wifi"];
      // removes whitespace and splits at commas
      m = m.replaceAll(' ', '');
      wifis = m.split(",");
      wifis.remove(" ");
      wifis.remove("");
      // ads name as key and wifi scan as value in map
      infos[k] = wifis;
    });
  }

  // function to get the list of images that have already been guessed so they 
  // do not show up more than once
  getAlreadyGuessed() async {
    inputData();
    // reset the values to be empty
    alreadyGuessed = [];
    guessed = " ";
    DatabaseEvent event = await _ref.once();
    dynamic values = event.snapshot.value;
    values.forEach((key, values) {
      if (values['uid'] == id) {
        guessed = values['alreadyGuessed'];
      }
      // remove whitespaces
      // split string into a list at every comma
      guessed = guessed.replaceAll(' ', '');
      alreadyGuessed = guessed.split(",");
    });
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

  // function to update points if guessed correctly
  updatePoints(int i) async {
    inputData();
    DatabaseReference ref = FirebaseDatabase.instance.ref("data");
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    // loops through database for where the uids match and update points using
    // number in parameter
    values.forEach((key, values) {
      if (values["uid"] == id) {
        int x = values["points"];
        ref.child(key).update({"points": x + i});
      }
    });
  }

  // Function to incremenet field in database called guessedCorrectly
  // this ensures there is an easy way to see the confirmed images 
  guessedCorrect(String name) async {
    // when an image is correctly guessed this field increments by 1
    DatabaseReference ref = FirebaseDatabase.instance.ref("photos");
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    values.forEach((key, values) {
      if (values["name"] == name) {
        int x = values["guessedCorrectly"];
        ref.child(key).update({"guessedCorrectly": x + 1});
      }
    });
  }

  // function to update the points of the original uploader
  updateUploadersPoints(int i) async {
    inputData();
    DatabaseReference ref = FirebaseDatabase.instance.ref("data");
    DatabaseEvent event = await ref.once();
    dynamic _values = event.snapshot.value;
    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;
    await Future.forEach<Reference>(allFiles, (file) async {
      final FullMetadata custom = await file.getMetadata();
      _values.forEach((key, values) {
        // if the uid is the same as that stored in metadata 
        // update points using number specified in parameter 
        values.forEach((key, values) {
          // check if the current use UID is the same as the stored metadata uid 
          if (values["uid"] == custom.customMetadata?['uid']) {
            if (path == _values['name']) {
              int x = values["points"];
              ref.child(key).update({"points": x + i});
            }
          }
        });
      });
    });
  }

  // function to create alert dialog box 
  printAlert(String message, int i) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
              title: const Text("Location Check"), content: Text(message)));
  }

  // function to take user back to the gallery of images 
  backToGallery() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Gallery()));
  }

  // function to compare the stored wifi and the wifi scan just taken 
  checkWifi(String name) async {
    // variables to holf the limits for wifi overlap
    double x = 0;
    double y = 0;
    // calls all required functions
    await getAlreadyGuessed();
    inputData();
    await check();
    await wificheck();

    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;
    DatabaseReference ref = FirebaseDatabase.instance.ref("data");
    DatabaseEvent event = await ref.once();
    dynamic values = event.snapshot.value;
    i = 0;
    int size = 0;
    late FullMetadata custom;
    // goes through the stored wifi list
    // if a network in that list appears in 
    // the subsequent scan then add 1 to counter
    infos.forEach((key, value) {
      if (key == name) {
        size = value.length;
        for (var n in value) {
          if (data.contains(n)) {
            i++;
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
      printAlert("Please try somewhere else", i);
    } else {
      // checks the subsequent scan is meeting the limit
      // adding points depending on the guess number 
      if (i > (size * x) && i < (size * y)) {
        if (points == 0) {
          updatePoints(10);
          guessedCorrect(name);
          updateUploadersPoints(8);
          printAlert("You got it first try, 10 points added", i);
          image = true;
        } else if (points == 1) {
          updatePoints(5);
          guessedCorrect(name);
          updateUploadersPoints(4);
          printAlert("Second try! 5 points added", i);
          image = true;
        } else if (points == 2) {
          updatePoints(2);
          guessedCorrect(name);
          updateUploadersPoints(2);
          printAlert("Third try! Well done", i);
          image = true;
        }
      } else {
        // dialog boxes to show users how many tries they have 
        points += 1;
        if (points == 1) {
          printAlert(
              "You have 2 tries left, you only matched " +
                  i.toString() +
                  " out of " +
                  size.toString() +
                  " and scanned " +
                  data.length.toString() +
                  " wifi networks",
              i);
        }
        if (points == 2) {
          printAlert(
              "You have 1 try left, you only matched " +
                  i.toString() +
                  " out of " +
                  size.toString() +
                  " and scanned " +
                  data.length.toString() +
                  " wifi networks",
              i);
        }
        if (points >= 3) {
          printAlert(
              "Out of tries, no points, you only matched " +
                  i.toString() +
                  " out of " +
                  size.toString() +
                  " and scanned " +
                  data.length.toString() +
                  " wifi networks",
              i);
          image = true;
        }
      }
    }
    //loop through images and check if the url is already in the guessed urls
    await Future.forEach<Reference>(allFiles, (file) async {
      custom = await file.getMetadata();
      if (custom.customMetadata?['uid'] != id) {
        if (image == true) {
          if (!alreadyGuessed.contains(url)) {
            test = true;
          }
        }
      }
    });
    // if the url is not in the guessed urls
    // code to add url to the list of guessed images 
    if (test == true) {
      values.forEach((key, values) {
        if (values['uid'] == id) {
          if (!alreadyGuessed.contains(url)) {
            alreadyGuessed.add(url + ",");
          }
          guessed = alreadyGuessed.join(",");
          // update value oin database
          if (values["uid"] == id) {
            ref.child(key).update({"alreadyGuessed": guessed});
          }
        }
      });
      // resets points and sends user back to gallery 
      points = 0;
      image = false;
      backToGallery();
    }
  }

  @override
  //code to display 1 image and 2 buttons, that when clicked call functions made above 
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 203, 162, 211),
          title: const Text('Eye Spy 2.0'),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              margin: const EdgeInsets.all(10.0),
              borderOnForeground: false,
              elevation: 0.0,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  // shows image on screen
                  child: Image.network(
                    url,
                    scale: 3.0,
                  )),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Card(
                  margin: const EdgeInsets.all(10.0),
                  borderOnForeground: false,
                  elevation: 0.0,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 58, 3, 68),
                          onPrimary: Colors.white),
                      onPressed: () {
                        // if button pressed perform a wifi scan
                        checkWifi(path);
                      },
                      child: const Text("Check location"),
                    ),
                  )),
              Card(
                  margin: const EdgeInsets.all(10.0),
                  borderOnForeground: false,
                  elevation: 0.0,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 58, 3, 68),
                          onPrimary: Colors.white),
                      onPressed: () {
                        // if button pressed go back to galleyr
                        backToGallery();
                      },
                      child: const Text("Back to gallery"),
                    ),
                  )),
            ])
          ],
        ));
  }
}
