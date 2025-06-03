class AdvisorModel {
  final String? fullname;
  final String? location;
  final DateTime? birthdate;
  final String? description;
  final String? occupation;
  final int? experience;
  final String? photo;
  final double? rating; // This will be used for the stars on the explore screen

  AdvisorModel({
    this.fullname,
    this.location,
    this.birthdate,
    this.description,
    this.occupation,
    this.experience,
    this.photo,
    this.rating,
  });

  factory AdvisorModel.fromJson(Map<String, dynamic> json) {
    return AdvisorModel(
      fullname: json['fullname'] as String?,
      location: json['location'] as String?,
      birthdate: json['birthdate'] != null
          ? DateTime.tryParse(json['birthdate'])
          : null,
      description: json['description'] as String?,
      occupation: json['occupation'] as String?,
      experience: json['experience'] as int?,
      photo: json['photo'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'location': location,
      'birthdate': birthdate?.toIso8601String(),
      'description': description,
      'occupation': occupation,
      'experience': experience,
      'photo': photo,
      'rating': rating,
    };
  }
}