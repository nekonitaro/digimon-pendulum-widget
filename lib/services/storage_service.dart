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
}