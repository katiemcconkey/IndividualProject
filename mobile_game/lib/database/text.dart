// class for the locationText property of the realtime database
// hold information about the uploaded text tags
class LocationText {
  // holds strig of all wifi networks
  String wifi;
  // stores current users uid
  String uid;
  // stores the uploaded text tag
  String text;
  // stores the amount of times this tag has been confirmed
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
