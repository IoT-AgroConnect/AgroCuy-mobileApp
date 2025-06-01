import '../../data/datasources/publication_remote_data_source.dart';
import '../../data/models/publication_model.dart';

class PublicationRepository {
  final PublicationRemoteDataSource remoteDataSource;

  PublicationRepository(this.remoteDataSource);

  Future<List<PublicationModel>> getAll() => remoteDataSource.getPublications();
  Future<PublicationModel> getById(int id) => remoteDataSource.getPublicationById(id);
  Future<void> create(PublicationModel pub) => remoteDataSource.createPublication(pub);
  Future<void> update(int id, PublicationModel pub) => remoteDataSource.updatePublication(id, pub);
  Future<void> delete(int id) => remoteDataSource.deletePublication(id);
}
