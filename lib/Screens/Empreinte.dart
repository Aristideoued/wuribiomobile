import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FingerprintPage extends StatefulWidget {
  @override
  _FingerprintPageState createState() => _FingerprintPageState();
}

class _FingerprintPageState extends State<FingerprintPage> {
  Uint8List? _fingerprintBytes;

  Future<void> _captureFingerprint() async {
    const channel = MethodChannel('sf370/sdk');
    try {
      final String base64 = await channel.invokeMethod('captureFingerprint');
      final Uint8List imageBytes = base64Decode(base64);
      Image.memory(imageBytes);
            setState(() {
        _fingerprintBytes = base64Decode(base64);
      });
    } catch (e) {
      print('Erreur SDK : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan Empreinte")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _captureFingerprint,
            child: Text("Capturer Empreinte"),
          ),
          if (_fingerprintBytes != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.memory(_fingerprintBytes!),
            ),
        ],
      ),
    );
  }
}
