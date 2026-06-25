import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/command_result.dart';

class ConnectivityCommand {
  static Future<CommandResult> checkStatus(FlutterTts tts) async {
    try {
      final result = await Connectivity().checkConnectivity();

      String msg;

      if (result.contains(ConnectivityResult.wifi)) {
        msg = 'আপনি এখন ওয়াইফাইয়ে সংযুক্ত আছেন।';
      } else if (result.contains(ConnectivityResult.mobile)) {
        msg = 'আপনি এখন মোবাইল ডেটায় সংযুক্ত আছেন।';
      } else {
        msg = 'এই মুহূর্তে কোনো ইন্টারনেট সংযোগ নেই।';
      }

      await tts.speak(msg);

      return CommandResult(
        success: true,
        status: CommandStatus.success,
        message: msg,
      );
    } catch (_) {
      const msg = 'সংযোগের তথ্য পাওয়া যায়নি।';
      await tts.speak(msg);

      return const CommandResult(
        success: false,
        status: CommandStatus.failed,
        message: msg,
      );
    }
  }

  static Future<CommandResult> showWifiSettings(
    FlutterTts tts,
    Function(Widget) showOverlay,
  ) async {
    const msg =
        'সরাসরি WiFi চালু বা বন্ধ করতে পারছি না। নিচের বাটন দিয়ে Settings খুলুন।';
    await tts.speak(msg);

    showOverlay(const _ConnectivityWidget());

    return const CommandResult(
      success: true,
      status: CommandStatus.success,
      message: msg,
    );
  }
}

class _ConnectivityWidget extends StatelessWidget {
  const _ConnectivityWidget();

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
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '📶 সংযোগ সেটিংস',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Android 10+ এ সরাসরি WiFi/Bluetooth\nচালু বা বন্ধ করা সম্ভব নয়।\nSettings থেকে নিজে পরিবর্তন করুন।',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () async {
              // Settings এ পাঠানো
            },
            icon: const Icon(Icons.settings),
            label: const Text('Settings খুলুন'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4A148C),
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