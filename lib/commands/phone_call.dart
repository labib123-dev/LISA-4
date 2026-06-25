import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/command_result.dart';

class PhoneCallCommand {
  static Future<CommandResult> callNumber(
    FlutterTts tts,
    String number,
  ) async {
    try {
      final cleanNumber = number.trim();

      if (cleanNumber.isEmpty) {
        const message =
            'ফোন নম্বর পাওয়া যায়নি।';

        await tts.speak(message);

        return const CommandResult(
          success: false,
          status: CommandStatus.invalidInput,
          message: message,
        );
      }

      final uri = Uri.parse(
        'tel:$cleanNumber',
      );

      final canCall =
          await canLaunchUrl(uri);

      if (!canCall) {
        const message =
            'কল করা সম্ভব নয়।';

        await tts.speak(message);

        return const CommandResult(
          success: false,
          status: CommandStatus.failed,
          message: message,
        );
      }

      await launchUrl(uri);

      final message =
          '$cleanNumber নম্বরে কল করা হচ্ছে।';

      await tts.speak(message);

      return CommandResult(
        success: true,
        status: CommandStatus.success,
        message: message,
      );
    } catch (_) {
      const message =
          'কল করতে সমস্যা হয়েছে।';

      await tts.speak(message);

      return const CommandResult(
        success: false,
        status: CommandStatus.failed,
        message: message,
      );
    }
  }
}