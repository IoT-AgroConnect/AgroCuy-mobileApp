class ReviewModel {
  final int id;
  final String content;
  final int rating;
  final int userId;
  final int advisorId;

  ReviewModel({
    required this.id,
    required this.content,
    required this.rating,
    required this.userId,
    required this.advisorId,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      content: json['content'],
      rating: json['rating'],
      userId: json['userId'],
      advisorId: json['advisorId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'rating': rating,
      'userId': userId,
      'advisorId': advisorId,
    };
  }
}
