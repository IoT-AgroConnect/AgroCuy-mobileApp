import 'package:flutter/material.dart';

class ScheduleModel {
  final int id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status;

  ScheduleModel({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
  });
}

