import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/command_result.dart';
import '../models/lisa_intent.dart';
import '../core/intent_matcher.dart';

import '../commands/alarm.dart';
import '../commands/app_launcher.dart';
import '../commands/battery.dart';
import '../commands/brightness.dart';
import '../commands/calculator.dart';
import '../commands/connectivity.dart';
import '../commands/flashlight.dart';
import '../commands/message.dart';
import '../commands/phone_call.dart';
import '../commands/time_date.dart';
import '../commands/volume.dart';

class CommandRouter {
  final FlutterTts tts;
  final Function(Widget) showOverlay;

  CommandRouter({
    required this.tts,
    required this.showOverlay,
  });

  Future<CommandResult> route(String command) async {
    final intent = IntentMatcher.detect(command);

    switch (intent) {
      case LisaIntent.flashlightOn:
        return FlashlightCommand.turnOn(tts);

      case LisaIntent.flashlightOff:
        return FlashlightCommand.turnOff(tts);

      case LisaIntent.volumeUp:
        return VolumeCommand.volumeUp(tts);

      case LisaIntent.volumeDown:
        return VolumeCommand.volumeDown(tts);

      case LisaIntent.brightnessUp:
        return BrightnessCommand.showWidget(tts, true, showOverlay);

      case LisaIntent.brightnessDown:
        return BrightnessCommand.showWidget(tts, false, showOverlay);

      case LisaIntent.tellTime:
        return TimeDateCommand.tellTime(tts);

      case LisaIntent.tellDate:
        return TimeDateCommand.tellDate(tts);

      case LisaIntent.setAlarm:
        return AlarmCommand.setAlarm(tts, command, showOverlay);

      case LisaIntent.openYoutube:
        return AppLauncherCommand.launchApp(tts, 'youtube');

      case LisaIntent.openFacebook:
        return AppLauncherCommand.launchApp(tts, 'facebook');

      case LisaIntent.openWhatsapp:
        return AppLauncherCommand.launchApp(tts, 'whatsapp');

      case LisaIntent.openMaps:
        return AppLauncherCommand.launchApp(tts, 'maps');

      case LisaIntent.openCamera:
        return AppLauncherCommand.launchApp(tts, 'camera');

      case LisaIntent.openSettings:
        return AppLauncherCommand.launchApp(tts, 'settings');

      case LisaIntent.makeCall:
        final number = _extractNumber(command);
        return PhoneCallCommand.callNumber(tts, number);

      case LisaIntent.sendMessage:
        final number = _extractNumber(command);
        return MessageCommand.sendMessage(tts, number, '');

      case LisaIntent.batteryStatus:
        return BatteryCommand.getBatteryStatus(tts);

      case LisaIntent.calculator:
        return CalculatorCommand.calculate(tts, command);

      case LisaIntent.wifiOn:
      case LisaIntent.wifiOff:
      case LisaIntent.bluetoothOn:
      case LisaIntent.bluetoothOff:
        return ConnectivityCommand.showWifiSettings(tts, showOverlay);

      case LisaIntent.unknown:
        const msg = 'দুঃখিত, কমান্ডটি বুঝতে পারিনি। আবার বলুন।';
        await tts.speak(msg);
        return const CommandResult(
          success: false,
          status: CommandStatus.notFound,
          message: msg,
        );
    }
  }

  String _extractNumber(String command) {
    final match = RegExp(r'[\d\+]+').firstMatch(command);
    return match?.group(0) ?? '';
  }
}