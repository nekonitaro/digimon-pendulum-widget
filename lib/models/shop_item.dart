import 'package:flutter/material.dart';

/// ショップアイテムの種類
enum ShopItemType {
  egg,              // 新しい卵
  slotExpansion,    // 飼育スペース拡張
  jogressItem,      // ジョグレスアイテム
  evolutionBooster, // 進化促進剤
  happyFood,        // ハッピーフード
  megaCoins,        // 大量コイン（デバッグ用）
}

/// ショップアイテム
class ShopItem {
  final ShopItemType type;
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final Color color;
  final int? maxPurchases; // null = 無制限

  const ShopItem({
    required this.type,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.color,
    this.maxPurchases,
  });
}

/// ショップアイテムのカタログ
class ShopCatalog {
  static const egg = ShopItem(
    type: ShopItemType.egg,
    name: '新しい卵',
    description: '新しいデジモンの卵を入手できます',
    price: 100,
    icon: Icons.egg,
    color: Colors.blue,
  );

  static const slotExpansion = ShopItem(
    type: ShopItemType.slotExpansion,
    name: '飼育スペース拡張',
    description: 'デジモンを1体多く飼育できるようになります',
    price: 200,
    icon: Icons.add_box,
    color: Colors.green,
  );

  static const jogressItem = ShopItem(
    type: ShopItemType.jogressItem,
    name: 'ジョグレスストーン',
    description: 'ジョグレス進化に必要なアイテム（使い切り）',
    price: 500,
    icon: Icons.merge_type,
    color: Colors.purple,
  );

  static const evolutionBooster = ShopItem(
    type: ShopItemType.evolutionBooster,
    name: '進化促進剤',
    description: '即座に次の進化段階へ進化します',
    price: 150,
    icon: Icons.auto_awesome,
    color: Colors.orange,
  );

  static const happyFood = ShopItem(
    type: ShopItemType.happyFood,
    name: 'ハッピーフード',
    description: '機嫌を50回復します',
    price: 50,
    icon: Icons.favorite,
    color: Colors.pink,
  );

  static const megaCoins = ShopItem(
    type: ShopItemType.megaCoins,
    name: 'メガコイン',
    description: '1000コインを獲得（デバッグ用）',
    price: 1,
    icon: Icons.monetization_on,
    color: Colors.amber,
  );

  /// 全アイテムリスト
  static List<ShopItem> get all => [
    egg,
    slotExpansion,
    jogressItem,
    evolutionBooster,
    happyFood,
    // megaCoins, // リリース時はコメントアウト
  ];

  /// タイプからアイテムを取得
  static ShopItem? getByType(ShopItemType type) {
    try {
      return all.firstWhere((item) => item.type == type);
    } catch (e) {
      return null;
    }
  }
}