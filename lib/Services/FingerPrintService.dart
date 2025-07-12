import 'package:flutter/services.dart';

class FingerprintService {
  static const _channel = MethodChannel('sf370/fingerprint');

  static Future<String?> captureFingerprint() async {
    try {
      final result = await _channel.invokeMethod('captureFingerprint');
      return result as String?;
    } on PlatformException catch (e) {
      print("Erreur lors de la capture : ${e.message}");
      return null;
    }
  }
}
