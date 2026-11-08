import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sales/core/theme/tema_app.dart';
import 'package:sales/domain/calculos/painel.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/pedido_item.dart';
import 'package:sales/features/painel/application/painel_providers.dart';
import 'package:sales/features/painel/presentation/painel_page.dart';

const _titulosKpi = [
  'Faturamento',
  'Taxas das plataformas',
  'Líquido recebido',
  'Custo dos pedidos',
  'Lucro',
];
const _titulosPaineis = [
  'Vendas por plataforma',
  'Pontos de atenção',
  'Caixa por destino',
  'Itens mais vendidos',
];

DadosBrutosPainel _vazio() => DadosBrutosPainel(
      pedidos: const [],
      faixasPorPlataforma: const {},
      nomesPlataformas: const {},
      coresPlataformas: const {},
      nomesProdutos: const {},
      nomesKits: const {},
      pontos: const [],
      destinosComSaldo: const [],
      totalSacado: Decimal.zero,
    );

DadosBrutosPainel _comDados() {
  final pedido = Pedido(
    id: 'p1',
    empresaId: 'e1',
    data: DateTime(2020, 1, 10),
    cliente: 'Ana',
    plataformaId: 'tiktok',
    embalagem: Decimal.zero,
    impressao: Decimal.zero,
    outros: Decimal.zero,
    precoVenda: Decimal.parse('100'),
    itens: [
      PedidoItem(
        id: 'i1',
        empresaId: 'e1',
        pedidoId: 'p1',
        tipo: TipoPedidoItem.produto,
        quantidade: 3,
        custoUnitario: Decimal.parse('10'),
        abelinhasUnitarias: Decimal.one,
        produtoId: 'prod1',
      ),
    ],
  );
  return DadosBrutosPainel(
    pedidos: [pedido],
    faixasPorPlataforma: {
      'tiktok': [
        FaixaTaxa(
          id: 'f',
          empresaId: 'e1',
          plataformaId: 'tiktok',
          taxaFixa: Decimal.parse('4'),
          taxaPercentual: Decimal.parse('12'),
        ),
      ],
    },
    nomesPlataformas: const {'tiktok': 'TikTok Shop'},
    coresPlataformas: const {'tiktok': '#6CC3B6'},
    nomesProdutos: const {'prod1': 'Gloss Playboy'},
    nomesKits: const {},
    pontos: const [
      PontoAtencao(
        tipo: 'codigoRepetido',
        mensagem: 'Códigos repetidos no cadastro: X. '
            'Cada código deve ser único.',
        gravidade: GravidadeAtencao.atencao,
      ),
    ],
    destinosComSaldo: [
      DestinoComSaldo(
        Destino(
          id: 'd1',
          empresaId: 'e1',
          nome: 'Cartão',
          cor: '#6A9FD8',
          percentual: Decimal.parse('40'),
        ),
        Decimal.parse('-5'),
      ),
    ],
    totalSacado: Decimal.parse('300'),
  );
}

Widget _montar(DadosBrutosPainel dados, {ThemeData? tema}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: PainelPage(),
          ),
        ),
      ),
      GoRoute(
        path: '/caixa',
        builder: (_, __) => const Scaffold(body: Text('TELA CAIXA')),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      dadosBrutosPainelProvider.overrideWith((ref) async => dados),
    ],
    child: MaterialApp.router(
      theme: tema ?? TemaApp.claro(),
      routerConfig: router,
    ),
  );
}

void _largura(WidgetTester tester, double largura) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(largura, 3000);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  for (final largura in [1440.0, 400.0]) {
    testWidgets('com dados em ${largura.toInt()}px', (tester) async {
      _largura(tester, largura);
      await tester.pumpWidget(_montar(_comDados()));
      await tester.pumpAndSettle();
      for (final t in [..._titulosKpi, ..._titulosPaineis]) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      expect(find.textContaining('100,00'), findsWidgets);
      expect(find.text('1 pedido(s)'), findsOneWidget);
      expect(find.text('Gloss Playboy'), findsOneWidget);
      expect(find.text('Total sacado das plataformas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('vazio em ${largura.toInt()}px', (tester) async {
      _largura(tester, largura);
      await tester.pumpWidget(_montar(_vazio()));
      await tester.pumpAndSettle();
      for (final t in [..._titulosKpi, ..._titulosPaineis]) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      expect(find.text('Nenhum pedido no período.'), findsOneWidget);
      expect(find.text('Nenhum alerta.'), findsOneWidget);
      expect(find.text('Sem vendas.'), findsOneWidget);
      expect(find.text('— do faturamento'), findsOneWidget);
      expect(find.text('margem —'), findsOneWidget);
      expect(find.text('Tudo certo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('alternar período muda o faturamento', (tester) async {
    _largura(tester, 1440);
    await tester.pumpWidget(_montar(_comDados()));
    await tester.pumpAndSettle();
    expect(find.text('1 pedido(s)'), findsOneWidget);
    await tester.tap(find.text('Este mês'));
    await tester.pumpAndSettle();
    expect(find.text('0 pedido(s)'), findsOneWidget);
    await tester.tap(find.text('Todo o período'));
    await tester.pumpAndSettle();
    expect(find.text('1 pedido(s)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Abrir caixa navega para /caixa', (tester) async {
    _largura(tester, 1440);
    await tester.pumpWidget(_montar(_comDados()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abrir caixa'));
    await tester.pumpAndSettle();
    expect(find.text('TELA CAIXA'), findsOneWidget);
  });

  testWidgets('tema escuro sem exceção', (tester) async {
    _largura(tester, 400);
    await tester.pumpWidget(_montar(_comDados(), tema: TemaApp.escuro()));
    await tester.pumpAndSettle();
    expect(find.text('Painel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
