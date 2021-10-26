import 'package:flutter/material.dart';
import 'upload_picture.dart';

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
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const pictureApp())),
          ),
          ListTile(
            leading: const Icon(Icons.add_location_outlined),
            title: const Text('Find Location'),
            // ignore: avoid_returning_null_for_void
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const pictureApp())),
          ),
        ],
      ),
    );
  }
}