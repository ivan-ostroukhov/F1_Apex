import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../common/network/local_storage_service.dart';
import '../domain/home_news_model.dart';

class HomeRepository {
  static const List<String> _fallbackImages = [
    'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?q=80&w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1533106497176-45ae19e68ba2?q=80&w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1503376780353-7e6692767b70?q=80&w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1511919884226-fd3cad34687c?q=80&w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1542282088-72c9c27ed0cd?q=80&w=800&auto=format&fit=crop',
  ];

  Future<List<HomeNewsModel>> getLatestNews({bool isEnglish = false}) async {
    final cacheKey = isEnglish ? 'cached_home_news_en' : 'cached_home_news_ru';
    final cachedJson = LocalStorageService.getString(cacheKey);
    List<HomeNewsModel> cachedList = [];
    if (cachedJson != null && cachedJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(cachedJson) as List<dynamic>;
        cachedList = decoded
            .map((item) => HomeNewsModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    try {
      final featuredDriverNews = _getFeaturedDriverNews(isEnglish: isEnglish);
      final rssNewsList = <HomeNewsModel>[];

      final primaryUrl = isEnglish
          ? 'https://www.racefans.net/feed/'
          : 'https://www.f1news.ru/export/news.xml';
      final primarySource = isEnglish ? 'RaceFans' : 'F1News.ru';

      try {
        final response = await http.get(
          Uri.parse(primaryUrl),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
          },
        ).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          final xmlText = utf8.decode(response.bodyBytes, allowMalformed: true);
          final parsed = _parseRssFeed(xmlText, sourceName: primarySource);
          rssNewsList.addAll(parsed);
        }
      } catch (_) {}

      // Fallback feed if primary RSS was empty
      if (rssNewsList.isEmpty) {
        final secondaryUrl = isEnglish
            ? 'https://www.f1news.ru/export/news.xml'
            : 'https://www.racefans.net/feed/';
        final secondarySource = isEnglish ? 'F1News.ru' : 'RaceFans';

        try {
          final response = await http.get(
            Uri.parse(secondaryUrl),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
            },
          ).timeout(const Duration(seconds: 8));

          if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
            final xmlText = utf8.decode(response.bodyBytes, allowMalformed: true);
            final parsed = _parseRssFeed(xmlText, sourceName: secondarySource);
            rssNewsList.addAll(parsed);
          }
        } catch (_) {}
      }

      // Merge featured driver news with RSS news
      final combined = <HomeNewsModel>[];
      final seenUrls = <String>{};

      // Add top driver news quotes first
      for (final feat in featuredDriverNews) {
        if (!seenUrls.contains(feat.url)) {
          seenUrls.add(feat.url);
          combined.add(feat);
        }
      }

      // Interleave live RSS articles
      for (final rss in rssNewsList) {
        if (!seenUrls.contains(rss.url) && rss.url.startsWith('http')) {
          seenUrls.add(rss.url);
          combined.add(rss);
        }
      }

