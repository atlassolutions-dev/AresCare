import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/encouragement.dart';
import '../domain/money.dart';
import '../state/savings_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/add_contribution_sheet.dart';
import '../widgets/add_section_sheet.dart';
import '../widgets/ares_hero.dart';
import '../widgets/balance_glass_card.dart';
import '../widgets/contribution_tile.dart';
import '../widgets/pastel_background.dart';
import '../widgets/section_card.dart';
import '../widgets/soft_3d_button.dart';
import 'section_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.controller, super.key});

  final SavingsController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final String _message;
  late final ConfettiController _confetti;

  SavingsController get _savings => widget.controller;

  @override
  void initState() {
    super.initState();
    _message = Encouragement.forLaunch(DateTime.now().millisecondsSinceEpoch);
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

  Future<void> _openAddSheet({String? sectionId}) async {
    final beforeTotal = _savings.balance;
    final beforeSections = {
      for (final section in _savings.sections)
        section.id: _savings.savedIn(section.id),
    };
    final savedSectionId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddContributionSheet(
        controller: _savings,
        initialSectionId: sectionId,
      ),
    );
    if (savedSectionId == null || !mounted) {
      return;
    }
    final section = _savings.findSection(savedSectionId);
    final previous = beforeSections[savedSectionId] ?? 0;
    final sectionDone =
        section != null &&
        previous < section.goal &&
        _savings.savedIn(savedSectionId) >= section.goal;
    final allDone =
        beforeTotal < _savings.goal && _savings.balance >= _savings.goal;
    _confetti.duration = Duration(seconds: allDone ? 3 : 2);
    _confetti.play();
    if (allDone) {
      await _showGoalDialog(
        'Meta completa 🐾',
        'Ares ya tiene lo que necesita. Cada sol que guardaste fue un abrazo.',
      );
    } else if (sectionDone) {
      await _showGoalDialog(
        '${section.name} está listo',
        'Ese proceso ya no pide más. El siguiente puede esperar su turno.',
      );
    }
  }

  Future<void> _openNewSection() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSectionSheet(controller: _savings),
    );
  }

  void _openSection(String sectionId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            SectionScreen(controller: _savings, sectionId: sectionId),
      ),
    );
  }

  Future<void> _showGoalDialog(String title, String body) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.sheet,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
                'Seguir cuidándolo',
                style: AppTypography.nunito(
                  fontWeight: FontWeight.w800,
                  color: AppColors.iconActive,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeAt(int index) async {
    final item = _savings.contributions[index];
    final removed = await _savings.remove(item.id);
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
    final balance = _savings.balance;
    final compact = MediaQuery.sizeOf(context).height < 760;
    final header = _header(balance: balance, compact: compact);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.gradientBottom,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const PastelBackground(),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      ...header,
                      const SizedBox(height: 18),
                      ..._sectionChildren(),
                      const SizedBox(height: 8),
                      ..._historyChildren(),
                    ],
                  ),
                ),
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
                    minimumSize: const Size(8, 5),
                    maximumSize: const Size(14, 9),
                    pauseEmissionOnLowFrameRate: false,
                    colors: const [
                      AppColors.accent,
                      AppColors.yellowPastel,
                      AppColors.gradientBottom,
                      Color(0xFFB39DDB),
                      Colors.white,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _header({required double balance, required bool compact}) {
    return [
      Text(
        'Ahorros para Ares 🐾',
        textAlign: TextAlign.center,
        style: AppTypography.nunito(
          fontSize: compact ? 24 : 28,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryText,
        ),
      ),
      SizedBox(height: compact ? 8 : 12),
      Center(
        child: AresHero(progress: _savings.overallProgress, compact: compact),
      ),
      SizedBox(height: compact ? 10 : 16),
      BalanceGlassCard(
        balance: balance,
        goal: _savings.goal,
        kicker: 'Todo lo guardado',
      ),
      SizedBox(height: compact ? 8 : 12),
      Text(
        _message,
        textAlign: TextAlign.center,
        style: AppTypography.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryText,
          height: 1.3,
        ),
      ),
      SizedBox(height: compact ? 8 : 12),
      Soft3DButton(
        key: const Key('add-contribution'),
        label: '+ Agregar Aporte ✨',
        onPressed: _openAddSheet,
      ),
    ];
  }

  List<Widget> _sectionChildren() {
    final nextId = _savings.nextSection?.id;
    return [
      Text(
        'Procesos de Ares',
        style: AppTypography.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryText,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Cada operación tiene su propia meta. Aporta al que toque.',
        style: AppTypography.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryText,
        ),
      ),
      const SizedBox(height: 10),
      for (final section in _savings.sections)
        SectionCard(
          section: section,
          saved: _savings.savedIn(section.id),
          isNext:
              section.id == nextId &&
              _savings.savedIn(section.id) < section.goal,
          onOpen: () => _openSection(section.id),
          onAdd: () => _openAddSheet(sectionId: section.id),
        ),
      OutlinedButton.icon(
        key: const Key('add-section'),
        onPressed: _openNewSection,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryText,
          side: const BorderSide(color: AppColors.accent, width: 1.4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Agregar proceso',
          style: AppTypography.nunito(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
    ];
  }

  List<Widget> _historyChildren() {
    final items = _savings.contributions;
    if (items.isEmpty) {
      return [_historyTitle(), const SizedBox(height: 12), _emptyHistory()];
    }
    return [
      _historyTitle(),
      const SizedBox(height: 8),
      for (var index = 0; index < items.length; index++) _dismissible(index),
    ];
  }

  String _effortDetail(String sectionId, DateTime createdAt) {
    final when = formatContributionDate(createdAt, DateTime.now());
    final name = _savings.findSection(sectionId)?.name;
    if (name == null) {
      return when;
    }
    return '$when · $name';
  }

  Widget _historyTitle() {
    return Text(
      'Pequeños esfuerzos',
      style: AppTypography.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryText,
      ),
    );
  }

  Widget _emptyHistory() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        'Todavía no hay aportes. El primero es el más valiente.',
        textAlign: TextAlign.center,
        style: AppTypography.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryText,
        ),
      ),
    );
  }

  Widget _dismissible(int index) {
    final item = _savings.contributions[index];
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeAt(index),
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
      child: ContributionTile(
        contribution: item,
        detail: _effortDetail(item.sectionId, item.createdAt),
      ),
    );
  }
}
