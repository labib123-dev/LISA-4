import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';

// FeedbackService — wake word ধরা পড়লে বা LISA respond করার সময়
// notification ও vibration দিয়ে visual/haptic feedback দেয়।
// কোনো special permission (overlay) ছাড়াই কাজ করে, সব Android
// version এ নিরাপদে চলে।
class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // একটা ধারাবাহিক notification id ব্যবহার করা হচ্ছে, যাতে প্রতিটা
  // command এ notification bar এ নতুন নতুন entry না জমে, বরং
  // একই notification আপডেট হয়।
  static const int _notificationId = 1001;

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(initSettings);

    // Android 8.0+ এ notification channel তৈরি করা আবশ্যক,
    // নাহলে notification দেখানো যায় না।
    const channel = AndroidNotificationChannel(
      'lisa_feedback_channel',
      'LISA Voice Feedback',
      description: 'LISA শোনা শুরু করলে বা কোনো কমান্ড সম্পন্ন করলে এই চ্যানেলে নোটিফিকেশন আসে।',
      importance: Importance.high,
      playSound: false,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);

    _initialized = true;
  }

  // LISA শোনা শুরু করলে (wake word detect হওয়ার পর) call করা হবে।
  Future<void> onListeningStarted() async {
    await _showNotification(
      title: 'LISA শুনছে...',
      body: 'বলুন, আমি শুনছি।',
    );

    await _vibrate(pattern: [0, 80]);
  }

  // LISA একটা command বুঝে process করার সময় call করা হবে।
  Future<void> onProcessing() async {
    await _showNotification(
      title: 'LISA',
      body: 'বুঝার চেষ্টা করছি...',
    );

    await _vibrate(pattern: [0, 40, 60, 40]);
  }

  // LISA সফলভাবে একটা command সম্পন্ন করলে call করা হবে।
  Future<void> onCommandSuccess(String message) async {
    await _showNotification(
      title: 'LISA সম্পন্ন করেছে',
      body: message,
    );

    await _vibrate(pattern: [0, 60, 50, 60]);
  }

  // কোনো error/fail হলে call করা হবে।
  Future<void> onCommandFailed(String message) async {
    await _showNotification(
      title: 'LISA',
      body: message,
    );

    await _vibrate(pattern: [0, 150]);
  }

  // শোনা বন্ধ হলে notification সরিয়ে দেওয়ার জন্য।
  Future<void> clearFeedback() async {
    await _notifications.cancel(_notificationId);
  }

  Future<void> _showNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      await init();
    }

    const androidDetails = AndroidNotificationDetails(
      'lisa_feedback_channel',
      'LISA Voice Feedback',
      importance: Importance.high,
      priority: Priority.high,
      // ongoing = true করলে notification swipe করে সরানো যায় না,
      // যতক্ষণ clearFeedback() call না হয়। এটা ব্যবহারকারীকে
      // জানিয়ে রাখে যে LISA এখনো active আছে।
      ongoing: false,
      autoCancel: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF7B2FF7),
      playSound: false,
      enableVibration: false,
    );

    const details = NotificationDetails(android: androidDetails);

    try {
      await _notifications.show(
        _notificationId,
        title,
        body,
        details,
      );
    } catch (e) {
      // notification দেখাতে ব্যর্থ হলেও app বন্ধ হবে না।
    }
  }

  Future<void> _vibrate({required List<int> pattern}) async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        await Vibration.vibrate(pattern: pattern);
      }
    } catch (e) {
      // vibration না থাকলেও app চলবে।
    }
  }
}
