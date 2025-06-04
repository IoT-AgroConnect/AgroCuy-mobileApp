import 'package:agrocuy/features/advisors/data/models/advisor_model.dart';

class AdvisorFakeRepository {
  Future<List<AdvisorModel>> getAll() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      AdvisorModel(
        id: 1,
        fullname: "Holi",
        location: "Peru",
        birthdate:  DateTime(1990, 1, 1),
        description: "description",
        occupation: "occupation",
        experience:  5,
        photo:  "https://i.pinimg.com/736x/04/7e/5c/047e5c0d3a18c1c79bc58073b1b5e7ca.jpg",
        rating:  4.5,
        userId: "1",
      ),
      AdvisorModel(
        id: 2,
        fullname: "Holi",
        location: "Peru",
        birthdate:  DateTime(1990, 1, 1),
        description: "description",
        occupation: "occupation",
        experience:  5,
        photo:  "https://i.pinimg.com/736x/9a/18/f1/9a18f152d0a30ce87880b773936c2917.jpg",
        rating:  4.5,
        userId: "1",
      ),
    ];
  }
}
