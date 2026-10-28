import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales/domain/calculos/painel.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/pedido_item.dart';

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
}