      if (combined.isNotEmpty) {
        final result = combined.take(12).toList();

        LocalStorageService.setString(
          cacheKey,
          jsonEncode(result.map((e) => e.toJson()).toList()),
        );

        return result;
      }
    } catch (_) {}

    if (cachedList.isNotEmpty) {
      return cachedList;
    }

    return _getFeaturedDriverNews(isEnglish: isEnglish);
  }

  List<HomeNewsModel> _getFeaturedDriverNews({required bool isEnglish}) {
    if (isEnglish) {
      return const [
        HomeNewsModel(
          id: 'driver_feat_1',
          title: 'Max Verstappen: "Overtaking in the rain is much easier when you have full confidence in the car balance"',
          source: 'Formula1.com',
          timeAgo: '15 минут назад',
          timeAgoEn: '15 mins ago',
          imageUrl: 'https://c.f1news.ru/userfiles/max_verstappen/192469.jpg',
          url: 'https://www.formula1.com/en/latest/all.html',
        ),
        HomeNewsModel(
          id: 'driver_feat_2',
          title: 'Charles Leclerc: "Ferrari floor & sidepod upgrades give us strong downforce gains in low-speed corners"',
          source: 'Motorsport.com',
          timeAgo: '42 минуты назад',
          timeAgoEn: '42 mins ago',
          imageUrl: 'https://c.f1news.ru/userfiles/ferrari/192463.jpg',
          url: 'https://www.motorsport.com/f1/news/',
        ),
        HomeNewsModel(
          id: 'driver_feat_3',
          title: 'Lando Norris: "Title fight against Verstappen is getting more intense with every Grand Prix"',
          source: 'Autosport.com',
          timeAgo: '2 часа назад',
          timeAgoEn: '2 hours ago',
          imageUrl: 'https://c.f1news.ru/userfiles/stella/192467.jpg',
          url: 'https://www.autosport.com/f1/news/',
        ),
        HomeNewsModel(
          id: 'driver_feat_4',
          title: 'Lewis Hamilton reflects on Mercedes progress ahead of his Ferrari transition',
          source: 'RaceFans.net',
          timeAgo: '4 часа назад',
          timeAgoEn: '4 hours ago',
          imageUrl: 'https://c.f1news.ru/userfiles/hamilton/192470.jpg',
          url: 'https://www.racefans.net/',
        ),
      ];
    } else {
      return const [
        HomeNewsModel(
          id: 'driver_feat_1',
          title: 'Макс Ферстаппен: «В дождь обгонять значительно легче, если ты полностью доверяешь машине»',
          source: 'F1News.ru',
          timeAgo: '15 минут назад',
          timeAgoEn: '15 mins ago',
          imageUrl: 'https://c.f1news.ru/userfiles/max_verstappen/192469.jpg',
          url: 'https://www.f1news.ru/news/f1-192470.html',
        ),
        HomeNewsModel(
          id: 'driver_feat_2',
          title: 'Шарль Леклер: «Обновления днища и понтонов Ferrari дают отличный прирост прижима в медленных поворотах»',
          source: 'Motorsport.com',
          timeAgo: '42 минуты назад',
          timeAgoEn: '42 mins ago',
          imageUrl: 'https://c.f1news.ru/userfiles/ferrari/192463.jpg',
          url: 'https://www.f1news.ru/',
        ),
        HomeNewsModel(
          id: 'driver_feat_3',
          title: 'Ландо Норрис: «Борьба за чемпионский титул с Ферстаппеном становится жестче с каждым этапом»',
          source: 'Autosport.com',
          timeAgo: '2 часа назад',
          timeAgoEn: '2 hours ago',
          imageUrl: 'https://c.f1news.ru/userfiles/stella/192467.jpg',
          url: 'https://www.f1news.ru/',
        ),
        HomeNewsModel(
          id: 'driver_feat_4',
          title: 'Льюис Хэмилтон подвел итоги прогресса Mercedes перед переходом в Ferrari',
          source: 'RaceFans.net',
          timeAgo: '4 часа назад',
          timeAgoEn: '4 hours ago',
          imageUrl: 'https://c.f1news.ru/userfiles/hamilton/192470.jpg',
          url: 'https://www.f1news.ru/',
        ),
      ];
    }
  }

  List<HomeNewsModel> _parseRssFeed(String xmlString, {required String sourceName}) {
    final list = <HomeNewsModel>[];
    final itemRegExp = RegExp(r'<item>([\s\S]*?)</item>', caseSensitive: false);
    final matches = itemRegExp.allMatches(xmlString);

    int idCounter = 1;
    for (final match in matches) {
      final itemXml = match.group(1) ?? '';

      // Title
      final titleMatch = RegExp(r'<title>([\s\S]*?)</title>', caseSensitive: false).firstMatch(itemXml);
      final rawTitle = titleMatch?.group(1) ?? '';
      final title = _cleanHtmlAndEntities(rawTitle);

      // Link
      final linkMatch = RegExp(r'<link>([\s\S]*?)</link>', caseSensitive: false).firstMatch(itemXml) ??
          RegExp(r'<guid[^>]*>([\s\S]*?)</guid>', caseSensitive: false).firstMatch(itemXml);
      final url = _cleanHtmlAndEntities(linkMatch?.group(1) ?? '');

      if (title.isEmpty || url.isEmpty) continue;

      // Image
      String imageUrl = '';
      final enclosureMatch = RegExp(r'enclosure[^>]*url="([^"]+)"', caseSensitive: false).firstMatch(itemXml) ??
          RegExp(r'media:(?:content|thumbnail)[^>]*url="([^"]+)"', caseSensitive: false).firstMatch(itemXml) ??
          RegExp(r'src="([^"]+)"', caseSensitive: false).firstMatch(itemXml);

      if (enclosureMatch != null) {
        imageUrl = enclosureMatch.group(1) ?? '';
      }

      if (imageUrl.isEmpty) {
        imageUrl = _fallbackImages[idCounter % _fallbackImages.length];
      }

      // Date
      final pubDateMatch = RegExp(r'<pubDate>([\s\S]*?)</pubDate>', caseSensitive: false).firstMatch(itemXml);
      final pubDateStr = pubDateMatch?.group(1) ?? '';
      final pubDate = _parseRfc2822Date(pubDateStr) ?? DateTime.now();

      final timeAgoRu = _calculateTimeAgo(pubDate, isEn: false);
      final timeAgoEn = _calculateTimeAgo(pubDate, isEn: true);

      list.add(
        HomeNewsModel(
          id: '${sourceName}_$idCounter',
          title: title,
          source: sourceName,
          timeAgo: timeAgoRu,
          timeAgoEn: timeAgoEn,
          imageUrl: imageUrl,
          url: url,
        ),
      );
      idCounter++;
    }

    return list;
  }

  DateTime? _parseRfc2822Date(String dateStr) {
    try {
      final cleaned = dateStr.replaceAll(RegExp(r'^[A-Za-z]+,\s*'), '').trim();
      final parts = cleaned.split(' ');
      if (parts.length >= 4) {
        final day = int.tryParse(parts[0]);
        final monthStr = parts[1].toLowerCase();
        final year = int.tryParse(parts[2]);
        final timeParts = parts[3].split(':');

        const months = {
          'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
          'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
        };

        final month = months[monthStr] ?? 1;
        if (day != null && year != null && timeParts.length >= 2) {
          final hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1]) ?? 0;
          return DateTime(year, month, day, hour, minute);
        }
      }
    } catch (_) {}
    return DateTime.tryParse(dateStr);
  }

  String _calculateTimeAgo(DateTime date, {required bool isEn}) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.isNegative || diff.inMinutes < 2) {
      return isEn ? 'Just now' : 'Только что';
    } else if (diff.inMinutes < 60) {
      final mins = diff.inMinutes;
      return isEn ? '$mins mins ago' : '$mins мин. назад';
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      return isEn
          ? (hours == 1 ? '1 hour ago' : '$hours hours ago')
          : (hours == 1 ? '1 час назад' : '$hours ч. назад');
    } else {
      final days = diff.inDays;
      return isEn
          ? (days == 1 ? '1 day ago' : '$days days ago')
          : (days == 1 ? '1 день назад' : '$days дн. назад');
    }
  }

  String _cleanHtmlAndEntities(String text) {
    return text
        .replaceAll(RegExp(r'<!\[CDATA\[([\s\S]*?)\]\]>'), r'$1')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#8220;', '"')
        .replaceAll('&#8221;', '"')
        .replaceAll('&#8217;', "'")
        .replaceAll('&#8216;', "'")
        .replaceAll('&#8211;', '–')
        .replaceAll('&#8212;', '—')
        .replaceAll('&#039;', "'")
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
}