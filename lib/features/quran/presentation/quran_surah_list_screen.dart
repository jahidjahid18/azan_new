import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/features/quran/data/models/quran_bookmark.dart';
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

  @override
  void initState() {
    super.initState();
    _surahsFuture = _repository.loadSurahs();
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

        final controller = context.read<AppController>();
        final surahs = snapshot.data!;
        final lastRead = controller.quranLastRead;
        final bookmarks = controller.quranBookmarks;

        return ListView(
          padding: const EdgeInsets.all(12),
          children: <Widget>[
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
            if (lastRead != null) const SizedBox(height: 8),
            if (bookmarks.isNotEmpty)
              _BookmarksCard(
                count: bookmarks.length,
                onView: () => _showBookmarks(
                  context: context,
                  surahs: surahs,
                  bookmarks: bookmarks,
                ),
              ),
            if (bookmarks.isNotEmpty) const SizedBox(height: 10),
            ...List<Widget>.generate(surahs.length, (index) {
              final surah = surahs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
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
          ],
        );
      },
    );
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
    setState(() {
      // Re-read bookmarks and last-read values from AppController.
    });
  }

  void _showBookmarks({
    required BuildContext context,
    required List<QuranSurah> surahs,
    required List<QuranBookmark> bookmarks,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: bookmarks.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final bookmark = bookmarks[index];
            return ListTile(
              title: Text(bookmark.surahNameEnglish),
              subtitle: Text('Ayah ${bookmark.ayahNumber}'),
              trailing: Text(
                bookmark.surahNameArabic,
                textDirection: TextDirection.rtl,
              ),
              onTap: () {
                Navigator.of(context).pop();
                _openReader(
                  surahs: surahs,
                  surahNumber: bookmark.surahNumber,
                  initialAyahNumber: bookmark.ayahNumber,
                );
              },
            );
          },
        );
      },
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
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.play_circle_fill_rounded),
        title: const Text('Resume Reading'),
        subtitle: Text('$surahName • Ayah $ayahNumber'),
        onTap: onTap,
      ),
    );
  }
}

class _BookmarksCard extends StatelessWidget {
  const _BookmarksCard({required this.count, required this.onView});

  final int count;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.bookmark_rounded),
        title: const Text('Bookmarks'),
        subtitle: Text('$count saved ayah(s)'),
        trailing: TextButton(onPressed: onView, child: const Text('View')),
      ),
    );
  }
}
