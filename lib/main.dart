import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'screens/home_screen.dart';
import 'services/digimon_manager.dart';
import 'services/widget_service.dart';

// main関数も修正
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WidgetService.registerCallbacks();

  final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();

  // DigimonManagerを初期化
  final digimonManager = DigimonManager();
  await digimonManager.initialize();

  runApp(MyApp(digimonManager: digimonManager, initialUri: initialUri));
}

class MyApp extends StatelessWidget {
  final DigimonManager digimonManager; // 追加
  final Uri? initialUri;

  const MyApp({super.key, required this.digimonManager, this.initialUri});
  @override
  Widget build(BuildContext context) {
    // ✅ 推奨
    return MaterialApp(
      title: 'デジモン育成',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomeScreen(digimonManager: digimonManager),
      debugShowCheckedModeBanner: false,
    );
  }
}
