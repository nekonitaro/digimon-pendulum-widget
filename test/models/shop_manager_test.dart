import 'package:flutter_test/flutter_test.dart';
import 'package:digimon_pendulum/models/digimon.dart';
import 'package:digimon_pendulum/models/shop_item.dart';
import 'package:digimon_pendulum/services/digimon_manager.dart';
import 'package:digimon_pendulum/services/shop_manager.dart';

void main() {
  group('ShopManager Tests', () {
    late DigimonManager digimonManager;
    late ShopManager shopManager;

    setUp(() {
      digimonManager = DigimonManager();
      digimonManager.maxSlots = 5;
      
      // 初期デジモン（コイン100）
      final digimon = Digimon(id: '1', name: 'テストデジモン', coins: 100);
      digimonManager.addDigimon(digimon);
      
      shopManager = ShopManager(digimonManager: digimonManager);
    });

    test('コインが足りる場合、アイテムを購入できる', () async {
      final result = await shopManager.purchaseItem(ShopCatalog.happyFood);

      expect(result.success, true);
      expect(digimonManager.currentDigimon.coins, 50); // 100 - 50
    });

    test('コインが足りない場合、購入失敗', () async {
      final result = await shopManager.purchaseItem(ShopCatalog.slotExpansion);

      expect(result.success, false);
      expect(result.message, contains('コインが足りません'));
    });

    test('新しい卵を購入すると、デジモンが追加される', () async {
      final initialCount = digimonManager.digimons.length;
      
      final result = await shopManager.purchaseItem(ShopCatalog.egg);

      expect(result.success, true);
      expect(digimonManager.digimons.length, initialCount + 1);
    });

    test('スペース不足時は卵を購入できない', () async {
      // スロットを埋める
      while (digimonManager.digimons.length < digimonManager.maxSlots) {
        digimonManager.addDigimon(Digimon(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'ダミー',
        ));
      }

      final result = await shopManager.purchaseItem(ShopCatalog.egg);

      expect(result.success, false);
      expect(result.message, contains('飼育スペースが足りません'));
    });

    test('スロット拡張を購入すると、最大スロット数が増える', () async {
      digimonManager.currentDigimon.coins = 300; // コイン追加
      final initialSlots = digimonManager.maxSlots;

      final result = await shopManager.purchaseItem(ShopCatalog.slotExpansion);

      expect(result.success, true);
      expect(digimonManager.maxSlots, initialSlots + 1);
    });

    test('ジョグレスアイテムを購入すると、所持数が増える', () async {
      digimonManager.currentDigimon.coins = 600;
      
      final result = await shopManager.purchaseItem(ShopCatalog.jogressItem);

      expect(result.success, true);
      expect(shopManager.jogressItemCount, 1);
    });

    test('ジョグレスアイテムを使用すると、所持数が減る', () {
      shopManager.jogressItemCount = 2;

      final used = shopManager.useJogressItem();

      expect(used, true);
      expect(shopManager.jogressItemCount, 1);
    });

    test('ジョグレスアイテムが0個の時は使用できない', () {
      shopManager.jogressItemCount = 0;

      final used = shopManager.useJogressItem();

      expect(used, false);
    });

    test('進化促進剤を購入すると、デジモンが進化する', () async {
      digimonManager.currentDigimon.coins = 200;
      final initialStage = digimonManager.currentDigimon.evolutionStage;

      final result = await shopManager.purchaseItem(ShopCatalog.evolutionBooster);

      expect(result.success, true);
      expect(
        digimonManager.currentDigimon.evolutionStage.index,
        initialStage.index + 1,
      );
    });

    test('ハッピーフードを購入すると、機嫌が回復する', () async {
      digimonManager.currentDigimon.mood = 30;

      final result = await shopManager.purchaseItem(ShopCatalog.happyFood);

      expect(result.success, true);
      expect(digimonManager.currentDigimon.mood, 80); // 30 + 50
    });

    test('複数のデジモンからコインを消費できる', () async {
      // 2体目を追加（コイン50）
      final digimon2 = Digimon(id: '2', name: 'デジモン2', coins: 50);
      digimonManager.addDigimon(digimon2);

      // 合計150コインで、150コインのアイテムを購入
      final result = await shopManager.purchaseItem(ShopCatalog.evolutionBooster);

      expect(result.success, true);
      
      // コインが消費されている
      final totalRemaining = digimonManager.digimons.fold<int>(
        0,
        (sum, d) => sum + d.coins,
      );
      expect(totalRemaining, 0); // 150 - 150
    });

    test('canPurchaseは購入可能かを正しく判定する', () {
      expect(shopManager.canPurchase(ShopCatalog.happyFood), true); // 50コイン
      expect(shopManager.canPurchase(ShopCatalog.egg), true); // 100コイン
      expect(shopManager.canPurchase(ShopCatalog.slotExpansion), false); // 200コイン
    });
  });

  group('ShopItem Tests', () {
    test('ShopCatalogから全アイテムを取得できる', () {
      final items = ShopCatalog.all;

      expect(items.length, greaterThan(0));
      expect(items, contains(ShopCatalog.egg));
      expect(items, contains(ShopCatalog.slotExpansion));
    });

    test('タイプから特定のアイテムを取得できる', () {
      final item = ShopCatalog.getByType(ShopItemType.egg);

      expect(item, isNotNull);
      expect(item!.name, '新しい卵');
    });
  });
}