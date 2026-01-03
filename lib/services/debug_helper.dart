import '../models/digimon.dart';
import '../models/evolution_stage.dart';
// import 'package:flutter/material.dart';
/// デバッグ用ヘルパークラス
/// 本番環境では使用しないこと
class DebugHelper {
  /// デジモンを指定レベルまで即座にレベルアップ
  static void setLevel(Digimon digimon, int targetLevel) {
    while (digimon.level < targetLevel) {
      // コインを大量に追加
      digimon.addCoins(1000);
      
      // レベルアップ可能な限り実行
      while (digimon.canLevelUp()) {
        digimon.levelUp();
      }
    }
  }

  /// デジモンを指定の進化段階まで進化
  static void setEvolutionStage(Digimon digimon, EvolutionStage targetStage) {
    while (digimon.evolutionStage.index < targetStage.index) {
      // 進化に必要な条件を満たす
      setLevel(digimon, digimon.evolutionStage.requiredLevel + 5);
      digimon.mood = 100;
      digimon.battleWins = 100;
      
      if (digimon.canEvolve()) {
        digimon.evolve();
      } else {
        break; // これ以上進化できない
      }
    }
  }

  /// 究極体のデジモンを即座に作成
  static Digimon createUltimateDigimon(String name, {String? customId}) {
    final digimon = Digimon(
      id: customId ?? '${DateTime.now().millisecondsSinceEpoch}_${name.hashCode}', // ユニークなIDを生成
      name: name,
      level: 30,
      coins: 1000,
      mood: 100,
      evolutionStage: EvolutionStage.ultimate,
    );
    digimon.battleWins = 50;
    return digimon;
  }

  /// ジョグレステスト用の究極体ペアを作成
  static List<Digimon> createJogressTestPair() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return [
      Digimon(
        id: '${timestamp}_wargreymon', // ユニークなID
        name: 'ウォーグレイモン',
        level: 30,
        coins: 1000,
        mood: 100,
        evolutionStage: EvolutionStage.ultimate,
      )..battleWins = 50,
      Digimon(
        id: '${timestamp}_metalgarurumon', // ユニークなID
        name: 'メタルガルルモン',
        level: 28,
        coins: 1000,
        mood: 100,
        evolutionStage: EvolutionStage.ultimate,
      )..battleWins = 50,
    ];
  }

  /// デジモンの状態を完璧にする（機嫌MAX、うんち0）
  static void perfectCondition(Digimon digimon) {
    digimon.mood = 100;
    while (digimon.poopCount > 0) {
      digimon.cleanPoop();
    }
  }

  /// 大量のコインを追加
  static void addManyCoins(Digimon digimon, int amount) {
    digimon.addCoins(amount);
  }

  /// バトル勝利数を設定
  static void setBattleWins(Digimon digimon, int wins) {
    digimon.battleWins = wins;
  }

  /// 冒険データを充実させる
  static void fillAdventureData(Digimon digimon) {
    digimon.adventure.distance = 9999;
    digimon.adventure.enemiesDefeated = 999;
    digimon.adventure.coinsCollected = 500;
  }

  /// 全ステータスをMAXにする
  static void maxStats(Digimon digimon) {
    setLevel(digimon, 50);
    addManyCoins(digimon, 9999);
    perfectCondition(digimon);
    setBattleWins(digimon, 100);
    fillAdventureData(digimon);
  }

  /// 🔍 デジモンの状態を診断
  static void diagnoseDigimon(Digimon digimon) {
    // debugPrint('=== デジモン診断: ${digimon.name} ===');
    // debugPrint('  ID: ${digimon.id}');
    // debugPrint('  レベル: ${digimon.level}');
    // debugPrint('  進化段階: ${digimon.evolutionStage.displayName}');
    // debugPrint('  コイン: ${digimon.coins}');
    // debugPrint('  機嫌: ${digimon.mood}');
    // debugPrint('  うんち: ${digimon.poopCount}');
    // debugPrint('  バトル勝利: ${digimon.battleWins}');
    // debugPrint('  バトル敗北: ${digimon.battleLosses}');
    // debugPrint('============================');
  }

  /// 🔍 ジョグレス可能性を診断
  static void diagnoseJogressPossibility(Digimon d1, Digimon d2, int coins) {
    // debugPrint('=== ジョグレス診断 ===');
    // debugPrint('デジモン1: ${d1.name} (${d1.evolutionStage.displayName})');
    // debugPrint('デジモン2: ${d2.name} (${d2.evolutionStage.displayName})');
    // debugPrint('所持コイン: $coins');
    
    if (d1.evolutionStage != EvolutionStage.ultimate) {
      // debugPrint('❌ デジモン1が究極体ではない');
    }
    if (d2.evolutionStage != EvolutionStage.ultimate) {
      // debugPrint('❌ デジモン2が究極体ではない');
    }
    
    final combo = d1.getJogressCombination(d2);
    if (combo != null) {
      // debugPrint('組み合わせ: ${combo.name}');
      // debugPrint('必要コイン: ${combo.requiredCoins}');
      
      if (coins >= combo.requiredCoins) {
        // debugPrint('✅ ジョグレス可能');
      } else {
        // debugPrint('❌ コイン不足 (不足: ${combo.requiredCoins - coins})');
      }
    } else {
      // debugPrint('❌ 組み合わせが見つからない');
    }
    // debugPrint('==================');
  }
}