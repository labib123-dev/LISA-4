import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:android_intent_plus/android_intent.dart';

import '../models/command_result.dart';

class AlarmCommand {
  static Future<CommandResult> setAlarm(
    FlutterTts tts,
    String command,
    Function(Widget) showOverlay,
  ) async {
    final parsed = _parseTime(command);

    if (parsed != null) {
      final hour = parsed['hour']!;
      final minute = parsed['minute']!;

      try {
        final intent = AndroidIntent(
          action: 'android.intent.action.SET_ALARM',
          arguments: {
            'android.intent.extra.alarm.HOUR': hour,
            'android.intent.extra.alarm.MINUTES': minute,
            'android.intent.extra.alarm.SKIP_UI': false,
          },
        );

        await intent.launch();

        final minuteText = minute == 0 ? '' : ' $minute মিনিটে';
        final msg = '$hour টা$minuteText অ্যালার্ম সেট করা হচ্ছে।';

        await tts.speak(msg);

        return CommandResult(
          success: true,
          status: CommandStatus.success,
          message: msg,
        );
      } catch (_) {
        const msg = 'অ্যালার্ম সেট করতে সমস্যা হয়েছে।';
        await tts.speak(msg);

        return const CommandResult(
          success: false,
          status: CommandStatus.failed,
          message: msg,
        );
      }
    } else {
      await tts.speak(
        'সময়টা বুঝতে পারিনি। নিচের উইজেট থেকে সেট করুন।',
      );

      showOverlay(AlarmPickerWidget(tts: tts));

      return const CommandResult(
        success: true,
        status: CommandStatus.success,
        message: 'অ্যালার্ম উইজেট দেখানো হয়েছে।',
      );
    }
  }

  static Map<String, int>? _parseTime(String command) {
    // ইংরেজি: "7:30" বা "7 30"
    final colonPattern = RegExp(r'(\d{1,2}):(\d{2})');
    final colonMatch = colonPattern.firstMatch(command);
    if (colonMatch != null) {
      return {
        'hour': int.parse(colonMatch.group(1)!),
        'minute': int.parse(colonMatch.group(2)!),
      };
    }

    // "7 30" ফরম্যাট
    final spacePattern = RegExp(r'(\d{1,2})\s+(\d{2})');
    final spaceMatch = spacePattern.firstMatch(command);
    if (spaceMatch != null) {
      final h = int.parse(spaceMatch.group(1)!);
      final m = int.parse(spaceMatch.group(2)!);
      if (h <= 23 && m <= 59) {
        return {'hour': h, 'minute': m};
      }
    }

    // বাংলা শব্দ: "সাত টায়"
    const banglaNumbers = {
      'এক': 1, 'দুই': 2, 'তিন': 3, 'চার': 4,
      'পাঁচ': 5, 'ছয়': 6, 'সাত': 7, 'আট': 8,
      'নয়': 9, 'দশ': 10, 'এগারো': 11, 'বারো': 12,
    };
    for (final entry in banglaNumbers.entries) {
      if (command.contains(entry.key)) {
        return {'hour': entry.value, 'minute': 0};
      }
    }

    // শুধু ঘণ্টা: "alarm at 7"
    final hourOnly = RegExp(r'(\d{1,2})\s*(টায়|টা)');
    final hourMatch = hourOnly.firstMatch(command);
    if (hourMatch != null) {
      return {
        'hour': int.parse(hourMatch.group(1)!),
        'minute': 0,
      };
    }

    // plain number fallback
    final anyNumber = RegExp(r'(\d{1,2})');
    final anyMatch = anyNumber.firstMatch(command);
    if (anyMatch != null) {
      final h = int.parse(anyMatch.group(1)!);
      if (h <= 23) return {'hour': h, 'minute': 0};
    }

    return null;
  }
}

class AlarmPickerWidget extends StatefulWidget {
  final FlutterTts tts;

  const AlarmPickerWidget({super.key, required this.tts});

  @override
  State<AlarmPickerWidget> createState() => _AlarmPickerWidgetState();
}

class _AlarmPickerWidgetState extends State<AlarmPickerWidget> {
  int _hour = 7;
  int _minute = 0;

  Future<void> _confirm() async {
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.SET_ALARM',
        arguments: {
          'android.intent.extra.alarm.HOUR': _hour,
          'android.intent.extra.alarm.MINUTES': _minute,
          'android.intent.extra.alarm.SKIP_UI': false,
        },
      );
      await intent.launch();

      final minuteText = _minute == 0 ? '' : ' $_minute মিনিটে';
      await widget.tts.speak(
        '$_hour টা$minuteText অ্যালার্ম সেট হচ্ছে।',
      );
    } catch (_) {
      await widget.tts.speak('অ্যালার্ম সেট করা যায়নি।');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.4),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '⏰ অ্যালার্ম সেট করুন',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TimeColumn(
                label: 'ঘণ্টা',
                value: _hour,
                min: 0,
                max: 23,
                onChanged: (v) => setState(() => _hour = v),
              ),

              const Text(
                ':',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),

              _TimeColumn(
                label: 'মিনিট',
                value: _minute,
                min: 0,
                max: 59,
                onChanged: (v) => setState(() => _minute = v),
              ),
            ],
          ),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _confirm,
            icon: const Icon(Icons.alarm_add),
            label: const Text('সেট করুন'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4A148C),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _TimeColumn({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),

        const SizedBox(height: 8),

        IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.white, size: 32),
          onPressed: () => onChanged(value < max ? value + 1 : min),
        ),

        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),

        IconButton(
          icon: const Icon(Icons.remove_circle, color: Colors.white, size: 32),
          onPressed: () => onChanged(value > min ? value - 1 : max),
        ),
      ],
    );
  }
}