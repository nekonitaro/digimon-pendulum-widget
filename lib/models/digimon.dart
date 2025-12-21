class Digimon {
  final String id;
  final String name;
  int level;
  int coins;

  Digimon({
    required this.id,
    required this.name,
    this.level = 1,
    this.coins = 0,
  });

  /// レベルアップに必要なコイン数を計算
  int getRequiredCoinsForLevelUp() {
    return level * 10;
  }

  /// レベルアップ可能かどうか
  bool canLevelUp() {
    return coins >= getRequiredCoinsForLevelUp();
  }

  /// レベルアップを実行
  void levelUp() {
    if (canLevelUp()) {
      coins -= getRequiredCoinsForLevelUp();
      level++;
    }
  }

  /// コインを追加
  void addCoins(int amount) {
    if (amount > 0) {
      coins += amount;
    }
  }

  /// JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'coins': coins,
    };
  }

  /// JSONから復元
  factory Digimon.fromJson(Map<String, dynamic> json) {
    return Digimon(
      id: json['id'] as String,
      name: json['name'] as String,
      level: json['level'] as int? ?? 1,
      coins: json['coins'] as int? ?? 0,
    );
  }
}