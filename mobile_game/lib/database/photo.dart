// ignore_for_file: camel_case_types
// class for the photo property of the realtime database
// hold information about the uploaded photos
class photo {
  // stores name of image
  String name;
  // stores string containing all WiFi networks
  String wifi;
  // stores current users uid
  String uid;
  // stores the amount of time this image has been confirmed
  int guessedCorrectly;

  photo(
    this.name,
    this.wifi,
    this.uid,
    this.guessedCorrectly,
  );

  photo.fromJson(Map<dynamic, dynamic> json)
      : name = json['name'],
        wifi = json['wifi'],
        uid = json['uid'],
        guessedCorrectly = json['guessedCorrectly'];

  Map<dynamic, dynamic> toJson() =>
      <dynamic, dynamic>{'name': name, 'wifi': wifi, 'uid': uid, 'guessedCorrectly' : guessedCorrectly};
}
