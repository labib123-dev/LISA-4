import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance =
      TtsService._internal();

  factory TtsService() => _instance;

  TtsService._internal();

  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    await _tts.setLanguage('bn-BD');

    await _tts.setPitch(1.0);

    await _tts.setSpeechRate(0.45);

    await _tts.setVolume(1.0);

    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;

    await _tts.stop();

    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> pause() async {
    await _tts.pause();
  }

  Future<void> setVolume(double value) async {
    await _tts.setVolume(value);
  }

  Future<void> setRate(double value) async {
    await _tts.setSpeechRate(value);
  }

  Future<void> setPitch(double value) async {
    await _tts.setPitch(value);
  }

  FlutterTts get engine => _tts;
}