import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'screens/home_screen.dart';
import 'services/widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ウィジェットのコールバック登録
  await WidgetService.registerCallbacks();
  
  // ウィジェットからの起動を監視
  HomeWidget.widgetClicked.listen(_onWidgetClicked);
  
  runApp(const MyApp());
}

// ウィジェットクリック時の処理
void _onWidgetClicked(Uri? uri) {
  if (uri != null) {
    debugPrint('ウィジェットクリック: ${uri.host}');
    // この処理は後でHomeScreenで実装
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'デジモン育成',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}