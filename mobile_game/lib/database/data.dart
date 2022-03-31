// class for the data property of the realtime database
// hold information about the user
class Data {
  //keeps track of the counter which updated when you upload an ima'ge or text tag
  // when counter hits 10 the user can no longer upload
  int counter;
  // keeps track og users points
  int points;
  // holds users UID
  String uid;
  // keeps track of last time the counter was updated
  String time;
  // holds user username which is just their email
  String username;
  // keeps track of images and text tags which the user has already guessed
  String alreadyGuessed;

  Data(
    this.counter,
    this.points,
    this.uid,
    this.time,
    this.alreadyGuessed,
    this.username,
  );

  Data.fromJson(Map<dynamic, dynamic> json)
      : counter = json['counter'],
        points = json['points'],
        uid = json['uid'],
        time = json['time'],
        alreadyGuessed = json['alreadyGuessed'],
        username = json['username'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'counter': counter,
        'points': points,
        'uid': uid,
        'time': time,
        'alreadyGuessed': alreadyGuessed,
        'username': username,
      };
}
