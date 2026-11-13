class HomeNewsModel {
  final String id;
  final String title;
  final String source;
  final String timeAgo;
  final String? timeAgoEn;
  final String imageUrl;
  final String url;

  const HomeNewsModel({
    required this.id,
    required this.title,
    required this.source,
    required this.timeAgo,
    this.timeAgoEn,
    required this.imageUrl,
    required this.url,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'source': source,
        'timeAgo': timeAgo,
        'timeAgoEn': timeAgoEn,
        'imageUrl': imageUrl,
        'url': url,
      };

  factory HomeNewsModel.fromJson(Map<String, dynamic> json) {
    return HomeNewsModel(
      id: json['id'] as String? ?? '1',
      title: json['title'] as String? ?? '',
      source: json['source'] as String? ?? 'F1 News',
      timeAgo: json['timeAgo'] as String? ?? '',
      timeAgoEn: json['timeAgoEn'] as String?,
      imageUrl: json['imageUrl'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}