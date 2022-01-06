class Notice {
  final String id;
  final String title;
  final String content;
  final String img;
  final String date;

  Notice(
      {required this.id,
      required this.title,
      required this.content,
      required this.img,
      required this.date});

  factory Notice.fromList(Map<String, dynamic> json) {
    return Notice(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      img: json['img'],
      date: json['date'],
    );
  }
}
