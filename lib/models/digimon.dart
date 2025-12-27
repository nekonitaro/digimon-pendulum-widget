import 'adventure.dart';


class Digimon {
  final String id;
  final String name;
  int level;
  int coins;
  int mood;           // 機嫌 (0-100)
  int poopCount;      // 糞の数
  DateTime lastUpdated; // 最終更新日時
  Adventure adventure;  // 追加


 Digimon({
    required this.id,
    required this.name,
    this.level = 1,
    this.coins = 0,
    this.mood = 100,
    this.poopCount = 0,
    DateTime? lastUpdated,
    Adventure? adventure,  // 追加
  }) : lastUpdated = lastUpdated ?? DateTime.now(),
       adventure = adventure ?? Adventure();  // 追加
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
      _updateTimestamp();
    }
  }

  /// コインを追加
  void addCoins(int amount) {
    if (amount > 0) {
      coins += amount;
      _updateTimestamp();
    }
  }

  /// 糞を追加
  void addPoop() {
    poopCount++;
    _updateMoodByPoop();
    _updateTimestamp();
  }

  /// 糞をクリーン
  void cleanPoop() {
    poopCount = 0;
    _updateTimestamp();
  }

  /// 触れ合い（機嫌を良くする）
  void interact() {
    if (mood < 100) {
      mood = (mood + 10).clamp(0, 100);
      _updateTimestamp();
    }
  }

  /// 糞の数に応じて機嫌を更新
  void _updateMoodByPoop() {
    if (poopCount >= 3) {
      mood = (mood - 5).clamp(0, 100);
    }
  }

  /// タイムスタンプ更新
  void _updateTimestamp() {
    lastUpdated = DateTime.now();
  }

  /// 時間経過による状態更新
void updateByTimePassed() {
    final now = DateTime.now();
    final hoursPassed = now.difference(lastUpdated).inHours;

    // 冒険を更新（追加）
    adventure.updateAdventure();


    // 2時間ごとに糞が1個増える
    final newPoops = hoursPassed ~/ 2;
    if (newPoops > 0) {
      for (int i = 0; i < newPoops; i++) {
        addPoop();
      }
    }

    // 放置による機嫌の悪化（6時間ごとに-10）
    final moodDecay = (hoursPassed ~/ 6) * 10;
    if (moodDecay > 0) {
      mood = (mood - moodDecay).clamp(0, 100);
    }

    _updateTimestamp();
  }

  /// JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'coins': coins,
      'mood': mood,
      'poopCount': poopCount,
      'lastUpdated': lastUpdated.toIso8601String(),
      'adventure': adventure.toJson(),  // 追加
    };
  }

  /// JSONから復元
  factory Digimon.fromJson(Map<String, dynamic> json) {
    return Digimon(
      id: json['id'] as String,
      name: json['name'] as String,
      level: json['level'] as int? ?? 1,
      coins: json['coins'] as int? ?? 0,
      mood: json['mood'] as int? ?? 100,
      poopCount: json['poopCount'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
      adventure: json['adventure'] != null  // 追加
          ? Adventure.fromJson(json['adventure'])
          : Adventure(),
    );
  }
}