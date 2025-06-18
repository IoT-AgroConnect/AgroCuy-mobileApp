import '../models/schedule_model.dart';

abstract class ScheduleRemoteDataSource {
  Future<List<ScheduleModel>> getSchedulesByAdvisor(int advisorId);
  Future<ScheduleModel> createSchedule(ScheduleModel schedule);
  Future<ScheduleModel> updateSchedule(int id, ScheduleModel schedule);
  Future<void> deleteSchedule(int id);
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  // Simulando datos locales por ahora
  static List<ScheduleModel> _schedules = [
    ScheduleModel(
      id: 1,
      date: '2025-06-18', // Miércoles
      startTime: '08:00',
      endTime: '12:00',
      advisorId: 1,
    ),
    ScheduleModel(
      id: 2,
      date: '2025-06-18', // Miércoles
      startTime: '14:00',
      endTime: '18:00',
      advisorId: 1,
    ),
    ScheduleModel(
      id: 3,
      date: '2025-06-19', // Jueves
      startTime: '09:00',
      endTime: '17:00',
      advisorId: 1,
    ),
    ScheduleModel(
      id: 4,
      date: '2025-06-20', // Viernes
      startTime: '08:00',
      endTime: '16:00',
      advisorId: 1,
    ),
    ScheduleModel(
      id: 5,
      date: '2025-06-23', // Lunes
      startTime: '10:00',
      endTime: '18:00',
      advisorId: 1,
    ),
    ScheduleModel(
      id: 6,
      date: '2025-06-24', // Martes
      startTime: '08:00',
      endTime: '15:00',
      advisorId: 1,
    ),
  ];

  @override
  Future<List<ScheduleModel>> getSchedulesByAdvisor(int advisorId) async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simular delay de red
    return _schedules
        .where((schedule) => schedule.advisorId == advisorId)
        .toList();
  }

  @override
  Future<ScheduleModel> createSchedule(ScheduleModel schedule) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newId = _schedules.isNotEmpty
        ? _schedules.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1
        : 1;
    final newSchedule = schedule.copyWith(id: newId);
    _schedules.add(newSchedule);
    return newSchedule;
  }

  @override
  Future<ScheduleModel> updateSchedule(int id, ScheduleModel schedule) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      _schedules[index] = schedule.copyWith(id: id);
      return _schedules[index];
    }
    throw Exception('Schedule not found');
  }

  @override
  Future<void> deleteSchedule(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _schedules.removeWhere((schedule) => schedule.id == id);
  }
}
