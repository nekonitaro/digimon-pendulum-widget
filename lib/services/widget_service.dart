// ========================================
// クラス: WidgetService
// メソッド: updateWidget() の修正
// ========================================

// ✅ 修正後の完全版
import 'package:digimon_pendulum/models/digimon.dart';
import 'package:digimon_pendulum/models/evolution_stage.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  static Future<void> updateWidget(Digimon digimon) async {
    try {
      // デジモン基本情報
      await HomeWidget.saveWidgetData<String>('digimon_name', digimon.name);
      await HomeWidget.saveWidgetData<int>(
        'evolution_stage',
        digimon.evolutionStage.index,
      );
      await HomeWidget.saveWidgetData<int>(
        'evolution_color',
        digimon.evolutionStage.colorValue,
      );

      // 冒険コイン（未回収分）を保存
      await HomeWidget.saveWidgetData<int>(
        'adventure_coins',
        digimon.adventure.coinsCollected,  // ✅ 変更: 冒険で増えた分
      );

      // 機嫌状態（ビジュアル用）
      await HomeWidget.saveWidgetData<int>('digimon_mood', digimon.mood);
      
      // うんち数
      await HomeWidget.saveWidgetData<int>(
        'digimon_poop',
        digimon.poopCount,
      );

      // イベント状態
      await HomeWidget.saveWidgetData<bool>(
        'can_evolve',
        digimon.canEvolve(),
      );

      // ウィジェットを更新
      await HomeWidget.updateWidget(
        androidName: 'DigimonWidgetProvider',
        iOSName: 'DigimonWidget',
      );
    } catch (e) {
      debugPrint('Widget update error: $e');
    }
  }

  static Future<void> registerCallbacks() async {
    await HomeWidget.registerInteractivityCallback(
      backgroundCallback,
    );
  }
}

@pragma('vm:entry-point')
void backgroundCallback(Uri? uri) async {
  if (uri == null) return;
  debugPrint('Widget clicked - opening app');
}