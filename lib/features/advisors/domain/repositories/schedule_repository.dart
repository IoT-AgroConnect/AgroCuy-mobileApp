import '../../data/datasources/schedule_remote_data_source.dart';
import '../../data/models/available_date_model.dart';

class ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;

  ScheduleRepository({required this.remoteDataSource});

  Future<List<ScheduleModel>> getSchedulesForAdvisor(int advisorId) {
    return remoteDataSource.getSchedulesByAdvisorId(advisorId);
  }
}
