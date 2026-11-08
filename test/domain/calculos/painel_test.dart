import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales/domain/calculos/painel.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/pedido_item.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/domain/entidades/produto_venda.dart';
import 'package:sales/domain/entidades/produto_venda_item.dart';

import 'plataformas_vetores.dart';
import 'tolerancia.dart';

const _empresa = '00000000-0000-0000-0000-0000000000aa';

PedidoItem _item(
  String id,
  String pedidoId,
  int qtd,
  String custo,
  String abelinhas,
) => PedidoItem(
  id: id,
  empresaId: _empresa,
  pedidoId: pedidoId,
  tipo: TipoPedidoItem.produto,
  quantidade: qtd,
  custoUnitario: Decimal.parse(custo),
  abelinhasUnitarias: Decimal.parse(abelinhas),
);

Pedido _pedido(
  String id,
  String liquidoInformado,
  List<PedidoItem> itens,
) => Pedido(
  id: id,
  empresaId: _empresa,
  data: DateTime(2026, 10, 12),
  cliente: id,
  plataformaId: 'tiktok',
  embalagem: Decimal.parse('0.90'),
  impressao: Decimal.parse('1.00'),
  outros: Decimal.zero,
  precoVenda: Decimal.parse('110.00'),
  liquidoInformado: Decimal.parse(liquidoInformado),
  itens: itens,
);

