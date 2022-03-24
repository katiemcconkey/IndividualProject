class LocationText {
  String wifi;
  String uid;
  String text;
  int guessedCorrectly;
  LocationText(this.wifi, this.uid, this.text, this.guessedCorrectly);

  LocationText.fromJson(Map<dynamic, dynamic> json)
      : wifi = json['wifi'],
        uid = json['uid'],
        text = json['text'],
        guessedCorrectly = json['guessedCorrectly'];

  Map<dynamic, dynamic> toJson() =>
      <dynamic, dynamic>{'wifi': wifi, 'uid': uid, 'text': text, 'guessedCorrectly' : guessedCorrectly};
}
