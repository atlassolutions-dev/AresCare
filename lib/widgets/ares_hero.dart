import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../theme/app_colors.dart';

/// Portrait of Ares wrapped in a pastel progress ring and a beating heart.
/// The circle crops `assets/images/ares.jpg` toward his face.
class AresHero extends StatefulWidget {
  const AresHero({required this.progress, this.compact = false, super.key});

  final double progress;
  final bool compact;

  @override
  State<AresHero> createState() => _AresHeroState();
}

class _AresHeroState extends State<AresHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heartbeat;

  @override
  void initState() {
    super.initState();
    _heartbeat = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _heartbeat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ringRadius = widget.compact ? 70.0 : 84.0;
    final avatarRadius = widget.compact ? 50.0 : 64.0;
    final percent = widget.progress.clamp(0.0, 1.0);

    return Semantics(
      label: 'Progreso de Ares, ${(percent * 100).round()} por ciento',
      child: SizedBox(
        width: ringRadius * 2,
        height: ringRadius * 2,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            CircularPercentIndicator(
              radius: ringRadius,
              lineWidth: 10,
              percent: percent,
              animation: true,
              animateFromLastPercent: true,
              animationDuration: 900,
              curve: Curves.easeOutCubic,
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: Colors.white.withValues(alpha: 0.55),
              linearGradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.yellowPastel, AppColors.accent],
              ),
              center: _AresPortrait(radius: avatarRadius),
            ),
            Positioned(
              right: 2,
              bottom: 8,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1, end: 1.18).animate(
                  CurvedAnimation(parent: _heartbeat, curve: Curves.easeInOut),
                ),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentShadow.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    '❤️',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1,
                      color: Color(0xFFE2556A),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AresPortrait extends StatelessWidget {
  const _AresPortrait({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryText.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/ares.jpg',
          width: size,
          height: size,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.35),
          semanticLabel: 'Foto de Ares',
          errorBuilder: (context, error, stackTrace) {
            return ColoredBox(
              color: AppColors.accent,
              child: Icon(
                Icons.pets,
                size: radius,
                color: AppColors.primaryText,
              ),
            );
          },
        ),
      ),
    );
  }
}
