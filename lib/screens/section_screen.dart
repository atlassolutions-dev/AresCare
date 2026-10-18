import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../domain/money.dart';
import '../models/savings_book.dart';
import '../state/savings_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/add_contribution_sheet.dart';
import '../widgets/add_section_sheet.dart';
import '../widgets/contribution_tile.dart';
import '../widgets/counting_amount.dart';
import '../widgets/pastel_background.dart';
import '../widgets/soft_3d_button.dart';

class SectionScreen extends StatefulWidget {
  const SectionScreen({
    required this.controller,
    required this.sectionId,
    super.key,
  });

  final SavingsController controller;
  final String sectionId;

  @override
  State<SectionScreen> createState() => _SectionScreenState();
}

class _SectionScreenState extends State<SectionScreen> {
  late final ConfettiController _confetti;

  SavingsController get _savings => widget.controller;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _savings.addListener(_onSavings);
  }

  void _onSavings() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _savings.removeListener(_onSavings);
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final section = _savings.findSection(widget.sectionId);
    if (section == null) {
      return;
    }
    final before = _savings.savedIn(section.id);
    final beforeTotal = _savings.balance;
    final savedId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddContributionSheet(
        controller: _savings,
        initialSectionId: section.id,
      ),
    );
    if (savedId == null || !mounted) {
      return;
    }
    final current = _savings.findSection(savedId);
    final finishedSection =
        current != null &&
        before < current.goal &&
        _savings.savedIn(savedId) >= current.goal;
    final finishedAll =
        beforeTotal < _savings.goal && _savings.balance >= _savings.goal;
    _confetti.play();
    if (finishedAll) {
      await _dialog(
        'Meta completa 🐾',
        'Todos los procesos de Ares ya tienen lo suyo.',
      );
    } else if (finishedSection) {
      await _dialog(
        '${current.name} está listo',
        'Ese proceso ya no pide más. Puedes cuidar el siguiente con calma.',
      );
    }
  }

  Future<void> _edit() async {
    final section = _savings.findSection(widget.sectionId);
    if (section == null) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AddSectionSheet(controller: _savings, existing: section),
    );
  }

  Future<void> _removeSection() async {
    final section = _savings.findSection(widget.sectionId);
    if (section == null || !mounted) {
      return;
    }
    if (_savings.sections.length <= 1) {
      await _dialog(
        'Déjalo con ella',
        'Tiene que quedar al menos un proceso para saber a dónde va cada sol.',
      );
      return;
    }
    final saved = _savings.savedIn(section.id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.sheet,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Quitar ${section.name}',
          style: AppTypography.nunito(
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
          ),
        ),
        content: Text(
          saved == 0
              ? 'Este proceso todavía no tiene aportes.'
              : 'Tiene ${formatSoles(saved)}. Si lo quitas, esos aportes también se van.',
          style: AppTypography.nunito(
            fontWeight: FontWeight.w400,
            color: AppColors.primaryText,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: AppTypography.nunito(
                fontWeight: FontWeight.w700,
                color: AppColors.secondaryText,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Quitar',
              style: AppTypography.nunito(
                fontWeight: FontWeight.w800,
                color: AppColors.iconActive,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final removed = await _savings.removeSection(section.id);
    if (removed && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _dialog(String title, String body) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.sheet,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          title,
          style: AppTypography.nunito(
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
          ),
        ),
        content: Text(
          body,
          style: AppTypography.nunito(
            fontWeight: FontWeight.w400,
            color: AppColors.primaryText,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Listo',
              style: AppTypography.nunito(
                fontWeight: FontWeight.w800,
                color: AppColors.iconActive,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _removeContribution(String id) async {
    final index = _savings.contributions.indexWhere((item) => item.id == id);
    final removed = await _savings.remove(id);
    if (!mounted || removed == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quitamos "${removed.title}"'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () => _savings.restore(removed, index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final section = _savings.findSection(widget.sectionId);
    if (section == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final saved = _savings.savedIn(section.id);
    final progress = portion(saved, section.goal);
    final ready = section.goal > 0 && saved >= section.goal;
    final missing = (section.goal - saved).clamp(0, section.goal).toDouble();
    final history = _savings.historyFor(section.id);

    return Scaffold(
      backgroundColor: AppColors.gradientTop,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        title: Text(
          section.name,
          style: AppTypography.nunito(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Editar proceso',
            onPressed: _edit,
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          const PastelBackground(),
          SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                const SizedBox(height: 8),
                Text(
                  section.emoji,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 42),
                ),
                const SizedBox(height: 8),
                CountingAmount(amount: saved),
                Text(
                  'Meta: ${formatSoles(section.goal)}',
                  textAlign: TextAlign.center,
                  style: AppTypography.nunito(
                    fontSize: 15,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: AppColors.track,
                    color: ready ? AppColors.achievement : AppColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ready
                      ? 'Este proceso ya está cubierto.'
                      : 'Faltan ${formatSoles(missing)} para cerrarlo.',
                  textAlign: TextAlign.center,
                  style: AppTypography.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ready
                        ? AppColors.achievement
                        : AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                Soft3DButton(
                  label: '+ Aportar a ${section.name}',
                  onPressed: _add,
                ),
                const SizedBox(height: 22),
                Text(
                  'Aportes de este proceso',
                  style: AppTypography.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                if (history.isEmpty)
                  Text(
                    'Todavía no hay aportes aquí. El primero cuenta igual.',
                    style: AppTypography.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryText,
                    ),
                  )
                else
                  for (final item in history)
                    Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _removeContribution(item.id),
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 18),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          'Quitar',
                          style: AppTypography.nunito(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                      child: ContributionTile(contribution: item),
                    ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _removeSection,
                  child: Text(
                    'Quitar este proceso',
                    style: AppTypography.nunito(
                      fontWeight: FontWeight.w700,
                      color: AppColors.iconActive,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 12,
                height: 12,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirection: math.pi / 2,
                  emissionFrequency: 0.08,
                  numberOfParticles: 14,
                  maxBlastForce: 22,
                  minBlastForce: 8,
                  gravity: 0.28,
                  pauseEmissionOnLowFrameRate: false,
                  colors: const [
                    AppColors.accent,
                    AppColors.yellowPastel,
                    AppColors.gradientBottom,
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
