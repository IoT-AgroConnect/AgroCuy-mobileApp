import '../../data/datasources/available_date_remote_data_source.dart';
import '../../data/models/available_date_model.dart';

class AvailableDateRepository {
  final AvailableDateRemoteDataSource remoteDataSource;

  AvailableDateRepository({required this.remoteDataSource});

  Future<List<AvailableDateModel>> getAvailableDatesForAdvisor(int advisorId) {
    return remoteDataSource.getAvailableDatesByAdvisorId(advisorId);
  }
}
