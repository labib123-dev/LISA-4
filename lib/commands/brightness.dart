import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/command_result.dart';

class BrightnessCommand {
  static Future<CommandResult> showWidget(
    FlutterTts tts,
    bool increase,
    Function(Widget) showOverlay,
  ) async {
    final msg = increase
        ? 'সরাসরি ব্রাইটনেস বাড়াতে পারছি না। নিচের স্লাইডার দিয়ে নিজে সেট করুন।'
        : 'সরাসরি ব্রাইটনেস কমাতে পারছি না। নিচের স্লাইডার দিয়ে নিজে সেট করুন।';

    await tts.speak(msg);

    showOverlay(
      BrightnessWidget(
        tts: tts,
        initialIncrease: increase,
      ),
    );

    return CommandResult(
      success: true,
      status: CommandStatus.success,
      message: msg,
    );
  }
}

class BrightnessWidget extends StatefulWidget {
  final FlutterTts tts;
  final bool initialIncrease;

  const BrightnessWidget({
    super.key,
    required this.tts,
    required this.initialIncrease,
  });

  @override
  State<BrightnessWidget> createState() =>
      _BrightnessWidgetState();
}

class _BrightnessWidgetState
    extends State<BrightnessWidget> {
  double brightness = 0.5;

  @override
  void initState() {
    super.initState();

    brightness =
        widget.initialIncrease ? 0.75 : 0.25;
  }

  String getLevel() {
    if (brightness < 0.33) {
      return 'কম';
    }

    if (brightness < 0.66) {
      return 'মাঝারি';
    }

    return 'বেশি';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A148C),
            Color(0xFF7B1FA2),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wb_sunny,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'ব্রাইটনেস',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            getLevel(),
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 10),

          Slider(
            value: brightness,
            min: 0,
            max: 1,
            activeColor: Colors.white,
            inactiveColor:
                Colors.white24,
            onChanged: (value) {
              setState(() {
                brightness = value;
              });
            },
            onChangeEnd: (value) async {
              final percent =
                  (value * 100).round();

              await widget.tts.speak(
                'ব্রাইটনেস $percent শতাংশে সেট করুন।',
              );
            },
          ),

          const SizedBox(height: 10),

          Text(
            '${(brightness * 100).round()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'স্লাইড করে ব্রাইটনেস নির্বাচন করুন',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}