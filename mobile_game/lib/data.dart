class Data {
  int counter;
  int points;
  String uid;
  String time;

  Data(
    this.counter,
    this.points,
    this.uid,
    this.time,
  );

  Data.fromJson(Map<dynamic, dynamic> json)
      : counter = json['counter'],
        points = json['points'],
        uid = json['uid'],
        time = json['time'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'counter': counter,
        'points': points,
        'uid': uid,
        'time': time,
      };
}
