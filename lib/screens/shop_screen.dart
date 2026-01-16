import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/shop_item.dart';
import '../services/digimon_manager.dart';
import '../services/shop_manager.dart';

class ShopScreen extends StatefulWidget {
  final DigimonManager digimonManager;

  const ShopScreen({super.key, required this.digimonManager});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with TickerProviderStateMixin {
  late ShopManager _shopManager;
  bool _isLoading = true;

  // アニメーションコントローラー
  late AnimationController _coinController;
  late Animation<double> _coinAnimation;

  @override
  void initState() {
    super.initState();
    _initializeShop();

    // コインアニメーション（キラキラ）
    _coinController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _coinAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _coinController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _coinController.dispose();
    super.dispose();
  }

  Future<void> _initializeShop() async {
    _shopManager = ShopManager(digimonManager: widget.digimonManager);
    await _shopManager.load();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _purchaseItem(ShopItem item) async {
    // 購入確認ダイアログ
    final confirm = await _showPurchaseDialog(item);
    if (confirm != true) return;

    // 振動
    HapticFeedback.mediumImpact();

    // 購入実行
    final result = await _shopManager.purchaseItem(item);

    if (!mounted) return;

    if (result.success) {
      // 成功時の演出
      _showPurchaseSuccessAnimation(item);

      // 効果音（システム音）
      SystemSound.play(SystemSoundType.click);

      // 成功メッセージ
      _showSnackBar('${item.name} を購入しました！', Colors.green);

      setState(() {});
    } else {
      // 失敗時の振動
      HapticFeedback.heavyImpact();

      // エラーメッセージ
      _showSnackBar(result.message, Colors.red);
    }
  }

  Future<bool?> _showPurchaseDialog(ShopItem item) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2318),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Color(0xFF4A5A48), width: 3),
        ),
        title: Row(
          children: [
            Icon(item.icon, size: 32, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(
                  color: Color(0xFF9CB68C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              style: const TextStyle(color: Color(0xFF9CB68C), fontSize: 14),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E2E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💰', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text(
                    '${item.price} コイン',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '購入しますか？',
              style: const TextStyle(color: Color(0xFF9CB68C), fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.withOpacity(0.3),
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green, width: 2),
            ),
            child: const Text('購入'),
          ),
        ],
      ),
    );
  }

  void _showPurchaseSuccessAnimation(ShopItem item) {
    // オーバーレイで購入成功エフェクト
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _PurchaseSuccessOverlay(item: item),
    );

    overlay.insert(overlayEntry);

    // 2秒後に削除
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCoinBreakdown() {
  // ✅ 改善: DigimonManager の getter を使用
  final totalCoins = widget.digimonManager.totalCoins;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1A2318),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFF4A5A48), width: 3),
      ),
      title: const Row(
        children: [
          Text('💰', style: TextStyle(fontSize: 28)),
          SizedBox(width: 10),
          Text(
            'コイン内訳',
            style: TextStyle(
              color: Color(0xFF9CB68C),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.digimonManager.digimons.map(
            (d) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      d.name,
                      style: const TextStyle(
                        color: Color(0xFF9CB68C),
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${d.coins}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Color(0xFF4A5A48), thickness: 2),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '合計',
                  style: TextStyle(
                    color: Color(0xFF9CB68C),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$totalCoins',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
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

 @override
Widget build(BuildContext context) {
  if (_isLoading) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E2E),
      appBar: AppBar(
        title: const Text('SHOP'),
        backgroundColor: const Color(0xFF2C3E2E),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: CircularProgressIndicator(color: Color(0xFF9CB68C)),
      ),
    );
  }

  // ✅ 改善: DigimonManager の getter を使用
  final totalCoins = widget.digimonManager.totalCoins;

  return Scaffold(
      backgroundColor: const Color(0xFF2C3E2E),
      appBar: AppBar(
        title: const Text('SHOP'),
        backgroundColor: const Color(0xFF2C3E2E),
        foregroundColor: Colors.white,
        actions: [
          // コイン内訳ボタン
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showCoinBreakdown,
            tooltip: 'コイン内訳',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // コイン表示エリア
            _buildCoinDisplay(totalCoins),

            const SizedBox(height: 15),

            // ジョグレスストーン所持数
            if (_shopManager.jogressItemCount > 0) _buildJogressStoneDisplay(),

            // ショップアイテムリスト
            Expanded(child: _buildShopItemList()),
          ],
        ),
      ),
    );
  }

  /// コイン表示エリア
  Widget _buildCoinDisplay(int totalCoins) {
    return AnimatedBuilder(
      animation: _coinAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _coinAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2318),
              border: Border.all(color: Colors.amber, width: 3),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💰', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '所持コイン',
                      style: TextStyle(color: Color(0xFF9CB68C), fontSize: 14),
                    ),
                    Text(
                      '$totalCoins',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ジョグレスストーン表示
  Widget _buildJogressStoneDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2318),
        border: Border.all(color: Colors.deepPurple, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💎', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Text(
            'ジョグレスストーン × ${_shopManager.jogressItemCount}',
            style: const TextStyle(
              color: Colors.deepPurple,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// ショップアイテムリスト
  Widget _buildShopItemList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2318),
        border: Border.all(color: const Color(0xFF4A5A48), width: 4),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
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
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF2C3E2E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: const Center(
              child: Text(
                'ITEM LIST',
                style: TextStyle(
                  color: Color(0xFF9CB68C),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          // アイテムリスト（スクロール可能）
          Expanded(
            child: Container(
              color: const Color(0xFF9CB68C),
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: ShopCatalog.all.length,
                itemBuilder: (context, index) {
                  final item = ShopCatalog.all[index];
                  final canPurchase = _shopManager.canPurchase(item);

                  return _buildShopItemCard(item, canPurchase);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ショップアイテムカード
  Widget _buildShopItemCard(ShopItem item, bool canPurchase) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2318),
        border: Border.all(
          color: canPurchase ? const Color(0xFF4A5A48) : Colors.grey,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: canPurchase
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canPurchase ? () => _purchaseItem(item) : null,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                // アイコン
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: canPurchase
                        ? const Color(0xFF2C3E2E)
                        : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: canPurchase ? Colors.amber : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(item.icon, size: 32, color: Colors.white),
                  ),
                ),

                const SizedBox(width: 15),

                // アイテム情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          color: canPurchase
                              ? const Color(0xFF9CB68C)
                              : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          color: canPurchase
                              ? const Color(0xFF88A878)
                              : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // 価格ボタン
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: canPurchase
                        ? Colors.amber.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: canPurchase ? Colors.amber : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💰', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 5),
                      Text(
                        '${item.price}',
                        style: TextStyle(
                          color: canPurchase ? Colors.amber : Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 購入成功時のオーバーレイエフェクト
class _PurchaseSuccessOverlay extends StatefulWidget {
  final ShopItem item;

  const _PurchaseSuccessOverlay({required this.item});

  @override
  State<_PurchaseSuccessOverlay> createState() =>
      _PurchaseSuccessOverlayState();
}

class _PurchaseSuccessOverlayState extends State<_PurchaseSuccessOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 40),
    ]).animate(_controller);

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: Colors.black.withOpacity(0.3 * _fadeAnimation.value),
              child: Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2318),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(widget.item.icon, size: 32, color: Colors.white),
                          const SizedBox(height: 15),
                          const Text(
                            '購入成功！',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.item.name,
                            style: const TextStyle(
                              color: Color(0xFF9CB68C),
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
