import 'package:flutter/material.dart';

import '../domain/money.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class CountingAmount extends StatefulWidget {
  const CountingAmount({required this.amount, super.key});

  final double amount;

  @override
  State<CountingAmount> createState() => _CountingAmountState();
}

class _CountingAmountState extends State<CountingAmount> {
  late double _from;

  @override
  void initState() {
    super.initState();
    _from = widget.amount;
  }

  @override
  void didUpdateWidget(CountingAmount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _from = oldWidget.amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _from, end: widget.amount),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Text(
          formatSoles(value),
          textAlign: TextAlign.center,
          style: AppTypography.nunito(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
            height: 1.05,
          ),
        );
      },
    );
  }
}
