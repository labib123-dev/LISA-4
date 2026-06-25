import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/command_result.dart';

class MessageCommand {
  static Future<CommandResult> sendMessage(
    FlutterTts tts,
    String number,
    String messageText,
  ) async {
    try {
      final cleanNumber = number.trim();

      if (cleanNumber.isEmpty) {
        const message = 'নম্বর পাওয়া যায়নি।';
        await tts.speak(message);

        return const CommandResult(
          success: false,
          status: CommandStatus.invalidInput,
          message: message,
        );
      }

      final uri = Uri.parse(
        'sms:$cleanNumber?body=${Uri.encodeComponent(messageText)}',
      );

      final canSend = await canLaunchUrl(uri);

      if (!canSend) {
        const message = 'মেসেজ অ্যাপ খোলা যাচ্ছে না।';
        await tts.speak(message);

        return const CommandResult(
          success: false,
          status: CommandStatus.failed,
          message: message,
        );
      }

      await launchUrl(uri);

      final response = '$cleanNumber নম্বরে মেসেজ প্রস্তুত করা হয়েছে।';
      await tts.speak(response);

      return CommandResult(
        success: true,
        status: CommandStatus.success,
        message: response,
      );
    } catch (_) {
      const message = 'মেসেজ পাঠাতে সমস্যা হয়েছে।';
      await tts.speak(message);

      return const CommandResult(
        success: false,
        status: CommandStatus.failed,
        message: message,
      );
    }
  }
}