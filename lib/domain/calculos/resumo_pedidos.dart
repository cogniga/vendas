import 'package:decimal/decimal.dart';
import 'package:sales/domain/calculos/painel.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/pedido.dart';

/// Período da tela de Pedidos.
enum PeriodoPedidos {
  /// Mês de hoje (padrão).
  mes,

  /// Todos os pedidos.
  tudo,

  /// Intervalo escolhido pelo usuário (de/até, inclusive).
  intervalo,
}

/// Pedidos (de qualquer situação) dentro do [periodo].
///
/// - [PeriodoPedidos.mes]: mesmo ano/mês de [hoje].
/// - [PeriodoPedidos.intervalo]: `de <= data <= ate` (só o dia conta; limite
///   nulo = sem limite naquele lado).
List<Pedido> filtrarPedidosPorPeriodo(
  List<Pedido> pedidos,
  PeriodoPedidos periodo,
  DateTime hoje, {
  DateTime? de,
  DateTime? ate,
}) {
  DateTime dia(DateTime d) => DateTime(d.year, d.month, d.day);
  return pedidos.where((p) {
    switch (periodo) {
      case PeriodoPedidos.tudo:
        return true;
      case PeriodoPedidos.mes:
        return p.data.year == hoje.year && p.data.month == hoje.month;
      case PeriodoPedidos.intervalo:
        final d = dia(p.data);
        if (de != null && d.isBefore(dia(de))) return false;
        if (ate != null && d.isAfter(dia(ate))) return false;
        return true;
    }
  }).toList();
}

/// Resumo dos cards da tela de Pedidos.
class ResumoPedidos {
  const ResumoPedidos({
    required this.quantidade,
    required this.quantidadeLancados,
    required this.liquido,
    required this.custo,
    required this.lucro,
    required this.margem,
  });

  /// Pedidos que contam no resultado (situação `concluido`, como no Painel).
  final int quantidade;

  /// Todos os pedidos listados (inclui cancelados/devolvidos).
  final int quantidadeLancados;

  /// Σ líquido (informado pela plataforma ou estimado).
  final Decimal liquido;

  /// Σ custo (mercadoria + embalagem + impressão + outros).
  final Decimal custo;

  /// Σ lucro.
  final Decimal lucro;

  /// lucro / faturamento (fração); 0 sem faturamento.
  final Decimal margem;
}

/// Resume [pedidos] (já filtrados) com as mesmas regras dos KPIs do Painel
/// (design.md §6.5): só pedidos `concluido` entram nos valores.
ResumoPedidos resumirPedidos(
  List<Pedido> pedidos,
  Map<String, List<FaixaTaxa>> faixasPorPlataforma,
) {
  final k = kpisPainel(pedidos, faixasPorPlataforma);
  return ResumoPedidos(
    quantidade:
        pedidos.where((p) => p.situacao == SituacaoPedido.concluido).length,
    quantidadeLancados: pedidos.length,
    liquido: k.liquido,
    custo: k.custo,
    lucro: k.lucro,
    margem: k.margem,
  );
}
