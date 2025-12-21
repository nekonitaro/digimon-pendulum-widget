import 'package:flutter/material.dart';

class DigimonSprite extends StatefulWidget {
  final String name;
  final int level;

  const DigimonSprite({
    super.key,
    required this.name,
    required this.level,
  });

  @override
  State<DigimonSprite> createState() => _DigimonSpriteState();
}

class _DigimonSpriteState extends State<DigimonSprite>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // アニメーションコントローラー（1秒で1往復）
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    // 上下に揺れるアニメーション
    _animation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: _getColorForLevel(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lv.${widget.level}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // レベルに応じて色を変える
  Color _getColorForLevel() {
    if (widget.level >= 5) {
      return Colors.red;
    } else if (widget.level >= 3) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }
}