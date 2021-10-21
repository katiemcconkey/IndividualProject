//import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:wifi_hunter/wifi_hunter.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final Set<Marker> _markers = {};
  // late GoogleMapController mapController;
  // final LatLng _center = const LatLng(55.875492878380975, -4.291251024554);
  // void _onMapCreated(GoogleMapController controller) {
  //   mapController = controller;
  //   setState(() {
  //     _markers.add(Marker(
  //       markerId: const MarkerId("1"),
  //       position: _center,
  //       infoWindow: const InfoWindow(title: "Your Location"),
  //     ));
  //   });
  // }

  String? wifiBSSID = 'Click below to see';
  String? wifiName = 'Click below to see';

  static final info = NetworkInfo();

  _getBSSID() async {
    var b = await info.getWifiBSSID();
    setState(() {
      wifiBSSID = b;
    });
    return wifiBSSID;
  }

  _getName() async {
    var name = await info.getWifiName();
    setState(() {
      wifiName = name;
    });
    return wifiName;
  }

  WiFiHunterResult wiFiHunterResult = WiFiHunterResult();
  Color scanButtonColor = Colors.purple;

  Future<void> huntWiFis() async {
    setState(() => scanButtonColor = Colors.deepPurpleAccent);

    try {
      wiFiHunterResult = (await WiFiHunter.huntWiFiNetworks)!;
    } on PlatformException catch (exception) {
      print(exception.toString());
    }

    if (!mounted) return;

    setState(() => scanButtonColor = Colors.purple);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mobile App'),
          backgroundColor: Colors.purple,
        ),
        body:
            // Center(
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       Text("WIFI INFO:\n $wifiName\n $wifiBSSID \n"),
            //       TextButton(
            //         child: const Text("Get Info"),
            //         onPressed: () async {
            //           await _getName();
            //           await _getBSSID();
            //         },
            //       ),
            //     ],
            //   ),
            // ),
            SingleChildScrollView(
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
                    onPressed: () => huntWiFis(),
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
                                              Text('Capabilities : ' +
                                                  wiFiHunterResult
                                                      .results[index]
                                                      .capabilities),
                                              Text('Frequency : ' +
                                                  wiFiHunterResult
                                                      .results[index].frequency
                                                      .toString()),
                                              Text('Channel Width : ' +
                                                  wiFiHunterResult
                                                      .results[index]
                                                      .channelWidth
                                                      .toString()),
                                              Text('Timestamp : ' +
                                                  wiFiHunterResult
                                                      .results[index].timestamp
                                                      .toString())
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
