import 'package:flutter/material.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:network_info_plus/network_info_plus.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final Set<Marker> _markers = {};

  //late String wifiBSSID;

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
  //wifiStuff() async {
  static final info = NetworkInfo();
  _getBSSID() async {
    var wifiBSSID = await info.getWifiBSSID();
    print(wifiBSSID);
    return wifiBSSID;
  }
    _getName() async {
    var wifiName = await info.getWifiName();
    //var wifiBSSID = await info.getWifiBSSID();
    print(wifiName);
    return wifiName;
  }

   // FooNetwork
  // 11:22:33:44:55:66
  var wifiIP = info.getWifiIP(); // 192.168.1.43
  var wifiIPv6 = info.getWifiIPv6(); // 2001:0db8:85a3:0000:0000:8a2e:0370:7334
  var wifiSubmask = info.getWifiSubmask(); // 255.255.255.0
  var wifiBroadcast = info.getWifiBroadcast(); // 192.168.1.255
  var wifiGateway = info.getWifiGatewayIP(); // 192.168.1.1

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Mobile App'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("BSSID is"),
            TextButton(
              child: const Text("Get BSSID"),
              onPressed: () async {
                _getName();
              },
            ),
          ],
        ),
      ),
    ));
  }
}
