import 'dart:convert';
// import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/digimon.dart';

class StorageService {
  // 単一デジモン用（後方互換性のため残す）
  static const String _digimonKey = 'current_digimon';
  // 複数デジモン用
  static const String _allDigimonsKey = 'all_digimons';

  /// 【非推奨】単一デジモンを保存（後方互換性のため残す）
  @Deprecated('Use saveAllDigimons instead')
  Future<void> saveDigimon(Digimon digimon) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(digimon.toJson());
    await prefs.setString(_digimonKey, jsonString);
  }

  /// 【非推奨】単一デジモンを読み込み（後方互換性のため残す）
  @Deprecated('Use loadAllDigimons instead')
  Future<Digimon?> loadDigimon() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_digimonKey);
    
    if (jsonString == null) {
      return null;
    }
    
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return Digimon.fromJson(json);
  }

  /// デジモンを削除
  Future<void> deleteDigimon() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_digimonKey);
  }

  /// ✅ 全デジモンを保存（メインで使用）
  Future<void> saveAllDigimons(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    
    // デジモンリストをJSON配列に変換
    final digimonsList = (data['digimons'] as List<Digimon>)
        .map((d) => d.toJson())
        .toList();
    
    final saveData = {
      'digimons': digimonsList,
      'currentIndex': data['currentIndex'],
      'maxSlots': data['maxSlots'],
      'savedAt': DateTime.now().toIso8601String(), // タイムスタンプ追加
    };
    
    final jsonString = jsonEncode(saveData);
    await prefs.setString(_allDigimonsKey, jsonString);
    
    // デバッグ用ログ
    // debugPrint('💾 保存完了: ${digimonsList.length}体のデジモン');
  }

  /// ✅ 全デジモンを読み込み（メインで使用）
  Future<Map<String, dynamic>?> loadAllDigimons() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_allDigimonsKey);
    
    if (jsonString == null) {
      // debugPrint('📂 保存データなし（初回起動）');
      return null;
    }
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // JSON配列をデジモンリストに変換
      final digimonsList = (json['digimons'] as List)
          .map((d) => Digimon.fromJson(d as Map<String, dynamic>))
          .toList();
      
      // debugPrint('📂 読み込み完了: ${digimonsList.length}体のデジモン');
      
      return {
        'digimons': digimonsList,
        'currentIndex': json['currentIndex'] as int,
        'maxSlots': json['maxSlots'] as int? ?? 2,
      };
    } catch (e) {
      // debugPrint('❌ 読み込みエラー: $e');
      return null;
    }
  }

  /// データをクリア（デバッグ用）
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_allDigimonsKey);
    await prefs.remove(_digimonKey);
    // debugPrint('🗑️ 全データクリア完了');
  }
}