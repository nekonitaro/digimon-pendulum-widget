import 'package:flutter/material.dart';
import '../models/shop_item.dart';
import '../services/shop_manager.dart';
import '../services/digimon_manager.dart';

class ShopScreen extends StatefulWidget {
  final DigimonManager digimonManager;
  final ShopManager shopManager;

  const ShopScreen({
    super.key,
    required this.digimonManager,
    required this.shopManager,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _totalCoins = 0;

  @override
  void initState() {
    super.initState();
    _updateTotalCoins();
  }

  void _updateTotalCoins() {
    int total = 0;
    for (var digimon in widget.digimonManager.digimons) {
      total += digimon.coins;
    }
    setState(() {
      _totalCoins = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ショップ'),
        backgroundColor: Colors.orange,
        actions: [
          // 所持コイン表示
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '$_totalCoins',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // コイン内訳ボタン（NEW!）
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showCoinBreakdown,
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: ShopCatalog.all.length,
        itemBuilder: (context, index) {
          final item = ShopCatalog.all[index];
          return _buildShopItemCard(item);
        },
      ),
    );
  }

  Widget _buildShopItemCard(ShopItem item) {
    final canAfford = _totalCoins >= item.price;

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: canAfford ? () => _confirmPurchase(item) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: canAfford ? item.color : Colors.grey,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // アイコン
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: canAfford 
                      ? item.color.withValues(alpha: 0.2) 
                      : Colors.grey.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  size: 32,
                  color: canAfford ? item.color : Colors.grey,
                ),
              ),

              // 商品名
              Text(
                item.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: canAfford ? Colors.black : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              // 説明
              Expanded(
                child: Center(
                  child: Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: canAfford ? Colors.grey[700] : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // 価格と購入ボタン
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: canAfford ? Colors.amber : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.price}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: canAfford ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canAfford ? () => _confirmPurchase(item) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.color,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        canAfford ? '購入' : 'コイン不足',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmPurchase(ShopItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('価格: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                Text(
                  ' ${item.price}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('所持: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                Text(
                  ' $_totalCoins',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
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
              _executePurchase(item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: item.color,
            ),
            child: const Text('購入する'),
          ),
        ],
      ),
    );
  }

  Future<void> _executePurchase(ShopItem item) async {
    final result = await widget.shopManager.purchaseItem(item);

    if (!mounted) return;

    // 結果を表示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );

    if (result.success) {
      // コイン更新
      _updateTotalCoins();

      // 🔧 デジモンデータを保存（重要！）
      await widget.digimonManager.save();

      // 成功時は画面を閉じて結果を返す
      if (mounted) {
        Navigator.pop(context, {
          'success': true,
          'item': item,
          'data': result.data,
        });
      }
    }
  }

  /// コイン内訳を表示
  void _showCoinBreakdown() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.monetization_on, color: Colors.amber),
            SizedBox(width: 8),
            Text('コイン内訳'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '各デジモンの所持コイン:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.digimonManager.digimons.asMap().entries.map((entry) {
              final index = entry.key;
              final digimon = entry.value;
              final isCurrent = index == widget.digimonManager.currentIndex;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    if (isCurrent)
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                    if (isCurrent)
                      const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${digimon.name}',
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${digimon.coins}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '合計:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '$_totalCoins',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}