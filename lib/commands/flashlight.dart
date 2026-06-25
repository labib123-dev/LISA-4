import 'package:flutter_tts/flutter_tts.dart';
import 'package:torch_light/torch_light.dart';

import '../models/command_result.dart';

class FlashlightCommand {
  static Future<CommandResult> turnOn(
    FlutterTts tts,
  ) async {
    try {
      await TorchLight.enableTorch();

      const msg = 'টর্চ চালু করা হয়েছে।';

      await tts.speak(msg);

      return const CommandResult(
        success: true,
        status: CommandStatus.success,
        message: msg,
      );
    } catch (_) {
      const msg =
          'টর্চ চালু করা যায়নি।';

      await tts.speak(msg);

      return const CommandResult(
        success: false,
        status: CommandStatus.failed,
        message: msg,
      );
    }
  }

  static Future<CommandResult> turnOff(
    FlutterTts tts,
  ) async {
    try {
      await TorchLight.disableTorch();

      const msg = 'টর্চ বন্ধ করা হয়েছে।';

      await tts.speak(msg);

      return const CommandResult(
        success: true,
        status: CommandStatus.success,
        message: msg,
      );
    } catch (_) {
      const msg =
          'টর্চ বন্ধ করা যায়নি।';

      await tts.speak(msg);

      return const CommandResult(
        success: false,
        status: CommandStatus.failed,
        message: msg,
      );
    }
  }
}