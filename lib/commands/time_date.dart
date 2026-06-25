import 'package:flutter_tts/flutter_tts.dart';

import '../models/command_result.dart';

class TimeDateCommand {
  static const _banglaMonths = [
    '',
    'জানুয়ারি',
    'ফেব্রুয়ারি',
    'মার্চ',
    'এপ্রিল',
    'মে',
    'জুন',
    'জুলাই',
    'আগস্ট',
    'সেপ্টেম্বর',
    'অক্টোবর',
    'নভেম্বর',
    'ডিসেম্বর',
  ];

  static const _banglaWeekdays = [
    'সোমবার',
    'মঙ্গলবার',
    'বুধবার',
    'বৃহস্পতিবার',
    'শুক্রবার',
    'শনিবার',
    'রবিবার',
  ];

  static Future<CommandResult> tellTime(
    FlutterTts tts,
  ) async {
    final now = DateTime.now();

    final hour = now.hour;
    final minute = now.minute;

    final period = hour < 12
        ? 'সকাল'
        : hour < 17
            ? 'বিকেল'
            : hour < 20
                ? 'সন্ধ্যা'
                : 'রাত';

    final displayHour =
        hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;

    final minuteText =
        minute == 0 ? '' : ' $minute মিনিট';

    final message =
        'এখন $period $displayHour টা$minuteText বাজছে।';

    await tts.speak(message);

    return CommandResult(
      success: true,
      status: CommandStatus.success,
      message: message,
    );
  }

  static Future<CommandResult> tellDate(
    FlutterTts tts,
  ) async {
    final now = DateTime.now();

    final day = now.day;
    final month = _banglaMonths[now.month];
    final year = now.year;

    final weekday =
        _banglaWeekdays[now.weekday - 1];

    final message =
        'আজ $weekday, $day $month $year সাল।';

    await tts.speak(message);

    return CommandResult(
      success: true,
      status: CommandStatus.success,
      message: message,
    );
  }
}