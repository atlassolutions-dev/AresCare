import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/money.dart';
import '../models/savings_section.dart';
import '../state/savings_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'soft_3d_button.dart';

class SectionIdea {
  const SectionIdea({required this.emoji, required this.name});

  final String emoji;
  final String name;
}

const sectionIdeas = <SectionIdea>[
  SectionIdea(emoji: '🐾', name: 'Consultas'),
  SectionIdea(emoji: '🩺', name: 'Anestesia'),
  SectionIdea(emoji: '❤️', name: 'Cirugía'),
  SectionIdea(emoji: '💊', name: 'Medicinas'),
  SectionIdea(emoji: '🧪', name: 'Exámenes'),
  SectionIdea(emoji: '🩹', name: 'Recuperación'),
];

const sectionEmojis = <String>[
  '🐾',
  '🩺',
  '❤️',
  '💊',
  '🧪',
  '🩹',
  '🛏️',
  '🥣',
  '✨',
  '🌸',
];

class AddSectionSheet extends StatefulWidget {
  const AddSectionSheet({required this.controller, this.existing, super.key});

  final SavingsController controller;
  final SavingsSection? existing;

  @override
  State<AddSectionSheet> createState() => _AddSectionSheetState();
}

class _AddSectionSheetState extends State<AddSectionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _goalController;
  late String _emoji;
  bool _saving = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _goalController = TextEditingController(
      text: existing == null ? '' : existing.goal.toStringAsFixed(2),
    );
    _emoji = existing?.emoji ?? '💊';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final goal = parseSoles(_goalController.text);
    if (goal == null) {
      return;
    }
    setState(() => _saving = true);
    final existing = widget.existing;
    if (existing == null) {
      final created = await widget.controller.addSection(
        name: _nameController.text,
        emoji: _emoji,
        goal: goal,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(created);
      return;
    }
    final updated = existing.copyWith(
      name: _nameController.text.trim(),
      emoji: _emoji,
      goal: goal,
    );
    await widget.controller.updateSection(updated);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
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
                    _editing ? 'Editar proceso' : 'Nuevo proceso',
                    textAlign: TextAlign.center,
                    style: AppTypography.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Un proceso es una meta aparte. Así cada sol tiene su lugar.',
                    textAlign: TextAlign.center,
                    style: AppTypography.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final emoji in sectionEmojis)
                        GestureDetector(
                          onTap: () => setState(() => _emoji = emoji),
                          child: Container(
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _emoji == emoji
                                  ? AppColors.accent
                                  : Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: const Key('section-name'),
                    controller: _nameController,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppTypography.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                    decoration: _decoration('Nombre del proceso'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ponle un nombre, por ejemplo Medicinas.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('section-goal'),
                    controller: _goalController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    style: AppTypography.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                    ),
                    decoration: _decoration(
                      'Meta de este proceso',
                      prefix: 'S/. ',
                    ),
                    validator: (value) {
                      final goal = parseSoles(value ?? '');
                      if (goal == null) {
                        return 'Escribe cuánto necesita este proceso.';
                      }
                      if (goal > 100000) {
                        return 'Esa meta es enorme. ¿La revisamos?';
                      }
                      return null;
                    },
                  ),
                  if (!_editing) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final idea in sectionIdeas)
                          ActionChip(
                            label: Text(
                              '${idea.emoji}  ${idea.name}',
                              style: AppTypography.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryText,
                              ),
                            ),
                            backgroundColor: Colors.white,
                            side: BorderSide.none,
                            onPressed: () {
                              setState(() {
                                _emoji = idea.emoji;
                                _nameController.text = idea.name;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  Soft3DButton(
                    key: const Key('save-section'),
                    label: _saving
                        ? 'Guardando...'
                        : _editing
                        ? 'Guardar cambios'
                        : 'Crear proceso',
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

  InputDecoration _decoration(String label, {String? prefix}) {
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
        fontSize: 16,
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
