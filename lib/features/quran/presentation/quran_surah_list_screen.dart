import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/widgets/glass_card.dart';
import 'package:azan_app/features/azkar/data/models/saved_azkar_item.dart';
import 'package:azan_app/features/daily/data/models/saved_daily_item.dart';
import 'package:azan_app/features/quran/data/models/quran_ayah.dart';
import 'package:azan_app/features/quran/data/models/quran_bookmark.dart';
import 'package:azan_app/features/quran/data/models/quran_read_position.dart';
import 'package:azan_app/features/quran/data/models/quran_surah.dart';
import 'package:azan_app/features/quran/data/quran_repository.dart';
import 'package:azan_app/features/quran/presentation/quran_reader_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuranSurahListScreen extends StatefulWidget {
  const QuranSurahListScreen({super.key});

  @override
  State<QuranSurahListScreen> createState() => _QuranSurahListScreenState();
}

class _QuranSurahListScreenState extends State<QuranSurahListScreen> {
  final QuranRepository _repository = QuranRepository();
  late Future<List<QuranSurah>> _surahsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _surahsFuture = _repository.loadSurahs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                'Failed to load Quran data. Please restart the app.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          );
        }

        final surahs = snapshot.data!;

        return DefaultTabController(
          length: 2,
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: TabBar(
                  tabs: <Widget>[
                    Tab(text: 'Surahs'),
                    Tab(text: 'Saved'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    _buildSurahTab(context: context, surahs: surahs),
                    _SavedContentTab(
                      onOpenReader:
                          ({
                            required int surahNumber,
                            required int initialAyahNumber,
                          }) {
                            _openReader(
                              surahs: surahs,
                              surahNumber: surahNumber,
                              initialAyahNumber: initialAyahNumber,
                            );
                          },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSurahTab({
    required BuildContext context,
    required List<QuranSurah> surahs,
  }) {
    final lastRead = context.select<AppController, QuranReadPosition?>(
      (c) => c.quranLastRead,
    );

    final filteredSurahs = surahs
        .where((surah) {
          if (_search.trim().isEmpty) return true;
          final query = _search.toLowerCase();
          return surah.nameEnglish.toLowerCase().contains(query) ||
              surah.nameArabic.contains(_search) ||
              surah.number.toString() == query;
        })
        .toList(growable: false);

    final ayahMatches = _ayahMatches(surahs: surahs, query: _search);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search Surah or Ayah text',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: (value) => setState(() => _search = value),
        ),
        const SizedBox(height: 10),
        if (lastRead != null)
          _ResumeReadingCard(
            surahName: lastRead.surahNameEnglish,
            ayahNumber: lastRead.ayahNumber,
            onTap: () => _openReader(
              surahs: surahs,
              surahNumber: lastRead.surahNumber,
              initialAyahNumber: lastRead.ayahNumber,
            ),
          ),
        if (lastRead != null) const SizedBox(height: 10),
        ...List<Widget>.generate(filteredSurahs.length, (index) {
          final surah = filteredSurahs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              borderRadius: 12,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text('${surah.number}')),
                title: Text(surah.nameEnglish),
                subtitle: Text('${surah.ayahCount} ayah(s)'),
                trailing: Text(
                  surah.nameArabic,
                  textDirection: TextDirection.rtl,
                ),
                onTap: () => _openReader(
                  surahs: surahs,
                  surahNumber: surah.number,
                  initialAyahNumber: 1,
                ),
              ),
            ),
          );
        }),
        if (_search.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
          Text('Ayah Matches', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (ayahMatches.isEmpty)
            const Text('No ayah text match found.')
          else
            ...ayahMatches.map((match) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  borderRadius: 12,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${match.surah.number}. ${match.surah.nameEnglish} - Ayah ${match.ayah.number}',
                    ),
                    subtitle: Text(
                      match.ayah.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                    ),
                    onTap: () => _openReader(
                      surahs: surahs,
                      surahNumber: match.surah.number,
                      initialAyahNumber: match.ayah.number,
                    ),
                  ),
                ),
              );
            }),
        ],
      ],
    );
  }

  List<_AyahSearchMatch> _ayahMatches({
    required List<QuranSurah> surahs,
    required String query,
  }) {
    if (query.trim().isEmpty) return const <_AyahSearchMatch>[];
    final normalized = query.toLowerCase();
    final matches = <_AyahSearchMatch>[];

    for (final surah in surahs) {
      for (final ayah in surah.ayahs) {
        if (ayah.text.contains(query) ||
            ayah.text.toLowerCase().contains(normalized)) {
          matches.add(_AyahSearchMatch(surah: surah, ayah: ayah));
        }
        if (matches.length >= 80) {
          return matches;
        }
      }
    }
    return matches;
  }

  Future<void> _openReader({
    required List<QuranSurah> surahs,
    required int surahNumber,
    required int initialAyahNumber,
  }) async {
    final index = surahs.indexWhere((surah) => surah.number == surahNumber);
    if (index < 0) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuranReaderScreen(
          surahs: surahs,
          initialIndex: index,
          initialAyahNumber: initialAyahNumber,
        ),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }
}

