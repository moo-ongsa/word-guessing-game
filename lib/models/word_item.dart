class WordItem {
  final String word;
  final String? imageUrl;
  final String? description;
  final String category;

  WordItem({
    required this.word,
    this.imageUrl,
    this.description,
    required this.category,
  });

  factory WordItem.fromJson(Map<String, dynamic> json) {
    return WordItem(
      word: json['word'] ?? '',
      imageUrl: json['imageUrl'],
      description: json['description'],
      category: json['category'] ?? 'ทั่วไป',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'imageUrl': imageUrl,
      'description': description,
      'category': category,
    };
  }
}
