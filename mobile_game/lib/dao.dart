import 'package:firebase_database/firebase_database.dart';
import 'photo.dart';

class Dao {
  late String data;
  final DatabaseReference _ref =
      FirebaseDatabase.instance.ref().child('photos');

  void saveData(photo photo) {
    _ref.push().set(photo.toJson());
  }

  Query getPhotoQuery() {
    return _ref;
  }

  String getData() {
    _ref.child('photos').child('wifi').once().then((dynamic snap) {
      data = snap.value as String;
    });
    return data;
  }
}
