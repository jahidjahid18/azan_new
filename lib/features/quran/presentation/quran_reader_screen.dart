import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/theme/app_theme.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:azan_app/features/audio/models/quran_reciter.dart';
import 'package:azan_app/features/audio/presentation/quran_full_player_screen.dart';
import 'package:azan_app/features/audio/services/quran_audio_service.dart';
import 'package:azan_app/features/audio/widgets/quran_player_bar.dart';
import 'package:azan_app/features/quran/data/models/quran_surah.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  bool _showEnglishTranslation = true;
  double _arabicFontSize = 30;
  double _translationFontSize = 15;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _selectedAyahNumber = widget.initialAyahNumber;
    _audioService.player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _setLastRead(_selectedAyahNumber);
      _jumpToAyah(_selectedAyahNumber);
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
    final controller = context.watch<AppController>();
    final l10n = context.l10n;
    final surah = widget.surahs[_currentIndex];
    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == widget.surahs.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('${surah.number}. ${surah.nameEnglish}'),
        actions: <Widget>[
          IconButton(
            tooltip: _showEnglishTranslation
                ? l10n.tr('hideTranslation')
                : l10n.tr('showTranslation'),
            onPressed: () {
              setState(() {
                _showEnglishTranslation = !_showEnglishTranslation;
              });
            },
            icon: Icon(
              _showEnglishTranslation
                  ? Icons.translate_rounded
                  : Icons.g_translate_rounded,
            ),
          ),
          IconButton(
            tooltip: l10n.tr('readerSettings'),
            onPressed: _openReaderSettings,
            icon: const Icon(Icons.format_size_rounded),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  const Color(0xFF0C1C36),
                  const Color(0xFF163259),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppThemeColors.gold.withValues(alpha: 0.4),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  surah.nameArabic,
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NotoNaskhArabic',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppThemeColors.gold.withValues(alpha: 0.95),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${surah.ayahCount} ayah(s)',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
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
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              itemBuilder: (context, index) {
                final ayah = surah.ayahs[index];
                final isSelectedAyah = ayah.number == _selectedAyahNumber;
                final isBookmarked = controller.isQuranBookmarked(
                  surahNumber: surah.number,
                  ayahNumber: ayah.number,
                );

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () async {
                      await _setLastRead(ayah.number);
                      await _playAyah(ayah.number);
                    },
                    onLongPress: () => _copyAyah(
                      surahName: surah.nameEnglish,
                      ayahNumber: ayah.number,
                      arabicText: ayah.text,
                      translationText: ayah.translation,
                    ),
                    child: AppSurfaceCard(
                      backgroundColor: isSelectedAyah
                          ? const Color(0xFFEFFBF3)
                          : null,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary
                                      .withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${l10n.tr('ayah')} ${ayah.number}',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                tooltip: l10n.tr('bookmarkAyah'),
                                onPressed: () async {
                                  await context
                                      .read<AppController>()
                                      .toggleQuranBookmark(
                                        surahNumber: surah.number,
                                        ayahNumber: ayah.number,
                                        surahName: surah.nameEnglish,
                                      );
                                },
                                icon: Icon(
                                  isBookmarked
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.tr('copyAyah'),
                                onPressed: () => _copyAyah(
                                  surahName: surah.nameEnglish,
                                  ayahNumber: ayah.number,
                                  arabicText: ayah.text,
                                  translationText: ayah.translation,
                                ),
                                icon: Icon(
                                  Icons.copy_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Icon(
                                Icons.play_circle_outline_rounded,
                                size: 18,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ayah.text,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  height: 1.8,
                                  fontFamily: 'NotoNaskhArabic',
                                  fontSize: _arabicFontSize,
                                ),
                          ),
                          if (_showEnglishTranslation &&
                              (ayah.translation ?? '').trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                ayah.translation!,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      height: 1.45,
                                      fontSize: _translationFontSize,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemCount: surah.ayahs.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isFirst ? null : () => _changeSurah(-1),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: Text(l10n.tr('previous')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isLast ? null : () => _changeSurah(1),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(l10n.tr('next')),
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
            onOpenFullPlayer: _openFullPlayer,
          ),
        ],
      ),
    );
  }

  void _openFullPlayer() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuranFullPlayerScreen(
          surahName: () => widget.surahs[_currentIndex].nameEnglish,
          maxAyahNumber: widget.surahs[_currentIndex].ayahCount,
          currentAyahNumber: () => _selectedAyahNumber,
          currentReciter: () => _selectedReciter,
          isPlaying: () => _isPlaying,
          isLoading: () => _isAudioLoading,
          onTogglePlayPause: _togglePlayPause,
          onPreviousAyah: _playPreviousAyah,
          onNextAyah: _playNextAyah,
          onReciterChanged: _changeReciter,
        ),
      ),
    );
  }

  void _openReaderSettings() {
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
              child: AppSurfaceCard(
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
                      title: Text(context.l10n.tr('showTranslation')),
                      value: _showEnglishTranslation,
                      onChanged: (value) {
                        setState(() => _showEnglishTranslation = value);
                        setBottomState(() {});
                      },
                    ),
                    Text(
                      context.l10n.tr('arabicFontSize', <String, String>{
                        'size': _arabicFontSize.toStringAsFixed(0),
                      }),
                    ),
                    Slider(
                      min: 24,
                      max: 42,
                      divisions: 18,
                      value: _arabicFontSize,
                      onChanged: (value) {
                        setState(() => _arabicFontSize = value);
                        setBottomState(() {});
                      },
                    ),
                    Text(
                      context.l10n.tr('translationFontSize', <String, String>{
                        'size': _translationFontSize.toStringAsFixed(0),
                      }),
                    ),
                    Slider(
                      min: 12,
                      max: 24,
                      divisions: 12,
                      value: _translationFontSize,
                      onChanged: (value) {
                        setState(() => _translationFontSize = value);
                        setBottomState(() {});
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
    await _setLastRead(_selectedAyahNumber);
  }

  Future<void> _playAyah(int ayahNumber) async {
    final surah = widget.surahs[_currentIndex];
    await _setLastRead(ayahNumber);
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
        _audioError = context.l10n.tr('unablePlayAudio');
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
    await _playAyah(_selectedAyahNumber - 1);
  }

  Future<void> _playNextAyah() async {
    final maxAyah = widget.surahs[_currentIndex].ayahCount;
    if (_selectedAyahNumber >= maxAyah) return;
    await _playAyah(_selectedAyahNumber + 1);
  }

  Future<void> _changeReciter(QuranReciter reciter) async {
    setState(() {
      _selectedReciter = reciter;
    });
    if (_audioService.player.audioSource != null) {
      await _playAyah(_selectedAyahNumber);
    }
  }

  void _jumpToAyah(int ayahNumber) {
    if (!_scrollController.hasClients) return;
    final targetOffset = (ayahNumber - 1) * 145.0;
    final max = _scrollController.position.maxScrollExtent;
    _scrollController.jumpTo(targetOffset.clamp(0, max));
  }

  Future<void> _setLastRead(int ayahNumber) async {
    final surah = widget.surahs[_currentIndex];
    await context.read<AppController>().setQuranLastRead(
      surahNumber: surah.number,
      ayahNumber: ayahNumber,
    );
  }

  Future<void> _copyAyah({
    required String surahName,
    required int ayahNumber,
    required String arabicText,
    String? translationText,
  }) async {
    final buffer = StringBuffer()
      ..writeln('$surahName - ${context.l10n.tr('ayah')} $ayahNumber')
      ..writeln()
      ..writeln(arabicText);
    if ((translationText ?? '').trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(translationText!.trim());
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.tr('ayahCopied'))));
  }
}
