import 'package:flutter/material.dart';

import '../domain/money.dart';
import '../models/contribution.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class ContributionTile extends StatelessWidget {
  const ContributionTile({required this.contribution, this.detail, super.key});

  final Contribution contribution;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryText.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: Text(
              contribution.emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contribution.title,
                  style: AppTypography.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                Text(
                  detail ??
                      formatContributionDate(
                        contribution.createdAt,
                        DateTime.now(),
                      ),
                  style: AppTypography.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatSoles(contribution.amount),
            style: AppTypography.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.achievement,
            ),
          ),
        ],
      ),
    );
  }
}
