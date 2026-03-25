import 'package:flutter/material.dart';

enum AppLanguage {
  english,
  arabic,
  malay,
  indonesian,
  urdu,
  hindi,
  turkish,
  bengali,
  persian,
  french,
  german,
  spanish,
  russian,
  italian,
  portuguese,
  dutch,
  chinese,
  japanese,
  korean,
}

extension AppLanguageX on AppLanguage {
  String get code => switch (this) {
    AppLanguage.english => 'en',
    AppLanguage.arabic => 'ar',
    AppLanguage.malay => 'ms',
    AppLanguage.indonesian => 'id',
    AppLanguage.urdu => 'ur',
    AppLanguage.hindi => 'hi',
    AppLanguage.turkish => 'tr',
    AppLanguage.bengali => 'bn',
    AppLanguage.persian => 'fa',
    AppLanguage.french => 'fr',
    AppLanguage.german => 'de',
    AppLanguage.spanish => 'es',
    AppLanguage.russian => 'ru',
    AppLanguage.italian => 'it',
    AppLanguage.portuguese => 'pt',
    AppLanguage.dutch => 'nl',
    AppLanguage.chinese => 'zh',
    AppLanguage.japanese => 'ja',
    AppLanguage.korean => 'ko',
  };

  Locale get locale => Locale(code);

  String get englishName => switch (this) {
    AppLanguage.english => 'English',
    AppLanguage.arabic => 'Arabic',
    AppLanguage.malay => 'Malay',
    AppLanguage.indonesian => 'Indonesian',
    AppLanguage.urdu => 'Urdu',
    AppLanguage.hindi => 'Hindi',
    AppLanguage.turkish => 'Turkish',
    AppLanguage.bengali => 'Bengali',
    AppLanguage.persian => 'Persian',
    AppLanguage.french => 'French',
    AppLanguage.german => 'German',
    AppLanguage.spanish => 'Spanish',
    AppLanguage.russian => 'Russian',
    AppLanguage.italian => 'Italian',
    AppLanguage.portuguese => 'Portuguese',
    AppLanguage.dutch => 'Dutch',
    AppLanguage.chinese => 'Chinese',
    AppLanguage.japanese => 'Japanese',
    AppLanguage.korean => 'Korean',
  };

  String get nativeName => switch (this) {
    AppLanguage.english => 'English',
    AppLanguage.arabic => 'العربية',
    AppLanguage.malay => 'Bahasa Melayu',
    AppLanguage.indonesian => 'Bahasa Indonesia',
    AppLanguage.urdu => 'اردو',
    AppLanguage.hindi => 'हिन्दी',
    AppLanguage.turkish => 'Türkçe',
    AppLanguage.bengali => 'বাংলা',
    AppLanguage.persian => 'فارسی',
    AppLanguage.french => 'Français',
    AppLanguage.german => 'Deutsch',
    AppLanguage.spanish => 'Español',
    AppLanguage.russian => 'Русский',
    AppLanguage.italian => 'Italiano',
    AppLanguage.portuguese => 'Português',
    AppLanguage.dutch => 'Nederlands',
    AppLanguage.chinese => '中文',
    AppLanguage.japanese => '日本語',
    AppLanguage.korean => '한국어',
  };

  String get translationAssetPath =>
      'assets/data/quran_translations/$code.json';

  static AppLanguage fromCode(String? value) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == value,
      orElse: () => AppLanguage.english,
    );
  }
}
