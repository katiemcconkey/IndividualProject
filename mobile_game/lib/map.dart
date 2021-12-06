// // ignore_for_file: camel_case_types

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:mobile_game/nav_bar.dart';
// import 'main.dart';

// class maps extends StatefulWidget {
//   const maps({Key? key}) : super(key: key);

//   @override
//   _mapState createState() => _mapState();
// }

// class _mapState extends State<maps> {
//   late GoogleMapController mapController;

//   final LatLng _center = const LatLng(55.87545333333333, -4.291243333333333);

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         drawer: const NavBar(),
//         appBar: AppBar(
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.map),
//               onPressed: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => const maps()));
//               },
//             ),
//             IconButton(
//                 onPressed: () {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (context) => const MyApp()));
//                 },
//                 icon: const Icon(Icons.home))
//           ],
//           backgroundColor: Colors.green[700],
//           title: const Text('Map'),
//           centerTitle: true,
//         ),
//         body: GoogleMap(
//           onMapCreated: _onMapCreated,
//           initialCameraPosition: CameraPosition(
//             target: _center,
//             zoom: 30.0,
//           ),
//         ),
//       ),
//     );
//   }
// }
