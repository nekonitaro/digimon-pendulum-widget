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
  });
}