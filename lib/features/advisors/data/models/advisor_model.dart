import 'package:agrocuy/features/advisors/data/models/review_model.dart';

class AdvisorModel {
  final int id;
  final String? fullname;
  final String location;
  final DateTime? birthdate;
  final String description;
  final String occupation;
  final int experience;
  final String? photo;
  final double? rating;
  final List<ReviewModel>? reviews;
  final String userId;

  AdvisorModel({
    required this.id,
    this.fullname,
    required this.location,
    this.birthdate,
    required this.description,
    required this.occupation,
    required this.experience,
    this.photo,
    this.rating,
    this.reviews,
    required this.userId,
  });

  factory AdvisorModel.fromJson(Map<String, dynamic> json) {
    return AdvisorModel(
      id: json['id'],
      fullname: json['fullname'],
      location: json['location'],
      birthdate: json['birthdate'] != null ? DateTime.parse(json['birthdate']) : null,
      description: json['description'],
      occupation: json['occupation'],
      experience: json['experience'],
      photo: json['photo'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((e) => ReviewModel.fromJson(e)).toList()
          : [],
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'location': location,
      'birthdate': birthdate?.toIso8601String(),
      'description': description,
      'occupation': occupation,
      'experience': experience,
      'photo': photo,
      'rating': rating,
      'reviews': reviews?.map((e) => e.toJson()).toList(),
      'userId': userId,
    };
  }
}
