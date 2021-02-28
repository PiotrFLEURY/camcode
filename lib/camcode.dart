
import 'dart:async';

import 'package:flutter/services.dart';

class Camcode {
  static const MethodChannel _channel =
      const MethodChannel('camcode');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
