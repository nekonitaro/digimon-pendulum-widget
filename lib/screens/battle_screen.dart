import 'package:flutter/material.dart';
import '../models/digimon.dart';
import '../models/battle.dart';

class BattleScreen extends StatefulWidget {
  final Digimon playerDigimon;

  const BattleScreen({super.key, required this.playerDigimon});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late Battle _battle;
  bool _battleStarted = false;
  bool _battleFinished = false;

  @override
  void initState() {
    super.initState();
    // 敵を生成
    final enemy = generateEnemy(widget.playerDigimon.level);
    _battle = Battle(player: widget.playerDigimon, enemy: enemy);
  }

  void _startBattle() {
    setState(() {
      _battleStarted = true;
    });

    // 1秒後にバトル実行
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _battle.execute();
        _battleFinished = true;
      });
    });
  }

  void _finishBattle() {
    // 結果を反映
    if (_battle.playerWon) {
      widget.playerDigimon.recordWin(_battle.coinsEarned);
    } else {
      widget.playerDigimon.recordLoss(_battle.coinsEarned);
    }
    
    // 画面を閉じる
    Navigator.pop(context, true); // trueを返して保存をトリガー
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('バトル'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_battleStarted) ...[
                // バトル開始前
                Text(
                  '${_battle.enemy.name} が現れた！',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text('敵 Lv.${_battle.enemy.level}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: _startBattle,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('バトル開始！', style: TextStyle(fontSize: 20)),
                ),
              ] else if (!_battleFinished) ...[
                // バトル中
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                const Text('バトル中...', style: TextStyle(fontSize: 20)),
              ] else ...[
                // バトル終了
                Text(
                  _battle.resultMessage,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _battle.playerWon ? Colors.green : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Text(
                  'コイン +${_battle.coinsEarned}',
                  style: const TextStyle(fontSize: 24, color: Colors.amber),
                ),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: _finishBattle,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                  ),
                  child: const Text('戻る', style: TextStyle(fontSize: 20)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}