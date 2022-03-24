// ignore_for_file: camel_case_types

class photo {
  String name;
  String wifi;
  String uid;
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
