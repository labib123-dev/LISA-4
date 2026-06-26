import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _vibrationEnabled = true;
  bool _notificationEnabled = true;
  double _ttsSpeed = 0.45;
  double _ttsPitch = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _notificationEnabled = prefs.getBool('notification_enabled') ?? true;
      _ttsSpeed = prefs.getDouble('tts_speed') ?? 0.45;
      _ttsPitch = prefs.getDouble('tts_pitch') ?? 1.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration_enabled', _vibrationEnabled);
    await prefs.setBool('notification_enabled', _notificationEnabled);
    await prefs.setDouble('tts_speed', _ttsSpeed);
    await prefs.setDouble('tts_pitch', _ttsPitch);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070722),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D2F),
        elevation: 0,
        title: const Text(
          '⚙️ সেটিংস',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'প্রতিক্রিয়া',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _SettingTile(
              title: 'কম্পন',
              value: _vibrationEnabled,
              onChanged: (value) async {
                setState(() => _vibrationEnabled = value);
                await _saveSettings();
              },
            ),
            const SizedBox(height: 12),

            _SettingTile(
              title: 'নোটিফিকেশন',
              value: _notificationEnabled,
              onChanged: (value) async {
                setState(() => _notificationEnabled = value);
                await _saveSettings();
              },
            ),

            const SizedBox(height: 32),

            const Text(
              'ভয়েস',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111133),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A66)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'কথার গতি',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${(_ttsSpeed * 100).round()}%',
                        style: const TextStyle(
                          color: Color(0xFF6F7BFF),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _ttsSpeed,
                    min: 0.25,
                    max: 1.0,
                    activeColor: const Color(0xFF6F7BFF),
                    inactiveColor: Colors.white24,
                    onChanged: (value) {
                      setState(() => _ttsSpeed = value);
                    },
                    onChangeEnd: (_) async {
                      await _saveSettings();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111133),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A66)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ভয়েসের টোন',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${_ttsPitch.toStringAsFixed(1)}x',
                        style: const TextStyle(
                          color: Color(0xFF6F7BFF),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _ttsPitch,
                    min: 0.5,
                    max: 2.0,
                    activeColor: const Color(0xFF6F7BFF),
                    inactiveColor: Colors.white24,
                    onChanged: (value) {
                      setState(() => _ttsPitch = value);
                    },
                    onChangeEnd: (_) async {
                      await _saveSettings();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'সম্পর্কে',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111133),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A66)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LISA - ব্যক্তিগত সহায়ক',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'সংস্করণ: 1.0.0',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'একটি অফলাইন ভয়েস সহায়ক যা আপনার ডিভাইসকে নিয়ন্ত্রণ করে।',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111133),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A66)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6F7BFF),
          ),
        ],
      ),
    );
  }
}
