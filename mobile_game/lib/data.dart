class Data {
  int counter;
  int points;
  String uid;
  Data(this.counter, this.points, this.uid);

  Data.fromJson(Map<dynamic, dynamic> json)
      : counter = json['counter'],
        points = json['points'],
        uid = json['uid'];

  Map<dynamic, dynamic> toJson() =>
      <dynamic, dynamic>{'counter': counter, 'points': points, 'uid': uid};
}