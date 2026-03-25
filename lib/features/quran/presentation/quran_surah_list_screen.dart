import 'dart:async';

import 'package:azan_app/core/localization/app_language.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/theme/app_theme.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:azan_app/features/quran/data/models/quran_surah.dart';
import 'package:azan_app/features/quran/data/quran_repository.dart';
import 'package:azan_app/features/quran/presentation/quran_reader_screen.dart';
import 'package:azan_app/features/quran/presentation/quran_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum QuranLibraryMode { translation, arabicOnly, audio }

class QuranSurahListScreen extends StatefulWidget {
  const QuranSurahListScreen({
    super.key,
    this.mode = QuranLibraryMode.translation,
    this.autoFocusSearch = false,
    this.openBookmarksOnStart = false,
  });

  final QuranLibraryMode mode;
  final bool autoFocusSearch;
  final bool openBookmarksOnStart;

  @override
  State<QuranSurahListScreen> createState() => _QuranSurahListScreenState();
}

class _QuranSurahListScreenState extends State<QuranSurahListScreen> {
  final QuranRepository _repository = QuranRepository();
  late Future<List<QuranSurah>> _surahsFuture;
  AppLanguage? _loadedLanguage;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _searchText = '';
  bool _bookmarksShown = false;

  @override
  void initState() {
    super.initState();
    _loadedLanguage = AppLanguage.english;
    _surahsFuture = _repository.loadSurahs(
      translationLanguage: _loadedLanguage!,
    );
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final l10n = context.l10n;
    if (_loadedLanguage != appController.appLanguage) {
      _loadedLanguage = appController.appLanguage;
      _surahsFuture = _repository.loadSurahs(
        translationLanguage: _loadedLanguage!,
      );
    }
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      appBar: AppBar(title: Text(_titleForMode(l10n))),
      body: FutureBuilder<List<QuranSurah>>(
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
          if (widget.openBookmarksOnStart && !_bookmarksShown) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _bookmarksShown = true;
              _showBookmarks(
                parentContext: context,
                surahs: surahs,
                controller: appController,
              );
            });
          }

          final query = _searchText.trim();
          final filteredSurahs = _filterSurahs(surahs, query);
          final ayahResults = _searchAyahs(surahs, query);

          return ListView(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 100 + bottomPadding),
            children: <Widget>[
              _LibraryHeader(mode: widget.mode),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                autofocus: widget.autoFocusSearch,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: l10n.tr('searchSurahAyah'),
                  suffixIcon: _searchText.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              if (query.isEmpty && appController.quranLastRead != null)
                AppSurfaceCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.tertiary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.mode == QuranLibraryMode.audio
                            ? Icons.graphic_eq_rounded
                            : Icons.play_circle_fill_rounded,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    title: Text(l10n.tr('resumeReading')),
                    subtitle: Text(
                      'Surah ${appController.quranLastRead!.surahNumber}, ${l10n.tr('ayah')} ${appController.quranLastRead!.ayahNumber}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      final position = appController.quranLastRead!;
                      final index = (position.surahNumber - 1).clamp(
                        0,
                        surahs.length - 1,
                      );
                      _openReader(
                        context: context,
                        surahs: surahs,
                        index: index,
                        initialAyah: position.ayahNumber,
                      );
                    },
                  ),
                ),
              if (query.isEmpty && appController.quranBookmarks.isNotEmpty)
                AppSurfaceCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.bookmarks_rounded,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    title: Text(l10n.tr('bookmarks')),
                    subtitle: Text(
                      l10n.tr('savedCount', <String, String>{
                        'count': '${appController.quranBookmarks.length}',
                      }),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showBookmarks(
                      parentContext: context,
                      surahs: surahs,
                      controller: appController,
                    ),
                  ),
                ),
              if (query.isNotEmpty && ayahResults.isNotEmpty) ...<Widget>[
                Text(
                  l10n.tr('ayahMatches', <String, String>{
                    'count': '${ayahResults.length}',
                  }),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ...List.generate(ayahResults.length, (index) {
                  final result = ayahResults[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${result.surahNumber}. ${result.surahNameEnglish} - ${l10n.tr('ayah')} ${result.ayahNumber}',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            result.ayahText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontFamily: 'NotoNaskhArabic',
                              fontSize: 21,
                              height: 1.5,
                            ),
                          ),
                          if (_showTranslation &&
                              (result.translationText ?? '').trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                result.translationText!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(height: 1.35),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.tonalIcon(
                              onPressed: () => _openReader(
                                context: context,
                                surahs: surahs,
                                index: result.surahIndex,
                                initialAyah: result.ayahNumber,
                              ),
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: Text(l10n.tr('openAyah')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 6),
                Text(
                  l10n.tr('surahResults'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
              ],
              if (filteredSurahs.isEmpty)
                AppSurfaceCard(
                  child: Text(
                    l10n.tr('noResults'),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...List.generate(filteredSurahs.length, (index) {
                  final surahItem = filteredSurahs[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == filteredSurahs.length - 1 ? 0 : 10,
                    ),
                    child: AppSurfaceCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openReader(
                          context: context,
                          surahs: surahs,
                          index: surahItem.$1,
                          initialAyah: 1,
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.tertiary.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${surahItem.$2.number}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    surahItem.$2.nameEnglish,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${surahItem.$2.ayahCount} ${l10n.tr('ayah')}',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              surahItem.$2.nameArabic,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontFamily: 'NotoNaskhArabic',
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  bool get _showTranslation => widget.mode != QuranLibraryMode.arabicOnly;

  String _titleForMode(AppLocalizations l10n) {
    return switch (widget.mode) {
      QuranLibraryMode.translation => l10n.tr('quranWithTranslation'),
      QuranLibraryMode.arabicOnly => l10n.tr('quranArabicOnly'),
      QuranLibraryMode.audio => l10n.tr('quranAudio'),
    };
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  List<(int, QuranSurah)> _filterSurahs(List<QuranSurah> surahs, String query) {
    if (query.isEmpty) {
      return List<(int, QuranSurah)>.generate(
        surahs.length,
        (index) => (index, surahs[index]),
      );
    }

    final normalized = query.toLowerCase();
    final isArabicQuery = RegExp(r'[\u0600-\u06FF]').hasMatch(query);

    final list = <(int, QuranSurah)>[];
    for (var i = 0; i < surahs.length; i++) {
      final surah = surahs[i];
      final englishMatch = surah.nameEnglish.toLowerCase().contains(normalized);
      final arabicMatch = isArabicQuery && surah.nameArabic.contains(query);
      final numberMatch = surah.number.toString() == query;
      if (englishMatch || arabicMatch || numberMatch) {
        list.add((i, surah));
      }
    }
    return list;
  }

  List<_AyahSearchResult> _searchAyahs(List<QuranSurah> surahs, String query) {
    final isArabicQuery = RegExp(r'[\u0600-\u06FF]').hasMatch(query);
    final normalized = query.toLowerCase();
    final numericQuery = int.tryParse(query);
    final coordinate = RegExp(
      r'^(\d{1,3})\s*[:.-]\s*(\d{1,3})$',
    ).firstMatch(query);
    if (query.isEmpty) return <_AyahSearchResult>[];
    if (query.length < 2 && numericQuery == null && coordinate == null) {
      return <_AyahSearchResult>[];
    }

    if (coordinate != null) {
      final surahNo = int.tryParse(coordinate.group(1)!);
      final ayahNo = int.tryParse(coordinate.group(2)!);
      if (surahNo != null &&
          ayahNo != null &&
          surahNo >= 1 &&
          surahNo <= surahs.length) {
        final surah = surahs[surahNo - 1];
        if (ayahNo >= 1 && ayahNo <= surah.ayahs.length) {
          final ayah = surah.ayahs[ayahNo - 1];
          return <_AyahSearchResult>[
            _AyahSearchResult(
              surahIndex: surahNo - 1,
              surahNumber: surah.number,
              surahNameEnglish: surah.nameEnglish,
              ayahNumber: ayah.number,
              ayahText: ayah.text,
              translationText: ayah.translation,
            ),
          ];
        }
      }
    }

    final results = <_AyahSearchResult>[];
    for (var surahIndex = 0; surahIndex < surahs.length; surahIndex++) {
      final surah = surahs[surahIndex];
      for (final ayah in surah.ayahs) {
        final translation = ayah.translation ?? '';
        final byNumber = numericQuery != null && ayah.number == numericQuery;
        final byKeyword = isArabicQuery
            ? ayah.text.contains(query)
            : ayah.text.toLowerCase().contains(normalized) ||
                  translation.toLowerCase().contains(normalized);

        if (!byNumber && !byKeyword) continue;
        results.add(
          _AyahSearchResult(
            surahIndex: surahIndex,
            surahNumber: surah.number,
            surahNameEnglish: surah.nameEnglish,
            ayahNumber: ayah.number,
            ayahText: ayah.text,
            translationText: translation,
          ),
        );
        if (results.length >= 30) {
          return results;
        }
      }
    }
    return results;
  }

  void _openReader({
    required BuildContext context,
    required List<QuranSurah> surahs,
    required int index,
    required int initialAyah,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuranReaderScreen(
          surahs: surahs,
          initialIndex: index,
          initialAyahNumber: initialAyah,
          initialShowTransliteration: _showTranslation,
          initialShowTranslation: _showTranslation,
          autoPlayOnOpen: widget.mode == QuranLibraryMode.audio,
        ),
      ),
    );
  }

  void _showBookmarks({
    required BuildContext parentContext,
    required List<QuranSurah> surahs,
    required AppController controller,
  }) {
    showModalBottomSheet<void>(
      context: parentContext,
      showDragHandle: true,
      builder: (context) {
        return ListView.builder(
          itemCount: controller.quranBookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = controller.quranBookmarks[index];
            return ListTile(
              leading: const Icon(Icons.bookmark_rounded),
              title: Text(bookmark.surahName),
              subtitle: Text(
                'Surah ${bookmark.surahNumber}, ${context.l10n.tr('ayah')} ${bookmark.ayahNumber}',
              ),
              onTap: () {
                Navigator.of(context).pop();
                final surahIndex = (bookmark.surahNumber - 1).clamp(
                  0,
                  surahs.length - 1,
                );
                _openReader(
                  context: parentContext,
                  surahs: surahs,
                  index: surahIndex,
                  initialAyah: bookmark.ayahNumber,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader({required this.mode});

  final QuranLibraryMode mode;

  @override
  Widget build(BuildContext context) {
    final subtitle = switch (mode) {
      QuranLibraryMode.translation => context.l10n.tr('quranSubtitle'),
      QuranLibraryMode.arabicOnly => context.l10n.tr('quranArabicOnlySubtitle'),
      QuranLibraryMode.audio => context.l10n.tr('quranAudioSubtitle'),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: QuranUiTheme.panelGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeColors.gold.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppThemeColors.gold.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(switch (mode) {
              QuranLibraryMode.translation => Icons.menu_book_rounded,
              QuranLibraryMode.arabicOnly => Icons.translate_rounded,
              QuranLibraryMode.audio => Icons.graphic_eq_rounded,
            }, color: AppThemeColors.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.tr('titleQuran'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AyahSearchResult {
  const _AyahSearchResult({
    required this.surahIndex,
    required this.surahNumber,
    required this.surahNameEnglish,
    required this.ayahNumber,
    required this.ayahText,
    this.translationText,
  });

  final int surahIndex;
  final int surahNumber;
  final String surahNameEnglish;
  final int ayahNumber;
  final String ayahText;
  final String? translationText;
}
