// ignore_for_file: camel_case_types

class photo {
  String name;
  //List<String>  wifi;
  photo(this.name);

  photo.fromJson(Map<dynamic, dynamic> json) : name = json['name'];

  Map<dynamic, dynamic> toJson() =>
      <dynamic, dynamic>{'name': name};
}
