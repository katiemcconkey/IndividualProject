class Data {
  int counter;
  int points;
  String uid;
  String time;
  String username;

  Data(
    this.counter,
    this.points,
    this.uid,
    this.time,
    this.username
  );

  Data.fromJson(Map<dynamic, dynamic> json)
      : counter = json['counter'],
        points = json['points'],
        uid = json['uid'],
        time = json['time'],
        username = json['username'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'counter': counter,
        'points': points,
        'uid': uid,
        'time': time,
        'username': username,
      };
}
