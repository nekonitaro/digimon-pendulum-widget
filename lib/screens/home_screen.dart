import 'package:flutter/material.dart';
import '../models/digimon.dart';
import '../services/storage_service.dart';
import '../widgets/digimon_sprite.dart';
import '../services/widget_service.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:async';
import '../services/deep_link_service.dart';

class HomeScreen extends StatefulWidget {
  final Uri? initialUri;
  
  const HomeScreen({super.key, this.initialUri});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Digimon _digimon;
  final StorageService _storageService = StorageService();
  bool _isLoading = true;
  StreamSubscription<Uri?>? _widgetClickSubscription; // 追加
  @override
  void initState() {
    super.initState();
    _loadDigimon();
    WidgetService.registerCallbacks();
    
    // ディープリンク監視
    DeepLinkService.linkStream.listen((link) {
      debugPrint('ディープリンク受信: $link');
      final uri = Uri.parse(link);
      _handleWidgetClick(uri);
    });
  }
  
  // 追加
  Future<void> _checkPendingAction() async {
    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (uri != null) {
      debugPrint('保留アクション検出: $uri');
      _handleWidgetClick(uri);
    }
  }

  @override
  void dispose() {
    _widgetClickSubscription?.cancel(); // 追加
    super.dispose();
  }

 // ウィジェットクリック処理
  void _handleWidgetClick(Uri? uri) {
    if (uri == null) return;
    
    debugPrint('ウィジェットクリック: ${uri.host}'); // デバッグ用
    
    setState(() {
      if (uri.host == 'addcoin') {
        _digimon.addCoins(1);
        _saveDigimon();
        _showSnackBar('コインを1枚もらった！');
      } else if (uri.host == 'cleanpoop') {
        if (_digimon.poopCount > 0) {
          _digimon.cleanPoop();
          _saveDigimon();
          _showSnackBar('うんちを掃除した！');
        }
      }
    });
  }
  // スナックバー表示
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  // 既存のメソッドはそのまま

  // デジモンを読み込み
  Future<void> _loadDigimon() async {
    final savedDigimon = await _storageService.loadDigimon();
    
    setState(() {
      _digimon = savedDigimon ?? Digimon(id: '1', name: 'アグモン');
      _digimon.updateByTimePassed();
      _isLoading = false;
    });
    
    _saveDigimon(); // 追加（起動時にウィジェット更新）
  }

  // デジモンを保存
  Future<void> _saveDigimon() async {
    await _storageService.saveDigimon(_digimon);
    debugPrint('ウィジェット更新: レベル${_digimon.level}, コイン${_digimon.coins}');
    await WidgetService.updateWidget(_digimon);
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('デジモン育成'), backgroundColor: Colors.blue),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // デジモンスプライト
                DigimonSprite(name: _digimon.name, level: _digimon.level),
                const SizedBox(height: 40),
                const SizedBox(height: 40),

                // レベル表示
                _buildInfoRow('レベル', '${_digimon.level}'),
                const SizedBox(height: 16),

                // コイン表示
                _buildInfoRow('コイン', '${_digimon.coins}'),
                const SizedBox(height: 16),

                // 機嫌表示（追加）
                _buildInfoRow('機嫌', '${_digimon.mood}', color: _getMoodColor()),
                const SizedBox(height: 16),

                // 冒険情報（追加）
                const SizedBox(height: 24),
                const Divider(),
                const Text(
                  '冒険',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('距離', '${_digimon.adventure.distance}m'),
                _buildInfoRow('発見コイン', '${_digimon.adventure.coinsCollected}枚'),
                _buildInfoRow('倒した敵', '${_digimon.adventure.enemiesDefeated}体'),
                const SizedBox(height: 16),

                // コイン回収ボタン
                ElevatedButton.icon(
                  onPressed: _digimon.adventure.coinsCollected > 0
                      ? _collectAdventureCoins
                      : null,
                  icon: const Icon(Icons.card_giftcard),
                  label: Text('コイン回収 (${_digimon.adventure.coinsCollected})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),

                // 糞表示（追加）
                _buildInfoRow('うんち', '💩' * _digimon.poopCount),
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
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 20, color: Colors.grey),
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

  void _collectAdventureCoins() {
    setState(() {
      final collected = _digimon.adventure.collectCoins();
      if (collected > 0) {
        _digimon.addCoins(collected);
        _showSnackBar('冒険で$collected枚のコインを手に入れた！');
      }
    });
    _saveDigimon();
  }
}
