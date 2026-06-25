import '../models/lisa_intent.dart';

class IntentMatcher {
  static LisaIntent detect(String command) {
    final cmd = _normalize(command);

    if (_containsAny(cmd, _flashlightOn)) {
      return LisaIntent.flashlightOn;
    }

    if (_containsAny(cmd, _flashlightOff)) {
      return LisaIntent.flashlightOff;
    }

    if (_containsAny(cmd, _volumeUp)) {
      return LisaIntent.volumeUp;
    }

    if (_containsAny(cmd, _volumeDown)) {
      return LisaIntent.volumeDown;
    }

    if (_containsAny(cmd, _brightnessUp)) {
      return LisaIntent.brightnessUp;
    }

    if (_containsAny(cmd, _brightnessDown)) {
      return LisaIntent.brightnessDown;
    }

    if (_containsAny(cmd, _timeKeywords)) {
      return LisaIntent.tellTime;
    }

    if (_containsAny(cmd, _dateKeywords)) {
      return LisaIntent.tellDate;
    }

    if (_containsAny(cmd, _alarmKeywords)) {
      return LisaIntent.setAlarm;
    }

    if (_containsAny(cmd, _youtubeKeywords)) {
      return LisaIntent.openYoutube;
    }

    if (_containsAny(cmd, _facebookKeywords)) {
      return LisaIntent.openFacebook;
    }

    if (_containsAny(cmd, _whatsappKeywords)) {
      return LisaIntent.openWhatsapp;
    }

    if (_containsAny(cmd, _mapsKeywords)) {
      return LisaIntent.openMaps;
    }

    if (_containsAny(cmd, _cameraKeywords)) {
      return LisaIntent.openCamera;
    }

    if (_containsAny(cmd, _settingsKeywords)) {
      return LisaIntent.openSettings;
    }

    if (_containsAny(cmd, _callKeywords)) {
      return LisaIntent.makeCall;
    }

    if (_containsAny(cmd, _smsKeywords)) {
      return LisaIntent.sendMessage;
    }

    if (_containsAny(cmd, _batteryKeywords)) {
      return LisaIntent.batteryStatus;
    }

    if (_containsAny(cmd, _calculatorKeywords)) {
      return LisaIntent.calculator;
    }

    return LisaIntent.unknown;
  }

  static bool _containsAny(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  static String _normalize(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll('lisa', '')
        .replaceAll('ok lisa', '')
        .replaceAll('okay lisa', '')
        .replaceAll('ওকে লিসা', '')
        .replaceAll(',', ' ')
        .replaceAll('.', ' ')
        .replaceAll('?', ' ')
        .replaceAll('!', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // FLASHLIGHT

  static const _flashlightOn = [
    'torch on',
    'flash on',
    'flashlight on',
    'light on',
    'torch jalao',
    'flash jalao',
    'light jalao',
    'alo dao',
    'টর্চ জ্বালাও',
    'ফ্ল্যাশ অন',
  ];

  static const _flashlightOff = [
    'torch off',
    'flash off',
    'flashlight off',
    'light off',
    'torch bondho',
    'flash bondho',
    'light bondho',
    'alo nibhao',
    'টর্চ বন্ধ',
    'ফ্ল্যাশ অফ',
  ];

  // VOLUME

  static const _volumeUp = [
    'volume up',
    'sound up',
    'volume barao',
    'awaj barao',
    'ভলিউম বাড়াও',
    'সাউন্ড বাড়াও',
  ];

  static const _volumeDown = [
    'volume down',
    'sound down',
    'volume kamao',
    'awaj kamao',
    'ভলিউম কমাও',
    'সাউন্ড কমাও',
  ];

  // BRIGHTNESS

  static const _brightnessUp = [
    'brightness up',
    'brightness barao',
    'light barao',
    'ব্রাইটনেস বাড়াও',
  ];

  static const _brightnessDown = [
    'brightness down',
    'brightness kamao',
    'light kamao',
    'ব্রাইটনেস কমাও',
  ];

  // TIME

  static const _timeKeywords = [
    'time',
    'what time',
    'koyta baje',
    'somoy',
    'কয়টা বাজে',
    'সময়',
  ];

  // DATE

  static const _dateKeywords = [
    'date',
    'today date',
    'tarikh',
    'আজ কত তারিখ',
    'তারিখ',
  ];

  // ALARM

  static const _alarmKeywords = [
    'alarm',
    'set alarm',
    'alarm dao',
    'অ্যালার্ম',
  ];

  // APPS

  static const _youtubeKeywords = ['youtube', 'ইউটিউব'];

  static const _facebookKeywords = ['facebook', 'ফেসবুক'];

  static const _whatsappKeywords = ['whatsapp', 'হোয়াটসঅ্যাপ'];

  static const _mapsKeywords = ['maps', 'map', 'ম্যাপ'];

  static const _cameraKeywords = ['camera', 'ক্যামেরা'];

  static const _settingsKeywords = ['settings', 'সেটিংস'];

  // CALL

  static const _callKeywords = [
    'call',
    'phone',
    'কল',
    'ফোন',
  ];

  // SMS

  static const _smsKeywords = [
    'message',
    'sms',
    'মেসেজ',
    'বার্তা',
  ];

  // BATTERY

  static const _batteryKeywords = [
    'battery',
    'charge',
    'ব্যাটারি',
    'চার্জ',
  ];

  // CALCULATOR

  static const _calculatorKeywords = [
    '+',
    '-',
    '*',
    '/',
    'plus',
    'minus',
    'gun',
    'vag',
    'যোগ',
    'বিয়োগ',
    'গুণ',
    'ভাগ',
  ];
}