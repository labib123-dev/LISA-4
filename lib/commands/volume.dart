import 'package:flutter_tts/flutter_tts.dart';
import 'package:volume_controller/volume_controller.dart';

import '../models/command_result.dart';

class VolumeCommand {
  static Future<CommandResult> volumeUp(
    FlutterTts tts,
  ) async {
    try {
      double volume =
          await VolumeController.instance.getVolume();

      volume += 0.1;

      if (volume > 1.0) {
        volume = 1.0;
      }

      await VolumeController.instance.setVolume(volume);

      final percent =
          (volume * 100).round();

      final msg =
          'ভলিউম $percent শতাংশ করা হয়েছে।';

      await tts.speak(msg);

      return CommandResult(
        success: true,
        status: CommandStatus.success,
        message: msg,
      );
    } catch (_) {
      const msg =
          'ভলিউম বাড়ানো যায়নি।';

      await tts.speak(msg);

      return const CommandResult(
        success: false,
        status: CommandStatus.failed,
        message: msg,
      );
    }
  }

  static Future<CommandResult> volumeDown(
    FlutterTts tts,
  ) async {
    try {
      double volume =
          await VolumeController.instance.getVolume();

      volume -= 0.1;

      if (volume < 0) {
        volume = 0;
      }

      await VolumeController.instance.setVolume(volume);

      final percent =
          (volume * 100).round();

      final msg =
          'ভলিউম $percent শতাংশ করা হয়েছে।';

      await tts.speak(msg);

      return CommandResult(
        success: true,
        status: CommandStatus.success,
        message: msg,
      );
    } catch (_) {
      const msg =
          'ভলিউম কমানো যায়নি।';

      await tts.speak(msg);

      return const CommandResult(
        success: false,
        status: CommandStatus.failed,
        message: msg,
      );
    }
  }
}
