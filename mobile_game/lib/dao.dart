import 'package:firebase_database/firebase_database.dart';
import 'photo.dart';
 
class Dao {
  final DatabaseReference _ref =
      FirebaseDatabase.instance.reference().child('photos');
  
  void saveData(photo photo) {
  _ref.push().set(photo.toJson());
}

Query getPhotoQuery() {
  return _ref;
}


}
