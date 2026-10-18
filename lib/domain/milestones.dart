class HealthMilestone {
  const HealthMilestone({
    required this.id,
    required this.label,
    required this.target,
  });

  final String id;
  final String label;

  /// Cumulative soles required to complete this step.
  final double target;
}

class MilestoneProgress {
  const MilestoneProgress({required this.milestone, required this.fill});

  final HealthMilestone milestone;

  /// 0 when the previous step just finished, 1 when this step is complete.
  final double fill;

  bool get reached => fill >= 1;
}

/// Medical steps sized so the opening balance (S/. 950) shows
/// consultas complete, anestesia halfway, and cirugía still ahead.
abstract final class SavingsPlan {
  static const goal = 1500.0;

  static const milestones = <HealthMilestone>[
    HealthMilestone(id: 'consultas', label: 'Consultas', target: 700),
    HealthMilestone(id: 'anestesia', label: 'Anestesia', target: 1200),
    HealthMilestone(id: 'cirugia', label: 'Cirugía', target: 1500),
  ];
}

List<MilestoneProgress> milestoneProgress(double balance) {
  final views = <MilestoneProgress>[];
  var previous = 0.0;
  for (final milestone in SavingsPlan.milestones) {
    final span = milestone.target - previous;
    final raw = span <= 0 ? 1.0 : (balance - previous) / span;
    views.add(
      MilestoneProgress(milestone: milestone, fill: raw.clamp(0.0, 1.0)),
    );
    previous = milestone.target;
  }
  return views;
}

double goalProgress(double balance) {
  if (SavingsPlan.goal <= 0) {
    return 0;
  }
  return (balance / SavingsPlan.goal).clamp(0.0, 1.0);
}
