import '../../data/datasources/schedule_remote_data_source.dart';
import '../../data/models/schedule_model.dart';

class ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;

  ScheduleRepository(this.remoteDataSource);

  Future<List<ScheduleModel>> getSchedulesByAdvisor(int advisorId) async {
    return await remoteDataSource.getSchedulesByAdvisor(advisorId);
  }

  Future<ScheduleModel> createSchedule(ScheduleModel schedule) async {
    return await remoteDataSource.createSchedule(schedule);
  }

  Future<ScheduleModel> updateSchedule(int id, ScheduleModel schedule) async {
    return await remoteDataSource.updateSchedule(id, schedule);
  }

  Future<void> deleteSchedule(int id) async {
    return await remoteDataSource.deleteSchedule(id);
  }
}
