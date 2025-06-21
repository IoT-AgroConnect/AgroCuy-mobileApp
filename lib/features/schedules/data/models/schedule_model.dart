class ScheduleModel {
  final int id;
  final String date; // Cambio de dayOfWeek a date (formato: yyyy-MM-dd)
  final String startTime;
  final String endTime;
  final int advisorId;
  final bool isActive;

  ScheduleModel({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.advisorId,
    this.isActive = true,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'],
      date: json['date'] ?? json['dayOfWeek'] ?? '', // Compatibilidad backward
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      advisorId: json['advisorId'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'advisorId': advisorId,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'advisorId': advisorId,
      'isActive': isActive,
    };
  }

  ScheduleModel copyWith({
    int? id,
    String? date,
    String? startTime,
    String? endTime,
    int? advisorId,
    bool? isActive,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      advisorId: advisorId ?? this.advisorId,
      isActive: isActive ?? this.isActive,
    );
  }
}
