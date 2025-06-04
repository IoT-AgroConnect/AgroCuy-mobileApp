class ScheduleModel {
  final int id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status;
  final int advisorId;

  ScheduleModel({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.advisorId,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      status: json['status'],
      advisorId: json['advisorId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'advisorId': advisorId,
    };
  }
}

