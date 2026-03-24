import 'dart:async';

import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/features/audio/models/quran_reciter.dart';
import 'package:azan_app/features/audio/services/quran_audio_service.dart';
import 'package:azan_app/features/audio/widgets/quran_player_bar.dart';
import 'package:azan_app/features/quran/data/models/quran_surah.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuranReaderScreen extends StatefulWidget {
  const QuranReaderScreen({
    super.key,
    required this.surahs,
    required this.initialIndex,
    this.initialAyahNumber = 1,
  });

  final List<QuranSurah> surahs;
  final int initialIndex;
  final int initialAyahNumber;

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  late int _currentIndex;
  final ScrollController _scrollController = ScrollController();
  final QuranAudioService _audioService = QuranAudioService();
  QuranReciter _selectedReciter = kQuranReciters.first;
  int _selectedAyahNumber = 1;
  bool _isAudioLoading = false;
  String? _audioError;
  bool _isPlaying = false;
  late Set<String> _bookmarkKeys;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    final surah = widget.surahs[_currentIndex];

    _selectedAyahNumber = widget.initialAyahNumber.clamp(1, surah.ayahCount);
    _bookmarkKeys = context
        .read<AppController>()
        .quranBookmarks
        .map((bookmark) => bookmark.key)
        .toSet();

    _saveLastRead(_selectedAyahNumber);

    _audioService.player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surah = widget.surahs[_currentIndex];
    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == widget.surahs.length - 1;

    return Scaffold(
      appBar: AppBar(title: Text('${surah.number}. ${surah.nameEnglish}')),
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  surah.nameArabic,
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${surah.ayahCount} ayah(s)'),
              ],
            ),
          ),
          if (_audioError != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_audioError!),
            ),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(14),
              itemBuilder: (context, index) {
                final ayah = surah.ayahs[index];
                final isSelectedAyah = ayah.number == _selectedAyahNumber;
                final bookmarkKey = _bookmarkKey(surah.number, ayah.number);
                final isBookmarked = _bookmarkKeys.contains(bookmarkKey);

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    _saveLastRead(ayah.number);
                    await _playAyah(ayah.number);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelectedAyah
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              'Ayah ${ayah.number}',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                isBookmarked
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                size: 20,
                              ),
                              onPressed: () => _toggleBookmark(ayah.number),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.play_circle_outline_rounded,
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ayah.text,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(height: 1.8),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemCount: surah.ayahs.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isFirst ? null : () => _changeSurah(-1),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isLast ? null : () => _changeSurah(1),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Next'),
                  ),
                ),
              ],
            ),
          ),
          QuranPlayerBar(
            surahName: surah.nameEnglish,
            ayahNumber: _selectedAyahNumber,
            maxAyahNumber: surah.ayahCount,
            currentReciter: _selectedReciter,
            isPlaying: _isPlaying,
            isLoading: _isAudioLoading,
            onTogglePlayPause: _togglePlayPause,
            onPreviousAyah: _playPreviousAyah,
            onNextAyah: _playNextAyah,
            onReciterChanged: _changeReciter,
          ),
        ],
      ),
    );
  }

  Future<void> _changeSurah(int delta) async {
    setState(() {
      _currentIndex += delta;
      _selectedAyahNumber = 1;
      _audioError = null;
    });

    await _audioService.player.stop();
    _isPlaying = false;
    _scrollController.jumpTo(0);
    _saveLastRead(1);
  }

  Future<void> _playAyah(int ayahNumber) async {
    final surah = widget.surahs[_currentIndex];
    setState(() {
      _isAudioLoading = true;
      _audioError = null;
      _selectedAyahNumber = ayahNumber;
    });

    try {
      await _audioService.playAyah(
        surahNumber: surah.number,
        ayahNumber: ayahNumber,
        reciter: _selectedReciter,
      );
      if (!mounted) return;
      setState(() {
        _isPlaying = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _audioError = 'Unable to play audio now. Please check internet.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAudioLoading = false;
        });
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_audioService.player.audioSource == null) {
      await _playAyah(_selectedAyahNumber);
      return;
    }
    await _audioService.togglePlayPause();
    if (!mounted) return;
    setState(() {
      _isPlaying = _audioService.player.playing;
    });
  }

  Future<void> _playPreviousAyah() async {
    if (_selectedAyahNumber <= 1) return;
    final nextAyah = _selectedAyahNumber - 1;
    _saveLastRead(nextAyah);
    await _playAyah(nextAyah);
  }

  Future<void> _playNextAyah() async {
    final maxAyah = widget.surahs[_currentIndex].ayahCount;
    if (_selectedAyahNumber >= maxAyah) return;
    final nextAyah = _selectedAyahNumber + 1;
    _saveLastRead(nextAyah);
    await _playAyah(nextAyah);
  }

  Future<void> _changeReciter(QuranReciter reciter) async {
    setState(() {
      _selectedReciter = reciter;
    });
    if (_audioService.player.audioSource != null) {
      await _playAyah(_selectedAyahNumber);
    }
  }

  Future<void> _toggleBookmark(int ayahNumber) async {
    final surah = widget.surahs[_currentIndex];
    final key = _bookmarkKey(surah.number, ayahNumber);

    setState(() {
      if (_bookmarkKeys.contains(key)) {
        _bookmarkKeys.remove(key);
      } else {
        _bookmarkKeys.add(key);
      }
    });

    await context.read<AppController>().toggleQuranBookmark(
      surahNumber: surah.number,
      ayahNumber: ayahNumber,
      surahNameEnglish: surah.nameEnglish,
      surahNameArabic: surah.nameArabic,
    );
  }

  void _saveLastRead(int ayahNumber) {
    final surah = widget.surahs[_currentIndex];
    unawaited(
      context.read<AppController>().setQuranLastRead(
        surahNumber: surah.number,
        ayahNumber: ayahNumber,
        surahNameEnglish: surah.nameEnglish,
        surahNameArabic: surah.nameArabic,
      ),
    );
  }

  String _bookmarkKey(int surahNumber, int ayahNumber) {
    return '$surahNumber:$ayahNumber';
  }
}
