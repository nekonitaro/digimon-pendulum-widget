import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/digimon.dart';
import '../models/evolution_stage.dart';
import '../services/digimon_manager.dart';
import '../services/widget_service.dart';
import '../services/deep_link_service.dart';
import '../widgets/digimon_sprite.dart';
import 'battle_screen.dart';
import 'shop_screen.dart';
import 'jogress_screen.dart';
import 'settings_screen.dart';

/// ペンデュラム風のホーム画面
class HomeScreen extends StatefulWidget {
  final DigimonManager digimonManager;

  const HomeScreen({super.key, required this.digimonManager});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _initializeScreen();

    // 定期的な更新（1分ごと）
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateDigimon();
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    // 初期化処理
    _updateDigimon();

    // 通知チェック
    await widget.digimonManager.currentDigimon.checkAndNotify();

    // ディープリンク設定
    DeepLinkService.initialize((uri) => _handleWidgetClick(uri));
  }

  void _updateDigimon() {
    setState(() {
      widget.digimonManager.currentDigimon.updateByTimePassed();
    });
  }

  Future<void> _saveDigimon() async {
    await widget.digimonManager.save();
    await WidgetService.updateWidget(widget.digimonManager.currentDigimon);
  }

  void _handleWidgetClick(Uri? uri) {
    if (uri == null) return;

    if (uri.host == 'addcoin') {
      widget.digimonManager.currentDigimon.addCoins(1);
      _saveDigimon();
      _showSnackBar('コイン +1');
    } else if (uri.host == 'cleanpoop') {
      if (widget.digimonManager.currentDigimon.poopCount > 0) {
        widget.digimonManager.currentDigimon.cleanPoop();
        _saveDigimon();
        _showSnackBar('うんちを掃除しました');
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final digimon = widget.digimonManager.currentDigimon;

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E2E), // ペンデュラム本体の色
      body: SafeArea(
        child: Column(
          children: [
            // 上部ボタンエリア（スクロール可能）
            _buildTopButtonArea(digimon),

            const SizedBox(height: 15),

            // ヘッダー（デジモン選択）
            _buildHeader(digimon),

            const SizedBox(height: 10),

            // メイン液晶画面
            Expanded(child: _buildMainLcdScreen(digimon)),

            const SizedBox(height: 10),

            // ステータス表示エリア
            _buildStatusBar(digimon),

            const SizedBox(height: 15),

            // 下部ボタンエリア（スクロール可能）
            _buildBottomButtonArea(digimon),
          ],
        ),
      ),
    );
  }

  /// 上部ボタンエリア（横スクロール対応）
  Widget _buildTopButtonArea(Digimon digimon) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildPendulumButton(
            icon: Icons.favorite,
            label: 'なでる',
            color: Colors.pink,
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                digimon.pet();
              });
              _saveDigimon();
              _showSnackBar('なでなで～ 機嫌 +10');
            },
          ),
          const SizedBox(width: 15),
          _buildPendulumButton(
            icon: Icons.cleaning_services,
            label: '掃除',
            color: Colors.brown,
            onPressed: digimon.poopCount > 0
                ? () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      digimon.cleanPoop();
                    });
                    _saveDigimon();
                    _showSnackBar('うんちを掃除しました');
                  }
                : null,
          ),
          const SizedBox(width: 15),
          _buildPendulumButton(
            icon: Icons.flash_on,
            label: '進化',
            color: Colors.purple,
            onPressed: digimon.canEvolve()
                ? () {
                    HapticFeedback.heavyImpact();
                    setState(() {
                      final oldStage = digimon.evolutionStage.displayName;
                      digimon.evolve();
                      final newStage = digimon.evolutionStage.displayName;
                      _showSnackBar('$oldStage → $newStage に進化！');
                    });
                    _saveDigimon();
                  }
                : null,
          ),
          const SizedBox(width: 15),
          _buildPendulumButton(
            icon: Icons.settings,
            label: '設定',
            color: Colors.grey,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  /// 下部ボタンエリア（横スクロール対応）
  Widget _buildBottomButtonArea(Digimon digimon) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildPendulumButton(
            icon: Icons.arrow_upward,
            label: 'レベルUP',
            color: Colors.green,
            onPressed: digimon.canLevelUp()
                ? () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      digimon.levelUp();
                    });
                    _saveDigimon();
                    _showSnackBar('レベルアップ！ Lv.${digimon.level}');
                  }
                : null,
          ),
          const SizedBox(width: 15),
          _buildPendulumButton(
            icon: Icons.sports_kabaddi,
            label: 'バトル',
            color: Colors.red,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BattleScreen(playerDigimon: digimon),
                ),
              );
              if (result == true) {
                _saveDigimon();
                setState(() {});
              }
            },
          ),
          const SizedBox(width: 15),
          _buildPendulumButton(
            icon: Icons.explore,
            label: '冒険',
            color: Colors.orange,
            onPressed: () {
              HapticFeedback.lightImpact();
              final coins = digimon.adventure.collectCoins();
              final enemies = digimon.adventure.defeatedEnemies;
              if (coins > 0 || enemies > 0) {
                digimon.addCoins(coins);
                _saveDigimon();
                _showSnackBar('コイン +$coins / 敵撃破 $enemies');
              } else {
                _showSnackBar('何も見つかりませんでした');
              }
              setState(() {});
            },
          ),
          const SizedBox(width: 15),
          _buildPendulumButton(
            icon: Icons.storefront,
            label: 'ショップ',
            color: Colors.amber,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ShopScreen(digimonManager: widget.digimonManager),
                ),
              );
              if (result == true) {
                _saveDigimon();
                setState(() {});
              }
            },
          ),
          const SizedBox(width: 15),
          _buildPendulumButton(
            icon: Icons.merge_type,
            label: 'ジョグレス',
            color: Colors.deepPurple,
            onPressed: widget.digimonManager.digimons.length >= 2
                ? () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JogressScreen(
                          digimonManager: widget.digimonManager,
                        ),
                      ),
                    );
                    if (result == true) {
                      _saveDigimon();
                      setState(() {});
                    }
                  }
                : null,
          ),
          const SizedBox(width: 15),
          _buildPendulumButton(
            icon: Icons.list,
            label: 'デジモン',
            color: Colors.blue,
            onPressed: () {
              _showDigimonList();
            },
          ),
        ],
      ),
    );
  }

  /// ヘッダー部分（デジモン選択）
  Widget _buildHeader(Digimon digimon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // デジモン名
          Expanded(
            child: Text(
              digimon.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 進化段階
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(digimon.evolutionStage.colorValue).withValues(alpha:0.3),
              border: Border.all(
                color: Color(digimon.evolutionStage.colorValue),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              digimon.evolutionStage.displayName,
              style: TextStyle(
                color: Color(digimon.evolutionStage.colorValue),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // デジモン切り替えボタン
          if (widget.digimonManager.digimons.length > 1)
            IconButton(
              icon: const Icon(Icons.swap_horiz, color: Colors.white),
              onPressed: () {
                _showDigimonList();
              },
            ),
        ],
      ),
    );
  }

  /// メイン液晶画面エリア
  Widget _buildMainLcdScreen(Digimon digimon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2318),
        border: Border.all(color: const Color(0xFF4A5A48), width: 4),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 液晶画面タイトルバー
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF2C3E2E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: const Center(
              child: Text(
                'DIGITAL MONSTER',
                style: TextStyle(
                  color: Color(0xFF9CB68C),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),

          // デジモンスプライト表示エリア
          Expanded(
            child: Container(
              color: const Color(0xFF9CB68C),
              child: Center(
                child: DigimonSprite(
                  stage: digimon.evolutionStage,
                  name: digimon.name,
                  size: 150,
                ),
              ),
            ),
          ),

          // 下部情報バー（レベルとコイン）
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: const BoxDecoration(
              color: Color(0xFF2C3E2E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(11),
                bottomRight: Radius.circular(11),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLcdInfo('LV', digimon.level.toString()),
                _buildLcdInfo('💰', digimon.coins.toString()),
                _buildLcdInfo('😊', digimon.mood.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 液晶画面内の情報表示（ペンデュラム風フォント）
  Widget _buildLcdInfo(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9CB68C),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF9CB68C),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  /// ステータスバー（うんちや機嫌のゲージ）
  Widget _buildStatusBar(Digimon digimon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2318),
        border: Border.all(color: const Color(0xFF4A5A48), width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // 機嫌ゲージ
          _buildGauge('機嫌', digimon.mood, 100, Colors.pink),
          const SizedBox(height: 10),
          // 冒険進捗と戦績
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('💩', '${digimon.poopCount}'),
              _buildStatItem('🗺️', '${digimon.adventure.explorationLevel}%'),
              _buildStatItem('⚔️', '${digimon.battleWins}勝'),
            ],
          ),
        ],
      ),
    );
  }

  /// ゲージ表示（機嫌など）
  Widget _buildGauge(String label, int current, int max, Color color) {
    final ratio = (current / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9CB68C),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E2E),
            border: Border.all(color: const Color(0xFF4A5A48), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }

  /// ステータスアイテム表示
  Widget _buildStatItem(String icon, String value) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF9CB68C),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// ペンデュラム風の丸ボタン
  Widget _buildPendulumButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isEnabled
                    ? color.withValues(alpha:0.3)
                    : Colors.grey.withValues(alpha:0.2),
                border: Border.all(
                  color: isEnabled ? color : Colors.grey,
                  width: 3,
                ),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha:0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isEnabled ? color : Colors.grey,
                size: 30,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: isEnabled ? const Color(0xFF9CB68C) : Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// デジモンリスト表示ダイアログ
  void _showDigimonList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2318),
        title: const Text('デジモン選択', style: TextStyle(color: Color(0xFF9CB68C))),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.digimonManager.digimons.length,
            itemBuilder: (context, index) {
              final d = widget.digimonManager.digimons[index];
              final isCurrent =
                  index ==
                  widget.digimonManager.digimons.indexOf(
                    widget.digimonManager.currentDigimon,
                  );

              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(d.evolutionStage.colorValue),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  d.name,
                  style: TextStyle(
                    color: isCurrent ? Colors.yellow : const Color(0xFF9CB68C),
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  'Lv.${d.level} ${d.evolutionStage.displayName}',
                  style: const TextStyle(color: Color(0xFF88A878)),
                ),
                trailing: isCurrent
                    ? const Icon(Icons.check_circle, color: Colors.yellow)
                    : null,
                onTap: () {
                  setState(() {
                    widget.digimonManager.switchDigimon(index);
                  });
                  Navigator.pop(context);
                  _showSnackBar('${d.name} に切り替えました');
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '閉じる',
              style: TextStyle(color: Color(0xFF9CB68C)),
            ),
          ),
        ],
      ),
    );
  }
}
