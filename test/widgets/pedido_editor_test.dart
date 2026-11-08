import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sales/core/theme/tema_app.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/data/repositorios/pedido_repository.dart';
import 'package:sales/domain/entidades/empresa.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/pedido_item.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/domain/entidades/produto_venda.dart';
import 'package:sales/domain/entidades/produto_venda_item.dart';
import 'package:sales/features/pedidos/application/pedidos_providers.dart';
import 'package:sales/features/pedidos/presentation/pedido_editor.dart';

class _MockRepo extends Mock implements PedidoRepository {}

const _empresa = Empresa(id: 'e1', nome: 'Revenda');
const _plataforma = Plataforma(
  id: 'pl1',
  empresaId: 'e1',
  nome: 'Shopee',
  cor: '#EE4D2D',
);

Produto _produto(String id, String codigo, String nome, int custo) => Produto(
      id: id,
      empresaId: 'e1',
      codigo: codigo,
      nome: nome,
      custo: Decimal.fromInt(custo),
    );

final _dados = DadosEdicaoPedido(
  plataformas: {
    _plataforma: [
      FaixaTaxa(
        id: 'f1',
        empresaId: 'e1',
        plataformaId: 'pl1',
        taxaFixa: Decimal.fromInt(4),
        taxaPercentual: Decimal.fromInt(20),
      ),
    ],
  },
  produtos: [
    _produto('p1', 'SKU1', 'Sachê máscara', 4),
    _produto('p2', 'SKU2', 'Batom matte', 6),
  ],
  kits: [
    ProdutoVenda(
      id: 'k1',
      empresaId: 'e1',
      nome: 'Kit 5 sachês',
      embalagem: Decimal.zero,
      impressao: Decimal.zero,
      outros: Decimal.zero,
      preco: Decimal.fromInt(60),
      desconto: Decimal.zero,
      cupom: Decimal.zero,
      metaLucro: Decimal.fromInt(200),
      fatiaRoas: Decimal.parse('0.3'),
      margemAlvo: Decimal.fromInt(30),
      itens: const [
        ProdutoVendaItem(
          id: 'ki1',
          empresaId: 'e1',
          produtoVendaId: 'k1',
          produtoId: 'p1',
          quantidade: 5,
        ),
      ],
    ),
  ],
  configuracoes: null,
  faixasAbelinha: [
    FaixaAbelinha(
      id: 'fa1',
      empresaId: 'e1',
      custoAte: Decimal.fromInt(10),
      abelinhas: Decimal.one,
    ),
  ],
);

PedidoItem _item(
  String id, {
  required int qtd,
  required int custo,
  required String ab,
  String? produtoId,
  String? kitId,
}) =>
    PedidoItem(
      id: id,
      empresaId: 'e1',
      pedidoId: 'ped1',
      tipo: kitId == null
          ? TipoPedidoItem.produto
          : TipoPedidoItem.produtoVenda,
      quantidade: qtd,
      custoUnitario: Decimal.fromInt(custo),
      abelinhasUnitarias: Decimal.parse(ab),
      produtoId: produtoId,
      produtoVendaId: kitId,
    );

/// Pedido como vem da lista sem itens, para provar que o editor busca o
/// completo.
Pedido _pedidoDaLista() => Pedido(
      id: 'ped1',
      empresaId: 'e1',
      data: DateTime(2024, 5, 10),
      cliente: 'CLIENTE 1',
      plataformaId: 'pl1',
      embalagem: Decimal.zero,
      impressao: Decimal.zero,
      outros: Decimal.zero,
      precoVenda: Decimal.fromInt(100),
    );

/// Snapshot de p1 (7, diferente do cadastro atual 4), kit, e um produto que
/// não existe mais no cadastro.
Pedido _pedidoCompleto() => _pedidoDaLista().copyWith(
      itens: [
        _item('i1', produtoId: 'p1', qtd: 2, custo: 7, ab: '1'),
        _item('i2', kitId: 'k1', qtd: 1, custo: 20, ab: '5'),
        _item('i3', produtoId: 'pX', qtd: 1, custo: 3, ab: '0.5'),
      ],
    );

Future<void> _abrir(
  WidgetTester tester, {
  required _MockRepo repo,
  Pedido? pedido,
  Future<Pedido?> Function()? completo,
  Size tamanho = const Size(1440, 900),
  List<bool?>? resultados,
}) async {
  tester.view.physicalSize = tamanho;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dadosEdicaoPedidoProvider.overrideWith((ref) async => _dados),
        pedidoCompletoProvider.overrideWith(
          (ref, id) => (completo ?? () async => _pedidoCompleto())(),
        ),
        pedidoRepositoryProvider.overrideWithValue(repo),
        empresaAtualProvider.overrideWith((ref) async => _empresa),
      ],
      child: MaterialApp(
        theme: TemaApp.claro(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                final r = await showDialog<bool>(
                  context: context,
                  builder: (_) => PedidoEditor(pedido: pedido),
                );
                resultados?.add(r);
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('abrir'));
  await tester.pump();
}

