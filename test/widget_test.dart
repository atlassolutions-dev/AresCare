import 'package:arescare/app.dart';
import 'package:arescare/data/savings_store.dart';
import 'package:arescare/data/seed_contributions.dart';
import 'package:arescare/state/savings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('muestra el ahorro de Ares y suma un aporte', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = SavingsController(
      MemorySavingsStore(seedBook(now: DateTime(2026, 10, 18, 12))),
    );
    await controller.load();

    await tester.pumpWidget(AresApp(controller: controller));
    await tester.pump();

    expect(find.text('Ahorros para Ares 🐾'), findsOneWidget);
    expect(find.text('S/. 950.00'), findsOneWidget);
    expect(find.text('Meta: S/. 1,500.00'), findsOneWidget);
    expect(find.text('Consultas'), findsOneWidget);
    expect(find.text('Anestesia'), findsOneWidget);
    expect(find.text('+ Agregar Aporte ✨'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Cirugía'), 200);
    expect(find.text('Cirugía'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Pequeños esfuerzos'), 200);
    expect(find.text('Ahorro del café'), findsWidgets);
    await tester.scrollUntilVisible(find.text('+ Agregar Aporte ✨'), -400);

    await tester.tap(find.byKey(const Key('add-contribution')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(find.byKey(const Key('contribution-amount')), '15');
    await tester.enterText(
      find.byKey(const Key('contribution-title')),
      'Prueba de amor',
    );
    await tester.tap(find.byKey(const Key('save-contribution')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Prueba de amor'), findsOneWidget);
    expect(controller.balance, 965);
    await tester.scrollUntilVisible(find.text('Todo lo guardado'), -400);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('S/. 965.00'), findsWidgets);
  });

  testWidgets('puede crear un proceso nuevo', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = SavingsController(
      MemorySavingsStore(seedBook(now: DateTime(2026, 10, 18, 12))),
    );
    await controller.load();
    await tester.pumpWidget(AresApp(controller: controller));
    await tester.pump();

    await tester.scrollUntilVisible(find.byKey(const Key('add-section')), 200);
    await tester.tap(find.byKey(const Key('add-section')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(find.byKey(const Key('section-name')), 'Medicinas');
    await tester.enterText(find.byKey(const Key('section-goal')), '200');
    await tester.tap(find.byKey(const Key('save-section')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Medicinas'), findsOneWidget);
    expect(controller.goal, 1700);
  });
}
