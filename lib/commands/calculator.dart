import 'package:flutter_tts/flutter_tts.dart';

import '../models/command_result.dart';

class CalculatorCommand {
  static Future<CommandResult> calculate(
    FlutterTts tts,
    String command,
  ) async {
    try {
      final result = _solve(command);

      if (result == null) {
        const message =
            'দুঃখিত, হিসাবটি বুঝতে পারিনি।';

        await tts.speak(message);

        return const CommandResult(
          success: false,
          status: CommandStatus.invalidInput,
          message: message,
        );
      }

      final message = 'উত্তর $result';

      await tts.speak(message);

      return CommandResult(
        success: true,
        status: CommandStatus.success,
        message: message,
      );
    } catch (_) {
      const message =
          'হিসাব করতে সমস্যা হয়েছে।';

      await tts.speak(message);

      return const CommandResult(
        success: false,
        status: CommandStatus.failed,
        message: message,
      );
    }
  }

  static double? _solve(String text) {
    final command = text.toLowerCase();

    final numbers = RegExp(r'\d+')
        .allMatches(command)
        .map((e) => double.parse(e.group(0)!))
        .toList();

    if (numbers.length < 2) {
      return null;
    }

    final a = numbers[0];
    final b = numbers[1];

    // ADD

    if (command.contains('+') ||
        command.contains('plus') ||
        command.contains('jog') ||
        command.contains('যোগ')) {
      return a + b;
    }

    // SUBTRACT

    if (command.contains('-') ||
        command.contains('minus') ||
        command.contains('biyog') ||
        command.contains('বিয়োগ')) {
      return a - b;
    }

    // MULTIPLY

    if (command.contains('*') ||
        command.contains('gun') ||
        command.contains('multiply') ||
        command.contains('গুণ')) {
      return a * b;
    }

    // DIVIDE

    if (command.contains('/') ||
        command.contains('vag') ||
        command.contains('divide') ||
        command.contains('ভাগ')) {
      if (b == 0) return null;

      return a / b;
    }

    return null;
  }
}