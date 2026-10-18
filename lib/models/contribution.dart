class Contribution {
  const Contribution({
    required this.id,
    required this.sectionId,
    required this.title,
    required this.amount,
    required this.emoji,
    required this.createdAt,
  });

  final String id;
  final String sectionId;
  final String title;
  final double amount;
  final String emoji;
  final DateTime createdAt;

  Contribution copyWith({String? sectionId}) {
    return Contribution(
      id: id,
      sectionId: sectionId ?? this.sectionId,
      title: title,
      amount: amount,
      emoji: emoji,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sectionId': sectionId,
      'title': title,
      'amount': amount,
      'emoji': emoji,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['id'] as String,
      sectionId: json['sectionId'] as String? ?? '',
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      emoji: json['emoji'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
