import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PastelBackground extends StatefulWidget {
  const PastelBackground({super.key});

  @override
  State<PastelBackground> createState() => _PastelBackgroundState();
}

class _PastelBackgroundState extends State<PastelBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift;

  static const _floaters = <_Floater>[
    _Floater(icon: Icons.pets, x: 0.08, size: 28, phase: 0.05, opacity: 0.13),
    _Floater(
      icon: Icons.star_rounded,
      x: 0.78,
      size: 18,
      phase: 0.22,
      opacity: 0.16,
    ),
    _Floater(
      icon: Icons.favorite_rounded,
      x: 0.88,
      size: 16,
      phase: 0.48,
      opacity: 0.12,
    ),
    _Floater(icon: Icons.pets, x: 0.62, size: 22, phase: 0.71, opacity: 0.10),
    _Floater(
      icon: Icons.star_rounded,
      x: 0.18,
      size: 14,
      phase: 0.36,
      opacity: 0.15,
    ),
    _Floater(icon: Icons.pets, x: 0.42, size: 18, phase: 0.84, opacity: 0.09),
    _Floater(
      icon: Icons.favorite_rounded,
      x: 0.30,
      size: 12,
      phase: 0.58,
      opacity: 0.12,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.gradientTop, AppColors.gradientBottom],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _drift,
          builder: (context, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    for (final floater in _floaters)
                      _floatingIcon(constraints.biggest, floater, _drift.value),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _floatingIcon(Size size, _Floater floater, double t) {
    final travel = (t + floater.phase) % 1;
    final y = size.height * (1.08 - travel * 1.25);
    final sway = math.sin((t + floater.phase) * math.pi * 2) * 10;
    return Positioned(
      left: size.width * floater.x + sway,
      top: y,
      child: Icon(
        floater.icon,
        size: floater.size,
        color: AppColors.primaryText.withValues(alpha: floater.opacity),
      ),
    );
  }
}

class _Floater {
  const _Floater({
    required this.icon,
    required this.x,
    required this.size,
    required this.phase,
    required this.opacity,
  });

  final IconData icon;
  final double x;
  final double size;
  final double phase;
  final double opacity;
}
