import 'package:flutter/services.dart';

class OverlayService {
  static const MethodChannel _channel =
      MethodChannel('com.example.tv_clock/overlay');

  static Future<bool> checkPermission() async {
    final result = await _channel.invokeMethod<bool>('checkPermission');
    return result ?? false;
  }

  static Future<bool> requestPermission() async {
    final result = await _channel.invokeMethod<bool>('requestPermission');
    return result ?? false;
  }

  static Future<void> startOverlay(Map<String, dynamic> settings) async {
    await _channel.invokeMethod('startOverlay', settings);
  }

  static Future<void> stopOverlay() async {
    await _channel.invokeMethod('stopOverlay');
  }
}
