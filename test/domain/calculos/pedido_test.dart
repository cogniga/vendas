import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales/domain/calculos/pedido.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/pedido_item.dart';

import 'plataformas_vetores.dart';
import 'tolerancia.dart';

const _empresa = '00000000-0000-0000-0000-0000000000aa';

PedidoItem _itemProduto(
  String id,
  String pedidoId,
  int qtd,
  String custoUnitario,
  String abelinhas,
) => PedidoItem(
  id: id,
  empresaId: _empresa,
  pedidoId: pedidoId,
  tipo: TipoPedidoItem.produto,
  quantidade: qtd,
  custoUnitario: Decimal.parse(custoUnitario),
  abelinhasUnitarias: Decimal.parse(abelinhas),
);

Pedido _pedido({
  required String id,
  required String plataformaId,
  required String precoVenda,
  required String embalagem,
  required String impressao,
  required List<PedidoItem> itens,
  String? liquidoInformado,
  int itensTaxaFixa = 1,
}) => Pedido(
  id: id,
  empresaId: _empresa,
  data: DateTime(2026, 10, 12),
  cliente: id,
  plataformaId: plataformaId,
  embalagem: Decimal.parse(embalagem),
  impressao: Decimal.parse(impressao),
  outros: Decimal.zero,
  precoVenda: Decimal.parse(precoVenda),
  itensTaxaFixa: itensTaxaFixa,
  liquidoInformado:
      liquidoInformado == null ? null : Decimal.parse(liquidoInformado),
  itens: itens,
);

void main() {
  test('KT01-DALILA no TikTok (design.md §6.4)', () {
    // Itens: K2, L1×2, C1, PB, PB3 → mercadoria 49,36; abelinhas 7,5.
    final pedido = _pedido(
      id: 'dalila',
      plataformaId: 'tiktok',
      precoVenda: '110.00',
      embalagem: '0.90',
      impressao: '1.00',
      liquidoInformado: '85.85',
      itens: [
        _itemProduto('i1', 'dalila', 1, '21.69', '3'),
        _itemProduto('i2', 'dalila', 2, '1.59', '0.5'),
        _itemProduto('i3', 'dalila', 1, '2.44', '0.5'),
        _itemProduto('i4', 'dalila', 1, '6.45', '1'),
        _itemProduto('i5', 'dalila', 1, '15.60', '2'),
      ],
    );
    final r = calcularPedido(pedido, faixasTikTok());
    esperaValor(r.mercadoria, '49.36');
    esperaValor(r.custo, '51.26');
    esperaValor(r.liquido, '85.85');
    esperaValor(r.lucro, '34.59');
    esperaValor(r.abelinhasPedido, '7.5');
  });

  test('KT01-THAIS no TikTok (design.md §6.4)', () {
    // Itens: K2, GLOSS, CT1, LPV1, L1 → mercadoria 41,76; abelinhas 6.
    final pedido = _pedido(
      id: 'thais',
      plataformaId: 'tiktok',
      precoVenda: '110.00',
      embalagem: '0.90',
      impressao: '1.00',
      liquidoInformado: '97.40',
      itens: [
        _itemProduto('i1', 'thais', 1, '21.69', '3'),
        _itemProduto('i2', 'thais', 1, '7.35', '1'),
        _itemProduto('i3', 'thais', 1, '6.45', '1'),
        _itemProduto('i4', 'thais', 1, '4.68', '0.5'),
        _itemProduto('i5', 'thais', 1, '1.59', '0.5'),
      ],
    );
    final r = calcularPedido(pedido, faixasTikTok());
    esperaValor(r.mercadoria, '41.76');
    esperaValor(r.custo, '43.66');
    esperaValor(r.liquido, '97.40');
    esperaValor(r.lucro, '53.74');
    esperaValor(r.abelinhasPedido, '6');
  });

  test('Kit Batom no Mercado Livre, sem informado (design.md §6.4)', () {
    // Só o kit (snapshot = investimento 13,28; abelinhas 1,5); emb/imp 0.
    final pedido = Pedido(
      id: 'kitml',
      empresaId: _empresa,
      data: DateTime(2026, 10, 12),
      cliente: 'kitml',
      plataformaId: 'ml',
      embalagem: Decimal.zero,
      impressao: Decimal.zero,
      outros: Decimal.zero,
      precoVenda: Decimal.parse('31.90'),
      itens: [
        PedidoItem(
          id: 'i1',
          empresaId: _empresa,
          pedidoId: 'kitml',
          tipo: TipoPedidoItem.produtoVenda,
          produtoVendaId: 'batom',
          quantidade: 1,
          custoUnitario: Decimal.parse('13.28'),
          abelinhasUnitarias: Decimal.parse('1.5'),
        ),
      ],
    );
    final r = calcularPedido(pedido, faixasMercadoLivre());
    esperaValor(r.custo, '13.28');
    esperaValor(r.taxaEstimada, '10.72');
    esperaValor(r.liquido, '21.18');
    esperaValor(r.lucro, '7.90');
    esperaValor(r.abelinhasPedido, '1.5');
  });
}
