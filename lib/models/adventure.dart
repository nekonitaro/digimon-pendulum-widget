class Adventure {
  int distance;           // 移動距離
  int coinsCollected;     // 収集したコイン数
  int enemiesDefeated;    // 倒した敵の数
  DateTime lastCoinTime;  // 最後にコインを拾った時間
  DateTime lastEnemyTime; // 最後に敵と遭遇した時間

  Adventure({
    this.distance = 0,
    this.coinsCollected = 0,
    this.enemiesDefeated = 0,
    DateTime? lastCoinTime,
    DateTime? lastEnemyTime,
  })  : lastCoinTime = lastCoinTime ?? DateTime.now(),
        lastEnemyTime = lastEnemyTime ?? DateTime.now();

  /// 時間経過で冒険を更新
  void updateAdventure() {
    final now = DateTime.now();
    
    // 5分ごとにコイン出現
    final minutesSinceCoin = now.difference(lastCoinTime).inMinutes;
    if (minutesSinceCoin >= 5) {
      coinsCollected += minutesSinceCoin ~/ 5;
      lastCoinTime = now;
    }
    
    // 10分ごとに敵出現
    final minutesSinceEnemy = now.difference(lastEnemyTime).inMinutes;
    if (minutesSinceEnemy >= 10) {
      enemiesDefeated += minutesSinceEnemy ~/ 10;
      lastEnemyTime = now;
    }
    
    // 距離を更新（1分で10進む）
    distance += minutesSinceCoin + minutesSinceEnemy;
  }

  /// コインを回収
  int collectCoins() {
    final coins = coinsCollected;
    coinsCollected = 0;
    return coins;
  }

  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'coinsCollected': coinsCollected,
      'enemiesDefeated': enemiesDefeated,
      'lastCoinTime': lastCoinTime.toIso8601String(),
      'lastEnemyTime': lastEnemyTime.toIso8601String(),
    };
  }

  factory Adventure.fromJson(Map<String, dynamic> json) {
    return Adventure(
      distance: json['distance'] ?? 0,
      coinsCollected: json['coinsCollected'] ?? 0,
      enemiesDefeated: json['enemiesDefeated'] ?? 0,
      lastCoinTime: json['lastCoinTime'] != null
          ? DateTime.parse(json['lastCoinTime'])
          : DateTime.now(),
      lastEnemyTime: json['lastEnemyTime'] != null
          ? DateTime.parse(json['lastEnemyTime'])
          : DateTime.now(),
    );
  }
}