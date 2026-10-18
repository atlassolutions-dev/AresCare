import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/money.dart';
import '../models/savings_section.dart';
import '../state/savings_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'add_section_sheet.dart';
import 'soft_3d_button.dart';

class ContributionPreset {
  const ContributionPreset({
    required this.emoji,
    required this.title,
    required this.amount,
  });

  final String emoji;
  final String title;
  final double amount;
}

const contributionPresets = <ContributionPreset>[
  ContributionPreset(emoji: '☕', title: 'Ahorro del café', amount: 15),
  ContributionPreset(emoji: '🐷', title: 'Aporte semanal', amount: 50),
  ContributionPreset(emoji: '🪙', title: 'Alcancía', amount: 20),
  ContributionPreset(emoji: '💝', title: 'Regalo con amor', amount: 30),
  ContributionPreset(emoji: '✨', title: 'Extra del día', amount: 10),
];

class AddContributionSheet extends StatefulWidget {
  const AddContributionSheet({
    required this.controller,
    this.initialSectionId,
    super.key,
  });

  final SavingsController controller;
  final String? initialSectionId;

  @override
  State<AddContributionSheet> createState() => _AddContributionSheetState();
}

class _AddContributionSheetState extends State<AddContributionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  String _emoji = '💖';
  int? _selectedPreset;
  bool _saving = false;
  String? _sectionId;

  @override
  void initState() {
    super.initState();
    final controller = widget.controller;
    _sectionId =
        widget.initialSectionId ??
        controller.nextSection?.id ??
        (controller.sections.isEmpty ? null : controller.sections.first.id);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _applyPreset(int index) {
    final preset = contributionPresets[index];
    setState(() {
      _selectedPreset = index;
      _emoji = preset.emoji;
      _titleController.text = preset.title;
      _amountController.text = preset.amount.toStringAsFixed(2);
    });
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final amount = parseSoles(_amountController.text);
    final sectionId = _sectionId;
    if (amount == null || sectionId == null) {
      return;
    }
    setState(() => _saving = true);
    await widget.controller.add(
      sectionId: sectionId,
      title: _titleController.text,
      amount: amount,
      emoji: _emoji,
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(sectionId);
  }

  Future<void> _createSection() async {
    final created = await showModalBottomSheet<SavingsSection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSectionSheet(controller: widget.controller),
    );
    if (!mounted || created == null) {
      return;
    }
    setState(() => _sectionId = created.id);
  }

  @override
  Widget build(BuildContext context) {
    final section = _sectionId == null
        ? null
        : widget.controller.findSection(_sectionId!);
    final savedHere = section == null
        ? 0.0
        : widget.controller.savedIn(section.id);
    final remaining = section == null
        ? 0.0
        : (section.goal - savedHere).clamp(0, section.goal).toDouble();
    final hint = section == null
        ? 'Primero crea un proceso para saber a dónde va este sol.'
        : remaining == 0
        ? '${section.name} ya está listo. Igual puedes sumar un extra.'
        : 'A ${section.name} le faltan ${formatSoles(remaining)}.';

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        child: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.sheet,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.track,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nuevo aporte',
                    textAlign: TextAlign.center,
                    style: AppTypography.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hint,
                    textAlign: TextAlign.center,
                    style: AppTypography.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¿Para qué proceso es?',
                    style: AppTypography.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in widget.controller.sections)
                        ChoiceChip(
                          label: Text(
                            '${item.emoji}  ${item.name}',
                            style: AppTypography.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                            ),
                          ),
                          selected: _sectionId == item.id,
                          selectedColor: AppColors.accent,
                          backgroundColor: Colors.white,
                          side: BorderSide.none,
                          onSelected: (_) =>
                              setState(() => _sectionId = item.id),
                        ),
                      ActionChip(
                        label: Text(
                          '+ Proceso',
                          style: AppTypography.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryText,
                          ),
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide.none,
                        onPressed: _createSection,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('contribution-amount'),
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    style: AppTypography.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                    decoration: _fieldDecoration('Monto', prefix: 'S/. '),
                    validator: (value) {
                      final amount = parseSoles(value ?? '');
                      if (amount == null) {
                        return 'Escribe un monto, aunque sea pequeño.';
                      }
                      if (amount > 20000) {
                        return 'Ese monto es enorme. ¿Lo revisamos?';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('contribution-title'),
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppTypography.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                    decoration: _fieldDecoration(
                      '¿De dónde salió este esfuerzo?',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ponle un nombre bonito a este esfuerzo.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < contributionPresets.length; i++)
                        _PresetChip(
                          preset: contributionPresets[i],
                          selected: _selectedPreset == i,
                          onTap: () => _applyPreset(i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Soft3DButton(
                    key: const Key('save-contribution'),
                    label: _saving ? 'Guardando...' : 'Guardar aporte ✨',
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, {String? prefix}) {
    return InputDecoration(
      labelText: label,
      prefixText: prefix,
      filled: true,
      fillColor: Colors.white,
      labelStyle: AppTypography.nunito(
        color: AppColors.secondaryText,
        fontWeight: FontWeight.w600,
      ),
      prefixStyle: AppTypography.nunito(
        color: AppColors.primaryText,
        fontWeight: FontWeight.w800,
        fontSize: 18,
      ),
      errorStyle: AppTypography.nunito(
        color: AppColors.iconActive,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final ContributionPreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accent : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            '${preset.emoji}  ${preset.title}',
            style: AppTypography.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ),
      ),
    );
  }
}
