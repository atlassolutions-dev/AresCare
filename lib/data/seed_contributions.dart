import '../models/contribution.dart';
import '../models/savings_book.dart';
import '../models/savings_section.dart';

abstract final class DefaultSections {
  static const consultas = 'sec-consultas';
  static const anestesia = 'sec-anestesia';
  static const cirugia = 'sec-cirugia';
}

SavingsBook seedBook({DateTime? now}) {
  final clock = now ?? DateTime.now();
  return SavingsBook(
    sections: [
      SavingsSection(
        id: DefaultSections.consultas,
        name: 'Consultas',
        emoji: '🐾',
        goal: 700,
        createdAt: clock.subtract(const Duration(days: 40)),
      ),
      SavingsSection(
        id: DefaultSections.anestesia,
        name: 'Anestesia',
        emoji: '🩺',
        goal: 500,
        createdAt: clock.subtract(const Duration(days: 40)),
      ),
      SavingsSection(
        id: DefaultSections.cirugia,
        name: 'Cirugía',
        emoji: '❤️',
        goal: 300,
        createdAt: clock.subtract(const Duration(days: 40)),
      ),
    ],
    contributions: _seedContributions(clock),
  );
}

/// Opening story: consultas already complete (S/. 700),
/// anestesia halfway (S/. 250), cirugía still waiting.
List<Contribution> _seedContributions(DateTime clock) {
  Contribution item({
    required String id,
    required String sectionId,
    required String title,
    required double amount,
    required String emoji,
    required Duration ago,
  }) {
    return Contribution(
      id: id,
      sectionId: sectionId,
      title: title,
      amount: amount,
      emoji: emoji,
      createdAt: clock.subtract(ago),
    );
  }

  return [
    item(
      id: 'seed-cafe-hoy',
      sectionId: DefaultSections.anestesia,
      title: 'Ahorro del café',
      amount: 15,
      emoji: '☕',
      ago: const Duration(hours: 3),
    ),
    item(
      id: 'seed-semanal',
      sectionId: DefaultSections.anestesia,
      title: 'Aporte semanal',
      amount: 80,
      emoji: '🐷',
      ago: const Duration(days: 2),
    ),
    item(
      id: 'seed-galletas',
      sectionId: DefaultSections.anestesia,
      title: 'Venta de galletas',
      amount: 45,
      emoji: '🍪',
      ago: const Duration(days: 5),
    ),
    item(
      id: 'seed-alcancia-mes',
      sectionId: DefaultSections.consultas,
      title: 'Alcancía del mes',
      amount: 120,
      emoji: '🪙',
      ago: const Duration(days: 9),
    ),
    item(
      id: 'seed-propinas',
      sectionId: DefaultSections.anestesia,
      title: 'Propinas',
      amount: 30,
      emoji: '✨',
      ago: const Duration(days: 12),
    ),
    item(
      id: 'seed-cafe-antes',
      sectionId: DefaultSections.consultas,
      title: 'Ahorro del café',
      amount: 15,
      emoji: '☕',
      ago: const Duration(days: 16),
    ),
    item(
      id: 'seed-semanal-antes',
      sectionId: DefaultSections.anestesia,
      title: 'Aporte semanal',
      amount: 80,
      emoji: '🐷',
      ago: const Duration(days: 21),
    ),
    item(
      id: 'seed-abuela',
      sectionId: DefaultSections.consultas,
      title: 'Regalo de la abuela',
      amount: 200,
      emoji: '💝',
      ago: const Duration(days: 28),
    ),
    item(
      id: 'seed-inicial',
      sectionId: DefaultSections.consultas,
      title: 'Alcancía inicial',
      amount: 365,
      emoji: '🪙',
      ago: const Duration(days: 40),
    ),
  ];
}

/// Places older one-pot contributions into the three surgery processes,
/// filling each goal before moving to the next.
SavingsBook migrateLegacyContributions(List<Contribution> items) {
  final clock = items.isEmpty ? DateTime.now() : items.last.createdAt;
  final template = seedBook(now: clock);
  final sections = template.sections;
  final filled = {for (final section in sections) section.id: 0.0};
  final chronological = [...items]
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  final assigned = <Contribution>[];

  for (final item in chronological) {
    var sectionId = sections.last.id;
    for (final section in sections) {
      if (filled[section.id]! < section.goal) {
        sectionId = section.id;
        break;
      }
    }
    filled[sectionId] = filled[sectionId]! + item.amount;
    assigned.add(item.copyWith(sectionId: sectionId));
  }

  assigned.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return SavingsBook(sections: sections, contributions: assigned);
}
