import '../domain/money.dart';
import 'contribution.dart';
import 'savings_section.dart';

class SavingsBook {
  const SavingsBook({required this.sections, required this.contributions});

  final List<SavingsSection> sections;
  final List<Contribution> contributions;

  static const empty = SavingsBook(sections: [], contributions: []);

  double get saved => roundSoles(
    contributions.fold<double>(0, (sum, item) => sum + item.amount),
  );

  double get goal => roundSoles(
    sections.fold<double>(0, (sum, section) => sum + section.goal),
  );

  double savedIn(String sectionId) {
    return roundSoles(
      contributions
          .where((item) => item.sectionId == sectionId)
          .fold<double>(0, (sum, item) => sum + item.amount),
    );
  }

  double progressOf(String sectionId) {
    final section = findSection(sectionId);
    if (section == null) {
      return 0;
    }
    return portion(savedIn(sectionId), section.goal);
  }

  double get overallProgress => portion(saved, goal);

  /// The first process that still needs money. She always knows what is next.
  SavingsSection? get nextSection {
    for (final section in sections) {
      if (savedIn(section.id) < section.goal) {
        return section;
      }
    }
    return sections.isEmpty ? null : sections.first;
  }

  SavingsSection? findSection(String id) {
    for (final section in sections) {
      if (section.id == id) {
        return section;
      }
    }
    return null;
  }

  List<Contribution> historyFor(String sectionId) {
    return contributions.where((item) => item.sectionId == sectionId).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'sections': sections.map((section) => section.toJson()).toList(),
      'contributions': contributions.map((item) => item.toJson()).toList(),
    };
  }

  factory SavingsBook.fromJson(Map<String, dynamic> json) {
    final sections = (json['sections'] as List<dynamic>)
        .map((item) => SavingsSection.fromJson(item as Map<String, dynamic>))
        .toList();
    final contributions = (json['contributions'] as List<dynamic>)
        .map((item) => Contribution.fromJson(item as Map<String, dynamic>))
        .toList();
    return SavingsBook(sections: sections, contributions: contributions);
  }
}

double portion(double saved, double goal) {
  if (goal <= 0) {
    return 0;
  }
  return (saved / goal).clamp(0.0, 1.0);
}
