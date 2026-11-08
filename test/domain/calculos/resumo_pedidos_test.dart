import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales/domain/calculos/resumo_pedidos.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/pedido_item.dart';

Pedido _pedido(
  String id,
  DateTime data, {
  SituacaoPedido situacao = SituacaoPedido.concluido,
  String liquido = '80',
  String custoItem = '30',
}) => Pedido(
  id: id,
  empresaId: 'e',
  data: data,
  cliente: id,
  plataformaId: 'p',
  embalagem: Decimal.zero,
  impressao: Decimal.zero,
  outros: Decimal.zero,
  precoVenda: Decimal.fromInt(100),
  liquidoInformado: Decimal.parse(liquido),
  situacao: situacao,
  itens: [
    PedidoItem(
      id: 'i$id',
      empresaId: 'e',
      pedidoId: id,
      tipo: TipoPedidoItem.produto,
      quantidade: 1,
      custoUnitario: Decimal.parse(custoItem),
      abelinhasUnitarias: Decimal.one,
    ),
  ],
);

void main() {
  final hoje = DateTime(2026, 11, 8);
  final pedidos = [
    _pedido('a', DateTime(2026, 11)),
    _pedido('b', DateTime(2026, 11, 8)),
    _pedido('c', DateTime(2026, 10, 31)),
    _pedido('d', DateTime(2026, 11, 5), situacao: SituacaoPedido.cancelado),
  ];

  group('filtrarPedidosPorPeriodo', () {
    test('mês atual', () {
      final r = filtrarPedidosPorPeriodo(pedidos, PeriodoPedidos.mes, hoje);
      expect(r.map((p) => p.id), ['a', 'b', 'd']);
    });

    test('todo o período', () {
      expect(
        filtrarPedidosPorPeriodo(pedidos, PeriodoPedidos.tudo, hoje).length,
        4,
      );
    });

    test('intervalo inclui os dois limites (só o dia conta)', () {
      final r = filtrarPedidosPorPeriodo(
        pedidos,
        PeriodoPedidos.intervalo,
        hoje,
        de: DateTime(2026, 10, 31, 15),
        ate: DateTime(2026, 11),
      );
      expect(r.map((p) => p.id), ['a', 'c']);
    });
  });

  test('resumo soma só concluídos e conta os lançados', () {
    final mes = filtrarPedidosPorPeriodo(pedidos, PeriodoPedidos.mes, hoje);
    final r = resumirPedidos(mes, const {});
    expect(r.quantidade, 2);
    expect(r.quantidadeLancados, 3);
    expect(r.liquido, Decimal.fromInt(160));
    expect(r.custo, Decimal.fromInt(60));
    expect(r.lucro, Decimal.fromInt(100));
  });

  test('lista vazia não quebra', () {
    final r = resumirPedidos(const [], const {});
    expect(r.quantidade, 0);
    expect(r.margem, Decimal.zero);
  });
}
