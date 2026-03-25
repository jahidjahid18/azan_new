import 'package:flutter/material.dart';

enum AppLanguage { english, arabic, malay, indonesian, urdu, hindi, turkish }

extension AppLanguageX on AppLanguage {
  String get code => switch (this) {
    AppLanguage.english => 'en',
    AppLanguage.arabic => 'ar',
    AppLanguage.malay => 'ms',
    AppLanguage.indonesian => 'id',
    AppLanguage.urdu => 'ur',
    AppLanguage.hindi => 'hi',
    AppLanguage.turkish => 'tr',
  };

  Locale get locale => Locale(code);

  String get nativeName => switch (this) {
    AppLanguage.english => 'English',
    AppLanguage.arabic => 'العربية',
    AppLanguage.malay => 'Bahasa Melayu',
    AppLanguage.indonesian => 'Bahasa Indonesia',
    AppLanguage.urdu => 'اردو',
    AppLanguage.hindi => 'हिन्दी',
    AppLanguage.turkish => 'Türkçe',
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
