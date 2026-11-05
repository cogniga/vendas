import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sales/core/theme/tema_app.dart';
import 'package:sales/data/repositorios/destino_repository.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:sales/domain/entidades/empresa.dart';
import 'package:sales/domain/entidades/investimento.dart';
import 'package:sales/domain/entidades/retirada.dart';
import 'package:sales/domain/entidades/saque.dart';
import 'package:sales/domain/entidades/saque_rateio.dart';
import 'package:sales/features/caixa/application/caixa_providers.dart';
import 'package:sales/features/caixa/presentation/caixa_page.dart';

class _FakeDestinoRepository extends Mock implements DestinoRepository {}

const _empresa = Empresa(id: 'e1', nome: 'Revenda');

final _destinos = <Destino>[
  Destino(
    id: 'd1',
    empresaId: 'e1',
    nome: 'Cartão',
    cor: '#2B7A70',
    percentual: Decimal.parse('40'),
  ),
  Destino(
    id: 'd2',
    empresaId: 'e1',
    nome: 'Compras de produtos',
    cor: '#9A8FD4',
    percentual: Decimal.parse('60'),
  ),
];

final _saques = <Saque>[
  Saque(
    id: 's1',
    empresaId: 'e1',
    data: DateTime(2024, 5, 10),
    plataformaId: 'p1',
    valor: Decimal.parse('100.00'),
    rateio: [
      SaqueRateio(
        saqueId: 's1',
        empresaId: 'e1',
        destinoId: 'd1',
        percentual: Decimal.parse('40'),
        valor: Decimal.parse('40.00'),
      ),
      SaqueRateio(
        saqueId: 's1',
        empresaId: 'e1',
        destinoId: 'd2',
        percentual: Decimal.parse('60'),
        valor: Decimal.parse('60.00'),
      ),
    ],
  ),
];

final _investimentos = <Investimento>[
  Investimento(
    id: 'i1',
    empresaId: 'e1',
    data: DateTime(2024, 5, 11),
    distribuidor: 'Dalila',
    valor: Decimal.parse('30.00'),
    destinoId: 'd2',
  ),
];

final _retiradas = <Retirada>[
  Retirada(
    id: 'r1',
    empresaId: 'e1',
    data: DateTime(2024, 5, 12),
    destinoId: 'd1',
    valor: Decimal.parse('10.00'),
    descricao: 'Pró-labore',
  ),
];

DadosCaixa _dados() => DadosCaixa(
      destinos: _destinos,
      saques: _saques,
      investimentos: _investimentos,
      comprasInsumo: const [],
      retiradas: _retiradas,
      pedidos: const [],
      plataformas: const {},
    );

Widget _montar(DadosCaixa dados) {
  return ProviderScope(
    overrides: [
      empresaAtualProvider.overrideWith((ref) async => _empresa),
      dadosCaixaProvider.overrideWith((ref) async => dados),
      destinoRepositoryProvider
          .overrideWithValue(_FakeDestinoRepository()),
    ],
    child: MaterialApp(
      theme: TemaApp.claro(),
      home: const Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: CaixaPage(),
        ),
      ),
    ),
  );
}

void _definirLargura(WidgetTester tester, double largura) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(largura, 3000);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  testWidgets('renderiza KPIs, saldos e extrato em tela larga',
      (tester) async {
    _definirLargura(tester, 1280);
    await tester.pumpWidget(_montar(_dados()));
    await tester.pumpAndSettle();

    expect(find.text('Caixa e saques'), findsOneWidget);
    expect(find.text('Sacado das plataformas'), findsOneWidget);
    expect(find.text('Saldo por destino'), findsOneWidget);
    // Rateio 40 + 60 = 100% => pill de rateio fechado.
    expect(find.text('Rateio fecha 100%'), findsOneWidget);
    expect(find.text('Destinos e percentuais'), findsOneWidget);
    expect(find.text('Por plataforma'), findsOneWidget);
    expect(find.text('Extrato'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renderiza sem viewport unbounded em tela estreita',
      (tester) async {
    _definirLargura(tester, 420);
    await tester.pumpWidget(_montar(_dados()));
    await tester.pumpAndSettle();

    expect(find.text('Caixa e saques'), findsOneWidget);
    expect(find.text('Extrato'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading não lança viewport unbounded', (tester) async {
    _definirLargura(tester, 1280);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          empresaAtualProvider.overrideWith((ref) async => _empresa),
          dadosCaixaProvider.overrideWith(
            (ref) => Completer<DadosCaixa>().future,
          ),
        ],
        child: MaterialApp(
          theme: TemaApp.claro(),
          home: const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: CaixaPage(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
