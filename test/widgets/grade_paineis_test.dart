import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales/core/widgets/grade_paineis.dart';

void main() {
  group('colunasPara', () {
    test('4 painéis em 3 colunas viram 2×2', () {
      expect(GradePaineis.colunasPara(4, 3), 2);
    });
    test('usa o máximo quando não sobra buraco', () {
      expect(GradePaineis.colunasPara(4, 4), 4);
      expect(GradePaineis.colunasPara(3, 3), 3);
      expect(GradePaineis.colunasPara(6, 3), 3);
    });
    test('estreito vira 1 coluna; vazio vira 0', () {
      expect(GradePaineis.colunasPara(4, 0), 1);
      expect(GradePaineis.colunasPara(0, 3), 0);
    });
  });

  testWidgets('painéis da mesma linha ficam com a mesma altura', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: GradePaineis(
              filhos: [
                Container(key: const Key('a'), height: 100, color: Colors.red),
                // Painel com LayoutBuilder dentro (caso que quebrava antes).
                LayoutBuilder(
                  key: const Key('b'),
                  builder: (_, __) => const SizedBox(height: 200),
                ),
                Container(key: const Key('c'), height: 50, color: Colors.blue),
                Container(key: const Key('d'), height: 80, color: Colors.green),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final a = tester.getRect(find.byKey(const Key('a')));
    final b = tester.getRect(find.byKey(const Key('b')));
    final c = tester.getRect(find.byKey(const Key('c')));
    final d = tester.getRect(find.byKey(const Key('d')));
    // 2×2: a e b na 1ª linha, c e d na 2ª, alturas iguais por linha.
    expect(a.top, b.top);
    expect(a.height, 200);
    expect(b.height, 200);
    expect(c.top, d.top);
    expect(c.height, 80);
    expect(c.width, a.width);
  });
}
