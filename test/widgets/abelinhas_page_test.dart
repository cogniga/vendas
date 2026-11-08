import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales/core/theme/tema_app.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/features/abelinhas/application/abelinhas_providers.dart';
import 'package:sales/features/abelinhas/presentation/abelinhas_page.dart';

FaixaAbelinha _faixa(String id, String ate, String ab) => FaixaAbelinha(
      id: id,
      empresaId: 'e1',
      custoAte: Decimal.parse(ate),
      abelinhas: Decimal.parse(ab),
    );

Widget _montar() {
  final dados = DadosAbelinhas(
    produtos: const [],
    faixas: [
      _faixa('a', '5', '0.5'),
      _faixa('b', '8', '1'),
      _faixa('c', '12', '1.5'),
      _faixa('d', '16', '2'),
    ],
    valorAbelinha: Decimal.fromInt(10),
  );
  return ProviderScope(
    overrides: [
      dadosAbelinhasProvider.overrideWith((ref) async => dados),
    ],
    child: MaterialApp(
      theme: TemaApp.claro(),
      home: const Scaffold(
        body: SingleChildScrollView(child: AbelinhasPage()),
      ),
    ),
  );
}

void main() {
  testWidgets('digitar nas faixas é rápido e não lança erro', (tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_montar());
    await tester.pumpAndSettle();

    final campos = find.byType(TextField);
    // 0 = valor da abelinha; depois pares (custo até, abelinhas) por faixa.
    final abelinhasUltima = campos.at(8);
    final relogio = Stopwatch()..start();
    for (var i = 1; i <= 25; i++) {
      await tester.enterText(abelinhasUltima, '2' * i);
      await tester.pump();
    }
    // Apagar tudo (campo vazio / zero) também não pode quebrar.
    await tester.enterText(abelinhasUltima, '');
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(7), '0');
    await tester.pump();
    relogio.stop();

    // ignore: avoid_print
    print('tempo total digitando: ${relogio.elapsedMilliseconds} ms');
    expect(tester.takeException(), isNull);
    expect(relogio.elapsedMilliseconds, lessThan(3000));
  });

  testWidgets('mudar o teto não troca a faixa da linha em edição', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_montar());
    await tester.pumpAndSettle();

    // "Custo até" da última faixa (16) passa a 1: ela continua na 4ª linha.
    await tester.enterText(find.byType(TextField).at(7), '1');
    await tester.pump();

    expect(tester.takeException(), isNull);
    // O campo "Abelinhas" da mesma linha continua sendo o da faixa editada.
    final campoAbelinhas = tester.widget<TextField>(
      find.byType(TextField).at(8),
    );
    expect(campoAbelinhas.controller!.text, '2,00');
  });
}
