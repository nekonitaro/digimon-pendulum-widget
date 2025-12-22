import 'package:flutter/material.dart';
import '../models/digimon.dart';
import '../services/storage_service.dart';
import '../widgets/digimon_sprite.dart';

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
      // 時間経過による状態更新
      _digimon.updateByTimePassed();


      // テスト用：糞を2個追加
      _digimon.addPoop();
      _digimon.addPoop();
      _digimon.addPoop();
      _digimon.addPoop();


      _isLoading = false;
    });
    
    // 更新後の状態を保存
    _saveDigimon();
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

void _cleanPoop() {
    setState(() {
      _digimon.cleanPoop();
    });
    _saveDigimon();
  }

  void _interact() {
    setState(() {
      _digimon.interact();
    });
    _saveDigimon();
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
  // デジモンスプライト
  DigimonSprite(
    name: _digimon.name,
    level: _digimon.level,
  ),
  const SizedBox(height: 40),
              const SizedBox(height: 40),
              
              // レベル表示
              _buildInfoRow('レベル', '${_digimon.level}'),
              const SizedBox(height: 16),
              
              // コイン表示
              _buildInfoRow('コイン', '${_digimon.coins}'),
              const SizedBox(height: 16),
              
              // 機嫌表示（追加）
              _buildInfoRow('機嫌', '${_digimon.mood}', 
                color: _getMoodColor()),
              const SizedBox(height: 16),
              
              // 糞表示（追加）
              _buildInfoRow('うんち', '${'💩' * _digimon.poopCount}'),
              const SizedBox(height: 16),
              
              // 次のレベルアップに必要なコイン
              _buildInfoRow(
                '次のレベルまで',
                '${_digimon.getRequiredCoinsForLevelUp()} コイン',
              ),
              const SizedBox(height: 20),
              
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
const SizedBox(height: 20),
              
              // 糞掃除ボタン（追加）
              ElevatedButton.icon(
                onPressed: _digimon.poopCount > 0 ? _cleanPoop : null,
                icon: const Icon(Icons.cleaning_services),
                label: const Text('うんち掃除'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.brown,
                ),
              ),
              const SizedBox(height: 20),
              
              // 触れ合いボタン（追加）
              ElevatedButton.icon(
                onPressed: _interact,
                icon: const Icon(Icons.favorite),
                label: const Text('なでなで'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.pink,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.blue,
          ),
        ),
      ],
    );
  }

  // 機嫌に応じた色を取得
  Color _getMoodColor() {
    if (_digimon.mood >= 70) {
      return Colors.green;
    } else if (_digimon.mood >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

