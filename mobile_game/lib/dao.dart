import 'package:firebase_database/firebase_database.dart';
import 'photo.dart';
import 'data.dart';

class Dao {
  late String data;
  final DatabaseReference _ref =
      FirebaseDatabase.instance.ref().child('photos');
  final DatabaseReference ref =
      FirebaseDatabase.instance.ref().child('data');


  void saveData(photo photo) {
    _ref.push().set(photo.toJson());
  }
  void saveDatas(Data data) {
    ref.push().set(data.toJson());
  }
}
