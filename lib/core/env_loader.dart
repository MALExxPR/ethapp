import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class EnvLoader {
  static Map<String, dynamic>? _envData;
  static bool _isLoaded = false;

  static Future<void> load() async {
    if (_isLoaded) return;

    try {
      final String envString = await rootBundle.loadString('env.json');
      _envData = jsonDecode(envString);
      _isLoaded = true;

      if (kDebugMode) {
        print('Environment variables loaded successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load env.json: $e');
      }
      _envData = {};
      _isLoaded = true;
    }
  }

  static String? get(String key) {
    if (!_isLoaded || _envData == null) return null;
    final value = _envData![key];
    return value?.toString();
  }

  static bool hasValidKey(String key) {
    final value = get(key);
    return value != null &&
        value.isNotEmpty &&
        !value.startsWith('your-') &&
        !value.contains('dummy') &&
        !value.contains('here');
  }

  // BingX specific getters
  static String? get bingxApiKey => get('BINGX_API_KEY');
  static String? get bingxSecretKey => get('BINGX_SECRET_KEY');

  static bool get hasBingxCredentials =>
      hasValidKey('BINGX_API_KEY') && hasValidKey('BINGX_SECRET_KEY');
}
