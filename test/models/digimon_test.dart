import 'package:flutter_test/flutter_test.dart';
import 'package:digimon_pendulum/models/digimon.dart';


//どうかな？


void main() {
  group('Digimon Model Tests', () {
    test('デジモンの初期状態が正しい', () {
      final digimon = Digimon(
        id: '1',
        name: 'アグモン',
      );

      expect(digimon.id, '1');
      expect(digimon.name, 'アグモン');
      expect(digimon.level, 1);
      expect(digimon.coins, 0);
    });

    test('コインを追加できる', () {
      final digimon = Digimon(id: '1', name: 'アグモン');
      
      digimon.addCoins(5);
      
      expect(digimon.coins, 5);
    });

    test('レベルアップに必要なコイン数を計算できる', () {
      final digimon = Digimon(id: '1', name: 'アグモン');
      
      expect(digimon.getRequiredCoinsForLevelUp(), 10);
      
      digimon.level = 2;
      expect(digimon.getRequiredCoinsForLevelUp(), 20);
    });

    test('コインが足りない場合、レベルアップできない', () {
      final digimon = Digimon(id: '1', name: 'アグモン');
      digimon.addCoins(5);
      
      expect(digimon.canLevelUp(), false);
    });

    test('コインが足りる場合、レベルアップできる', () {
      final digimon = Digimon(id: '1', name: 'アグモン');
      digimon.addCoins(10);
      
      expect(digimon.canLevelUp(), true);
    });

    test('レベルアップすると、レベルが上がりコインが消費される', () {
      final digimon = Digimon(id: '1', name: 'アグモン');
      digimon.addCoins(15);
      
      digimon.levelUp();
      
      expect(digimon.level, 2);
      expect(digimon.coins, 5);
    });

    test('コインが足りない場合、レベルアップしても変化しない', () {
      final digimon = Digimon(id: '1', name: 'アグモン');
      digimon.addCoins(5);
      
      digimon.levelUp();
      
      expect(digimon.level, 1);
      expect(digimon.coins, 5);
    });

test('JSONに変換できる', () {
      final digimon = Digimon(id: '1', name: 'アグモン');
      digimon.addCoins(15);
      digimon.levelUp();
      
      final json = digimon.toJson();
      
      expect(json['id'], '1');
      expect(json['name'], 'アグモン');
      expect(json['level'], 2);
      expect(json['coins'], 5);
    });

    test('JSONから復元できる', () {
      final json = {
        'id': '1',
        'name': 'アグモン',
        'level': 3,
        'coins': 25,
      };
      
      final digimon = Digimon.fromJson(json);
      
      expect(digimon.id, '1');
      expect(digimon.name, 'アグモン');
      expect(digimon.level, 3);
      expect(digimon.coins, 25);
    });

test('機嫌の初期値は100', () {
      final digimon = Digimon(id: '1', name: 'アグモン');
      
      expect(digimon.mood, 100);
    });

    test('糞の初期値は0', () {
      final digimon = Digimon(id: '1', name: 'アグモン');
      
      expect(digimon.poopCount, 0);
    });

    test('糞を追加できる', () {
      final digimon = Digimon(id: '1', name: 'アグモン');
      
      digimon.addPoop();
      
      expect(digimon.poopCount, 1);
    });

    test('糞をクリーンできる', () {
      final digimon = Digimon(id: '1', name: 'アグモン');
      digimon.addPoop();
      digimon.addPoop();
      
      digimon.cleanPoop();
      
      expect(digimon.poopCount, 0);
    });

    test('糞が3個以上で機嫌が悪化する', () {
      final digimon = Digimon(id: '1', name: 'アグモン');
      
      digimon.addPoop();
      digimon.addPoop();
      digimon.addPoop();
      
      expect(digimon.mood, lessThan(100));
    });

    test('最終更新日時が記録される', () {
      final digimon = Digimon(id: '1', name: 'アグモン');
      
      expect(digimon.lastUpdated, isNotNull);
    });

    
  });
}