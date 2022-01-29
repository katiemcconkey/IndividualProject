import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_game/main.dart';
//import 'package:mobile_game/map.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:mobile_game/nav_bar.dart';

import '../homepage.dart';

class Bssid extends StatefulWidget {
  const Bssid({Key? key}) : super(key: key);

  @override
  _BssidState createState() => _BssidState();
}

class _BssidState extends State<Bssid> {
  static List<WifiNetwork> _wifiNetworks = <WifiNetwork>[];

  static Future<List<WifiNetwork>> getListOfWifis() async {
    try {
      _wifiNetworks = await WiFiForIoTPlugin.loadWifiList();
    } on PlatformException {
      _wifiNetworks = <WifiNetwork>[];
    }
    return Future.value(_wifiNetworks);
  }

  signalcheck(List<WifiNetwork> _wifiNetworks) async {}

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
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.deepPurple)),
                    onPressed: () => {
                          getListOfWifis(),
                          signalcheck(_wifiNetworks),
                        },
                    child: const Text('Scan for Networks')),
              ),
              _wifiNetworks.isNotEmpty
                  ? Container(
                      margin: const EdgeInsets.only(
                          bottom: 20.0, left: 30.0, right: 30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                            _wifiNetworks.length,
                            (index) => Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 1.0),
                                child: ListTile(
                                    leading: Text(_wifiNetworks[index]
                                            .bssid
                                            .toString() +
                                        '--- ' +
                                        _wifiNetworks[index].ssid.toString() +
                                        '--- ' +
                                        _wifiNetworks[index].level.toString()),
                                    trailing: Text(
                                        _wifiNetworks.length.toString())))),
                      ))
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
