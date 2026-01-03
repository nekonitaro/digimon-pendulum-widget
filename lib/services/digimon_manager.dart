import '../models/digimon.dart';
import '../models/evolution_stage.dart';
import 'storage_service.dart';
// import 'package:flutter/material.dart';

class DigimonManager {
  final StorageService _storageService = StorageService();
  List<Digimon> _digimons = [];
  int _currentIndex = 0;
  int maxSlots = 2; // 初期は2体まで

  List<Digimon> get digimons => _digimons;
  Digimon get currentDigimon => _digimons[_currentIndex];
  int get currentIndex => _currentIndex;

  /// デジモンを初期化
  Future<void> initialize() async {
    final savedData = await _storageService.loadAllDigimons();
    if (savedData != null) {
      _digimons = savedData['digimons'] as List<Digimon>;
      _currentIndex = savedData['currentIndex'] as int;
      maxSlots = savedData['maxSlots'] as int? ?? 2;
    } else {
      // 初回起動：最初の1体を作成
      _digimons = [
        Digimon(id: '1', name: 'アグモン'),
      ];
      _currentIndex = 0;
    }
  }

  /// 現在のデジモンを切り替え
  void switchDigimon(int index) {
    if (index >= 0 && index < _digimons.length) {
      _currentIndex = index;
    }
  }

  /// 新しいデジモンを追加
  bool addDigimon(Digimon digimon) {
    if (_digimons.length >= maxSlots) {
      return false; // スペース不足
    }
    _digimons.add(digimon);
    return true;
  }

  /// デジモンを削除
  void removeDigimon(int index) {
    if (_digimons.length > 1 && index >= 0 && index < _digimons.length) {
      _digimons.removeAt(index);
      if (_currentIndex >= _digimons.length) {
        _currentIndex = _digimons.length - 1;
      }
    }
  }

  /// 飼育スペースを増やす
  void expandSlots(int amount) {
    maxSlots += amount;
  }

  /// 保存
  Future<void> save() async {
    await _storageService.saveAllDigimons({
      'digimons': _digimons,
      'currentIndex': _currentIndex,
      'maxSlots': maxSlots,
    });
  }

// digimon_manager.dart に追加するメソッド

/// ジョグレス可能なデジモンペアのリストを取得
List<Map<String, dynamic>> getJogressablePairs() {
  final pairs = <Map<String, dynamic>>[];
  
  // 究極体のデジモンを抽出
  final ultimateDigimons = _digimons
      .asMap()
      .entries
      .where((entry) => entry.value.evolutionStage == EvolutionStage.ultimate)
      .toList();
  
  // 2体ずつペアを作成
  for (int i = 0; i < ultimateDigimons.length; i++) {
    for (int j = i + 1; j < ultimateDigimons.length; j++) {
      final digimon1 = ultimateDigimons[i].value;
      final digimon2 = ultimateDigimons[j].value;
      final index1 = ultimateDigimons[i].key;
      final index2 = ultimateDigimons[j].key;
      
      // ジョグレス可能か確認
      final combination = digimon1.getJogressCombination(digimon2);
      if (combination != null) {
        pairs.add({
          'digimon1': digimon1,
          'digimon2': digimon2,
          'index1': index1,
          'index2': index2,
          'combination': combination,
        });
      }
    }
  }
  
  return pairs;
}
/// ジョグレス進化を実行（デバッグログ付き）
bool executeJogress(int index1, int index2, int coinsToSpend) {
  // // debugPrint('🔍 executeJogress開始');
  // // debugPrint('  index1: $index1, index2: $index2');
  // // debugPrint('  現在のデジモン数: ${_digimons.length}');
  // // debugPrint('  コイン: $coinsToSpend');
  
  // インデックスチェック
  if (index1 < 0 || index1 >= _digimons.length) {
    // // debugPrint('❌ index1が無効: $index1 (範囲: 0-${_digimons.length - 1})');
    return false;
  }
  if (index2 < 0 || index2 >= _digimons.length) {
    // debugPrint('❌ index2が無効: $index2 (範囲: 0-${_digimons.length - 1})');
    return false;
  }
  if (index1 == index2) {
    // debugPrint('❌ 同じインデックス: $index1');
    return false;
  }
  
  final digimon1 = _digimons[index1];
  final digimon2 = _digimons[index2];

  // debugPrint('  デジモン1: ${digimon1.name} (${digimon1.evolutionStage.displayName})');
  // debugPrint('  デジモン2: ${digimon2.name} (${digimon2.evolutionStage.displayName})');
  
  // ジョグレス可能か確認
  if (!digimon1.canJogressWith(digimon2, availableCoins: coinsToSpend)) {
    // debugPrint('❌ ジョグレス条件を満たしていない');
    return false;
  }
  
  // 組み合わせ情報を取得
  final combination = digimon1.getJogressCombination(digimon2);
  if (combination == null) {
    // debugPrint('❌ ジョグレス組み合わせが見つからない');
    return false;
  }

  // debugPrint('  組み合わせ: ${combination.name} (必要コイン: ${combination.requiredCoins})');
  
  // コイン確認
  if (coinsToSpend < combination.requiredCoins) {
    // debugPrint('❌ コイン不足: $coinsToSpend < ${combination.requiredCoins}');
    return false;
  }
  
  // 新しいデジモンを生成
  final newDigimon = digimon1.jogressWith(digimon2);
  // debugPrint('  新デジモン生成: ${newDigimon.name}');
  
  // 古いデジモンを削除（インデックスの大きい方から削除）
  final largerIndex = index1 > index2 ? index1 : index2;
  final smallerIndex = index1 < index2 ? index1 : index2;
  
  // debugPrint('  削除: largerIndex=$largerIndex, smallerIndex=$smallerIndex');
  
  _digimons.removeAt(largerIndex);
  // debugPrint('  削除後1: ${_digimons.length}体');
  
  _digimons.removeAt(smallerIndex);
  // debugPrint('  削除後2: ${_digimons.length}体');
  
  // 新しいデジモンを追加
  _digimons.add(newDigimon);
  // debugPrint('  追加後: ${_digimons.length}体');
  
  // 現在のインデックスを新しいデジモンに設定
  _currentIndex = _digimons.length - 1;
  // debugPrint('  新しいcurrentIndex: $_currentIndex');
  
  // debugPrint('✅ executeJogress成功');
  return true;
}


}