void main() {
  test('KPIs do painel com os pedidos da planilha (design.md §6.5)', () {
    final dalila = _pedido('dalila', '85.85', [
      _item('d1', 'dalila', 1, '21.69', '3'),
      _item('d2', 'dalila', 2, '1.59', '0.5'),
      _item('d3', 'dalila', 1, '2.44', '0.5'),
      _item('d4', 'dalila', 1, '6.45', '1'),
      _item('d5', 'dalila', 1, '15.60', '2'),
    ]);
    final thais = _pedido('thais', '97.40', [
      _item('t1', 'thais', 1, '21.69', '3'),
      _item('t2', 'thais', 1, '7.35', '1'),
      _item('t3', 'thais', 1, '6.45', '1'),
      _item('t4', 'thais', 1, '4.68', '0.5'),
      _item('t5', 'thais', 1, '1.59', '0.5'),
    ]);

    final faixas = <String, List<FaixaTaxa>>{'tiktok': faixasTikTok()};
    final kpis = kpisPainel([dalila, thais], faixas);

    esperaValor(kpis.faturamento, '220.00');
    esperaValor(kpis.taxas, '36.75');
    esperaValor(kpis.liquido, '183.25');
    esperaValor(kpis.custo, '94.92');
    esperaValor(kpis.lucro, '88.33');
    esperaPct(kpis.margem, '40.1');
  });

  group('filtrarPedidosPeriodo', () {
    Pedido ped(String id, DateTime data, [SituacaoPedido? st]) => _pedido(
      id,
      '10',
      const [],
    ).copyWith(
      data: data,
      situacao: st ?? SituacaoPedido.concluido,
    );
    final hoje = DateTime(2026, 10, 20);
    final lista = [
      ped('a', DateTime(2026, 10)),
      ped('b', DateTime(2025, 10)),
      ped('c', DateTime(2026, 9, 30)),
      ped('d', DateTime(2026, 10, 2), SituacaoPedido.cancelado),
      ped('e', DateTime(2026, 10, 3), SituacaoPedido.devolvido),
    ];

    test('mês exclui outros meses, anos e não concluídos', () {
      final r = filtrarPedidosPeriodo(lista, PeriodoPainel.mes, hoje);
      expect(r.map((p) => p.id), ['a']);
    });

    test('tudo inclui todos os concluídos', () {
      final r = filtrarPedidosPeriodo(lista, PeriodoPainel.tudo, hoje);
      expect(r.map((p) => p.id), ['a', 'b', 'c']);
    });
  });

  group('vendasPorPlataforma', () {
    test('lista vazia', () {
      expect(vendasPorPlataforma(const [], const {}), isEmpty);
    });

    test('soma bruto, líquido e conta na ordem de inserção', () {
      final faixas = <String, List<FaixaTaxa>>{'tiktok': faixasTikTok()};
      final a = _pedido('a', '90', const []);
      final b = _pedido('b', '80', const []);
      final c = _pedido('c', '70', const []).copyWith(plataformaId: 'x');
      final r = vendasPorPlataforma([a, b, c], faixas);
      expect(r.map((v) => v.plataformaId), ['tiktok', 'x']);
      esperaValor(r[0].bruto, '220.00');
      esperaValor(r[0].liquido, '170.00');
      expect(r[0].pedidos, 2);
      expect(r[1].pedidos, 1);
    });
  });

  group('itensMaisVendidos', () {
    PedidoItem it(String id, TipoPedidoItem tipo, String ref, int q) =>
        PedidoItem(
          id: id,
          empresaId: _empresa,
          pedidoId: 'p',
          tipo: tipo,
          quantidade: q,
          custoUnitario: Decimal.one,
          abelinhasUnitarias: Decimal.one,
          produtoId: tipo == TipoPedidoItem.produto ? ref : null,
          produtoVendaId: tipo == TipoPedidoItem.produtoVenda ? ref : null,
        );

    test('agrupa, ordena, mantém empate estável e resolve nomes', () {
      final ped = _pedido('p', '10', [
        it('1', TipoPedidoItem.produto, 'a', 1),
        it('2', TipoPedidoItem.produtoVenda, 'a', 1),
        it('3', TipoPedidoItem.produto, 'b', 2),
        it('4', TipoPedidoItem.produto, 'a', 1),
        it('5', TipoPedidoItem.produto, 'z', 1),
      ]);
      final r = itensMaisVendidos(
        [ped],
        nomesProdutos: {'a': 'Prod A', 'b': 'Prod B'},
        nomesKits: {'a': 'Kit A'},
      );
      expect(r.map((i) => i.nome), [
        'Prod A',
        'Prod B',
        'Kit A',
        '(produto removido)',
      ]);
      expect(r.map((i) => i.quantidade), [2, 2, 1, 1]);
    });

    test('limita a 6 e kit removido tem fallback', () {
      final ped = _pedido('p', '10', [
        for (var i = 0; i < 8; i++)
          it('$i', TipoPedidoItem.produtoVenda, 'k$i', 1),
      ]);
      final r = itensMaisVendidos([ped]);
      expect(r, hasLength(6));
      expect(r.first.nome, '(kit removido)');
    });
  });

  group('pontosAtencao', () {
    Destino dest(String id, String pct) => Destino(
      id: id,
      empresaId: _empresa,
      nome: id,
      cor: '#000000',
      percentual: Decimal.parse(pct),
    );
    Produto prod(String id, String codigo, String custo) => Produto(
      id: id,
      empresaId: _empresa,
      codigo: codigo,
      nome: id,
      custo: Decimal.parse(custo),
    );
    ProdutoVenda kit(String preco) => ProdutoVenda(
      id: 'k',
      empresaId: _empresa,
      nome: 'Batom',
      embalagem: Decimal.zero,
      impressao: Decimal.zero,
      outros: Decimal.zero,
      preco: Decimal.parse(preco),
      desconto: Decimal.zero,
      cupom: Decimal.zero,
      metaLucro: Decimal.parse('200'),
      fatiaRoas: Decimal.parse('0.3'),
      margemAlvo: Decimal.parse('30'),
      itens: const [
        ProdutoVendaItem(
          id: 'i',
          empresaId: _empresa,
          produtoVendaId: 'k',
          produtoId: 'p',
          quantidade: 1,
        ),
      ],
    );
    const plataforma = Plataforma(
      id: 'tiktok',
      empresaId: _empresa,
      nome: 'TikTok',
    );

    List<PontoAtencao> calc({
      List<Destino>? destinos,
      List<Produto>? produtos,
      List<ProdutoVenda> kits = const [],
      List<Plataforma> plataformas = const [plataforma],
    }) {
      final prods = produtos ?? [prod('p', 'A', '10')];
      return pontosAtencao(
        destinos: destinos ?? [dest('d', '100')],
        produtos: prods,
        kits: kits,
        produtosPorId: {for (final p in prods) p.id: p},
        plataformas: plataformas,
        faixasPorPlataforma: {'tiktok': faixasTikTok()},
        faixasAbelinha: const [],
      );
    }

    test('tudo certo: lista vazia', () {
      expect(calc(kits: [kit('100')]), isEmpty);
    });

    test('destinos somando 95,5 gera alerta ruim', () {
      final r = calc(destinos: [dest('a', '95.5')]);
      expect(r.single.gravidade, GravidadeAtencao.ruim);
      expect(
        r.single.mensagem,
        'Os destinos do caixa somam 95,5%. '
        'Ajuste para 100% em Caixa e saques.',
      );
    });

    test('soma dentro de 0,01 de 100 não alerta', () {
      expect(calc(destinos: [dest('a', '100.005')]), isEmpty);
    });

    test('kit com prejuízo', () {
      final r = calc(
        produtos: [prod('p', 'A', '90')],
        kits: [kit('100')],
      );
      expect(r.single.gravidade, GravidadeAtencao.ruim);
      expect(r.single.mensagem, startsWith('\u201cBatom\u201d dá prejuízo em'));
      expect(r.single.mensagem, contains(r'TikTok (mín. R$'));
    });

    test('kit com margem baixa', () {
      final r = calc(
        produtos: [prod('p', 'A', '80')],
        kits: [kit('100')],
      );
      expect(r.single.gravidade, GravidadeAtencao.atencao);
      expect(
        r.single.mensagem,
        '\u201cBatom\u201d tem margem baixa em TikTok (4,8%).',
      );
    });

    test('kit sem plataformas não alerta', () {
      expect(
        calc(kits: [kit('100')], plataformas: const []),
        isEmpty,
      );
    });

    test('códigos repetidos', () {
      final r = calc(
        produtos: [prod('p', 'X', '10'), prod('q', 'X', '10')],
      );
      expect(
        r.single.mensagem,
        'Códigos repetidos no cadastro: X. Cada código deve ser único.',
      );
    });
  });

  test('KPIs sem pedidos não lançam e dão margem zero', () {
    final k = kpisPainel(const [], const {});
    expect(k.margem, Decimal.zero);
    expect(k.faturamento, Decimal.zero);
  });
}
