import 'dart:ui';

class L10n {
  static final all = [
    const Locale('en', 'US'),
    const Locale('ko', 'KR'),
    const Locale('fr', 'FR'),
    const Locale('ar', 'AR'),
    const Locale('de', 'DE'),
    const Locale('th', 'TH'),
  ];

  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ko':
        return '한국어';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'ar':
        return 'عربي';
      case 'th':
        return 'ภาษาไทย';
      default:
        return '한국어';
    }
  }
}
