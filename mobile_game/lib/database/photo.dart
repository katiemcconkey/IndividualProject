// ignore_for_file: camel_case_types

class photo {
  String name;
  String wifi;
  String uid;
 
  photo(this.name, this.wifi, this.uid, );

  photo.fromJson(Map<dynamic, dynamic> json)
      : name = json['name'],
        wifi = json['wifi'],
        uid = json['uid'];

  Map<dynamic, dynamic> toJson() =>
      <dynamic, dynamic>{'name': name, 'wifi': wifi, 'uid': uid};
}
