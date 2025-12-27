import 'package:flutter/services.dart';

class DeepLinkService {
  static const platform = MethodChannel('digimon.deeplink');
  
  static Future<String?> getInitialLink() async {
    try {
      final String? link = await platform.invokeMethod('getInitialLink');
      return link;
    } catch (e) {
      print('getInitialLink エラー: $e');
      return null;
    }
  }
  
  static Stream<String> get linkStream {
    return const EventChannel('digimon.deeplink/events')
        .receiveBroadcastStream()
        .map((dynamic link) => link as String);
  }
}