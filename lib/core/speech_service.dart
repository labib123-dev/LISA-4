import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  static final SpeechService _instance =
      SpeechService._internal();

  factory SpeechService() => _instance;

  SpeechService._internal();

  final SpeechToText _speech =
      SpeechToText();


  bool _initialized = false;

  Future<bool> initialize() async {
    if (_initialized) {
      return true;
    }

    _initialized =
        await _speech.initialize(
      onStatus: (status) {
        print('Speech Status: $status');
      },
      onError: (error) {
        print('Speech Error: $error');
      },
    );

    return _initialized;
  }

  Future<void> startListening({
    required Function(String text)
        onResult,
  }) async {
    if (!_initialized) {
      final ready =
          await initialize();

      if (!ready) {
        return;
      }
    }

    await _speech.listen(
      localeId: 'bn_BD',
      partialResults: true,
      listenMode: ListenMode.confirmation,
      onResult: (result) {
        onResult(
          result.recognizedWords,
        );
      },
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
  }

  bool get isListening =>
      _speech.isListening;
}