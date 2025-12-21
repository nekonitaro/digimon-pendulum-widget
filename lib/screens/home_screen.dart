import 'package:flutter/material.dart';
import '../models/digimon.dart';
import '../services/storage_service.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Digimon _digimon;
  final StorageService _storageService = StorageService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDigimon();
  }

  // デジモンを読み込み
  Future<void> _loadDigimon() async {
    final savedDigimon = await _storageService.loadDigimon();
    
    setState(() {
      _digimon = savedDigimon ?? Digimon(id: '1', name: 'アグモン');
      _isLoading = false;
    });
  }

  // デジモンを保存
  Future<void> _saveDigimon() async {
    await _storageService.saveDigimon(_digimon);
  }

  void _addCoin() {
    setState(() {
      _digimon.addCoins(1);
    });
    _saveDigimon(); // 保存
  }

  void _levelUp() {
    setState(() {
      _digimon.levelUp();
    });
    _saveDigimon(); // 保存
  }

  @override
  Widget build(BuildContext context) {
    // ローディング中の表示
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('デジモン育成'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // デジモン名
              Text(
                _digimon.name,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              
              // レベル表示
              _buildInfoRow('レベル', '${_digimon.level}'),
              const SizedBox(height: 16),
              
              // コイン表示
              _buildInfoRow('コイン', '${_digimon.coins}'),
              const SizedBox(height: 16),
              
              // 次のレベルアップに必要なコイン
              _buildInfoRow(
                '次のレベルまで',
                '${_digimon.getRequiredCoinsForLevelUp()} コイン',
              ),
              const SizedBox(height: 60),
              
              // コインをもらうボタン
              ElevatedButton.icon(
                onPressed: _addCoin,
                icon: const Icon(Icons.monetization_on),
                label: const Text('コインをもらう (+1)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              
              // レベルアップボタン
              ElevatedButton.icon(
                onPressed: _digimon.canLevelUp() ? _levelUp : null,
                icon: const Icon(Icons.arrow_upward),
                label: const Text('レベルアップ'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
