class PublicationModel {
  final int id;
  final String title;
  final String description;
  final String image;
  final String date;
  final int advisorId;

  PublicationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.date,
    required this.advisorId,
  });

  factory PublicationModel.fromJson(Map<String, dynamic> json) {
    return PublicationModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      date: json['date'] ?? '',
      advisorId: json['advisorId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'date': date,
      'advisorId': advisorId,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'date': date,
      'advisorId': advisorId,
    };
  }
}
