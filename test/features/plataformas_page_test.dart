import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/theme/tema_app.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/features/plataformas/application/plataformas_providers.dart';
import 'package:sales/features/plataformas/presentation/plataformas_page.dart';

/// Plataforma de teste com uma faixa única sem limite (fixo 2,00 + 5%).
const _plataforma = Plataforma(
  id: 'p1',
  empresaId: 'e1',
  nome: 'Shopee',
  cor: '#f0846a',
);

final _faixas = <FaixaTaxa>[
  FaixaTaxa(
    id: 'f1',
    empresaId: 'e1',
    plataformaId: 'p1',
    taxaFixa: Decimal.parse('2.00'),
    taxaPercentual: Decimal.parse('5'),
  ),
];

/// Monta a página com `plataformasProvider` sobrescrito pelo [mapa] dado,
/// dentro de um SingleChildScrollView (como o AppShell faz em runtime).
Widget _montar(Map<Plataforma, List<FaixaTaxa>> mapa) {
  return ProviderScope(
    overrides: [
      plataformasProvider.overrideWith((ref) async => mapa),
    ],
    child: MaterialApp(
      theme: TemaApp.claro(),
      home: const Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: PlataformasPage(),
        ),
      ),
    ),
  );
}

void _definirLargura(WidgetTester tester, double largura) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(largura, 2000);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('renderiza cartão e simulação em tela larga', (tester) async {
    _definirLargura(tester, 1280);
    await tester.pumpWidget(_montar({_plataforma: _faixas}));
    await tester.pumpAndSettle();

    expect(find.text('Plataformas e taxas'), findsOneWidget);
    // Nome da plataforma aparece no cabeçalho e no campo Nome do cartão.
    expect(find.text('Shopee'), findsWidgets);
    // As 5 linhas de simulação (taxa/líquido) aparecem (rótulo = preço).
    expect(find.text(Formatos.moedaDecimal(Decimal.parse('19.99'))),
        findsOneWidget);
    expect(find.text(Formatos.moedaDecimal(Decimal.parse('249.90'))),
        findsOneWidget);
    // Simulação de 19,99: taxa = 2,00 + 5% de 19,99 = 3,00 (arred.); líquido
    // = 16,99. Conferimos o texto combinado.
    final taxaStr = Formatos.moedaDecimal(Decimal.parse('3.00'));
    final liqStr = Formatos.moedaDecimal(Decimal.parse('16.99'));
    expect(
      find.text('taxa $taxaStr · líq. $liqStr'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renderiza sem exceção em tela estreita', (tester) async {
    _definirLargura(tester, 400);
    await tester.pumpWidget(_montar({_plataforma: _faixas}));
    await tester.pumpAndSettle();

    expect(find.text('Shopee'), findsWidgets);
    expect(find.text(Formatos.moedaDecimal(Decimal.parse('59.90'))),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mapa vazio mostra estado vazio sem crash', (tester) async {
    _definirLargura(tester, 1280);
    await tester.pumpWidget(_montar({}));
    await tester.pumpAndSettle();

    expect(find.text('Plataformas e taxas'), findsOneWidget);
    expect(find.text('Nenhuma plataforma ainda.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
