class WordModel {
  final String id;
  final String text;
  final DateTime nextReview;

  WordModel({
    required this.id,
    required this.text,
    required this.nextReview,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'],
      text: json['text'],
      nextReview: DateTime.parse(json['nextReview']),
    );
  }
}