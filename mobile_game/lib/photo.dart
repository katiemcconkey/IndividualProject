// ignore_for_file: camel_case_types

class photo {
  String name;
  String wifi;
  photo(this.name, this.wifi);

  photo.fromJson(Map<dynamic, dynamic> json)
      : name = json['name'],
        wifi = json['wifi'];

  Map<dynamic, dynamic> toJson() =>
      <dynamic, dynamic>{'name': name, 'wifi': wifi};
}
