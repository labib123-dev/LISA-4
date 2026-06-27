import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'router/command_router.dart';
import 'ui/homepage_updated.dart';
import 'ui/pages/notes_page.dart';
import 'ui/pages/history_page.dart';
import 'ui/pages/settings_page.dart';
import 'ui/overly_manager.dart';
import 'ui/splash_screen.dart';
import 'core/tts_service.dart';
import 'core/speech_service.dart';
import 'core/wake_word.dart';
import 'core/feedback_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _currentPageIndex = 0;

  final GlobalKey<_OverlayHostState> _overlayKey =
      GlobalKey<_OverlayHostState>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await _requestPermissions();

      try {
        await _ttsService.init();
      } catch (e) {
        debugPrint('TTS init failed: $e');
      }

      try {
        await _speechService.initialize();
      } catch (e) {
        debugPrint('Speech service init failed: $e');
      }

      try {
        await _feedbackService.init();
      } catch (e) {
        debugPrint('Feedback service init failed: $e');
      }

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
      Permission.notification,
    ].request();

    final micGranted =
        statuses[Permission.microphone]?.isGranted ?? false;

    if (!micGranted) {
      debugPrint('Microphone permission not granted — voice command won\'t work.');
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
            await _feedbackService.onListeningStarted();
            await _feedbackService.onProcessing();

            final result = await _router!.route(text);

            await _saveToHistory(text, result.success, result.message);

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

  Future<void> _saveToHistory(
    String command,
    bool success,
    String message,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('command_history') ?? [];
    final timestamp = DateTime.now().toString().split('.')[0];
    final entry = '${success ? 'success' : 'failed'}|$command|$message|$timestamp';
    history.insert(0, entry);
    if (history.length > 100) history.removeAt(100);
    await prefs.setStringList('command_history', history);
  }

  // Bottom nav থেকে page পরিবর্তনের জন্য — এর আগে main.dart এ এই
  // callback টা ব্যবহারই হতো না, তাই Notes/History/Settings এ ক্লিক
  // করলে কিছু হতো না। এখন HomePageUpdated.onPageChanged থেকে আসা
  // index দিয়ে _currentPageIndex আপডেট হয়, যা _buildPage() switch করে।
  void _onPageChanged(int index) {
    setState(() => _currentPageIndex = index);
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
      return const SplashScreen();
    }

    return _OverlayHost(
      key: _overlayKey,
      child: Scaffold(
        body: _buildPage(),
      ),
    );
  }

  Widget _buildPage() {
    switch (_currentPageIndex) {
      case 0:
        return HomePageUpdated(
          isListening: _isListening,
          spokenText: _spokenText,
          onMicTap: _toggleListening,
          tts: _ttsService.engine,
          speechService: _speechService,
          onPageChanged: _onPageChanged,
        );
      case 1:
        return const NotesPage();
      case 2:
        return const HistoryPage();
      case 3:
        return const SettingsPage();
      default:
        return const SizedBox.shrink();
    }
  }
}

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
