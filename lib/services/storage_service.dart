import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/digimon.dart';

class StorageService {
  static const String _digimonKey = 'current_digimon';

  /// デジモンを保存
  Future<void> saveDigimon(Digimon digimon) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(digimon.toJson());
    await prefs.setString(_digimonKey, jsonString);
  }

  /// デジモンを読み込み
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



/// 全デジモンを保存
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
    };
    
    final jsonString = jsonEncode(saveData);
    await prefs.setString('all_digimons', jsonString);
  }

  /// 全デジモンを読み込み
  Future<Map<String, dynamic>?> loadAllDigimons() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('all_digimons');
    
    if (jsonString == null) {
      return null;
    }
    
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    
    // JSON配列をデジモンリストに変換
    final digimonsList = (json['digimons'] as List)
        .map((d) => Digimon.fromJson(d as Map<String, dynamic>))
        .toList();
    
    return {
      'digimons': digimonsList,
      'currentIndex': json['currentIndex'] as int,
      'maxSlots': json['maxSlots'] as int? ?? 2,
    };
  }

}