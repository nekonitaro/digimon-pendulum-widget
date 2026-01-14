import 'package:flutter/services.dart';
// import 'package:flutter/foundation.dart';

class DeepLinkService {
  static const platform = MethodChannel('digimon.deeplink');
  
  static void initialize(Function(Uri?) callback) {
    platform.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onLinkReceived') {
        final String? link = call.arguments as String?;
        if (link != null) {
          callback(Uri.parse(link));
        } else {
          callback(null);
        }
      }
    });
  }
 static Future<String?> getInitialLink() async {
    try {
      final String? link = await platform.invokeMethod('getInitialLink');
      return link;
    } catch (e) {
      return null;
    }
  }
  
  static Stream<String> get linkStream {
    return const EventChannel('digimon.deeplink/events')
        .receiveBroadcastStream()
        .map((dynamic link) => link as String);
  }
}