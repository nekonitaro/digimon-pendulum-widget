import '../models/digimon.dart';
import 'storage_service.dart';

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
}