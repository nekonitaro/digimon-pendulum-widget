import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'screens/home_screen.dart';
import 'services/widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ウィジェットのコールバック登録
  await WidgetService.registerCallbacks();
  
  // 初期URLをチェック
  final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
  debugPrint('main.dart: 初期URI = $initialUri');
  
  // ウィジェットクリックのストリームを監視
  HomeWidget.widgetClicked.listen((uri) {
    debugPrint('main.dart: ウィジェットクリック検出 - $uri');
  });
  
  runApp(MyApp(initialUri: initialUri));
}

class MyApp extends StatelessWidget {
  final Uri? initialUri;
  
  const MyApp({super.key, this.initialUri});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'デジモン育成',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomeScreen(initialUri: initialUri),
      debugShowCheckedModeBanner: false,
    );
  }
}