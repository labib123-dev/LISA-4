import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/command_result.dart';

class AppLauncherCommand {
  static const Map<String, String> _apps = {
    'youtube':  'https://youtube.com',
    'facebook': 'https://facebook.com',
    'whatsapp': 'whatsapp://send',
    'google':   'https://google.com',
    'gmail':    'https://mail.google.com',
    'maps':     'https://maps.google.com',
    'camera':   'android-app://com.android.camera2',
    'settings': 'android-app://com.android.settings',
  };

  static const Map<String, String> _banglaNames = {
    'youtube':  'ইউটিউব',
    'facebook': 'ফেসবুক',
    'whatsapp': 'হোয়াটসঅ্যাপ',
    'google':   'গুগল',
    'gmail':    'জিমেইল',
    'maps':     'গুগল ম্যাপস',
    'camera':   'ক্যামেরা',
    'settings': 'সেটিংস',
  };

  static Future<CommandResult> launchApp(
    FlutterTts tts,
    String appName,
  ) async {
    try {
      final key = appName.toLowerCase().trim();
      final displayName = _banglaNames[key] ?? appName;

      if (!_apps.containsKey(key)) {
        final msg = '$displayName অ্যাপটি খুঁজে পাওয়া যায়নি।';
        await tts.speak(msg);
        return CommandResult(
          success: false,
          status: CommandStatus.failed,
          message: msg,
        );
      }

      final uri = Uri.parse(_apps[key]!);
      final canOpen = await canLaunchUrl(uri);

      if (canOpen) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        final msg = '$displayName খুলছি।';
        await tts.speak(msg);
        return CommandResult(
          success: true,
          status: CommandStatus.success,
          message: msg,
        );
      } else {
        // Play Store এ search করবে
        final storeUri = Uri.parse(
          'https://play.google.com/store/search?q=$appName&c=apps',
        );
        await launchUrl(storeUri, mode: LaunchMode.externalApplication);
        final msg = '$displayName পাওয়া যায়নি। Play Store খুলছি।';
        await tts.speak(msg);
        return CommandResult(
          success: false,
          status: CommandStatus.failed,
          message: msg,
        );
      }
    } catch (_) {
      final msg = '$appName খুলতে সমস্যা হয়েছে।';
      await tts.speak(msg);
      return CommandResult(
        success: false,
        status: CommandStatus.failed,
        message: msg,
      );
    }
  }
}