class _SavedContentTab extends StatelessWidget {
  const _SavedContentTab({required this.onOpenReader});

  final void Function({
    required int surahNumber,
    required int initialAyahNumber,
  })
  onOpenReader;

  @override
  Widget build(BuildContext context) {
    final bookmarks = context.select<AppController, List<QuranBookmark>>(
      (controller) => controller.quranBookmarks,
    );
    final dailyFavorites = context.select<AppController, List<SavedDailyItem>>(
      (controller) => controller.dailyFavorites,
    );
    final azkarFavorites = context.select<AppController, List<SavedAzkarItem>>(
      (controller) => controller.azkarFavorites,
    );

    final hasAnySaved =
        bookmarks.isNotEmpty ||
        dailyFavorites.isNotEmpty ||
        azkarFavorites.isNotEmpty;

    if (!hasAnySaved) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No saved items yet. Use the heart/bookmark icons to save.',
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        if (bookmarks.isNotEmpty)
          _SavedSection(
            title: 'Saved Ayah',
            children: bookmarks
                .map(
                  (bookmark) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(bookmark.surahNameEnglish),
                    subtitle: Text('Ayah ${bookmark.ayahNumber}'),
                    trailing: Text(
                      bookmark.surahNameArabic,
                      textDirection: TextDirection.rtl,
                    ),
                    onTap: () => onOpenReader(
                      surahNumber: bookmark.surahNumber,
                      initialAyahNumber: bookmark.ayahNumber,
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        if (dailyFavorites.isNotEmpty)
          _SavedSection(
            title: 'Saved Daily Content',
            children: dailyFavorites
                .map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.title),
                    subtitle: Text(item.reference),
                    trailing: Text(item.type.toUpperCase()),
                  ),
                )
                .toList(growable: false),
          ),
        if (azkarFavorites.isNotEmpty)
          _SavedSection(
            title: 'Saved Azkar',
            children: azkarFavorites
                .map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item.text,
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('${item.category} • x${item.repeat}'),
                  ),
                )
                .toList(growable: false),
          ),
      ],
    );
  }
}

class _SavedSection extends StatelessWidget {
  const _SavedSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        borderRadius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ResumeReadingCard extends StatelessWidget {
  const _ResumeReadingCard({
    required this.surahName,
    required this.ayahNumber,
    required this.onTap,
  });

  final String surahName;
  final int ayahNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 12,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.play_circle_fill_rounded),
        title: const Text('Resume Reading'),
        subtitle: Text('$surahName • Ayah $ayahNumber'),
        onTap: onTap,
      ),
    );
  }
}

class _AyahSearchMatch {
  const _AyahSearchMatch({required this.surah, required this.ayah});

  final QuranSurah surah;
  final QuranAyah ayah;
}
