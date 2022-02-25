
class LocationText {
  String wifi;
  String uid;
  String text;
  LocationText(this.wifi, this.uid, this.text);

  LocationText.fromJson(Map<dynamic, dynamic> json)
      :
        wifi = json['wifi'],
        uid = json['uid'],
        text = json['text'];

  Map<dynamic, dynamic> toJson() =>
  <dynamic, dynamic>{'wifi': wifi, 'uid': uid, 'text':  text};
}

     