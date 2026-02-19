// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Audioguide';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get settings => 'Settings';

  @override
  String get routes => 'Routes';

  @override
  String get catalog => 'Catalog';

  @override
  String get map => 'Map';

  @override
  String get favorites => 'Favorites';

  @override
  String get share => 'Share';
}
