//import 'package:network_info_plus/network_info_plus.dart';
// ignore_for_file: camel_case_types

import 'package:wifi_hunter/wifi_hunter.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';
//import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class scanWifi extends StatefulWidget {
  const scanWifi({Key? key}) : super(key: key);

  @override
  _wifiState createState() => _wifiState();
}

class _wifiState extends State<scanWifi> {
  String? wifiBSSID = 'Click below to see';
  String? wifiName = 'Click below to see';

  // static final info = NetworkInfo();

  // _getBSSID() async {
  //   var b = await info.getWifiBSSID();
  //   setState(() {
  //     wifiBSSID = b;
  //   });
  //   return wifiBSSID;
  // }

  // _getName() async {
  //   var name = await info.getWifiName();
  //   setState(() {
  //     wifiName = name;
  //   });
  //   return wifiName;
  // }

  WiFiHunterResult wiFiHunterResult = WiFiHunterResult();
  Color scanButtonColor = Colors.purple;

  Future<void> huntWiFis() async {
    setState(() => scanButtonColor = Colors.deepPurpleAccent);

    try {
      wiFiHunterResult = (await WiFiHunter.huntWiFiNetworks)!;
    } on PlatformException catch (exception) {
      // ignore: avoid_print
      print(exception.toString());
    }

    if (!mounted) return;

    setState(() => scanButtonColor = Colors.purple);
  }

  // getConnection() async {
  //   var con = await Connectivity().checkConnectivity();
  //   if (con == ConnectivityResult.mobile) {
  //     AlertDialog(
  //       title: const Text('Connection Type'),
  //       content: SingleChildScrollView(
  //         child: ListBody(
  //           children: const <Widget>[
  //             Text('You are connected to mobile network.')
  //           ],
  //         ),
  //       ),
  //       actions: <Widget>[
  //         TextButton(
  //           child: const Text('Ok'),
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //           },
  //         ),
  //       ],
  //     );
  //   } else if (con == ConnectivityResult.wifi) {
  //     AlertDialog(
  //       title: const Text('Connection Type'),
  //       content: SingleChildScrollView(
  //         child: ListBody(
  //           children: const <Widget>[
  //             Text('You are connected to wifi network.')
  //           ],
  //         ),
  //       ),
  //       actions: <Widget>[
  //         TextButton(
  //           child: const Text('Ok'),
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //           },
  //         ),
  //       ],
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mobile App'),
          backgroundColor: Colors.purple,
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
                        backgroundColor:
                            MaterialStateProperty.all<Color>(scanButtonColor)),
                    onPressed: () => {huntWiFis()},
                    child: const Text('Scan for Networks')),
              ),
              wiFiHunterResult.results.isNotEmpty
                  ? Container(
                      margin: const EdgeInsets.only(
                          bottom: 20.0, left: 30.0, right: 30.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                              wiFiHunterResult.results.length,
                              (index) => Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: ListTile(
                                        leading: Text(wiFiHunterResult
                                                .results[index].level
                                                .toString() +
                                            ' dbm'),
                                        title: Text(wiFiHunterResult
                                            .results[index].SSID),
                                        subtitle: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('BSSID : ' +
                                                  wiFiHunterResult
                                                      .results[index].BSSID),
                                             
                                            ])),
                                  ))),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
