import 'package:flutter/material.dart';
import '../models/digimon.dart';
import '../services/digimon_manager.dart';
import '../models/jogress_combination.dart';
import '../models/evolution_stage.dart'; // 追加

class JogressScreen extends StatefulWidget {
  final DigimonManager digimonManager;
  final int totalCoins; // 所持コイン総数

  const JogressScreen({
    super.key,
    required this.digimonManager,
    required this.totalCoins,
  });

  @override
  State<JogressScreen> createState() => _JogressScreenState();
}

class _JogressScreenState extends State<JogressScreen> {
  List<Map<String, dynamic>> _jogressablePairs = [];

  @override
  void initState() {
    super.initState();
    _loadJogressablePairs();
  }

  void _loadJogressablePairs() {
    setState(() {
      _jogressablePairs = widget.digimonManager.getJogressablePairs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ジョグレス進化'),
        backgroundColor: Colors.purple,
      ),
      body: _jogressablePairs.isEmpty
          ? _buildEmptyState()
          : _buildJogressList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'ジョグレス可能なデジモンがいません',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '究極体のデジモンを2体育成してください',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJogressList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _jogressablePairs.length,
      itemBuilder: (context, index) {
        final pair = _jogressablePairs[index];
        return _buildJogressCard(pair);
      },
    );
  }

  Widget _buildJogressCard(Map<String, dynamic> pair) {
    final digimon1 = pair['digimon1'] as Digimon;
    final digimon2 = pair['digimon2'] as Digimon;
    final combination = pair['combination'] as JogressCombination;
    final canAfford = widget.totalCoins >= combination.requiredCoins;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // タイトル
            Text(
              combination.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              combination.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // デジモン1 + デジモン2
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDigimonInfo(digimon1),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.add, size: 32, color: Colors.grey),
                ),
                _buildDigimonInfo(digimon2),
              ],
            ),
            const SizedBox(height: 16),

            // 矢印
            const Icon(Icons.arrow_downward, size: 32, color: Colors.purple),
            const SizedBox(height: 16),

            // 結果
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    '超究極体',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    combination.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 必要コイン
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '必要コイン: ${combination.requiredCoins}',
                  style: TextStyle(
                    fontSize: 16,
                    color: canAfford ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ジョグレスボタン
            ElevatedButton.icon(
              onPressed: canAfford
                  ? () => _confirmJogress(pair)
                  : null,
              icon: const Icon(Icons.merge_type),
              label: Text(
                canAfford ? 'ジョグレス進化' : 'コイン不足',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 50),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigimonInfo(Digimon digimon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // デジモンアイコン（色付き円）
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(digimon.evolutionStage.colorValue),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            digimon.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Lv.${digimon.level}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmJogress(Map<String, dynamic> pair) {
    final digimon1 = pair['digimon1'] as Digimon;
    final digimon2 = pair['digimon2'] as Digimon;
    final combination = pair['combination'] as JogressCombination;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ジョグレス進化確認'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${digimon1.name} と ${digimon2.name} を融合して'),
            Text(
              combination.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const Text('に進化させますか？'),
            const SizedBox(height: 16),
            const Text(
              '⚠️ 警告',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('・元のデジモンは消滅します'),
            const Text('・この操作は取り消せません'),
            const SizedBox(height: 8),
            Text('必要コイン: ${combination.requiredCoins}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _executeJogress(pair);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: const Text('ジョグレス進化！'),
          ),
        ],
      ),
    );
  }

  void _executeJogress(Map<String, dynamic> pair) {
    final index1 = pair['index1'] as int;
    final index2 = pair['index2'] as int;
    final combination = pair['combination'] as JogressCombination;

    final success = widget.digimonManager.executeJogress(
      index1,
      index2,
      widget.totalCoins,
    );

    if (success) {
      // 成功時は画面を閉じて結果を返す
      Navigator.pop(context, {
        'success': true,
        'coinsSpent': combination.requiredCoins,
        'resultName': combination.name,
      });

      // 成功メッセージ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${combination.name}に進化した！'),
          backgroundColor: Colors.purple,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      // 失敗時
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ジョグレス進化に失敗しました'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}