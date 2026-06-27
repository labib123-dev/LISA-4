import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../core/speech_service.dart';

class HomePageUpdated extends StatefulWidget {
  final bool isListening;
  final String spokenText;
  final VoidCallback onMicTap;
  final FlutterTts tts;
  final SpeechService speechService;
  final Function(int) onPageChanged;

  const HomePageUpdated({
    super.key,
    required this.isListening,
    required this.spokenText,
    required this.onMicTap,
    required this.tts,
    required this.speechService,
    required this.onPageChanged,
  });

  @override
  State<HomePageUpdated> createState() => _HomePageUpdatedState();
}

class _HomePageUpdatedState extends State<HomePageUpdated> {
  int selectedIndex = 0;

  Future<void> _handleQuickAction(String action) async {
    if (action == 'call') {
      await widget.tts.speak('কে কল করব? নম্বর বলুন।');
      widget.speechService.startListening(
        onResult: (text) async {
          if (text.isNotEmpty) {
            await widget.tts.speak('$text নম্বরে কল করা হচ্ছে।');
          }
        },
      );
    } else if (action == 'message') {
      await widget.tts.speak('কাকে মেসেজ পাঠাব? নম্বর বলুন।');
      widget.speechService.startListening(
        onResult: (text) async {
          if (text.isNotEmpty) {
            await widget.tts.speak('$text নম্বরে মেসেজ প্রস্তুত করা হচ্ছে।');
          }
        },
      );
    } else if (action == 'alarm') {
      await widget.tts.speak('অ্যালার্ম সেট করতে সময় বলুন।');
      widget.speechService.startListening(
        onResult: (text) async {
          if (text.isNotEmpty) {
            await widget.tts.speak('$text এ অ্যালার্ম সেট করা হচ্ছে।');
          }
        },
      );
    } else if (action == 'torch') {
      await widget.tts.speak('টর্চ চালু করছি।');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070722),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LISA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Personal Assistant',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF7B61FF), Color(0xFF44D7FF)],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'ABL',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                widget.isListening
                    ? 'শুনছি...'
                    : "হ্যালো! আমি LISA। সবসময় আপনার পাশে।",
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: widget.onMicTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isListening
                          ? Colors.redAccent
                          : const Color(0xFF4B43D8),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: widget.isListening
                              ? [Colors.red, Colors.redAccent]
                              : [
                                  const Color(0xFF6F7BFF),
                                  const Color(0xFF4DD8FF),
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.isListening
                                    ? Colors.red
                                    : const Color(0xFF6F7BFF))
                                .withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.isListening ? 'বলুন...' : 'ট্যাপ করে বলুন',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              if (widget.spokenText.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111133),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.spokenText,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    color: Colors.white54,
                    letterSpacing: 1,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _actionButton('📞 কল করুন', () => _handleQuickAction('call')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton('💬 মেসেজ', () => _handleQuickAction('message')),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _actionButton('⏰ অ্যালার্ম', () => _handleQuickAction('alarm')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton('🔦 টর্চ', () => _handleQuickAction('torch')),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D2F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navItem(0, Icons.home_outlined, 'Home'),
                    _navItem(1, Icons.note_outlined, 'Notes'),
                    _navItem(2, Icons.history, 'History'),
                    _navItem(3, Icons.settings_outlined, 'Settings'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF111133),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A66)),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => selectedIndex = index);
        widget.onPageChanged(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: selected ? const Color(0xFF6F7BFF) : Colors.white54,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFF6F7BFF) : Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
