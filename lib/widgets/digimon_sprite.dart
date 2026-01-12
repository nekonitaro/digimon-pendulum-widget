import 'package:flutter/material.dart';
import '../models/evolution_stage.dart';

/// ペンデュラム風のデジモンスプライト表示ウィジェット
class DigimonSprite extends StatefulWidget {
  final EvolutionStage stage;
  final String name;
  final double size;

  const DigimonSprite({
    super.key,
    required this.stage,
    required this.name,
    this.size = 120,
  });

  @override
  State<DigimonSprite> createState() => _DigimonSpriteState();
}

class _DigimonSpriteState extends State<DigimonSprite>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentFrame = 0;

  @override
  void initState() {
    super.initState();
    // 5フレームアニメーション（1秒で1ループ）
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    _controller.addListener(() {
      final newFrame = (_controller.value * 5).floor() % 5;
      if (newFrame != _currentFrame) {
        setState(() {
          _currentFrame = newFrame;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        // ペンデュラム風の液晶画面背景
        color: const Color(0xFF9CB68C), // 懐かしい液晶グリーン
        border: Border.all(color: const Color(0xFF2C3E2E), width: 3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 液晶のドットパターン背景
          _buildLcdPattern(),
          // デジモンスプライト
          Center(
            child: _buildDigimonSprite(),
          ),
        ],
      ),
    );
  }

  /// 液晶画面のドットパターン
  Widget _buildLcdPattern() {
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _LcdPatternPainter(),
    );
  }

  /// デジモンのドット絵スプライト
  Widget _buildDigimonSprite() {
    return CustomPaint(
      size: Size(widget.size * 0.6, widget.size * 0.6),
      painter: _DigimonPixelPainter(
        stage: widget.stage,
        frame: _currentFrame,
      ),
    );
  }
}

/// 液晶画面のドットパターンを描画
class _LcdPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF88A878).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // 格子状のドットパターン
    const spacing = 4.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(
          Offset(x, y),
          0.5,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// デジモンのドット絵を描画（5フレームアニメーション対応）
class _DigimonPixelPainter extends CustomPainter {
  final EvolutionStage stage;
  final int frame;

  _DigimonPixelPainter({
    required this.stage,
    required this.frame,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pixelSize = size.width / 16; // 16x16ドット絵を想定
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 進化段階に応じた色
    final color = Color(stage.colorValue);
    final darkColor = Color.lerp(color, Colors.black, 0.4)!;
    final lightColor = Color.lerp(color, Colors.white, 0.3)!;

    // 各進化段階のドット絵パターンを描画
    switch (stage) {
      case EvolutionStage.baby1:
        _drawBaby1(canvas, centerX, centerY, pixelSize, color, darkColor, lightColor);
        break;
      case EvolutionStage.baby2:
        _drawBaby2(canvas, centerX, centerY, pixelSize, color, darkColor, lightColor);
        break;
      case EvolutionStage.child:
        _drawChild(canvas, centerX, centerY, pixelSize, color, darkColor, lightColor);
        break;
      case EvolutionStage.adult:
        _drawAdult(canvas, centerX, centerY, pixelSize, color, darkColor, lightColor);
        break;
      case EvolutionStage.perfect:
        _drawPerfect(canvas, centerX, centerY, pixelSize, color, darkColor, lightColor);
        break;
      case EvolutionStage.ultimate:
        _drawUltimate(canvas, centerX, centerY, pixelSize, color, darkColor, lightColor);
        break;
      case EvolutionStage.superUltimate:
        _drawSuperUltimate(canvas, centerX, centerY, pixelSize, color, darkColor, lightColor);
        break;
    }
  }

  /// ドットを描画するヘルパー関数
  void _drawPixel(Canvas canvas, double x, double y, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(x - size / 2, y - size / 2, size, size),
      paint,
    );
  }

  /// 幼年期Ⅰ: 小さな丸い生物
  void _drawBaby1(Canvas canvas, double cx, double cy, double ps, Color c, Color d, Color l) {
    final bounce = (frame % 2 == 0) ? 0.0 : -ps * 0.5; // バウンドアニメーション
    
    // 体（4x4）
    for (int y = -2; y <= 1; y++) {
      for (int x = -2; x <= 1; x++) {
        if ((x.abs() + y.abs()) <= 3) {
          _drawPixel(canvas, cx + x * ps, cy + y * ps + bounce, ps, c);
        }
      }
    }
    
    // 目（フレームで瞬き）
    if (frame != 2) {
      _drawPixel(canvas, cx - ps, cy - ps + bounce, ps * 0.6, d);
      _drawPixel(canvas, cx + ps, cy - ps + bounce, ps * 0.6, d);
    }
    
    // 口（フレームで動く）
    final mouthY = frame == 1 ? cy + ps * 0.5 : cy;
    _drawPixel(canvas, cx, mouthY + bounce, ps * 0.5, d);
  }

  /// 幼年期Ⅱ: 少し大きくなった形
  void _drawBaby2(Canvas canvas, double cx, double cy, double ps, Color c, Color d, Color l) {
    final sway = (frame % 3 == 0) ? -ps * 0.3 : (frame % 3 == 1) ? ps * 0.3 : 0.0;
    
    // 頭（5x4）
    for (int y = -2; y <= 1; y++) {
      for (int x = -2; x <= 2; x++) {
        if (y == -2 && x.abs() <= 1) {
          _drawPixel(canvas, cx + x * ps + sway, cy + y * ps, ps, l);
        } else if (y >= -1) {
          _drawPixel(canvas, cx + x * ps + sway, cy + y * ps, ps, c);
        }
      }
    }
    
    // 手（フレームで動く）
    final armOffset = (frame == 1 || frame == 3) ? ps : 0.0;
    _drawPixel(canvas, cx - 3 * ps + sway, cy + armOffset, ps, c);
    _drawPixel(canvas, cx + 3 * ps + sway, cy + armOffset, ps, c);
    
    // 目
    _drawPixel(canvas, cx - ps + sway, cy - ps, ps * 0.6, d);
    _drawPixel(canvas, cx + ps + sway, cy - ps, ps * 0.6, d);
    
    // 口
    _drawPixel(canvas, cx + sway, cy, ps * 0.7, d);
  }

  /// 成長期: 手足が明確な形
  void _drawChild(Canvas canvas, double cx, double cy, double ps, Color c, Color d, Color l) {
    final walkCycle = frame % 4;
    final legL = walkCycle < 2 ? 0.0 : ps;
    final legR = walkCycle >= 2 ? 0.0 : ps;
    
    // 頭
    for (int y = -3; y <= -1; y++) {
      for (int x = -2; x <= 2; x++) {
        _drawPixel(canvas, cx + x * ps, cy + y * ps, ps, l);
      }
    }
    
    // 体
    for (int y = 0; y <= 2; y++) {
      for (int x = -2; x <= 2; x++) {
        if (x.abs() <= 1 || y == 0) {
          _drawPixel(canvas, cx + x * ps, cy + y * ps, ps, c);
        }
      }
    }
    
    // 腕（フレームで動く）
    final armSwing = (frame == 0 || frame == 2) ? -ps : ps;
    _drawPixel(canvas, cx - 3 * ps, cy + armSwing, ps, c);
    _drawPixel(canvas, cx + 3 * ps, cy - armSwing, ps, c);
    
    // 足（歩行アニメーション）
    _drawPixel(canvas, cx - ps, cy + 3 * ps + legL, ps, d);
    _drawPixel(canvas, cx + ps, cy + 3 * ps + legR, ps, d);
    
    // 目
    _drawPixel(canvas, cx - ps, cy - 2 * ps, ps * 0.7, d);
    _drawPixel(canvas, cx + ps, cy - 2 * ps, ps * 0.7, d);
  }

  /// 成熟期: より戦闘的な姿
  void _drawAdult(Canvas canvas, double cx, double cy, double ps, Color c, Color d, Color l) {
    _drawHumanoidBase(canvas, cx, cy, ps, c, d, l, scale: 1.0);
  }

  /// 完全体: さらに大きく
  void _drawPerfect(Canvas canvas, double cx, double cy, double ps, Color c, Color d, Color l) {
    _drawHumanoidBase(canvas, cx, cy, ps, c, d, l, scale: 1.2);
    // 追加の装飾（肩アーマーなど）
    _drawPixel(canvas, cx - 4 * ps, cy - ps, ps, l);
    _drawPixel(canvas, cx + 4 * ps, cy - ps, ps, l);
  }

  /// 究極体: 威圧感のある姿
  void _drawUltimate(Canvas canvas, double cx, double cy, double ps, Color c, Color d, Color l) {
    _drawHumanoidBase(canvas, cx, cy, ps, c, d, l, scale: 1.4);
    // 翼や角などの装飾
    _drawPixel(canvas, cx - 5 * ps, cy - 2 * ps, ps, l);
    _drawPixel(canvas, cx + 5 * ps, cy - 2 * ps, ps, l);
    _drawPixel(canvas, cx, cy - 4 * ps, ps, l); // 角
  }

  /// 超究極体: 最終進化形態（輝きエフェクト付き）
  void _drawSuperUltimate(Canvas canvas, double cx, double cy, double ps, Color c, Color d, Color l) {
    // 輝きエフェクト（フレームで点滅）
    if (frame % 2 == 0) {
      final glowPaint = Paint()
        ..color = Colors.yellow.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(Offset(cx, cy), ps * 6, glowPaint);
    }
    
    _drawHumanoidBase(canvas, cx, cy, ps, c, d, l, scale: 1.6);
    
    // 豪華な装飾
    for (int i = -6; i <= 6; i += 2) {
      _drawPixel(canvas, cx + i * ps, cy - 3 * ps, ps, l);
    }
    _drawPixel(canvas, cx, cy - 5 * ps, ps, Colors.yellow); // 頂点
  }

  /// 人型の基本形を描画（成熟期以降で使用）
  void _drawHumanoidBase(Canvas canvas, double cx, double cy, double ps, 
                          Color c, Color d, Color l, {double scale = 1.0}) {
    final s = scale;
    final walkCycle = frame % 4;
    final legL = walkCycle < 2 ? 0.0 : ps * 0.5;
    final legR = walkCycle >= 2 ? 0.0 : ps * 0.5;
    
    // 頭
    for (int y = -3; y <= -1; y++) {
      for (int x = -1; x <= 1; x++) {
        _drawPixel(canvas, cx + x * ps * s, cy + y * ps * s, ps * s, l);
      }
    }
    
    // 体
    for (int y = 0; y <= 2; y++) {
      for (int x = -1; x <= 1; x++) {
        _drawPixel(canvas, cx + x * ps * s, cy + y * ps * s, ps * s, c);
      }
    }
    
    // 腕
    final armSwing = (frame == 0 || frame == 2) ? -ps * 0.5 : ps * 0.5;
    _drawPixel(canvas, cx - 2 * ps * s, cy + armSwing, ps * s, c);
    _drawPixel(canvas, cx + 2 * ps * s, cy - armSwing, ps * s, c);
    
    // 足
    _drawPixel(canvas, cx - ps * s, cy + 3 * ps * s + legL, ps * s, d);
    _drawPixel(canvas, cx + ps * s, cy + 3 * ps * s + legR, ps * s, d);
    
    // 目
    _drawPixel(canvas, cx - ps * 0.5 * s, cy - 2 * ps * s, ps * 0.6 * s, d);
    _drawPixel(canvas, cx + ps * 0.5 * s, cy - 2 * ps * s, ps * 0.6 * s, d);
  }

  @override
  bool shouldRepaint(covariant _DigimonPixelPainter oldDelegate) {
    return oldDelegate.frame != frame || oldDelegate.stage != stage;
  }
}