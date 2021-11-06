import 'package:flutter/material.dart';
import 'package:mobile_game/screens/bssid.dart';
import 'screens/camera_screen.dart';
import 'screens/photo_gallery.dart';

class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(child: ClipOval(child: Text('NAME'),) ),
          ListTile(
            leading: const Icon(Icons.add_a_photo_outlined),
            title: const Text('Upload Picture'),
            // ignore: avoid_returning_null_for_void
            onTap: () => 
            //Null,
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  const pictureApp())),
          ),
          ListTile(
            leading: const Icon(Icons.add_location_outlined),
            title: const Text('Find Location'),
            // ignore: avoid_returning_null_for_void
            onTap: () => Null,
            //Navigator.push(context, MaterialPageRoute(builder: (context) =>  const pictureApp())),
          ),
          ListTile(
            leading: const Icon(Icons.burst_mode_outlined),
            title: const Text('Gallery'),
            // ignore: avoid_returning_null_for_void
            onTap: () => 
            //Null,
            // Navigator.push(context, MaterialPageRoute(builder: (context) => Gallery())),
            Navigator.push(context, MaterialPageRoute(builder: (context) =>  const Bssid())),
          ),
        ],
      ),
    );
  }
}