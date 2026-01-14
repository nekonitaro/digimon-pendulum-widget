import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/digimon.dart';
import '../models/battle.dart';
import '../models/evolution_stage.dart';

class BattleScreen extends StatefulWidget {
  final Digimon playerDigimon;

  const BattleScreen({super.key, required this.playerDigimon});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with TickerProviderStateMixin {
  late Battle _battle;
  bool _battleStarted = false;
  bool _battleFinished = false;
  
  // アニメーションコントローラー
  late AnimationController _shakeController;
  late AnimationController _attackController;
  late AnimationController _scrollController;
  late AnimationController _criticalController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _attackAnimation;
  late Animation<double> _scrollAnimation;
  late Animation<double> _criticalAnimation;
  
  // バトル演出用
  bool _playerAttacking = false;
  bool _enemyAttacking = false;
  bool _isPlayerCritical = false;
  bool _isEnemyCritical = false;
  int _attackPhase = 0;

  @override
  void initState() {
    super.initState();
    // 敵を生成
    final enemy = generateEnemy(widget.playerDigimon.level);
    _battle = Battle(player: widget.playerDigimon, enemy: enemy);
    
    // アニメーション初期化
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _attackController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // 背景スクロール用（連続ループ）
    _scrollController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    // クリティカル演出用
    _criticalController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    
    _attackAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _attackController, curve: Curves.easeOut),
    );
    
    _scrollAnimation = Tween<double>(begin: 0, end: 1).animate(_scrollController);
    