void main() {
  late _MockRepo repo;

  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    registerFallbackValue(_pedidoDaLista());
  });

  setUp(() {
    repo = _MockRepo();
    when(() => repo.salvar(any())).thenAnswer(
      (i) async => i.positionalArguments.first as Pedido,
    );
  });

  Future<Pedido> salvar(WidgetTester tester) async {
    await tester.tap(find.text('Salvar pedido'));
    await tester.pumpAndSettle();
    return verify(() => repo.salvar(captureAny())).captured.single as Pedido;
  }

  testWidgets('abrir pedido existente mostra os itens do pedido completo', (
    tester,
  ) async {
    await _abrir(tester, repo: repo, pedido: _pedidoDaLista());
    await tester.pumpAndSettle();

    expect(find.text('Sachê máscara'), findsWidgets);
    expect(find.text('Kit 5 sachês'), findsWidgets);
    expect(find.text('(produto removido)'), findsWidgets);
    expect(find.text('Adicione os itens que o cliente comprou.'), findsNothing);
    expect(find.text('CLIENTE 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('enquanto carrega mostra indicador e Salvar fica desabilitado', (
    tester,
  ) async {
    final c = Completer<Pedido?>();
    await _abrir(
      tester,
      repo: repo,
      pedido: _pedidoDaLista(),
      completo: () => c.future,
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final salvarBtn = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(salvarBtn.onPressed, isNull);

    c.complete(_pedidoCompleto());
    await tester.pumpAndSettle();
    expect(find.text('Sachê máscara'), findsWidgets);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets(
    'editar: remove, muda quantidade e adiciona item; salva a lista nova',
    (tester) async {
      final resultados = <bool?>[];
      await _abrir(
        tester,
        repo: repo,
        pedido: _pedidoDaLista(),
        resultados: resultados,
      );
      await tester.pumpAndSettle();

      // Remove o kit (2ª linha).
      await tester.tap(find.byTooltip('Remover item').at(1));
      await tester.pump();
      // p1: qtd 2 -> 3.
      await tester.tap(find.byTooltip('Aumentar').first);
      await tester.pump();
      // Adiciona p2 pelo picker.
      await tester.tap(find.text('Adicionar').last);
      await tester.pump();

      final salvo = await salvar(tester);

      expect(resultados, [true]);
      final porRef = {
        for (final i in salvo.itens) (i.produtoId ?? i.produtoVendaId): i,
      };
      expect(porRef.keys, unorderedEquals(['p1', 'pX', 'p2']));
      expect(porRef['p1']!.quantidade, 3);
      // Mantém o snapshot gravado (7) mesmo com o cadastro em 4.
      expect(porRef['p1']!.custoUnitario, Decimal.fromInt(7));
      // Item novo usa o cadastro atual.
      expect(porRef['p2']!.custoUnitario, Decimal.fromInt(6));
      expect(porRef['p2']!.quantidade, 1);
      expect(salvo.id, 'ped1');
      expect(salvo.empresaId, 'e1');
    },
  );

  testWidgets('salvar sem alterar mantém itens, snapshots e item órfão', (
    tester,
  ) async {
    await _abrir(tester, repo: repo, pedido: _pedidoDaLista());
    await tester.pumpAndSettle();

    final salvo = await salvar(tester);

    expect(salvo.itens, hasLength(3));
    final orfao = salvo.itens.firstWhere((i) => i.produtoId == 'pX');
    expect(orfao.custoUnitario, Decimal.fromInt(3));
    expect(orfao.abelinhasUnitarias, Decimal.parse('0.5'));
    final kit = salvo.itens.firstWhere((i) => i.produtoVendaId == 'k1');
    expect(kit.tipo, TipoPedidoItem.produtoVenda);
    expect(kit.custoUnitario, Decimal.fromInt(20));
    expect(salvo.precoVenda, Decimal.fromInt(100));
  });

  for (final tamanho in const [Size(1440, 900), Size(400, 800)]) {
    testWidgets('layout do protótipo em ${tamanho.width.toInt()}px', (
      tester,
    ) async {
      await _abrir(
        tester,
        repo: repo,
        pedido: _pedidoDaLista(),
        tamanho: tamanho,
      );
      await tester.pumpAndSettle();

      for (final t in const [
        'Pedido',
        'Fechar',
        'Data',
        'Cliente / nº do pedido',
        'Plataforma de venda',
        'Status',
        'Itens do pedido',
        'Adicionar produto ou produto de venda',
        'Custos do envio',
        r'Embalagem (R$)',
        r'Impressão (R$)',
        r'Outros (R$)',
        'Venda',
        r'Preço de venda (R$)',
        'Itens cobrados com taxa fixa',
        r'Líquido recebido (R$)',
        'Observação',
        'Cancelar',
        'Salvar pedido',
      ]) {
        expect(find.text(t), findsWidgets, reason: t);
      }
      // O resumo fica na coluna rolável à direita; no celular, empilhado.
      if (tamanho.width < 800) {
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -3000),
        );
        await tester.pumpAndSettle();
      }
      for (final t in const [
        'Custo do pedido',
        'Mercadoria',
        'Custo total',
        'Abelinhas do pedido',
        'Total de abelinhas',
        'Líquido estimado',
        'Líquido considerado',
        'Lucro do pedido',
      ]) {
        expect(find.text(t), findsWidgets, reason: t);
      }
      expect(
        find.textContaining(r'Taxa estimada Shopee (20% + R$'),
        findsOneWidget,
      );
      expect(find.text('estimado'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('novo pedido vazio mostra a mensagem de itens e traço', (
    tester,
  ) async {
    await _abrir(tester, repo: repo);
    await tester.pumpAndSettle();

    expect(find.text('Novo pedido'), findsOneWidget);
    expect(find.text('Adicione os itens que o cliente comprou.'),
        findsOneWidget);
    expect(find.text('Nenhum item ainda'), findsOneWidget);
    expect(find.text('Margem sobre a venda: —'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
