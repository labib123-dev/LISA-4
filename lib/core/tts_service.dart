import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsService {
  static final TtsService _instance =
      TtsService._internal();

  factory TtsService() => _instance;

  TtsService._internal();

  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    await _tts.setLanguage('bn-BD');

    // Settings page এ ব্যবহারকারী যে speed/pitch সেট করে রেখেছেন
    // (SharedPreferences এ সংরক্ষিত), app চালু হওয়ার সময় সেটাই
    // load করে apply করা হচ্ছে। আগে এখানে hardcoded মান
    // (setPitch(1.0), setSpeechRate(0.45)) বসানো ছিল, যার ফলে
    // Settings এ পরিবর্তন করলেও পরের বার app চালু হলে আবার
    // default মানে ফিরে যেত।
    final prefs = await SharedPreferences.getInstance();
    final savedPitch = prefs.getDouble('tts_pitch') ?? 1.0;
    final savedRate = prefs.getDouble('tts_speed') ?? 0.45;

    await _tts.setPitch(savedPitch);

    await _tts.setSpeechRate(savedRate);

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
