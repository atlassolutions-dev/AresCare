import 'package:arescare/data/savings_store.dart';
import 'package:arescare/data/seed_contributions.dart';
import 'package:arescare/domain/encouragement.dart';
import 'package:arescare/domain/money.dart';
import 'package:arescare/models/contribution.dart';
import 'package:arescare/state/savings_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatea soles con separador de miles', () {
    expect(formatSoles(950), 'S/. 950.00');
    expect(formatSoles(1500), 'S/. 1,500.00');
    expect(formatSoles(965), 'S/. 965.00');
    expect(formatSoles(0.5), 'S/. 0.50');
    expect(formatSoles(1000000), 'S/. 1,000,000.00');
  });

  test('acepta coma o punto como decimal', () {
    expect(parseSoles('15,50'), 15.5);
    expect(parseSoles('15.5'), 15.5);
    expect(parseSoles('0'), isNull);
    expect(parseSoles(''), isNull);
  });

  test('el ahorro inicial separa consultas, anestesia y cirugía', () {
    final book = seedBook(now: DateTime(2026, 10, 18));
    expect(book.saved, 950);
    expect(book.goal, 1500);
    expect(book.savedIn(DefaultSections.consultas), 700);
    expect(book.savedIn(DefaultSections.anestesia), 250);
    expect(book.savedIn(DefaultSections.cirugia), 0);
    expect(book.nextSection?.id, DefaultSections.anestesia);
    expect(book.progressOf(DefaultSections.consultas), 1);
    expect(book.progressOf(DefaultSections.anestesia), closeTo(0.5, 0.001));
  });

  test('un aporte viejo sin proceso se reparte llenando cada meta', () {
    final clock = DateTime(2026, 10, 18);
    final legacy = [
      Contribution(
        id: 'a',
        sectionId: '',
        title: 'Inicio',
        amount: 700,
        emoji: '🪙',
        createdAt: clock,
      ),
      Contribution(
        id: 'b',
        sectionId: '',
        title: 'Siguiente',
        amount: 100,
        emoji: '✨',
        createdAt: clock.add(const Duration(days: 1)),
      ),
    ];
    final book = migrateLegacyContributions(legacy);
    expect(book.savedIn(DefaultSections.consultas), 700);
    expect(book.savedIn(DefaultSections.anestesia), 100);
  });

  test('los mensajes rotan con cada apertura', () {
    expect(Encouragement.forLaunch(0), Encouragement.messages[0]);
    expect(Encouragement.forLaunch(1), Encouragement.messages[1]);
    expect(Encouragement.forLaunch(2), Encouragement.messages[2]);
    expect(Encouragement.forLaunch(3), Encouragement.messages[0]);
  });

  test('un aporte entra a un proceso y una sección nueva se guarda', () async {
    final store = MemorySavingsStore(seedBook(now: DateTime(2026, 10, 18)));
    final controller = SavingsController(store);
    await controller.load();
    expect(controller.balance, 950);

    await controller.add(
      sectionId: DefaultSections.cirugia,
      title: 'Extra del día',
      amount: 15,
      emoji: '✨',
    );
    expect(controller.balance, 965);
    expect(controller.savedIn(DefaultSections.cirugia), 15);

    final created = await controller.addSection(
      name: 'Medicinas',
      emoji: '💊',
      goal: 200,
    );
    expect(controller.goal, 1700);
    expect(controller.findSection(created.id)?.name, 'Medicinas');

    final reloaded = SavingsController(store);
    await reloaded.load();
    expect(reloaded.balance, 965);
    expect(reloaded.sections.last.name, 'Medicinas');
  });
}
