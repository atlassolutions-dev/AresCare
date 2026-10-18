/// Formats a sol amount as `S/. 1,500.00`.
String formatSoles(double value) {
  final negative = value < 0;
  final cents = (value.abs() * 100).round();
  final whole = cents ~/ 100;
  final fraction = (cents % 100).toString().padLeft(2, '0');
  final digits = whole.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  final prefix = negative ? '-S/. ' : 'S/. ';
  return '$prefix$buffer.$fraction';
}

/// Rounds to cents so savings never drift by floating-point dust.
double roundSoles(double value) => (value * 100).roundToDouble() / 100;

/// Accepts `15.50` and `15,50`. Returns null when the text is not a positive amount.
double? parseSoles(String raw) {
  final cleaned = raw.trim().replaceAll(' ', '').replaceAll(',', '.');
  if (cleaned.isEmpty || '.'.allMatches(cleaned).length > 1) {
    return null;
  }
  final value = double.tryParse(cleaned);
  if (value == null || value <= 0) {
    return null;
  }
  return roundSoles(value);
}

const monthsShort = <String>[
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

String formatContributionDate(DateTime date, DateTime now) {
  final local = date.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) {
    return 'Hoy';
  }
  if (diff == 1) {
    return 'Ayer';
  }
  return '${local.day} ${monthsShort[local.month - 1]}';
}
