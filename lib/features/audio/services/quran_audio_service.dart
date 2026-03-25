import 'package:azan_app/features/audio/models/quran_reciter.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:just_audio/just_audio.dart';

class QuranAudioService {
  QuranAudioService()
    : _player = AudioPlayer(),
      _cacheManager = DefaultCacheManager();

  final AudioPlayer _player;
  final CacheManager _cacheManager;

  AudioPlayer get player => _player;

  Future<void> playAyah({
    required int surahNumber,
    required int ayahNumber,
    required QuranReciter reciter,
  }) async {
    final url = _audioUrl(
      reciterDirectory: reciter.directory,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
    final cached = await _cacheManager.getSingleFile(url);
    await _player.setFilePath(cached.path);
    await _player.play();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  String _audioUrl({
    required String reciterDirectory,
    required int surahNumber,
    required int ayahNumber,
  }) {
    final fileName =
        '${surahNumber.toString().padLeft(3, '0')}${ayahNumber.toString().padLeft(3, '0')}.mp3';
    return 'https://everyayah.com/data/$reciterDirectory/$fileName';
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
