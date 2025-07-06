class NotificationModel {
  final int id;
  final String type;
  final String text;
  final DateTime date;
  final int userId;
  final String? meetingUrl;

  NotificationModel({
    required this.id,
    required this.type,
    required this.text,
    required this.date,
    required this.userId,
    this.meetingUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      text: json['text'] ?? '',
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      userId: json['userId'] ?? 0,
      meetingUrl: json['meetingUrl'] ??
          json['linkMeet'], // Support both field names for compatibility
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'text': text,
      'date': date.toIso8601String(),
      'userId': userId,
      'meetingUrl': meetingUrl,
    };
  }

  // Getter for backward compatibility
  String? get linkMeet => meetingUrl;
}
