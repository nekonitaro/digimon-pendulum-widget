import 'digimon.dart';

class Battle {
  final Digimon player;
  final Digimon enemy;
  bool playerWon;
  int coinsEarned;

  Battle({
    required this.player,
    required this.enemy,
    this.playerWon = false,
    this.coinsEarned = 0,
  });

  /// バトル実行
  void execute() {
    // 戦闘力計算
    final playerPower = _calculatePower(player);
    final enemyPower = _calculatePower(enemy);

    // 勝敗判定
    playerWon = playerPower > enemyPower;

    // 報酬計算
    if (playerWon) {
      coinsEarned = 5 + (enemy.level * 2);
    } else {
      coinsEarned = 1; // 負けても少しもらえる
    }
  }

  /// 戦闘力計算
  int _calculatePower(Digimon digimon) {
    // レベル + 筋力の合計
    // 機嫌が良いとボーナス
    int power = digimon.level * 10;
    
    // 機嫌ボーナス
    if (digimon.mood >= 80) {
      power = (power * 1.2).round();
    } else if (digimon.mood < 50) {
      power = (power * 0.8).round();
    }

    // 進化段階ボーナス
    power += digimon.evolutionStage.index * 10;

    return power;
  }

  /// バトル結果のメッセージ
  String get resultMessage {
    if (playerWon) {
      return '勝利！ ${enemy.name}を倒した！';
    } else {
      return '敗北... ${enemy.name}に負けた...';
    }
  }
}

/// CPU用のデジモン生成
Digimon generateEnemy(int playerLevel) {
  // プレイヤーのレベル±2のランダムな敵
  final enemyLevel = (playerLevel - 2 + (playerLevel % 5)).clamp(1, 99);
  
  return Digimon(
    id: 'enemy',
    name: 'ワイルドデジモン',
    level: enemyLevel,
    mood: 100,
  );
}