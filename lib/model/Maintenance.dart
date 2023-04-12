class Maintenance {
  final String title;
  final String detail;
  final DateTime start;
  final DateTime end;
  Maintenance({
    required this.title,
    required this.detail,
    required this.start,
    required this.end,
  });
  factory Maintenance.fromJson(Map json) {
    return Maintenance(
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
}