    _criticalAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _criticalController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _attackController.dispose();
    _scrollController.dispose();
    _criticalController.dispose();
    super.dispose();
  }

  void _startBattle() {
    setState(() {
      _battleStarted = true;
      _attackPhase = 1;
    });

    // 効果音: バトル開始
    _playSound('battle_start');
    
    // 振動: 中程度
    HapticFeedback.mediumImpact();

    // バトル演出シーケンス
    _runBattleSequence();
  }

  Future<void> _runBattleSequence() async {
    // クリティカル判定（30%の確率）
    _isPlayerCritical = math.Random().nextDouble() < 0.3;
    _isEnemyCritical = math.Random().nextDouble() < 0.3;
    
    // フェーズ1: プレイヤー攻撃
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _playerAttacking = true;
    });
    
    // 効果音: 攻撃
    _playSound('attack');
    
    // 振動: 軽い
    HapticFeedback.lightImpact();
    
    _attackController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    
    // ヒット時の演出
    if (_isPlayerCritical) {
      // クリティカルヒット！
      _playSound('critical');
      HapticFeedback.heavyImpact(); // 強い振動
      _criticalController.forward();
      await Future.delayed(const Duration(milliseconds: 200));
    } else {
      // 通常ヒット
      _playSound('hit');
      HapticFeedback.mediumImpact();
    }
    
    _shakeController.forward().then((_) => _shakeController.reverse());
    
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _playerAttacking = false;
      _attackPhase = 2;
    });
    _attackController.reset();
    _criticalController.reset();

    // フェーズ2: 敵攻撃
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _enemyAttacking = true;
    });
    
    // 効果音: 攻撃
    _playSound('attack');
    HapticFeedback.lightImpact();
    
    _attackController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    
    // ヒット時の演出
    if (_isEnemyCritical) {
      // クリティカルヒット！
      _playSound('critical');
      HapticFeedback.heavyImpact();
      _criticalController.forward();
      await Future.delayed(const Duration(milliseconds: 200));
    } else {
      // 通常ヒット
      _playSound('hit');
      HapticFeedback.mediumImpact();
    }
    
    _shakeController.forward().then((_) => _shakeController.reverse());
    
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _enemyAttacking = false;
      _attackPhase = 3;
    });
    _criticalController.reset();

    // フェーズ3: 結果判定
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _battle.execute();
      _battleFinished = true;
    });
    
    // 効果音: 勝敗
    if (_battle.playerWon) {
      _playSound('victory');
      HapticFeedback.heavyImpact();
    } else {
      _playSound('defeat');
      HapticFeedback.mediumImpact();
    }
  }

  /// 効果音再生（ビープ音で代用）
  void _playSound(String type) {
    // 実際の効果音ファイルがない場合、システム音で代用
    switch (type) {
      case 'battle_start':
      case 'attack':
      case 'hit':
        SystemSound.play(SystemSoundType.click);
        break;
      case 'critical':
        // クリティカルは2回鳴らす
        SystemSound.play(SystemSoundType.click);
        Future.delayed(const Duration(milliseconds: 50), () {
          SystemSound.play(SystemSoundType.click);
        });
        break;
      case 'victory':
        // 勝利音（3連続）
        SystemSound.play(SystemSoundType.click);
        Future.delayed(const Duration(milliseconds: 100), () {
          SystemSound.play(SystemSoundType.click);
        });
        Future.delayed(const Duration(milliseconds: 200), () {
          SystemSound.play(SystemSoundType.click);
        });
        break;
      case 'defeat':
        // 敗北音（低い音）
        SystemSound.play(SystemSoundType.click);
        break;
    }
    
    // TODO: 実際のオーディオファイルを使用する場合
    // final player = AudioPlayer();
    // await player.play(AssetSource('sounds/$type.mp3'));
  }

  void _finishBattle() {
    // 結果を反映
    if (_battle.playerWon) {
      widget.playerDigimon.recordWin(_battle.coinsEarned);
    } else {
      widget.playerDigimon.recordLoss(_battle.coinsEarned);
    }
    
    // 画面を閉じる
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E2E),
      appBar: AppBar(
        title: const Text('BATTLE'),
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // メインバトル画面
            Expanded(
              child: _buildBattleScreen(),
            ),
            
            const SizedBox(height: 20),
            
            // 下部ボタンエリア
            _buildBottomArea(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// メインバトル画面（液晶風）
  Widget _buildBattleScreen() {
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
          // タイトルバー
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF8B0000),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Center(
              child: Text(
                _getBattlePhaseText(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          
          // バトルフィールド（スクロール背景付き）
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(11),
                bottomRight: Radius.circular(11),
              ),
              child: Stack(
                children: [
                  // スクロールする背景
                  AnimatedBuilder(
                    animation: _scrollAnimation,
                    builder: (context, child) {
                      return Container(
                        color: const Color(0xFF9CB68C),
                        child: CustomPaint(
                          size: const Size(double.infinity, double.infinity),
                          painter: _ScrollingBgPainter(
                            scrollOffset: _scrollAnimation.value,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // バトルフィールド本体
                  _buildBattleField(),
                ],
              ),
            ),
          ),
          
          // 下部情報バー
          _buildBattleInfoBar(),
        ],
      ),
    );
  }

  String _getBattlePhaseText() {
    if (!_battleStarted) return 'ENEMY APPEARED!';
    if (_battleFinished) return _battle.playerWon ? 'YOU WIN!' : 'YOU LOSE...';
    if (_playerAttacking && _isPlayerCritical) return 'CRITICAL HIT!';
    if (_enemyAttacking && _isEnemyCritical) return 'CRITICAL HIT!';
    if (_playerAttacking) return 'PLAYER ATTACK!';
    if (_enemyAttacking) return 'ENEMY ATTACK!';
    return 'BATTLE START!';
  }

  /// バトルフィールド（デジモン2体の表示）
  Widget _buildBattleField() {
    return Stack(
      children: [
        // プレイヤーデジモン（左）
        Positioned(
          left: 30,
          bottom: 80,
          child: _buildPlayerDigimon(),
        ),
        
        // 敵デジモン（右）
        Positioned(
          right: 30,
          bottom: 80,
          child: _buildEnemyDigimon(),
        ),
        
        // 攻撃エフェクト
        if (_playerAttacking) _buildAttackEffect(isPlayer: true, isCritical: _isPlayerCritical),
        if (_enemyAttacking) _buildAttackEffect(isPlayer: false, isCritical: _isEnemyCritical),
        
        // クリティカルヒット演出
        if (_playerAttacking && _isPlayerCritical)
          _buildCriticalEffect(isPlayer: false),
        if (_enemyAttacking && _isEnemyCritical)
          _buildCriticalEffect(isPlayer: true),
        
        // 中央メッセージ
        if (!_battleStarted || _battleFinished)
          Center(child: _buildCenterMessage()),
      ],
    );
  }

  /// プレイヤーデジモン表示
  Widget _buildPlayerDigimon() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shake = _enemyAttacking ? _shakeAnimation.value : 0.0;
        return Transform.translate(
          offset: Offset(shake * math.sin(_shakeController.value * math.pi * 4), 0),
          child: _buildDigimonSprite(
            widget.playerDigimon,
            isPlayer: true,
          ),
        );
      },
    );
  }

  /// 敵デジモン表示
  Widget _buildEnemyDigimon() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shake = _playerAttacking ? _shakeAnimation.value : 0.0;
        return Transform.translate(
          offset: Offset(-shake * math.sin(_shakeController.value * math.pi * 4), 0),
          child: _buildDigimonSprite(
            _battle.enemy,
            isPlayer: false,
          ),
        );
      },
    );
  }

  /// デジモンスプライト（簡易版）
  Widget _buildDigimonSprite(Digimon digimon, {required bool isPlayer}) {
    final color = Color(digimon.evolutionStage.colorValue);
    final size = 60.0;
    
    return Column(
      children: [
        // 名前
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E2E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            digimon.name,
            style: const TextStyle(
              color: Color(0xFF9CB68C),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // スプライト
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.3),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              isPlayer ? '👊' : '💀',
              style: const TextStyle(fontSize: 30),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // レベル
        Text(
          'Lv.${digimon.level}',
          style: const TextStyle(
            color: Color(0xFF2C3E2E),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 攻撃エフェクト（クリティカル対応）
  Widget _buildAttackEffect({required bool isPlayer, required bool isCritical}) {
    return AnimatedBuilder(
      animation: _attackAnimation,
      builder: (context, child) {
        final progress = _attackAnimation.value;
        final startX = isPlayer ? 100.0 : MediaQuery.of(context).size.width - 100;
        final endX = isPlayer ? MediaQuery.of(context).size.width - 100 : 100.0;
        final currentX = startX + (endX - startX) * progress;
        
        // クリティカルの場合はサイズが大きい
        final size = isCritical ? 40.0 : 30.0;
        final glowSpread = isCritical ? 10.0 : 5.0;
        
        return Positioned(
          left: currentX - size / 2,
          top: MediaQuery.of(context).size.height * 0.4,
          child: Opacity(
            opacity: 1 - progress,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: isCritical ? Colors.red : Colors.yellow,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isCritical ? Colors.red : Colors.yellow).withValues(alpha:0.8),
                    blurRadius: 15,
                    spreadRadius: glowSpread,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  isCritical ? '💢' : '💥',
                  style: TextStyle(fontSize: isCritical ? 25 : 20),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// クリティカルヒット演出（星が飛び散る）
  Widget _buildCriticalEffect({required bool isPlayer}) {
    return AnimatedBuilder(
      animation: _criticalAnimation,
      builder: (context, child) {
        final progress = _criticalAnimation.value;
        final centerX = isPlayer ? 100.0 : MediaQuery.of(context).size.width - 100;
        final centerY = MediaQuery.of(context).size.height * 0.4;
        
        return Stack(
          children: List.generate(8, (index) {
            final angle = (index * math.pi / 4) + (progress * math.pi / 4);
            final distance = progress * 50;
            final x = centerX + math.cos(angle) * distance;
            final y = centerY + math.sin(angle) * distance;
            
            return Positioned(
              left: x - 10,
              top: y - 10,
              child: Opacity(
                opacity: 1 - progress,
                child: Transform.rotate(
                  angle: progress * math.pi * 2,
                  child: const Text(
                    '⭐',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  /// 中央メッセージ
  Widget _buildCenterMessage() {
    if (!_battleStarted) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2C3E2E).withValues(alpha:0.9),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.red, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_battle.enemy.name} が現れた！',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '敵 Lv.${_battle.enemy.level}',
              style: const TextStyle(
                color: Color(0xFF9CB68C),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    if (_battleFinished) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2C3E2E).withValues(alpha:0.9),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _battle.playerWon ? Colors.green : Colors.red,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _battle.resultMessage,
              style: TextStyle(
                color: _battle.playerWon ? Colors.green : Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              'コイン +${_battle.coinsEarned}',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 20,
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  /// 下部情報バー
  Widget _buildBattleInfoBar() {
    return Container(
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
          _buildStatDisplay('💪', widget.playerDigimon.level.toString()),
          _buildStatDisplay('VS', ''),
          _buildStatDisplay('💀', _battle.enemy.level.toString()),
        ],
      ),
    );
  }

  Widget _buildStatDisplay(String icon, String value) {
    return Row(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 16),
        ),
        if (value.isNotEmpty) ...[
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF9CB68C),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  /// 下部ボタンエリア
  Widget _buildBottomArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: !_battleStarted
          ? _buildPendulumButton(
              label: 'バトル開始！',
              color: Colors.red,
              onPressed: _startBattle,
            )
          : _battleFinished
              ? _buildPendulumButton(
                  label: '戻る',
                  color: Colors.blue,
                  onPressed: _finishBattle,
                )
              : const SizedBox(
                  height: 60,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF9CB68C),
                    ),
                  ),
                ),
    );
  }

  /// ペンデュラム風ボタン
  Widget _buildPendulumButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha:0.3),
          foregroundColor: color,
          side: BorderSide(color: color, width: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

/// スクロールする背景パターン描画
class _ScrollingBgPainter extends CustomPainter {
  final double scrollOffset;

  _ScrollingBgPainter({required this.scrollOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF88A878).withValues(alpha:0.2)
      ..style = PaintingStyle.fill;

    // スクロールするドットパターン
    const spacing = 6.0;
    final offsetX = scrollOffset * size.width;
    
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final scrolledX = (x + offsetX) % size.width;
        canvas.drawCircle(
          Offset(scrolledX, y),
          0.8,
          paint,
        );
      }
    }
    
    // 地面のライン（複数本でスクロール感）
    final groundPaint = Paint()
      ..color = const Color(0xFF2C3E2E).withValues(alpha:0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < 3; i++) {
      final y = size.height * (0.6 + i * 0.05);
      final lineOffset = (scrollOffset * size.width * (1 + i * 0.3)) % size.width;
      
      // 左のライン
      canvas.drawLine(
        Offset(lineOffset - size.width, y),
        Offset(lineOffset, y),
        groundPaint,
      );
      
      // 右のライン
      canvas.drawLine(
        Offset(lineOffset, y),
        Offset(lineOffset + size.width, y),
        groundPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScrollingBgPainter oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset;
  }
}