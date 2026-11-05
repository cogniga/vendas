import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales/core/theme/tema_app.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/domain/entidades/produto_venda.dart';
import 'package:sales/domain/entidades/produto_venda_item.dart';
import 'package:sales/features/composicao/application/composicao_providers.dart';
import 'package:sales/features/composicao/presentation/composicao_page.dart';

const _empresa = 'e1';

ProdutoVenda _kit() => ProdutoVenda(
      id: 'k1',
      empresaId: _empresa,
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
          id: 'i1',
          empresaId: _empresa,
          produtoVendaId: 'k1',
          produtoId: 'p1',
          quantidade: 5,
        ),
      ],
    );

Produto _produto() => Produto(
      id: 'p1',
      empresaId: _empresa,
      codigo: 'SKU1',
      nome: 'Sachê máscara',
      custo: Decimal.fromInt(4),
    );

const _plataforma = Plataforma(
  id: 'pl1',
  empresaId: _empresa,
  nome: 'Shopee',
  cor: '#EE4D2D',
);

FaixaTaxa _faixa() => FaixaTaxa(
      id: 'f1',
      empresaId: _empresa,
      plataformaId: 'pl1',
      taxaFixa: Decimal.fromInt(4),
      taxaPercentual: Decimal.fromInt(20),
    );

FaixaAbelinha _faixaAbelinha() => FaixaAbelinha(
      id: 'fa1',
      empresaId: _empresa,
      custoAte: Decimal.fromInt(10),
      abelinhas: Decimal.one,
    );

Widget _montar({required List<ProdutoVenda> kits}) {
  return ProviderScope(
    overrides: [
      kitsProvider.overrideWith((ref) async => kits),
      plataformasComFaixasProvider.overrideWith(
        (ref) async => {
          _plataforma: [_faixa()],
        },
      ),
      produtosProvider.overrideWith((ref) async => [_produto()]),
      faixasAbelinhaProvider.overrideWith(
        (ref) async => [_faixaAbelinha()],
      ),
    ],
    child: MaterialApp(
      theme: TemaApp.claro(),
      home: const Scaffold(
        body: SingleChildScrollView(child: ComposicaoPage()),
      ),
    ),
  );
}

void main() {
  testWidgets('mostra cabeçalho e botão de novo produto de venda', (
    tester,
  ) async {
    await tester.pumpWidget(_montar(kits: [_kit()]));
    await tester.pumpAndSettle();

    expect(find.text('Composição de custo'), findsOneWidget);
    expect(find.text('Novo produto de venda'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('com kits mostra a coluna da plataforma e a hint do rodapé', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_montar(kits: [_kit()]));
    await tester.pumpAndSettle();

    expect(find.text('Produto de venda'), findsOneWidget);
    expect(find.text('Investimento'), findsOneWidget);
    expect(find.text('Shopee'), findsWidgets);
    expect(find.text('Kit 5 sachês'), findsOneWidget);
    expect(
      find.textContaining('lucro por venda'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('estado vazio mostra mensagem de nenhum produto', (
    tester,
  ) async {
    await tester.pumpWidget(_montar(kits: const []));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Nenhum produto de venda ainda'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
