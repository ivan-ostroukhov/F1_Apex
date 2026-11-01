import '../domain/home_news_model.dart';

class HomeRepository {
  Future<List<HomeNewsModel>> getLatestNews() async {
    return const [
      HomeNewsModel(
        id: '1',
        title: 'Honda outlines two-step 2027 engine upgrade plan for Aston Martin',
        source: 'Gpfans.com',
        timeAgo: '34 минуты назад',
        timeAgoEn: '34 mins ago',
        imageUrl: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?q=80&w=800&auto=format&fit=crop',
        url: 'https://www.gpfans.com/en/f1-news/',
      ),
      HomeNewsModel(
        id: '2',
        title: 'Ferrari introduces major floor & sidepod upgrades for upcoming Grand Prix',
        source: 'Motorsport.com',
        timeAgo: '1 час назад',
        timeAgoEn: '1 hour ago',
        imageUrl: 'https://images.unsplash.com/photo-1533106497176-45ae19e68ba2?q=80&w=800&auto=format&fit=crop',
        url: 'https://www.motorsport.com/f1/news/',
      ),
      HomeNewsModel(
        id: '3',
        title: 'Norris vs Verstappen: Championship title fight intensifies as season progresses',
        source: 'Formula1.com',
        timeAgo: '3 часа назад',
        timeAgoEn: '3 hours ago',
        imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?q=80&w=800&auto=format&fit=crop',
        url: 'https://www.formula1.com/en/latest/all.html',
      ),
      HomeNewsModel(
        id: '4',
        title: 'McLaren reveals striking special livery for Mexico & Brazil Grand Prix',
        source: 'Autosport.com',
        timeAgo: '5 часов назад',
        timeAgoEn: '5 hours ago',
        imageUrl: 'https://images.unsplash.com/photo-1511919884226-fd3cad34687c?q=80&w=800&auto=format&fit=crop',
        url: 'https://www.autosport.com/f1/news/',
      ),
      HomeNewsModel(
        id: '5',
        title: 'Hamilton reflects on Mercedes progress ahead of Ferrari transition',
        source: 'RaceFans.net',
        timeAgo: '12 часов назад',
        timeAgoEn: '12 hours ago',
        imageUrl: 'https://images.unsplash.com/photo-1542282088-72c9c27ed0cd?q=80&w=800&auto=format&fit=crop',
        url: 'https://www.racefans.net/category/f1-news/',
      ),
    ];
  }
}