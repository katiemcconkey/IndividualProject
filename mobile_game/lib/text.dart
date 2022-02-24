
class locationText {
  String wifi;
  String uid;
  String text;
  locationText(this.wifi, this.uid, this.text);

  locationText.fromJson(Map<dynamic, dynamic> json)
      :
        wifi = json['wifi'],
        uid = json['uid'],
        text = json['text'];

  Map<dynamic, dynamic> toJson() =>
  <dynamic, dynamic>{'wifi': wifi, 'uid': uid, 'text':  text};
}

     