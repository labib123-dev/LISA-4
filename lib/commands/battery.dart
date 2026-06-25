import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/command_result.dart';

class BatteryCommand {
  static final Battery _battery = Battery();

  static Future<CommandResult> getBatteryStatus(
    FlutterTts tts,
  ) async {
    try {
      final level = await _battery.batteryLevel;

      String batteryState;

      if (level >= 80) {
        batteryState = 'ব্যাটারি অনেক ভালো অবস্থায় আছে';
      } else if (level >= 50) {
        batteryState = 'ব্যাটারি মাঝারি অবস্থায় আছে';
      } else if (level >= 20) {
        batteryState = 'ব্যাটারি কিছুটা কম';
      } else {
        batteryState = 'ব্যাটারি খুব কম, চার্জ দেওয়া দরকার';
      }

      final message =
          'বর্তমানে ব্যাটারির চার্জ $level শতাংশ। $batteryState।';

      await tts.speak(message);

      return CommandResult(
        success: true,
        status: CommandStatus.success,
        message: message,
      );
    } catch (e) {
      const message =
          'দুঃখিত, ব্যাটারির তথ্য পাওয়া যায়নি।';

      await tts.speak(message);

      return const CommandResult(
        success: false,
        status: CommandStatus.failed,
        message: message,
      );
    }
  }
}