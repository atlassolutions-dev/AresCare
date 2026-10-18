class SavingsSection {
  const SavingsSection({
    required this.id,
    required this.name,
    required this.emoji,
    required this.goal,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String emoji;
  final double goal;
  final DateTime createdAt;

  SavingsSection copyWith({String? name, String? emoji, double? goal}) {
    return SavingsSection(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      goal: goal ?? this.goal,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'goal': goal,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavingsSection.fromJson(Map<String, dynamic> json) {
    return SavingsSection(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      goal: (json['goal'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
