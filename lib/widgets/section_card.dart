import 'package:flutter/material.dart';

import '../domain/money.dart';
import '../models/savings_book.dart';
import '../models/savings_section.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.section,
    required this.saved,
    required this.isNext,
    required this.onOpen,
    required this.onAdd,
    super.key,
  });

  final SavingsSection section;
  final double saved;
  final bool isNext;
  final VoidCallback onOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final progress = portion(saved, section.goal);
    final ready = saved >= section.goal && section.goal > 0;
    final missing = (section.goal - saved).clamp(0, section.goal).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ready
                            ? const Color(0xFFDDF5EA)
                            : AppColors.accent.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        section.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  section.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                              ),
                              if (isNext) ...[
                                const SizedBox(width: 8),
                                const _NextPill(),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ready
                                ? 'Listo · ${formatSoles(saved)}'
                                : 'Faltan ${formatSoles(missing)}',
                            style: AppTypography.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ready
                                  ? AppColors.achievement
                                  : AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: Key('add-to-${section.id}'),
                      tooltip: 'Aportar a ${section.name}',
                      onPressed: onAdd,
                      icon: const Icon(
                        Icons.add_rounded,
                        color: AppColors.primaryText,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        minimumSize: const Size(40, 40),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: AppColors.track,
                    color: ready ? AppColors.achievement : AppColors.accent,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${formatSoles(saved)} de ${formatSoles(section.goal)}',
                    style: AppTypography.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NextPill extends StatelessWidget {
  const _NextPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        'Siguiente',
        style: AppTypography.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryText,
        ),
      ),
    );
  }
}
