import 'package:flutter_test/flutter_test.dart';
import 'package:digimon_pendulum/models/digimon.dart';
import 'package:digimon_pendulum/models/evolution_stage.dart';
import 'package:digimon_pendulum/models/jogress_combination.dart';
import 'package:digimon_pendulum/services/digimon_manager.dart';

void main() {
  group('JogressCombination Tests', () {
    test('汎用ジョグレス組み合わせは任意の究極体2体で成立する', () {
      final combo = JogressCombinations.generic;
      
      expect(combo.canJogress('デジモンA', 'デジモンB'), true);
      expect(combo.canJogress('ウォーグレイモン', 'メタルガルルモン'), true);
    });

    test('特定組み合わせは指定されたデジモン名でのみ成立する', () {
      final combo = JogressCombinations.warGreymonMetalGarurumon;
      
      expect(combo.canJogress('ウォーグレイモン', 'メタルガルルモン'), true);
      expect(combo.canJogress('メタルガルルモン', 'ウォーグレイモン'), true);
      expect(combo.canJogress('他のデジモン', 'メタルガルルモン'), false);
    });

    test('findCombinationは最適な組み合わせを返す', () {
      final combo = JogressCombinations.findCombination(
        'ウォーグレイモン',
        'メタルガルルモン',
      );
      
      expect(combo, isNotNull);
      expect(combo!.name, 'オメガモン');
      expect(combo.requiredCoins, 300); // 特定組み合わせは安い
    });

    test('findCombinationは汎用パターンにフォールバックする', () {
      final combo = JogressCombinations.findCombination(
        '究極体A',
        '究極体B',
      );
      
      expect(combo, isNotNull);
      expect(combo!.name, 'オメガモン'); // 汎用パターン
      expect(combo.requiredCoins, 500);
    });
  });

  group('Digimon Jogress Tests', () {
    late Digimon ultimate1;
    late Digimon ultimate2;
    late Digimon perfect;

    setUp(() {
      // 究極体2体を準備
      ultimate1 = Digimon(
        id: '1',
        name: 'ウォーグレイモン',
        level: 30,
        coins: 100,
        evolutionStage: EvolutionStage.ultimate,
      );
      ultimate1.battleWins = 10;
      ultimate1.adventure.distance = 500;

      ultimate2 = Digimon(
        id: '2',
        name: 'メタルガルルモン',
        level: 28,
        coins: 50,
        evolutionStage: EvolutionStage.ultimate,
      );
      ultimate2.battleWins = 8;
      ultimate2.adventure.distance = 300;

      // 完全体（比較用）
      perfect = Digimon(
        id: '3',
        name: '完全体デジモン',
        level: 20,
        evolutionStage: EvolutionStage.perfect,
      );
    });

    test('究極体2体はジョグレス可能', () {
      expect(ultimate1.canJogressWith(ultimate2, availableCoins: 500), true);
    });

    test('完全体はジョグレス不可', () {
      expect(perfect.canJogressWith(ultimate1, availableCoins: 500), false);
      expect(ultimate1.canJogressWith(perfect, availableCoins: 500), false);
    });

    test('同じデジモン同士はジョグレス不可', () {
      expect(ultimate1.canJogressWith(ultimate1, availableCoins: 500), false);
    });

    test('コイン不足時はジョグレス不可', () {
      expect(ultimate1.canJogressWith(ultimate2, availableCoins: 100), false);
    });

    test('ジョグレス進化で超究極体が誕生する', () {
      final result = ultimate1.jogressWith(ultimate2);

      expect(result.evolutionStage, EvolutionStage.superUltimate);
      expect(result.name, 'オメガモン');
    });

    test('ジョグレス後はレベルが引き継がれる（高い方）', () {
      final result = ultimate1.jogressWith(ultimate2);

      expect(result.level, 30); // ultimate1のレベル
    });

    test('ジョグレス後はバトル戦績が合算される', () {
      final result = ultimate1.jogressWith(ultimate2);

      expect(result.battleWins, 18); // 10 + 8
      expect(result.battleLosses, 0); // 両方とも0
    });

    test('ジョグレス後は冒険データが合算される', () {
      final result = ultimate1.jogressWith(ultimate2);

      expect(result.adventure.distance, 800); // 500 + 300
    });

    test('ジョグレス後はコインがリセットされる', () {
      final result = ultimate1.jogressWith(ultimate2);

      expect(result.coins, 0);
    });

    test('ジョグレス後は機嫌が最高になる', () {
      final result = ultimate1.jogressWith(ultimate2);

      expect(result.mood, 100);
    });

    test('getJogressCombinationで組み合わせ情報を取得できる', () {
      final combo = ultimate1.getJogressCombination(ultimate2);

      expect(combo, isNotNull);
      expect(combo!.name, 'オメガモン');
    });
  });

  group('DigimonManager Jogress Tests', () {
    late DigimonManager manager;

    setUp(() {
      manager = DigimonManager();
      manager.maxSlots = 5;
    });

    test('究極体が2体いる場合、ジョグレス可能ペアが取得できる', () {
      final ultimate1 = Digimon(
        id: '1',
        name: 'ウォーグレイモン',
        evolutionStage: EvolutionStage.ultimate,
      );
      final ultimate2 = Digimon(
        id: '2',
        name: 'メタルガルルモン',
        evolutionStage: EvolutionStage.ultimate,
      );

      manager.addDigimon(ultimate1);
      manager.addDigimon(ultimate2);

      final pairs = manager.getJogressablePairs();

      expect(pairs.length, 1);
      expect(pairs[0]['digimon1'].name, 'ウォーグレイモン');
      expect(pairs[0]['digimon2'].name, 'メタルガルルモン');
    });

    test('究極体が3体いる場合、3ペア取得できる', () {
      manager.addDigimon(Digimon(
        id: '1',
        name: '究極体A',
        evolutionStage: EvolutionStage.ultimate,
      ));
      manager.addDigimon(Digimon(
        id: '2',
        name: '究極体B',
        evolutionStage: EvolutionStage.ultimate,
      ));
      manager.addDigimon(Digimon(
        id: '3',
        name: '究極体C',
        evolutionStage: EvolutionStage.ultimate,
      ));

      final pairs = manager.getJogressablePairs();

      // 3体から2体選ぶ組み合わせ = 3C2 = 3
      expect(pairs.length, 3);
    });

    test('究極体が1体以下の場合、ジョグレス可能ペアは0', () {
      manager.addDigimon(Digimon(
        id: '1',
        name: '究極体A',
        evolutionStage: EvolutionStage.ultimate,
      ));

      final pairs = manager.getJogressablePairs();

      expect(pairs.length, 0);
    });

    test('完全体と究極体が混在する場合、究極体ペアのみ取得', () {
      manager.addDigimon(Digimon(
        id: '1',
        name: '完全体A',
        evolutionStage: EvolutionStage.perfect,
      ));
      manager.addDigimon(Digimon(
        id: '2',
        name: '究極体A',
        evolutionStage: EvolutionStage.ultimate,
      ));
      manager.addDigimon(Digimon(
        id: '3',
        name: '究極体B',
        evolutionStage: EvolutionStage.ultimate,
      ));

      final pairs = manager.getJogressablePairs();

      expect(pairs.length, 1); // 究極体2体のペアのみ
    });

    test('ジョグレス進化を実行すると2体が1体になる', () {
      final ultimate1 = Digimon(
        id: '1',
        name: 'ウォーグレイモン',
        level: 30,
        evolutionStage: EvolutionStage.ultimate,
      );
      final ultimate2 = Digimon(
        id: '2',
        name: 'メタルガルルモン',
        level: 28,
        evolutionStage: EvolutionStage.ultimate,
      );

      manager.addDigimon(ultimate1);
      manager.addDigimon(ultimate2);

      expect(manager.digimons.length, 2);

      final success = manager.executeJogress(0, 1, 500);

      expect(success, true);
      expect(manager.digimons.length, 1); // 2体が1体に
      expect(manager.currentDigimon.evolutionStage, EvolutionStage.superUltimate);
      expect(manager.currentDigimon.name, 'オメガモン');
    });

    test('ジョグレス後は新しいデジモンが現在のデジモンになる', () {
      final ultimate1 = Digimon(
        id: '1',
        name: 'ウォーグレイモン',
        evolutionStage: EvolutionStage.ultimate,
      );
      final ultimate2 = Digimon(
        id: '2',
        name: 'メタルガルルモン',
        evolutionStage: EvolutionStage.ultimate,
      );

      manager.addDigimon(ultimate1);
      manager.addDigimon(ultimate2);
      manager.switchDigimon(0); // 1体目を選択

      manager.executeJogress(0, 1, 500);

      expect(manager.currentIndex, 0); // 新しいデジモン
      expect(manager.currentDigimon.name, 'オメガモン');
    });

    test('コイン不足時はジョグレス失敗', () {
      final ultimate1 = Digimon(
        id: '1',
        name: 'ウォーグレイモン',
        evolutionStage: EvolutionStage.ultimate,
      );
      final ultimate2 = Digimon(
        id: '2',
        name: 'メタルガルルモン',
        evolutionStage: EvolutionStage.ultimate,
      );

      manager.addDigimon(ultimate1);
      manager.addDigimon(ultimate2);

      final success = manager.executeJogress(0, 1, 100); // コイン不足

      expect(success, false);
      expect(manager.digimons.length, 2); // 変化なし
    });

    test('無効なインデックスでジョグレス失敗', () {
      final ultimate1 = Digimon(
        id: '1',
        name: '究極体A',
        evolutionStage: EvolutionStage.ultimate,
      );

      manager.addDigimon(ultimate1);

      final success = manager.executeJogress(0, 5, 500); // 無効なインデックス

      expect(success, false);
    });

    test('同じインデックス同士ではジョグレス失敗', () {
      final ultimate1 = Digimon(
        id: '1',
        name: '究極体A',
        evolutionStage: EvolutionStage.ultimate,
      );

      manager.addDigimon(ultimate1);

      final success = manager.executeJogress(0, 0, 500); // 同じインデックス

      expect(success, false);
    });
  });

  group('EvolutionStage Tests', () {
    test('超究極体の表示名は「超究極体」', () {
      expect(EvolutionStage.superUltimate.displayName, '超究極体');
    });

    test('超究極体の必要レベルは35', () {
      expect(EvolutionStage.superUltimate.requiredLevel, 35);
    });

    test('超究極体の色はゴールド', () {
      expect(EvolutionStage.superUltimate.colorValue, 0xFFFFD700);
    });

    test('究極体の次の進化段階はnull（通常進化不可）', () {
      expect(EvolutionStage.ultimate.next, null);
    });

    test('超究極体の次の進化段階はnull（最終形態）', () {
      expect(EvolutionStage.superUltimate.next, null);
    });
  });
}