import 'package:azan_app/core/localization/app_language.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/features/quran/data/models/quran_ayah.dart';
import 'package:azan_app/features/quran/data/models/quran_reader_preferences.dart';
import 'package:azan_app/features/quran/data/models/quran_surah.dart';
import 'package:azan_app/features/quran/data/quran_repository.dart';
import 'package:azan_app/features/quran/presentation/quran_reader_screen.dart';
import 'package:azan_app/features/quran/presentation/quran_surah_list_screen.dart';
import 'package:azan_app/features/quran/presentation/quran_theme.dart';
import 'package:azan_app/features/quran/presentation/widgets/quran_option_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuranDashboardScreen extends StatefulWidget {
  const QuranDashboardScreen({super.key});

  @override
  State<QuranDashboardScreen> createState() => _QuranDashboardScreenState();
}

class _QuranDashboardScreenState extends State<QuranDashboardScreen> {
  final QuranRepository _repository = QuranRepository();
  late Future<List<QuranSurah>> _surahsFuture;
  AppLanguage? _loadedLanguage;

  @override
  void initState() {
    super.initState();
    _loadedLanguage = AppLanguage.english;
    _surahsFuture = _repository.loadSurahs(
      translationLanguage: _loadedLanguage!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final language = controller.appLanguage;
    if (_loadedLanguage != language) {
      _loadedLanguage = language;
      _surahsFuture = _repository.loadSurahs(translationLanguage: language);
    }

    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final l10n = context.l10n;

    return FutureBuilder<List<QuranSurah>>(
      future: _surahsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                l10n.tr('failedLoadQuran'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          );
        }

        final surahs = snapshot.data!;
        final todayAyah = _dailyAyah(surahs);

        return ListView(
          padding: EdgeInsets.fromLTRB(14, 14, 14, 24 + bottomPadding),
          children: <Widget>[
            _HeaderCard(
              language: language,
              onChangeLanguage: _openLanguagePicker,
            ),
            const SizedBox(height: 12),
            _ContinueReadingCard(
              surahs: surahs,
              onResume: (surahIndex, ayahNumber) => _openReader(
                context: context,
                surahs: surahs,
                index: surahIndex,
                initialAyah: ayahNumber,
                withTransliteration: true,
                withTranslation: true,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.tr('quranMainOptions'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.24,
              children: <Widget>[
                _DashboardIconCard(
                  title: l10n.tr('quranWithTranslation'),
                  icon: Icons.menu_book_rounded,
                  onTap: () => _openLibrary(
                    context: context,
                    mode: QuranLibraryMode.translation,
                  ),
                ),
                _DashboardIconCard(
                  title: l10n.tr('quranArabicOnly'),
                  icon: Icons.translate_rounded,
                  onTap: () => _openLibrary(
                    context: context,
                    mode: QuranLibraryMode.arabicOnly,
                  ),
                ),
                _DashboardIconCard(
                  title: l10n.tr('quranAudio'),
                  icon: Icons.graphic_eq_rounded,
                  onTap: () => _openLibrary(
                    context: context,
                    mode: QuranLibraryMode.audio,
                  ),
                ),
                _DashboardIconCard(
                  title: l10n.tr('bookmarks'),
                  icon: Icons.bookmarks_rounded,
                  onTap: () => _openLibrary(
                    context: context,
                    mode: QuranLibraryMode.translation,
                    openBookmarksOnStart: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.tr('quranSecondaryOptions'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            QuranOptionCard(
              title: l10n.tr('dailyAyah'),
              subtitle: l10n.tr('quranDailyAyahSubtitle'),
              icon: Icons.auto_awesome_rounded,
              onTap: () => _showDailyAyah(context, todayAyah.$1, todayAyah.$2),
            ),
            const SizedBox(height: 10),
            QuranOptionCard(
              title: l10n.tr('search'),
              subtitle: l10n.tr('quranSearchSubtitle'),
              icon: Icons.search_rounded,
              onTap: () => _openLibrary(
                context: context,
                mode: QuranLibraryMode.translation,
                autoFocusSearch: true,
              ),
            ),
            const SizedBox(height: 10),
            QuranOptionCard(
              title: l10n.tr('readerSettings'),
              subtitle: l10n.tr('quranReadingSettingsSubtitle'),
              icon: Icons.tune_rounded,
              onTap: _openReaderSettings,
            ),
          ],
        );
      },
    );
  }

  (QuranSurah, QuranAyah) _dailyAyah(List<QuranSurah> surahs) {
    final daySeed = DateTime.now().difference(DateTime(2020, 1, 1)).inDays;
    final surahIndex = daySeed % surahs.length;
    final surah = surahs[surahIndex];
    final ayahIndex = daySeed % surah.ayahs.length;
    return (surah, surah.ayahs[ayahIndex]);
  }

  void _showDailyAyah(BuildContext context, QuranSurah surah, QuranAyah ayah) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16 + MediaQuery.of(context).viewPadding.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: QuranUiTheme.softBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    '${surah.nameEnglish} - ${context.l10n.tr('ayah')} ${ayah.number}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ayah.text,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 31,
                      height: 1.7,
                    ),
                  ),
                  if ((ayah.translation ?? '').trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        ayah.translation!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openReaderSettings() {
    final controller = context.read<AppController>();
    final initial = controller.quranReaderPreferences;
    var current = initial;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16 + MediaQuery.of(context).viewPadding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    context.l10n.tr('readerSettings'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.tr('showTransliteration')),
                    value: current.showTransliteration,
                    onChanged: (value) {
                      current = current.copyWith(showTransliteration: value);
                      setBottomState(() {});
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.tr('showTranslation')),
                    value: current.showTranslation,
                    onChanged: (value) {
                      current = current.copyWith(showTranslation: value);
                      setBottomState(() {});
                    },
                  ),
                  Text(
                    context.l10n.tr('arabicFontSize', <String, String>{
                      'size': current.arabicFontSize.toStringAsFixed(0),
                    }),
                  ),
                  Slider(
                    min: 24,
                    max: 42,
                    divisions: 18,
                    value: current.arabicFontSize,
                    onChanged: (value) {
                      current = current.copyWith(arabicFontSize: value);
                      setBottomState(() {});
                    },
                  ),
                  Text(
                    context.l10n.tr('translationFontSize', <String, String>{
                      'size': current.translationFontSize.toStringAsFixed(0),
                    }),
                  ),
                  Slider(
                    min: 12,
                    max: 24,
                    divisions: 12,
                    value: current.translationFontSize,
                    onChanged: (value) {
                      current = current.copyWith(translationFontSize: value);
                      setBottomState(() {});
                    },
                  ),
                  FilledButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final next = QuranReaderPreferences(
                        arabicFontSize: current.arabicFontSize,
                        translationFontSize: current.translationFontSize,
                        lineHeight: current.lineHeight,
                        showTransliteration: current.showTransliteration,
                        showTranslation: current.showTranslation,
                        fontPreset: current.fontPreset,
                      );
                      await controller.setQuranReaderPreferences(next);
                      if (!mounted) return;
                      navigator.pop();
                    },
                    child: Text(context.l10n.tr('done')),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openReader({
    required BuildContext context,
    required List<QuranSurah> surahs,
    required int index,
    required int initialAyah,
    required bool withTransliteration,
    required bool withTranslation,
    bool autoPlay = false,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuranReaderScreen(
          surahs: surahs,
          initialIndex: index,
          initialAyahNumber: initialAyah,
          initialShowTransliteration: withTransliteration,
          initialShowTranslation: withTranslation,
          autoPlayOnOpen: autoPlay,
        ),
      ),
    );
  }

  void _openLibrary({
    required BuildContext context,
    required QuranLibraryMode mode,
    bool autoFocusSearch = false,
    bool openBookmarksOnStart = false,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuranSurahListScreen(
          mode: mode,
          autoFocusSearch: autoFocusSearch,
          openBookmarksOnStart: openBookmarksOnStart,
        ),
      ),
    );
  }

  void _openLanguagePicker() {
    final controller = context.read<AppController>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: appLanguagesAlphabetical
              .map(
                (language) => ListTile(
                  leading: Icon(
                    controller.appLanguage == language
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                  ),
                  title: Row(
                    children: <Widget>[
                      Expanded(child: Text(language.englishName)),
                      const SizedBox(width: 12),
                      Text(language.nativeName),
                    ],
                  ),
                  onTap: () async {
                    final navigator = Navigator.of(context);
                    await controller.setAppLanguage(language);
                    if (!mounted) return;
                    navigator.pop();
                  },
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.language, required this.onChangeLanguage});

  final AppLanguage language;
  final VoidCallback onChangeLanguage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: QuranUiTheme.heroGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: QuranUiTheme.accentDark.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.tr('titleQuran'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.tr('quranSubtitle'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  'Translation: ${language.nativeName}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onChangeLanguage,
            icon: const Icon(Icons.language_rounded, color: Colors.white),
            tooltip: context.l10n.tr('appLanguage'),
          ),
        ],
      ),
    );
  }
}

