class Article {
  final String title;
  final String? description;
  final String? urlimage;

  Article({
    required this.title,
    this.description,
    this.urlimage,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'tanpa judul',
      description: json['description'],
      urlimage: json['urlToImage']
    );
  }
}