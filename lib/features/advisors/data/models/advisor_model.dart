class AdvisorModel {
  final int id;
  final String? fullname;
  final String? location;
  final DateTime? birthdate;
  final String description;
  final String? occupation;
  final int? experience;
  final String? photo;
  final double? rating;
  final String userId;

  AdvisorModel({
    required this.id,
    this.fullname,
    this.location,
    this.birthdate,
    required this.description,
    this.occupation,
    this.experience,
    this.photo,
    this.rating,
    this.userId = '',
  });

  factory AdvisorModel.fromJson(Map<String, dynamic> json) {
    return AdvisorModel(
      id: json['id'] as int,
      fullname: json['fullname'] as String?,
      location: json['location'] as String?,
      birthdate: json['birthdate'] != null
          ? DateTime.tryParse(json['birthdate'])
          : null,
      description: json['description'] as String,
      occupation: json['occupation'] as String?,
      experience: json['experience'] as int?,
      photo: json['photo'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      userId: json['userId'] as String? ?? '',
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
      'userId': userId,
    };
  }
}