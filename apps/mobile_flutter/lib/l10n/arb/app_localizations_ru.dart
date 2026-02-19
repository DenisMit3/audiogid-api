// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Аудиогид';

  @override
  String get loading => 'Загрузка...';

  @override
  String get error => 'Ошибка';

  @override
  String get retry => 'Повторить';

  @override
  String get noInternet => 'Нет подключения к интернету';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get settings => 'Настройки';

  @override
  String get routes => 'Маршруты';

  @override
  String get catalog => 'Каталог';

  @override
  String get map => 'Карта';

  @override
  String get favorites => 'Избранное';

  @override
  String get share => 'Поделиться';
}
