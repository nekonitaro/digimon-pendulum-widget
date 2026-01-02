import 'adventure.dart';
import 'evolution_stage.dart';
import 'jogress_combination.dart';

class Digimon {
  final String id;
  final String name;
  int level;
  int coins;
  int mood;           // 機嫌 (0-100)
  int poopCount;      // 糞の数
  DateTime lastUpdated; // 最終更新日時
  Adventure adventure;  // 追加
  EvolutionStage evolutionStage;  // 追加
int battleWins;    // 勝利数
  int battleLosses;  // 敗北数

Digimon({
    required this.id,
    required this.name,
    this.level = 1,
    this.coins = 0,
    this.mood = 100,
    this.poopCount = 0,
    DateTime? lastUpdated,
    Adventure? adventure,
    this.evolutionStage = EvolutionStage.baby1,
    this.battleWins = 0,     // 追加
    this.battleLosses = 0,   // 追加
  }) : lastUpdated = lastUpdated ?? DateTime.now(),
       adventure = adventure ?? Adventure();

/// 進化可能かチェック
  bool canEvolve() {
    final nextStage = evolutionStage.next;
    if (nextStage == null) return false; // 最終形態
    
    // レベル条件
    if (level < nextStage.requiredLevel) return false;
    
    // 機嫌条件
    if (mood < 50) return false;
    
    // バトル勝利数条件（追加）
    final requiredWins = nextStage.index * 2; // 段階ごとに2勝必要
    if (battleWins < requiredWins) return false;
    
    return true;
  }

/// バトル勝利を記録
  void recordWin(int coinsEarned) {
    battleWins++;
    addCoins(coinsEarned);
    _updateTimestamp();
  }

  /// バトル敗北を記録
  void recordLoss(int coinsEarned) {
    battleLosses++;
    addCoins(coinsEarned);
    mood = (mood - 10).clamp(0, 100); // 負けると機嫌が下がる
    _updateTimestamp();
  }

  /// 総バトル数
  int get totalBattles => battleWins + battleLosses;

  /// 勝率
  double get winRate {
    if (totalBattles == 0) return 0.0;
    return (battleWins / totalBattles * 100);
  }


  /// 進化実行
  void evolve() {
    if (canEvolve()) {
      evolutionStage = evolutionStage.next!;
      _updateTimestamp();
    }
  }

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
Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'coins': coins,
      'mood': mood,
      'poopCount': poopCount,
      'lastUpdated': lastUpdated.toIso8601String(),
      'adventure': adventure.toJson(),
      'evolutionStage': evolutionStage.index,
      'battleWins': battleWins,     // 追加
      'battleLosses': battleLosses, // 追加
    };
  }

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
      adventure: json['adventure'] != null
          ? Adventure.fromJson(json['adventure'])
          : Adventure(),
      evolutionStage: json['evolutionStage'] != null
          ? EvolutionStage.values[json['evolutionStage'] as int]
          : EvolutionStage.baby1,
      battleWins: json['battleWins'] as int? ?? 0,      // 追加
      battleLosses: json['battleLosses'] as int? ?? 0,  // 追加
    );
  }

/// ジョグレス進化が可能か確認
bool canJogressWith(Digimon other, {int availableCoins = 0}) {
  // 1. 両方とも究極体である必要がある
  if (evolutionStage != EvolutionStage.ultimate) return false;
  if (other.evolutionStage != EvolutionStage.ultimate) return false;
  
  // 2. 同じデジモンではない
  if (id == other.id) return false;
  
  // 3. 組み合わせが存在するか確認
  final combination = JogressCombinations.findCombination(name, other.name);
  if (combination == null) return false;
  
  // 4. コインが足りるか確認
  if (availableCoins < combination.requiredCoins) return false;
  
  return true;
}

/// ジョグレス進化を実行（新しいデジモンを返す）
Digimon jogressWith(Digimon other) {
  // 組み合わせを取得
  final combination = JogressCombinations.findCombination(name, other.name);
  if (combination == null) {
    throw Exception('ジョグレス組み合わせが見つかりません');
  }
  
  // 新しいデジモンを生成
  final newDigimon = Digimon(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: combination.name,
    level: level > other.level ? level : other.level, // 高い方のレベルを引き継ぐ
    coins: 0, // コインはリセット
    mood: 100, // 機嫌は最高
    evolutionStage: EvolutionStage.superUltimate,
  );
  
  // バトル戦績を引き継ぐ（合算）
  newDigimon.battleWins = battleWins + other.battleWins;
  newDigimon.battleLosses = battleLosses + other.battleLosses;
  
  // 冒険データも引き継ぐ（合算）
  newDigimon.adventure.distance = adventure.distance + other.adventure.distance;
  newDigimon.adventure.enemiesDefeated = 
      adventure.enemiesDefeated + other.adventure.enemiesDefeated;
  
  return newDigimon;
}

/// ジョグレス可能な組み合わせを取得
JogressCombination? getJogressCombination(Digimon other) {
  return JogressCombinations.findCombination(name, other.name);
}

}