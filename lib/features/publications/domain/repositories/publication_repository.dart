import '../../data/datasources/publication_remote_data_source.dart';
import '../../data/models/publication_model.dart';

class PublicationRepository {
  final PublicationRemoteDataSource remoteDataSource;

  PublicationRepository(this.remoteDataSource);

  Future<List<PublicationModel>> getAll(String token) =>
      remoteDataSource.getPublications(token);

  Future<PublicationModel> getById(int id, String token) =>
      remoteDataSource.getPublicationById(id, token);

  Future<void> create(PublicationModel pub, String token) =>
      remoteDataSource.createPublication(pub, token);

  Future<void> update(int id, PublicationModel pub, String token) =>
      remoteDataSource.updatePublication(id, pub.toCreateJson(), token);

  Future<void> delete(int id, String token) =>
      remoteDataSource.deletePublication(id, token);
}
