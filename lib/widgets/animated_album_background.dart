import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedAlbumBackground extends StatefulWidget {
  final String imageUrl;

  const AnimatedAlbumBackground({required this.imageUrl, super.key});

  @override
  State<AnimatedAlbumBackground> createState() =>
      _AnimatedAlbumBackgroundState();
}

class _AnimatedAlbumBackgroundState extends State<AnimatedAlbumBackground>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _shiftController;
  late final AnimationController _rotateController;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _shiftAnimation;
  late final Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Faster scale animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // More dramatic shift
    _shiftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    // New rotation animation
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Larger scale range
    _scaleAnimation = Tween<double>(begin: 1.1, end: 1.3).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOutCubic),
    );

    // More dramatic shift
    _shiftAnimation = Tween<Offset>(
      begin: const Offset(-0.05, 0.03),
      end: const Offset(0.05, -0.05),
    ).animate(
      CurvedAnimation(parent: _shiftController, curve: Curves.easeInOutSine),
    );

    // Subtle rotation
    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shiftController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleController,
        _shiftController,
        _rotateController,
      ]),
      builder: (_, __) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Transform.rotate(
              angle: _rotateAnimation.value * math.pi,
              child: FractionalTranslation(
                translation: _shiftAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(color: Colors.black),
                  ),
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      _shiftAnimation.value.dx * 2,
                      _shiftAnimation.value.dy * 2,
                    ),
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.6),
                    ],
                    radius: 1.5,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