class _ContinueReadingCard extends StatefulWidget {
  const _ContinueReadingCard({required this.surahs, required this.onResume});

  final List<QuranSurah> surahs;
  final void Function(int surahIndex, int ayahNumber) onResume;

  @override
  State<_ContinueReadingCard> createState() => _ContinueReadingCardState();
}

class _ContinueReadingCardState extends State<_ContinueReadingCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final lastRead = controller.quranLastRead;
    if (lastRead == null) {
      return const SizedBox.shrink();
    }

    final surahIndex = (lastRead.surahNumber - 1).clamp(
      0,
      widget.surahs.length - 1,
    );
    final surah = widget.surahs[surahIndex];

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      scale: _pressed ? 0.985 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => widget.onResume(surahIndex, lastRead.ayahNumber),
          onHighlightChanged: (value) => setState(() => _pressed = value),
          child: Ink(
            decoration: BoxDecoration(
              gradient: QuranUiTheme.panelGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                const Icon(Icons.play_circle_fill_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        context.l10n.tr('resumeReading'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${surah.nameEnglish} - ${context.l10n.tr('ayah')} ${lastRead.ayahNumber}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardIconCard extends StatefulWidget {
  const _DashboardIconCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_DashboardIconCard> createState() => _DashboardIconCardState();
}

class _DashboardIconCardState extends State<_DashboardIconCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      scale: _pressed ? 0.985 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onTap,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Theme.of(context).cardTheme.color ?? Colors.white,
                  scheme.secondary.withValues(alpha: 0.07),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.35),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.secondary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: scheme.secondary),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
