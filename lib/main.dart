import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'router/command_router.dart';
import 'ui/homepage.dart';
import 'ui/overly_manager.dart';
import 'core/tts_service.dart';
import 'core/speech_service.dart';
import 'core/wake_word.dart';
import 'core/feedback_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LisaApp());
}

class LisaApp extends StatelessWidget {
  const LisaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LISA',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF070722),
      ),
      home: const LisaMain(),
    );
  }
}

class LisaMain extends StatefulWidget {
  const LisaMain({super.key});

  @override
  State<LisaMain> createState() => _LisaMainState();
}

class _LisaMainState extends State<LisaMain> {
  final TtsService _ttsService = TtsService();
  final SpeechService _speechService = SpeechService();
  final FeedbackService _feedbackService = FeedbackService();

  CommandRouter? _router;

  bool _isListening = false;
  bool _permissionsReady = false;
  String _spokenText = '';

  // GlobalKey এর type হতে হবে State class (_OverlayHostState),
  // widget class নয়। এটাই ছিল showOverlay না পাওয়ার মূল কারণ।
  final GlobalKey<_OverlayHostState> _overlayKey =
      GlobalKey<_OverlayHostState>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  // পুরো init প্রক্রিয়াটা try-catch দিয়ে wrap করা হয়েছে।
  // কোনো plugin (TTS, speech_to_text) ব্যর্থ হলেও পুরো app
  // crash না করে স্বাভাবিকভাবে চলতে থাকবে।
  Future<void> _init() async {
    try {
      // ধাপ ১ — সব প্রয়োজনীয় runtime permission চেয়ে নেওয়া।
      // Manifest এ permission declare করা যথেষ্ট নয়; Android 6.0+
      // এ ব্যবহারকারীর কাছ থেকে সরাসরি অনুমতি নিতে হয়, নাহলে
      // mic/camera ব্যবহার করা plugin গুলো crash করে।
      await _requestPermissions();

      // ধাপ ২ — TTS init (ব্যর্থ হলেও app বন্ধ হবে না)
      try {
        await _ttsService.init();
      } catch (e) {
        debugPrint('TTS init failed: $e');
      }

      // ধাপ ৩ — Speech service init (ব্যর্থ হলেও app বন্ধ হবে না)
      try {
        await _speechService.initialize();
      } catch (e) {
        debugPrint('Speech service init failed: $e');
      }

      // ধাপ ৪ — Feedback service (notification + vibration) init
      try {
        await _feedbackService.init();
      } catch (e) {
        debugPrint('Feedback service init failed: $e');
      }

      // ধাপ ৫ — Router তৈরি করা
      _router = CommandRouter(
        tts: _ttsService.engine,
        showOverlay: (widget) {
          _overlayKey.currentState?.showOverlay(widget);
        },
      );

      if (mounted) {
        setState(() => _permissionsReady = true);
      }
    } catch (e) {
      debugPrint('LISA init error: $e');
      // এখানে কোনো রিথ্রো নেই, তাই app চালু থাকবে এবং
      // UI স্বাভাবিকভাবে দেখানো হবে, এমনকি init partially fail করলেও।
      if (mounted) {
        setState(() => _permissionsReady = true);
      }
    }
  }

  Future<void> _requestPermissions() async {
    final statuses = await [
      Permission.microphone,
      Permission.camera,
      Permission.phone,
      Permission.sms,
      // Android 13+ এ notification দেখানোর জন্য runtime permission লাগে।
      Permission.notification,
    ].request();

    final micGranted =
        statuses[Permission.microphone]?.isGranted ?? false;

    if (!micGranted) {
      debugPrint('Microphone permission not granted — voice command কাজ করবে না।');
    }
  }

  Future<void> _toggleListening() async {
    if (_router == null) {
      return;
    }

    if (_isListening) {
      await _speechService.stopListening();
      await _feedbackService.clearFeedback();
      setState(() => _isListening = false);
      return;
    }

    final micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      final result = await Permission.microphone.request();
      if (!result.isGranted) {
        await _ttsService.speak('মাইক্রোফোন অনুমতি ছাড়া শোনা সম্ভব নয়।');
        return;
      }
    }

    try {
      final ready = await _speechService.initialize();
      if (!ready) {
        await _ttsService.speak('মাইক্রোফোন চালু করা যায়নি।');
        return;
      }

      setState(() => _isListening = true);

      await _speechService.startListening(
        onResult: (text) async {
          setState(() => _spokenText = text);

          if (WakeWord.detected(text)) {
            // ধাপ ১ — wake word ধরা পড়ার সাথে সাথেই
            // notification + vibration দিয়ে feedback দেওয়া।
            // অন্য কোনো app খোলা থাকলেও notification বার এ
            // এটা দেখা যাবে, যা ব্যবহারকারীকে জানাবে যে
            // LISA সাড়া দিয়েছে।
            await _feedbackService.onListeningStarted();

            await _feedbackService.onProcessing();

            final result = await _router!.route(text);

            // ধাপ ২ — command সম্পন্ন হওয়ার পর result অনুযায়ী
            // আলাদা feedback (success/failed) দেওয়া।
            if (result.success) {
              await _feedbackService.onCommandSuccess(result.message);
            } else {
              await _feedbackService.onCommandFailed(result.message);
            }

            setState(() => _isListening = false);
            await _speechService.stopListening();
          }
        },
      );
    } catch (e) {
      debugPrint('Listening error: $e');
      setState(() => _isListening = false);
    }
  }

  @override
  void dispose() {
    _speechService.stopListening();
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsReady) {
      return const Scaffold(
        backgroundColor: Color(0xFF070722),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return _OverlayHost(
      key: _overlayKey,
      child: Scaffold(
        body: HomePage(
          isListening: _isListening,
          spokenText: _spokenText,
          onMicTap: _toggleListening,
        ),
      ),
    );
  }
}

// Overlay দেখানোর জন্য host widget — এর state class এ showOverlay() method আছে
class _OverlayHost extends StatefulWidget {
  final Widget child;

  const _OverlayHost({super.key, required this.child});

  @override
  State<_OverlayHost> createState() => _OverlayHostState();
}

class _OverlayHostState extends State<_OverlayHost> {
  Widget? _overlayWidget;

  void showOverlay(Widget w) => setState(() => _overlayWidget = w);
  void hideOverlay() => setState(() => _overlayWidget = null);

  @override
  Widget build(BuildContext context) {
    return OverlayManager(
      overlayWidget: _overlayWidget,
      onDismiss: hideOverlay,
      child: widget.child,
    );
  }
}
