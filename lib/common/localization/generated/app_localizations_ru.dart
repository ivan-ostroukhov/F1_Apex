// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Apex';

  @override
  String get searchPlaceholder => 'Поиск пилота или команды...';

  @override
  String get points => 'Очков';

  @override
  String get teammate => 'Напарник';

  @override
  String get viewTeammate => 'Перейти к напарнику';

  @override
  String get notFoundTitle => 'Пилоты не найдены';

  @override
  String get notFoundSubtitle => 'Попробуйте изменить запрос';

  @override
  String get errorLoading => 'Ошибка загрузки данных из сети';

  @override
  String get retry => 'Повторить';

  @override
  String get driversTab => 'Пилоты';

  @override
  String get homeTab => 'Главная';

  @override
  String get constructorsTab => 'Команды';

  @override
  String get constructorsTable => 'Таблица команд';

  @override
  String get driversTable => 'Таблица пилотов';

  @override
  String get constructorsComingSoon => 'Кубок конструкторов скоро появится';

  @override
  String get scheduleTab => 'Календарь';

  @override
  String get roundPrefix => 'Этап';

  @override
  String get raceCompleted => 'Завершен';

  @override
  String get raceUpcoming => 'Предстоит';

  @override
  String get driverPositionShort => 'поз';

  @override
  String get driverPointsShort => 'блв';

  @override
  String get winsLabel => 'Победы';

  @override
  String get podiumsLabel => 'Подиумы';

  @override
  String get polesLabel => 'Поулы';

  @override
  String get dnfsLabel => 'DNFs';

  @override
  String seasonPrefix(String year) {
    return 'Сезон $year';
  }

  @override
  String get selectSeason => 'Выберите сезон';

  @override
  String sinceDebut(String year) {
    return 'С дебюта ($year)';
  }

  @override
  String get driverCodeLabel => 'Код гонщика';

  @override
  String get teamLabel => 'Команда';

  @override
  String get firstRaceLabel => 'Первая гонка';

  @override
  String get firstWinLabel => 'Первая победа';

  @override
  String get worldChampionshipsLabel => 'Мировой чемпионат';

  @override
  String get dateOfBirthLabel => 'Дата рождения';

  @override
  String get countryLabel => 'Страна';

  @override
  String get chassisLabel => 'Шасси';

  @override
  String get engineLabel => 'Двигатель';

  @override
  String get teamPrincipalLabel => 'Руководитель команды';

  @override
  String get constructorsChampionshipsLabel => 'Чемпионат конструкторов';

  @override
  String get driversChampionshipsLabel => 'Чемпионат гонщиков';

  @override
  String get baseLabel => 'База';

  @override
  String get headToHeadSubtitle =>
      'Выберите пилот для сравнения статистики сезона или карьеры для более интересного сравнения.';

  @override
  String get pastRaces => 'Прошедшие гонки';

  @override
  String get upcomingRaces => 'Предстоящие гонки';

  @override
  String get raceCountdownPrefix => 'Гонка начинается через';

  @override
  String get daysShort => 'Дни';

  @override
  String get hoursShort => 'Часы';

  @override
  String get minutesShort => 'Минуты';

  @override
  String get scheduleButton => 'Расписание';

  @override
  String get resultsButton => 'Результаты';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get generalSection => 'Общее';

  @override
  String get favoritesSection => 'Избранное';

  @override
  String get notifications => 'Уведомления';

  @override
  String get appTheme => 'Тема приложения';

  @override
  String get unitSystem => 'Система единиц';

  @override
  String get timeFormat24 => '24 Часа Время';

  @override
  String get detailedResults => 'Подробные результаты';

  @override
  String get language => 'Язык';

  @override
  String get selectDriver => 'Select Driver';

  @override
  String get selectTeam => 'Выбрать команду';

  @override
  String get searchDriver => 'Поиск гонщика';

  @override
  String get searchTeam => 'Поисковая группа';

  @override
  String get cancel => 'Отмена';

  @override
  String get themeSystem => 'Система';

  @override
  String get themeDark => 'Темная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get metricUnits => 'Метрика';

  @override
  String get grandPrixCompleted => 'Гран-при завершено';

  @override
  String get distanceCovered => 'Пройдено';

  @override
  String get lapsCompleted => 'Пройдено кругов';

  @override
  String get breakingNews => 'Срочные новости';

  @override
  String get viewAllNews => 'Посмотреть все >';

  @override
  String get mexicoGrandPrixTitle => 'R19 Гран-при Мехико';

  @override
  String get lapsCount => 'Количество кругов';

  @override
  String get maxSpeed => 'Максимальная скорость';

  @override
  String get turnsCount => 'Количество поворотов';

  @override
  String get elevationChange => 'Перепад высот';

  @override
  String get mostSuccessfulConstructor => 'Самая успешная команда-конструктор';

  @override
  String recordWinsFormat(String count) {
    return '$count ПОБЕДЫ';
  }

  @override
  String get mostSuccessfulDrivers => 'Самые успешные пилоты';

  @override
  String get raceLapRecord => 'Рекорд круга гонки';

  @override
  String get fastestPitStop => 'Самый быстрый пит-стоп сезона';

  @override
  String get fastestLapSeason => 'Самый быстрый круг сезона';

  @override
  String get mexicoDateRange => '31 Окт. - 02 Нояб.';

  @override
  String get mexicoSessionDate => '31 СБ';

  @override
  String get mexicoSessionTitle => 'Practice 1';

  @override
  String get noPointsData => 'Нет данных по очкам текущего сезона';

  @override
  String roundFormat(String number) {
    return 'Раунд $number';
  }

  @override
  String get kmUnit => 'КМ';

  @override
  String get kmhUnit => 'км/ч';

  @override
  String get mUnit => 'м';

  @override
  String get topSpeed => 'Максимальная скорость';

  @override
  String get turns => 'Повороты';

  @override
  String get elevationChangeLabel => 'Перепад высот';

  @override
  String get lapsCountLabel => 'Количество кругов';

  @override
  String get weekendSessions => 'Выходные гонки';
}
