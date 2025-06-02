import 'package:agrocuy/infrastructure/services/session_service.dart';
import '../../data/datasources/publication_remote_data_source.dart';
import '../../data/models/publication_model.dart';

class PublicationRepository {
  final PublicationRemoteDataSource remoteDataSource;
  final SessionService _session = SessionService();

  PublicationRepository(this.remoteDataSource);

  Future<List<PublicationModel>> getAll() async {
    final token = _session.getToken();
    return remoteDataSource.getPublications(token);
  }

  Future<PublicationModel> getById(int id) async {
    final token = _session.getToken();
    return remoteDataSource.getPublicationById(id, token);
  }

  Future<void> create(PublicationModel pub) async {
    final token = _session.getToken();
    return remoteDataSource.createPublication(pub, token);
  }

  Future<void> update(int id, PublicationModel pub) async {
    final token = _session.getToken();
    return remoteDataSource.updatePublication(id, pub.toCreateJson(), token);
  }

  Future<void> delete(int id) async {
    final token = _session.getToken();
    return remoteDataSource.deletePublication(id, token);
  }
}
