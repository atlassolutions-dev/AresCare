import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/contribution.dart';
import '../models/savings_book.dart';
import 'seed_contributions.dart';

abstract class SavingsStore {
  Future<SavingsBook> load();

  Future<void> save(SavingsBook book);
}

class SharedPreferencesSavingsStore implements SavingsStore {
  SharedPreferencesSavingsStore(this._prefs);

  final SharedPreferences _prefs;
  static const storageKey = 'arescare.savings.v2';
  static const legacyKey = 'arescare.contributions.v1';

  @override
  Future<SavingsBook> load() async {
    final raw = _prefs.getString(storageKey);
    if (raw != null) {
      return SavingsBook.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }

    final legacy = _prefs.getString(legacyKey);
    if (legacy != null) {
      final decoded = jsonDecode(legacy) as List<dynamic>;
      final items = decoded
          .map((item) => Contribution.fromJson(item as Map<String, dynamic>))
          .toList();
      final book = migrateLegacyContributions(items);
      await save(book);
      return book;
    }

    final seed = seedBook();
    await save(seed);
    return seed;
  }

  @override
  Future<void> save(SavingsBook book) async {
    await _prefs.setString(storageKey, jsonEncode(book.toJson()));
  }
}

class MemorySavingsStore implements SavingsStore {
  MemorySavingsStore([SavingsBook? initial]) : _book = initial ?? seedBook();

  SavingsBook _book;

  @override
  Future<SavingsBook> load() async => _book;

  @override
  Future<void> save(SavingsBook book) async {
    _book = book;
  }
}
