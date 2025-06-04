class AvailableDateModel {
  final int id;
  final int advisorId;
  final String dateTime;

  AvailableDateModel({
    required this.id,
    required this.advisorId,
    required this.dateTime,
  });

  factory AvailableDateModel.fromJson(Map<String, dynamic> json) {
    return AvailableDateModel(
      id: json['id'],
      advisorId: json['advisorId'],
      dateTime: json['dateTime'],
    );
  }
}
