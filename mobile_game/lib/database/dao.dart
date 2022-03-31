import 'package:firebase_database/firebase_database.dart';
import 'package:mobile_game/database/text.dart';
import 'photo.dart';
import 'data.dart';
import 'text.dart';

class Dao {
  late String data;
  // references to all categories in the database
  final DatabaseReference _ref = FirebaseDatabase.instance.ref().child('photos');
  final DatabaseReference ref = FirebaseDatabase.instance.ref().child('data');
  final DatabaseReference reference = FirebaseDatabase.instance.ref().child('locationText');

  // 3 different methods used to save data to each top level json object in the firebase realtime database 
  void saveData(photo photo) {
    _ref.push().set(photo.toJson());
  }

  void saveDatas(Data data) {
    ref.push().set(data.toJson());
  }

  void savedata(LocationText locationText) {
    reference.push().set(locationText.toJson());
  }
}
