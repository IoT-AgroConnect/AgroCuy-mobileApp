import 'package:agrocuy/infrastructure/services/session_service.dart';
import '../../data/datasources/advisor_remote_data_source.dart';
import '../../data/models/advisor_model.dart';

class AdvisorRepository {
  final AdvisorRemoteDataSource remoteDataSource;
  final SessionService _session = SessionService();

  AdvisorRepository(this.remoteDataSource);

  Future<List<AdvisorModel>> getAll() async {
    final token = _session.getToken();
    return remoteDataSource.getAdvisors(token);
  }

  Future<AdvisorModel> getById(int id) async {
    final token = _session.getToken();
    return remoteDataSource.getAdvisorById(id, token);
  }
}
