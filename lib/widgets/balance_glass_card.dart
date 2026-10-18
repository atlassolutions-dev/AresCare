import 'dart:ui';

import 'package:flutter/material.dart';

import '../domain/money.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'counting_amount.dart';

class BalanceGlassCard extends StatelessWidget {
  const BalanceGlassCard({
    required this.balance,
    required this.goal,
    this.kicker,
    super.key,
  });

  final double balance;
  final double goal;
  final String? kicker;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.75),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              if (kicker != null) ...[
                Text(
                  kicker!,
                  style: AppTypography.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              CountingAmount(amount: balance),
              const SizedBox(height: 4),
              Text(
                'Meta: ${formatSoles(goal)}',
                style: AppTypography.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
