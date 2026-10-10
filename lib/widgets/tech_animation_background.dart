import 'package:flutter/material.dart';
import 'dart:math' as math;

class TechAnimationBackground extends StatefulWidget {
  const TechAnimationBackground({super.key});

  @override
  State<TechAnimationBackground> createState() =>
      _TechAnimationBackgroundState();
}

class _TechAnimationBackgroundState extends State<TechAnimationBackground>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _waveController;
  late AnimationController _rotationController;
  late Animation<double> _waveAnimation;
  late Animation<double> _rotationAnimation;

  final List<Particle> _particles = [];
  final int particleCount = 50;

  @override
  void initState() {
    super.initState();

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Wave animation controller
    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Rotation animation controller
    _rotationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    // Initialize particles
    _initParticles();
  }

  void _initParticles() {
    for (int i = 0; i < particleCount; i++) {
      _particles.add(Particle());
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    _waveController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0F4C75),
            Color(0xFF3282B8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated geometric patterns
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: GeometricPatternPainter(_rotationAnimation.value),
              );
            },
          ),

          // Floating particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: ParticlePainter(_particles, _particleController.value),
              );
            },
          ),

          // Wave overlay
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: WavePainter(_waveAnimation.value),
              );
            },
          ),

          // Gradient overlay for depth
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late double size;
  late Color color;
  late double opacity;

  Particle() {
    x = math.Random().nextDouble() * 400;
    y = math.Random().nextDouble() * 800;
    vx = (math.Random().nextDouble() - 0.5) * 2;
    vy = (math.Random().nextDouble() - 0.5) * 2;
    size = math.Random().nextDouble() * 3 + 1;
    opacity = math.Random().nextDouble() * 0.8 + 0.2;

    final colors = [
      const Color(0xFF00D4FF),
      const Color(0xFF7B68EE),
      const Color(0xFF00BFFF),
      const Color(0xFF40E0D0),
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }

  void update(double screenWidth, double screenHeight) {
    x += vx;
    y += vy;

    if (x < 0 || x > screenWidth) vx = -vx;
    if (y < 0 || y > screenHeight) vy = -vy;

    x = x.clamp(0, screenWidth);
    y = y.clamp(0, screenHeight);
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update(size.width, size.height);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);

      // Draw connecting lines between nearby particles
      for (var other in particles) {
        final distance = math.sqrt(
          math.pow(particle.x - other.x, 2) + math.pow(particle.y - other.y, 2),
        );

        if (distance < 100) {
          final linePaint = Paint()
            ..color = particle.color.withValues(alpha: 0.1)
            ..strokeWidth = 0.5;

          canvas.drawLine(
            Offset(particle.x, particle.y),
            Offset(other.x, other.y),
            linePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GeometricPatternPainter extends CustomPainter {
  final double rotation;

  GeometricPatternPainter(this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    // Draw hexagonal patterns
    for (int i = 0; i < 6; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 3);

      final paint = Paint()
        ..color = Colors.cyanAccent.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      final path = Path();
      for (int j = 0; j < 6; j++) {
        final angle = j * math.pi / 3;
        final radius = 100 + (i * 20);
        final x = radius * math.cos(angle);
        final y = radius * math.sin(angle);

        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);

      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WavePainter extends CustomPainter {
  final double wavePhase;

  WavePainter(this.wavePhase);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.cyanAccent.withValues(alpha: 0.3), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y =
          size.height * 0.8 +
          30 * math.sin((x / size.width) * 2 * math.pi + wavePhase);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
