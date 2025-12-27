import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../models/digimon.dart';

class WidgetService {
  /// ウィジェットにデータを送信
  static Future<void> updateWidget(Digimon digimon) async {
    try {
      await HomeWidget.saveWidgetData('name', digimon.name);
      await HomeWidget.saveWidgetData('level', digimon.level);
      await HomeWidget.saveWidgetData('coins', digimon.coins);
      await HomeWidget.saveWidgetData('mood', digimon.mood);
      await HomeWidget.saveWidgetData('poopCount', digimon.poopCount);
      
      // 冒険データ追加
      await HomeWidget.saveWidgetData('adventureCoins', digimon.adventure.coinsCollected);
      await HomeWidget.saveWidgetData('distance', digimon.adventure.distance);
      
      await HomeWidget.updateWidget(
        name: 'HomeWidgetProvider',
        androidName: 'HomeWidgetProvider',
      );
    } catch (e) {
      debugPrint('ウィジェット更新エラー: $e');
    }
  }

  /// ウィジェットのアクションを登録
  static Future<void> registerCallbacks() async {
    // コイン追加のコールバック
    HomeWidget.setAppGroupId('digimon_widget_group');
    
    HomeWidget.registerInteractivityCallback(backgroundCallback);
  }

  /// バックグラウンドで実行されるコールバック
  @pragma('vm:entry-point')
  static Future<void> backgroundCallback(Uri? uri) async {
    if (uri?.host == 'addcoin') {
      // コイン追加処理
      debugPrint('コイン追加');
    } else if (uri?.host == 'cleanpoop') {
      // うんち掃除処理
      debugPrint('うんち掃除');
    }
  }
}