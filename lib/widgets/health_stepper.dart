import 'package:flutter/material.dart';

import '../domain/milestones.dart';
import '../domain/money.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class HealthStepper extends StatelessWidget {
  const HealthStepper({required this.balance, super.key});

  final double balance;

  @override
  Widget build(BuildContext context) {
    final steps = milestoneProgress(balance);
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              _StepNode(progress: steps[i]),
              if (i < steps.length - 1)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: _Connector(value: steps[i + 1].fill),
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({required this.progress});

  final MilestoneProgress progress;

  @override
  Widget build(BuildContext context) {
    final reached = progress.reached;
    return SizedBox(
      width: 78,
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: reached
                  ? AppColors.accent.withValues(alpha: 0.55)
                  : const Color(0xFFF4F2FA),
              border: Border.all(
                color: reached ? AppColors.accent : AppColors.track,
                width: 1.4,
              ),
            ),
            child: _FillIcon(
              fill: progress.fill,
              childBuilder: (color) => _glyph(progress.milestone.id, color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            progress.milestone.label,
            textAlign: TextAlign.center,
            style: AppTypography.nunito(
              fontSize: 12,
              fontWeight: reached ? FontWeight.w800 : FontWeight.w600,
              color: reached ? AppColors.primaryText : AppColors.secondaryText,
            ),
          ),
          Text(
            formatSoles(progress.milestone.target),
            textAlign: TextAlign.center,
            style: AppTypography.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glyph(String id, Color color) {
    switch (id) {
      case 'consultas':
        return Icon(Icons.pets, size: 22, color: color);
      case 'anestesia':
        return CustomPaint(
          size: const Size(26, 26),
          painter: _StethoscopePainter(color),
        );
      case 'cirugia':
        return Icon(Icons.favorite_rounded, size: 22, color: color);
      default:
        return Icon(Icons.circle, size: 22, color: color);
    }
  }
}

class _FillIcon extends StatelessWidget {
  const _FillIcon({required this.fill, required this.childBuilder});

  final double fill;
  final Widget Function(Color color) childBuilder;

  @override
  Widget build(BuildContext context) {
    final amount = fill.clamp(0.0, 1.0);
    return SizedBox(
      width: 26,
      height: 26,
      child: Stack(
        alignment: Alignment.center,
        children: [
          childBuilder(AppColors.pending),
          ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: amount == 0 ? 0.001 : amount,
              child: childBuilder(AppColors.iconActive),
            ),
          ),
        ],
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          minHeight: 6,
          backgroundColor: AppColors.track,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _StethoscopePainter extends CustomPainter {
  const _StethoscopePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;

    canvas.drawCircle(Offset(s * 0.24, s * 0.16), s * 0.07, fill);
    canvas.drawCircle(Offset(s * 0.76, s * 0.16), s * 0.07, fill);

    final binaural = Path()
      ..moveTo(s * 0.24, s * 0.22)
      ..cubicTo(s * 0.24, s * 0.46, s * 0.40, s * 0.50, s * 0.50, s * 0.50)
      ..cubicTo(s * 0.60, s * 0.50, s * 0.76, s * 0.46, s * 0.76, s * 0.22);
    canvas.drawPath(binaural, stroke);
    canvas.drawLine(
      Offset(s * 0.50, s * 0.50),
      Offset(s * 0.50, s * 0.66),
      stroke,
    );
    canvas.drawCircle(Offset(s * 0.50, s * 0.80), s * 0.14, stroke);
    canvas.drawCircle(Offset(s * 0.50, s * 0.80), s * 0.045, fill);
  }

  @override
  bool shouldRepaint(_StethoscopePainter oldDelegate) =>
      oldDelegate.color != color;
}
