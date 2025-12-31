import '../services/digimon_manager.dart';
import 'package:flutter/material.dart';
import '../models/digimon.dart';
import '../services/storage_service.dart';
import '../widgets/digimon_sprite.dart';
import '../services/widget_service.dart';

import 'dart:async';
import '../services/deep_link_service.dart';
import 'battle_screen.dart';

class HomeScreen extends StatefulWidget {
  final Uri? initialUri;

  const HomeScreen({super.key, this.initialUri});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DigimonManager _digimonManager = DigimonManager();  // 変更
  final StorageService _storageService = StorageService();
  bool _isLoading = true;
  StreamSubscription<Uri?>? _widgetClickSubscription;


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
  // Future<void> _checkPendingAction() async {
  //   final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
  //   if (uri != null) {
  //     debugPrint('保留アクション検出: $uri');
  //     _handleWidgetClick(uri);
  //   }
  // }

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
        _digimonManager.currentDigimon.addCoins(1);
        _saveDigimon();
        _showSnackBar('コインを1枚もらった！');
      } else if (uri.host == 'cleanpoop') {
        if (_digimonManager.currentDigimon.poopCount > 0) {
          _digimonManager.currentDigimon.cleanPoop();
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



// ✅ 修正版：全デジモンリストを保存する
Future<void> _saveDigimon() async {
  // DigimonManagerの保存メソッドを使用
  await _digimonManager.save();
  
  debugPrint('全デジモン保存完了: ${_digimonManager.digimons.length}体');
  debugPrint('現在のデジモン: ${_digimonManager.currentDigimon.name} Lv.${_digimonManager.currentDigimon.level}');
  
  // ウィジェット更新
  await WidgetService.updateWidget(_digimonManager.currentDigimon);
}

// ✅ 修正版：全デジモンリストを読み込む
Future<void> _loadDigimon() async {
  await _digimonManager.initialize();
  
  setState(() {
    _digimonManager.currentDigimon.updateByTimePassed();
    _isLoading = false;
  });
  
  // 初回読み込み後も保存（時間経過処理を反映）
  await _saveDigimon();
}

  void _addCoin() {
    setState(() {
      _digimonManager.currentDigimon.addCoins(1);
    });
    _saveDigimon(); // 保存
  }

  void _levelUp() {
    setState(() {
      _digimonManager.currentDigimon.levelUp();
    });
    _saveDigimon(); // 保存
  }

  void _cleanPoop() {
    setState(() {
      _digimonManager.currentDigimon.cleanPoop();
    });
    _saveDigimon();
  }

  void _interact() {
    setState(() {
      _digimonManager.currentDigimon.interact();
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
      appBar: AppBar(title: Text('デジモン育成 (${_digimonManager.currentIndex + 1}/${_digimonManager.digimons.length})'),
        backgroundColor: Colors.blue,
        actions: [
          // デジモンリストボタン（追加）
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _showDigimonList,
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // デジモンスプライト
                // デジモンスプライト
                DigimonSprite(
                  name: _digimonManager.currentDigimon.name,
                  level: _digimonManager.currentDigimon.level,
                  evolutionStage: _digimonManager.currentDigimon.evolutionStage, // 追加
                ),
                const SizedBox(height: 40),
                const SizedBox(height: 40),

                // レベル表示
                _buildInfoRow('レベル', '${_digimonManager.currentDigimon.level}'),
                const SizedBox(height: 16),

                // 進化段階表示（追加）
                _buildInfoRow('進化段階', _digimonManager.currentDigimon.evolutionStage.displayName),
                const SizedBox(height: 16),

                // コイン表示
                _buildInfoRow('コイン', '${_digimonManager.currentDigimon.coins}'),
                const SizedBox(height: 16),

                // 機嫌表示（追加）
                _buildInfoRow('機嫌', '${_digimonManager.currentDigimon.mood}', color: _getMoodColor()),
                const SizedBox(height: 16),
                // 糞表示（追加）
                _buildInfoRow('うんち', '💩' * _digimonManager.currentDigimon.poopCount),
                const SizedBox(height: 16),

 // 糞掃除ボタン（追加）
                ElevatedButton.icon(
                  onPressed: _digimonManager.currentDigimon.poopCount > 0 ? _cleanPoop : null,
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

                // 冒険情報（追加）
                const SizedBox(height: 24),
                const Divider(),
                const Text(
                  '冒険',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('距離', '${_digimonManager.currentDigimon.adventure.distance}m'),
                _buildInfoRow('発見コイン', '${_digimonManager.currentDigimon.adventure.coinsCollected}枚'),
                _buildInfoRow('倒した敵', '${_digimonManager.currentDigimon.adventure.enemiesDefeated}体'),
                const SizedBox(height: 16),

// コイン回収ボタン
                ElevatedButton.icon(
                  onPressed: _digimonManager.currentDigimon.adventure.coinsCollected > 0
                      ? _collectAdventureCoins
                      : null,
                  icon: const Icon(Icons.card_giftcard),
                  label: Text('コイン回収 (${_digimonManager.currentDigimon.adventure.coinsCollected})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),


                // バトル戦績（追加）
                const Text(
                  'バトル',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('勝利', '${_digimonManager.currentDigimon.battleWins}回'),
                _buildInfoRow('敗北', '${_digimonManager.currentDigimon.battleLosses}回'),
                _buildInfoRow('勝率', '${_digimonManager.currentDigimon.winRate.toStringAsFixed(1)}%'),
                const SizedBox(height: 16),

                // バトル開始ボタン（追加）
                ElevatedButton.icon(
                  onPressed: _startBattle,
                  icon: const Icon(Icons.sports_martial_arts),
                  label: const Text('バトル開始'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),

                

                // 次のレベルアップに必要なコイン
                _buildInfoRow(
                  '次のレベルまで',
                  '${_digimonManager.currentDigimon.getRequiredCoinsForLevelUp()} コイン',
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
                  onPressed: _digimonManager.currentDigimon.canLevelUp() ? _levelUp : null,
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

                // 進化ボタン（追加）
                ElevatedButton.icon(
                  onPressed: _digimonManager.currentDigimon.canEvolve() ? _evolve : null,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(_digimonManager.currentDigimon.canEvolve() ? '進化する！' : '進化条件未達成'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.purple,
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(),


               
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
    if (_digimonManager.currentDigimon.mood >= 70) {
      return Colors.green;
    } else if (_digimonManager.currentDigimon.mood >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _collectAdventureCoins() {
    setState(() {
      final collected = _digimonManager.currentDigimon.adventure.collectCoins();
      if (collected > 0) {
        _digimonManager.currentDigimon.addCoins(collected);
        _showSnackBar('冒険で$collected枚のコインを手に入れた！');
      }
    });
    _saveDigimon();
  }

  void _evolve() {
    setState(() {
      _digimonManager.currentDigimon.evolve();
    });
    _saveDigimon();
    _showSnackBar('進化した！ ${_digimonManager.currentDigimon.evolutionStage.displayName}になった！');
  }

  Future<void> _startBattle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BattleScreen(playerDigimon: _digimonManager.currentDigimon),
      ),
    );

    if (result == true) {
      setState(() {
        // ここで再描画をトリガー
      });
      await _saveDigimon();
    }
  }

void _showDigimonList() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'デジモン一覧',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _digimonManager.digimons.length,
                  itemBuilder: (context, index) {
                    final digimon = _digimonManager.digimons[index];
                    final isSelected = index == _digimonManager.currentIndex;
                    
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(digimon.name),
                      subtitle: Text('Lv.${digimon.level} ${digimon.evolutionStage.displayName}'),
                      trailing: isSelected 
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() {
                          _digimonManager.switchDigimon(index);
                        });
                        _saveDigimon();
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // 新しいデジモン追加ボタン
              if (_digimonManager.digimons.length < _digimonManager.maxSlots)
                ElevatedButton.icon(
                  onPressed: _addNewDigimon,
                  icon: const Icon(Icons.add),
                  label: Text('新しいデジモン (${_digimonManager.digimons.length}/${_digimonManager.maxSlots})'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _addNewDigimon() {
    Navigator.pop(context);
    
    // 名前入力ダイアログ
    showDialog(
      context: context,
      builder: (context) {
        String newName = 'デジモン${_digimonManager.digimons.length + 1}';
        
        return AlertDialog(
          title: const Text('新しいデジモン'),
          content: TextField(
            decoration: const InputDecoration(labelText: '名前'),
            onChanged: (value) {
              newName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                final newDigimon = Digimon(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: newName.isEmpty ? 'デジモン${_digimonManager.digimons.length + 1}' : newName,
                );
                
                if (_digimonManager.addDigimon(newDigimon)) {
                  setState(() {
                    _digimonManager.switchDigimon(_digimonManager.digimons.length - 1);
                  });
                  _saveDigimon();
                  Navigator.pop(context);
                  _showSnackBar('${newDigimon.name}が仲間になった！');
                }
              },
              child: const Text('作成'),
            ),
          ],
        );
      },
    );
  }


}
