class Maintenence {
  final String title;
  final String detail;
  final DateTime start;
  final DateTime end;
  Maintenence({
    required this.title,
    required this.detail,
    required this.start,
    required this.end,
  });
  factory Maintenence.fromJson(Map json) {
    return Maintenence(
      title: json['title'],
      detail: json['detail'],
      start: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['start']["\$date"]["\$numberLong"]),
      ),
      end: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['start']["\$date"]["\$numberLong"]),
      ),
    );
  }
  Map toJson(Maintenence maintenence) {
    return {
      title: maintenence.title,
      detail: maintenence.detail,
      start: maintenence.start,
      end: maintenence.end
    };
  }
}
