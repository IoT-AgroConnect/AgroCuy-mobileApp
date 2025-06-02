class NotificationModel {
  final int id;
  final String type;
  final String text;
  final DateTime date;
  final int userId;

  NotificationModel({
    required this.id,
    required this.type,
    required this.text,
    required this.date,
    required this.userId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      text: json['text'],
      date: DateTime.parse(json['date']),
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'text': text,
      'date': date.toIso8601String(),
      'userId': userId,
    };
  }
}
