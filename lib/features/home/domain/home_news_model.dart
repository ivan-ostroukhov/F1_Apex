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
}