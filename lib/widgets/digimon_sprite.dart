import 'package:flutter/material.dart';
import '../models/evolution_stage.dart';

class DigimonSprite extends StatefulWidget {
  final String name;
  final int level;
  final EvolutionStage evolutionStage;  // 追加

  const DigimonSprite({
    super.key,
    required this.name,
    required this.level,
    required this.evolutionStage,  // 追加
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
          color: _getColorForStage(),  // 変更
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
                widget.evolutionStage.displayName,  // 追加
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
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

 // 進化段階に応じて色を変える
  Color _getColorForStage() {
    switch (widget.evolutionStage) {
      case EvolutionStage.baby1:
        return Colors.lightBlue;
      case EvolutionStage.baby2:
        return Colors.blue;
      case EvolutionStage.child:
        return Colors.green;
      case EvolutionStage.adult:
        return Colors.orange;
      case EvolutionStage.perfect:
        return Colors.red;
      case EvolutionStage.ultimate:
        return Colors.purple;
    }
  }
}