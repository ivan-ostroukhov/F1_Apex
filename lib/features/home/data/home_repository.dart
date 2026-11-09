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
      final newsList = <HomeNewsModel>[];

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
          newsList.addAll(parsed);
        }
      } catch (_) {}

      // Fallback feed if primary was empty
      if (newsList.isEmpty) {
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
            newsList.addAll(parsed);
          }
        } catch (_) {}
      }

      if (newsList.isNotEmpty) {
        final uniqueNews = <String, HomeNewsModel>{};
        for (final item in newsList) {
          if (!uniqueNews.containsKey(item.url) && item.url.startsWith('http')) {
            uniqueNews[item.url] = item;
          }
        }
        final result = uniqueNews.values.take(12).toList();

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

    return isEnglish ? _fallbackNewsEn : _fallbackNewsRu;
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

  static const List<HomeNewsModel> _fallbackNewsRu = [
    HomeNewsModel(
      id: '1',
      title: 'Макс Ферстаппен подвел итоги прошедшей гонки и прокомментировал обгоны',
      source: 'F1News.ru',
      timeAgo: '15 минут назад',
      timeAgoEn: '15 mins ago',
      imageUrl: 'https://c.f1news.ru/userfiles/max_verstappen/192469.jpg',
      url: 'https://www.f1news.ru/news/f1-192469.html',
    ),
    HomeNewsModel(
      id: '2',
      title: 'Шарль Леклер оценил работу новинок и прогресс Ferrari',
      source: 'F1News.ru',
      timeAgo: '45 минут назад',
      timeAgoEn: '45 mins ago',
      imageUrl: 'https://c.f1news.ru/userfiles/ferrari/192463.jpg',
      url: 'https://www.f1news.ru/news/f1-192463.html',
    ),
  ];

  static const List<HomeNewsModel> _fallbackNewsEn = [
    HomeNewsModel(
      id: '1',
      title: 'Aston Martin told Alonso he was quicker than the Mercedes at end of Brazilian GP',
      source: 'RaceFans',
      timeAgo: '15 минут назад',
      timeAgoEn: '15 mins ago',
      imageUrl: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?q=80&w=800&auto=format&fit=crop',
      url: 'https://www.racefans.net/',
    ),
    HomeNewsModel(
      id: '2',
      title: 'Ferrari introduces major floor & sidepod upgrades for upcoming Grand Prix',
      source: 'RaceFans',
      timeAgo: '45 минут назад',
      timeAgoEn: '45 mins ago',
      imageUrl: 'https://images.unsplash.com/photo-1533106497176-45ae19e68ba2?q=80&w=800&auto=format&fit=crop',
      url: 'https://www.racefans.net/',
    ),
  ];
}