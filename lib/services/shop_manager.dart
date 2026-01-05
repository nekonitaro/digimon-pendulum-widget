import 'package:shared_preferences/shared_preferences.dart';

import '../models/shop_item.dart';
import '../models/digimon.dart';
import '../models/evolution_stage.dart'; // 追加
import 'digimon_manager.dart';

/// ショップでの購入結果
class PurchaseResult {
  final bool success;
  final String message;
  final dynamic data; // 追加データ（新デジモンなど）

  const PurchaseResult({
    required this.success,
    required this.message,
    this.data,
  });
}

/// ショップマネージャー
class ShopManager {
  final DigimonManager digimonManager;
  int jogressItemCount = 0; // ジョグレスアイテムの所持数

  ShopManager({required this.digimonManager});

  /// データを読み込み
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    jogressItemCount = prefs.getInt('jogress_item_count') ?? 0;
    print('ショップデータ読み込み: ジョグレスストーン $jogressItemCount個');
  }

  /// データを保存
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('jogress_item_count', jogressItemCount);
    print('ショップデータ保存: ジョグレスストーン $jogressItemCount個');
  }

  /// アイテムを購入
  Future<PurchaseResult> purchaseItem(ShopItem item) async {
    // コインチェック
    final totalCoins = _getTotalCoins();
    if (totalCoins < item.price) {
      return PurchaseResult(
        success: false,
        message: 'コインが足りません（不足: ${item.price - totalCoins}コイン）',
      );
    }

    // アイテムタイプごとの処理
    switch (item.type) {
      case ShopItemType.egg:
        return _purchaseEgg(item.price);

      case ShopItemType.slotExpansion:
        return _purchaseSlotExpansion(item.price);

      case ShopItemType.jogressItem:
        return _purchaseJogressItem(item.price);

      case ShopItemType.evolutionBooster:
        return _purchaseEvolutionBooster(item.price);

      case ShopItemType.happyFood:
        return _purchaseHappyFood(item.price);

      case ShopItemType.megaCoins:
        return _purchaseMegaCoins(item.price);
    }
  }

  /// 全デジモンの合計コインを取得
  int _getTotalCoins() {
    int total = 0;
    for (var digimon in digimonManager.digimons) {
      total += digimon.coins;
    }
    return total;
  }

  /// コインを消費（現在のデジモンから優先的に）
  void _spendCoins(int amount) {
    print('=== コイン消費 ===');
    print('  消費額: $amount');
    print('  消費前の合計: ${_getTotalCoins()}');
    
    int remaining = amount;
    
    // 現在のデジモンから優先的に消費
    final current = digimonManager.currentDigimon;
    print('  ${current.name}のコイン: ${current.coins}');
    
    if (current.coins >= remaining) {
      // 十分なコインがある場合
      final newCoins = current.coins - remaining;
      current.coins = newCoins; // 直接代入
      print('  → ${current.name}から$remaining消費（残: ${current.coins}）');
      print('  消費後の合計: ${_getTotalCoins()}');
      print('================');
      return;
    }
    
    // 現在のデジモンのコインを全て消費
    final currentUsed = current.coins;
    remaining -= current.coins;
    current.coins = 0;
    if (currentUsed > 0) {
      print('  → ${current.name}から$currentUsed消費（残り: $remaining）');
    }
    
    // 他のデジモンから消費
    for (var digimon in digimonManager.digimons) {
      if (digimon.id == current.id) continue;
      if (remaining <= 0) break;
      
      print('  ${digimon.name}のコイン: ${digimon.coins}');
      
      if (digimon.coins >= remaining) {
        final newCoins = digimon.coins - remaining;
        digimon.coins = newCoins; // 直接代入
        print('  → ${digimon.name}から$remaining消費（残: ${digimon.coins}）');
        remaining = 0;
        break;
      }
      
      // このデジモンのコインを全て消費
      final used = digimon.coins;
      remaining -= digimon.coins;
      digimon.coins = 0;
      if (used > 0) {
        print('  → ${digimon.name}から$used消費（残り: $remaining）');
      }
    }
    
    print('  消費後の合計: ${_getTotalCoins()}');
    print('================');
  }

  /// 新しい卵を購入
  PurchaseResult _purchaseEgg(int price) {
    // スペースチェック
    if (digimonManager.digimons.length >= digimonManager.maxSlots) {
      return const PurchaseResult(
        success: false,
        message: '飼育スペースが足りません。先にスペースを拡張してください。',
      );
    }

    // コイン消費
    _spendCoins(price);

    // 新しいデジモン作成
    final newDigimon = Digimon(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'デジモン${digimonManager.digimons.length + 1}',
    );

    digimonManager.addDigimon(newDigimon);

    return PurchaseResult(
      success: true,
      message: '新しいデジモンの卵を入手しました！',
      data: newDigimon,
    );
  }

  /// 飼育スペース拡張を購入
  PurchaseResult _purchaseSlotExpansion(int price) {
    _spendCoins(price);
    digimonManager.expandSlots(1);

    return PurchaseResult(
      success: true,
      message: '飼育スペースが拡張されました！（${digimonManager.maxSlots}体まで飼育可能）',
    );
  }

  /// ジョグレスアイテムを購入
  PurchaseResult _purchaseJogressItem(int price) {
    _spendCoins(price);
    jogressItemCount++;
    
    print('  ジョグレスストーン購入: 所持数 $jogressItemCount');
    
    // データを保存
    save();

    return PurchaseResult(
      success: true,
      message: 'ジョグレスストーンを入手しました！（所持数: $jogressItemCount）',
    );
  }

  /// 進化促進剤を購入
  PurchaseResult _purchaseEvolutionBooster(int price) {
    final current = digimonManager.currentDigimon;

    // 進化可能かチェック
    if (current.evolutionStage.next == null) {
      return const PurchaseResult(
        success: false,
        message: 'これ以上進化できません',
      );
    }

    // 究極体の場合は通常進化できない
    if (current.evolutionStage == EvolutionStage.ultimate) {
      return const PurchaseResult(
        success: false,
        message: '究極体からはジョグレス進化のみ可能です',
      );
    }

    _spendCoins(price);
    
    // 強制進化（条件を無視）
    final nextStage = current.evolutionStage.next!;
    current.evolutionStage = nextStage;
    print('  進化: ${current.name} → ${nextStage.displayName}');

    return PurchaseResult(
      success: true,
      message: '${current.name}が${current.evolutionStage.displayName}に進化しました！',
    );
  }

  /// ハッピーフードを購入
  PurchaseResult _purchaseHappyFood(int price) {
    final current = digimonManager.currentDigimon;

    _spendCoins(price);
    current.mood = (current.mood + 50).clamp(0, 100);

    return PurchaseResult(
      success: true,
      message: '${current.name}の機嫌が良くなりました！（機嫌: ${current.mood}）',
    );
  }

  /// メガコインを購入（デバッグ用）
  PurchaseResult _purchaseMegaCoins(int price) {
    _spendCoins(price);
    digimonManager.currentDigimon.addCoins(1000);

    return const PurchaseResult(
      success: true,
      message: '1000コインを獲得しました！',
    );
  }

  /// ジョグレスアイテムを消費
  bool useJogressItem() {
    if (jogressItemCount > 0) {
      jogressItemCount--;
      print('ジョグレスストーン使用: 残り $jogressItemCount個');
      save(); // 保存
      return true;
    }
    print('ジョグレスストーン不足');
    return false;
  }

  /// 購入可能かチェック
  bool canPurchase(ShopItem item) {
    return _getTotalCoins() >= item.price;
  }
}