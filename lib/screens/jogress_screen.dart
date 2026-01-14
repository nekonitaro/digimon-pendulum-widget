import 'package:digimon_pendulum/models/evolution_stage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/digimon.dart';
import '../models/jogress_combination.dart';
import '../services/digimon_manager.dart';

class JogressScreen extends StatefulWidget {
  final DigimonManager digimonManager;

  const JogressScreen({
    super.key,
    required this.digimonManager,
  });

  @override
  State<JogressScreen> createState() => _JogressScreenState();
}

class _JogressScreenState extends State<JogressScreen>
    with TickerProviderStateMixin {
  int? _selectedIndex1;
  int? _selectedIndex2;
  JogressCombination? _combination;
  bool _isJogressing = false;
  
  late AnimationController _glowController;
  late AnimationController _rotateController;
  late AnimationController _mergeController;
  late AnimationController _explosionController;
  late Animation<double> _glowAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _mergeAnimation;
  late Animation<double> _explosionAnimation;

  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _rotateAnimation = Tween<double>(begin: 0, end: math.pi * 4).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );
    
    _mergeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _mergeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mergeController, curve: Curves.easeInOut),
    );
    
    _explosionController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _explosionAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _explosionController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _rotateController.dispose();
    _mergeController.dispose();
    _explosionController.dispose();
    super.dispose();
  }

  void _selectDigimon(int index) {
    setState(() {
      if (_selectedIndex1 == null) {
        _selectedIndex1 = index;
        HapticFeedback.lightImpact();
      } else if (_selectedIndex2 == null && _selectedIndex1 != index) {
        _selectedIndex2 = index;
        HapticFeedback.mediumImpact();
        _checkCombination();
      } else {
        _selectedIndex1 = null;
        _selectedIndex2 = null;
        _combination = null;
        HapticFeedback.lightImpact();
      }
    });
  }

  void _checkCombination() {
    if (_selectedIndex1 == null || _selectedIndex2 == null) return;
    
    final d1 = widget.digimonManager.digimons[_selectedIndex1!];
    final d2 = widget.digimonManager.digimons[_selectedIndex2!];
    
    setState(() {
      _combination = d1.getJogressCombination(d2);
    });
  }

  Future<void> _executeJogress() async {
    if (_selectedIndex1 == null || _selectedIndex2 == null || _combination == null) {
      return;
    }

    final confirm = await _showJogressConfirmDialog();
    if (confirm != true) return;

    setState(() {
      _isJogressing = true;
    });

    await _runJogressSequence();

    final success = widget.digimonManager.executeJogress(
      _selectedIndex1!,
      _selectedIndex2!,
      _combination!.requiredCoins,
    );

    if (!mounted) return;

    if (success) {
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.click);
      
      _showSnackBar(
        'ジョグレス成功！ ${_combination!.name} が誕生！',
        Colors.green,
      );
      
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      HapticFeedback.heavyImpact();
      _showSnackBar('ジョグレスに失敗しました', Colors.red);
      
      setState(() {
        _isJogressing = false;
        _selectedIndex1 = null;
        _selectedIndex2 = null;
        _combination = null;
      });
    }
  }

  Future<void> _runJogressSequence() async {
    _rotateController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    HapticFeedback.mediumImpact();
    
    await Future.delayed(const Duration(milliseconds: 1000));
    _mergeController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    HapticFeedback.heavyImpact();
    
    await Future.delayed(const Duration(milliseconds: 1000));
    _explosionController.forward();
    SystemSound.play(SystemSoundType.click);
    
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  Future<bool?> _showJogressConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2318),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.deepPurple, width: 3),
        ),
        title: const Row(
          children: [
            Text('🔀', style: TextStyle(fontSize: 32)),
            SizedBox(width: 10),
            Text(
              'ジョグレス進化',
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
            Text(
              '${_combination!.name} に進化します',
              style: const TextStyle(
                color: Color(0xFF9CB68C),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E2E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('💰', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        '${_combination!.requiredCoins} コイン',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('💎', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text(
                        '1 ストーン',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              '※合体元のデジモンは消滅します',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'キャンセル',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.withValues(alpha: 0.3),
              foregroundColor: Colors.deepPurple,
              side: const BorderSide(color: Colors.deepPurple, width: 2),
            ),
            child: const Text('ジョグレス！'),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E2E),
      appBar: AppBar(
        title: const Text('JOGRESS'),
        backgroundColor: const Color(0xFF2C3E2E),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _isJogressing
            ? _buildJogressAnimation()
            : _buildSelectionScreen(),
      ),
    );
  }

  Widget _buildSelectionScreen() {
    return Column(
      children: [
        const SizedBox(height: 15),
        
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2318),
            border: Border.all(color: Colors.deepPurple, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            '究極体デジモンを2体選択してください',
            style: TextStyle(
              color: Color(0xFF9CB68C),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 15),
        
        if (_selectedIndex1 != null || _selectedIndex2 != null)
          _buildSelectionPreview(),
        
        const SizedBox(height: 15),
        
        Expanded(
          child: _buildDigimonList(),
        ),
        
        const SizedBox(height: 15),
        
        if (_combination != null)
          _buildJogressButton(),
        
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildSelectionPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2318),
        border: Border.all(color: const Color(0xFF4A5A48), width: 3),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_selectedIndex1 != null)
            _buildPreviewDigimon(widget.digimonManager.digimons[_selectedIndex1!]),
          
          if (_selectedIndex1 != null && _selectedIndex2 != null)
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _glowAnimation.value,
                  child: const Text(
                    '➕',
                    style: TextStyle(fontSize: 40, color: Colors.deepPurple),
                  ),
                );
              },
            ),
          
          if (_selectedIndex2 != null)
            _buildPreviewDigimon(widget.digimonManager.digimons[_selectedIndex2!]),
          
          if (_combination != null) ...[
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _glowAnimation.value,
                  child: const Text(
                    '→',
                    style: TextStyle(fontSize: 40, color: Colors.yellow),
                  ),
                );
              },
            ),
            _buildResultPreview(),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewDigimon(Digimon digimon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: digimon.Color(evolutionStage.colorValue),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          digimon.name,
          style: const TextStyle(
            color: Color(0xFF9CB68C),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildResultPreview() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.yellow, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: const Center(
            child: Text('⭐', style: TextStyle(fontSize: 30)),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _combination!.name,
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDigimonList() {
    final ultimateDigimons = widget.digimonManager.digimons
        .asMap()
        .entries
        .where((entry) => entry.value.evolutionStage.index >= 5)
        .toList();

    if (ultimateDigimons.isEmpty) {
      return const Center(
        child: Text(
          '究極体デジモンがいません',
          style: TextStyle(
            color: Color(0xFF9CB68C),
            fontSize: 16,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2318),
        border: Border.all(color: const Color(0xFF4A5A48), width: 4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
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
                'ULTIMATE DIGIMON',
                style: TextStyle(
                  color: Color(0xFF9CB68C),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFF9CB68C),
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: ultimateDigimons.length,
                itemBuilder: (context, listIndex) {
                  final entry = ultimateDigimons[listIndex];
                  final index = entry.key;
                  final digimon = entry.value;
                  final isSelected = index == _selectedIndex1 || index == _selectedIndex2;

                  return _buildDigimonCard(digimon, index, isSelected);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigimonCard(Digimon digimon, int index, bool isSelected) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2318),
            border: Border.all(
              color: isSelected
                  ? Colors.deepPurple
                  : const Color(0xFF4A5A48),
              width: isSelected ? 4 : 3,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.deepPurple.withValues(alpha: _glowAnimation.value * 0.8),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _selectDigimon(index),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: digimon.Color(evolutionStage.colorValue),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? Colors.deepPurple : Colors.white,
                          width: isSelected ? 3 : 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            digimon.name,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.deepPurple
                                  : const Color(0xFF9CB68C),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lv.${digimon.level} ${digimon.evolutionStage.displayName}',
                            style: const TextStyle(
                              color: Color(0xFF88A878),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          index == _selectedIndex1 ? '1' : '2',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJogressButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: _executeJogress,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple.withValues(alpha: 0.3),
            foregroundColor: Colors.deepPurple,
            side: const BorderSide(color: Colors.deepPurple, width: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🔀',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: 10),
              Text(
                'ジョグレス進化！',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJogressAnimation() {
    return Stack(
      children: [
        Container(
          color: Colors.black,
        ),
        
        if (_selectedIndex1 != null)
          AnimatedBuilder(
            animation: Listenable.merge([_rotateAnimation, _mergeAnimation]),
            builder: (context, child) {
              final digimon = widget.digimonManager.digimons[_selectedIndex1!];
              final progress = _mergeAnimation.value;
              final centerX = MediaQuery.of(context).size.width / 2;
              final startX = centerX - 100;
              final currentX = startX + (centerX - startX) * progress;
              
              return Positioned(
                left: currentX - 75,
                top: MediaQuery.of(context).size.height * 0.4 - 75,
                child: Transform.rotate(
                  angle: _rotateAnimation.value,
                  child: Opacity(
                    opacity: 1 - progress * 0.5,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: digimon.Color(evolutionStage.colorValue),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: digimon.Color(evolutionStage.colorValue).withValues(alpha: 0.8),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        
        if (_selectedIndex2 != null)
          AnimatedBuilder(
            animation: Listenable.merge([_rotateAnimation, _mergeAnimation]),
            builder: (context, child) {
              final digimon = widget.digimonManager.digimons[_selectedIndex2!];
              final progress = _mergeAnimation.value;
              final centerX = MediaQuery.of(context).size.width / 2;
              final startX = centerX + 100;
              final currentX = startX - (startX - centerX) * progress;
              
              return Positioned(
                left: currentX - 75,
                top: MediaQuery.of(context).size.height * 0.4 - 75,
                child: Transform.rotate(
                  angle: -_rotateAnimation.value,
                  child: Opacity(
                    opacity: 1 - progress * 0.5,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: digimon.Color(evolutionStage.colorValue),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: digimon.Color(evolutionStage.colorValue).withValues(alpha: 0.8),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        
        AnimatedBuilder(
          animation: _explosionAnimation,
          builder: (context, child) {
            if (_explosionAnimation.value == 0) return const SizedBox.shrink();
            
            return Positioned.fill(
              child: CustomPaint(
                painter: _ExplosionPainter(progress: _explosionAnimation.value),
              ),
            );
          },
        ),
        
        if (_combination != null)
          AnimatedBuilder(
            animation: _explosionAnimation,
            builder: (context, child) {
              final progress = _explosionAnimation.value;
              if (progress < 0.5) return const SizedBox.shrink();
              
              final appearProgress = (progress - 0.5) * 2;
              
              return Positioned.fill(
                child: Center(
                  child: Transform.scale(
                    scale: appearProgress,
                    child: Opacity(
                      opacity: appearProgress,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.yellow, width: 5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.yellow.withValues(alpha: 0.8),
                                  blurRadius: 50,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('⭐', style: TextStyle(fontSize: 80)),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            _combination!.name,
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _ExplosionPainter extends CustomPainter {
  final double progress;

  _ExplosionPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 16; i++) {
      final angle = (i * math.pi / 8) + (progress * math.pi / 4);
      final length = progress * 300;
      final opacity = (1 - progress).clamp(0.0, 1.0);
      
      paint.color = Colors.yellow.withValues(alpha: opacity);
      
      final startX = centerX;
      final startY = centerY;
      final endX = centerX + math.cos(angle) * length;
      final endY = centerY + math.sin(angle) * length;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint..strokeWidth = 5,
      );
    }
    
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: (1 - progress).clamp(0.0, 1.0))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30 * progress);
    
    canvas.drawCircle(
      Offset(centerX, centerY),
      100 * progress,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ExplosionPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}