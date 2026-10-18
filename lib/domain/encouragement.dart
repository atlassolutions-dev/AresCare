abstract final class Encouragement {
  static const messages = <String>[
    'Ares está muy orgulloso de ti.',
    '¡Un pasito más cerca de la meta!',
    'Cada sol cuenta, eres la mejor mamá perruna.',
  ];

  /// Stable for a single app launch. A new open picks again.
  static String forLaunch(int seed) {
    return messages[seed.abs() % messages.length];
  }
}
