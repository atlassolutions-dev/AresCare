import 'package:flutter/foundation.dart';

import '../data/savings_store.dart';
import '../domain/money.dart';
import '../models/contribution.dart';
import '../models/savings_book.dart';
import '../models/savings_section.dart';

class SavingsController extends ChangeNotifier {
  SavingsController(this._store);

  final SavingsStore _store;
  SavingsBook _book = SavingsBook.empty;

  List<SavingsSection> get sections => List.unmodifiable(_book.sections);

  List<Contribution> get contributions =>
      List.unmodifiable(_book.contributions);

  double get balance => _book.saved;

  double get goal => _book.goal;

  double get overallProgress => _book.overallProgress;

  SavingsSection? get nextSection => _book.nextSection;

  double savedIn(String sectionId) => _book.savedIn(sectionId);

  double progressOf(String sectionId) => _book.progressOf(sectionId);

  SavingsSection? findSection(String id) => _book.findSection(id);

  List<Contribution> historyFor(String sectionId) =>
      _book.historyFor(sectionId);

  Future<void> load() async {
    _book = await _store.load();
    notifyListeners();
  }

  Future<Contribution> add({
    required String sectionId,
    required String title,
    required double amount,
    required String emoji,
  }) async {
    final contribution = Contribution(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      sectionId: sectionId,
      title: title.trim(),
      amount: roundSoles(amount),
      emoji: emoji,
      createdAt: DateTime.now(),
    );
    _book = SavingsBook(
      sections: _book.sections,
      contributions: [contribution, ..._book.contributions],
    );
    notifyListeners();
    await _store.save(_book);
    return contribution;
  }

  Future<Contribution?> remove(String id) async {
    final index = _book.contributions.indexWhere((item) => item.id == id);
    if (index < 0) {
      return null;
    }
    final removed = _book.contributions[index];
    final next = [..._book.contributions]..removeAt(index);
    _book = SavingsBook(sections: _book.sections, contributions: next);
    notifyListeners();
    await _store.save(_book);
    return removed;
  }

  Future<void> restore(Contribution contribution, int index) async {
    final next = [..._book.contributions];
    next.insert(index.clamp(0, next.length), contribution);
    _book = SavingsBook(sections: _book.sections, contributions: next);
    notifyListeners();
    await _store.save(_book);
  }

  Future<SavingsSection> addSection({
    required String name,
    required String emoji,
    required double goal,
  }) async {
    final section = SavingsSection(
      id: 'sec-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      emoji: emoji,
      goal: roundSoles(goal),
      createdAt: DateTime.now(),
    );
    _book = SavingsBook(
      sections: [..._book.sections, section],
      contributions: _book.contributions,
    );
    notifyListeners();
    await _store.save(_book);
    return section;
  }

  Future<void> updateSection(SavingsSection section) async {
    final next = [
      for (final current in _book.sections)
        if (current.id == section.id) section else current,
    ];
    _book = SavingsBook(sections: next, contributions: _book.contributions);
    notifyListeners();
    await _store.save(_book);
  }

  Future<bool> removeSection(String id) async {
    if (_book.sections.length <= 1) {
      return false;
    }
    final sections = _book.sections
        .where((section) => section.id != id)
        .toList();
    final contributions = _book.contributions
        .where((item) => item.sectionId != id)
        .toList();
    _book = SavingsBook(sections: sections, contributions: contributions);
    notifyListeners();
    await _store.save(_book);
    return true;
  }
}
