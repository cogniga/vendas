import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/domain/calculos/caixa.dart';
import 'package:sales/domain/calculos/decimais.dart';
import 'package:sales/domain/calculos/painel.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/features/caixa/application/caixa_providers.dart';
import 'package:sales/features/pedidos/application/pedidos_providers.dart';

/// Período selecionado no painel (padrão: todo o período, como o protótipo).
final periodoPainelProvider =
    StateProvider<PeriodoPainel>((ref) => PeriodoPainel.tudo);

/// Venda de uma plataforma já com nome, cor e proporção da barra.
class VendaPlataformaPainel {
  const VendaPlataformaPainel({
    required this.nome,
    required this.cor,
    required this.bruto,
    required this.liquido,
    required this.fracao,
  });

  final String nome;
  final String? cor;
  final Decimal bruto;
  final Decimal liquido;

  /// `bruto / maior bruto`, de 0 a 1.
  final double fracao;
}

/// Destino com seu saldo atual.
class DestinoComSaldo {
  const DestinoComSaldo(this.destino, this.saldo);

  final Destino destino;
  final Decimal saldo;
}

/// Dados que não dependem do período (carregados do banco).
class DadosBrutosPainel {
  const DadosBrutosPainel({
    required this.pedidos,
    required this.faixasPorPlataforma,
    required this.nomesPlataformas,
    required this.coresPlataformas,
    required this.nomesProdutos,
    required this.nomesKits,
    required this.pontos,
    required this.destinosComSaldo,
    required this.totalSacado,
  });

  final List<Pedido> pedidos;
  final Map<String, List<FaixaTaxa>> faixasPorPlataforma;
  final Map<String, String> nomesPlataformas;
  final Map<String, String> coresPlataformas;
  final Map<String, String> nomesProdutos;
  final Map<String, String> nomesKits;
  final List<PontoAtencao> pontos;
  final List<DestinoComSaldo> destinosComSaldo;
  final Decimal totalSacado;
}

/// Tudo que a tela do painel exibe, já calculado para o período.
class DadosPainel {
  const DadosPainel({
    required this.kpis,
    required this.qtdPedidos,
    required this.vendas,
    required this.pontos,
    required this.destinosComSaldo,
    required this.totalSacado,
    required this.topItens,
  });

  final KpisPainel kpis;
  final int qtdPedidos;
  final List<VendaPlataformaPainel> vendas;
  final List<PontoAtencao> pontos;
  final List<DestinoComSaldo> destinosComSaldo;
  final Decimal totalSacado;
  final List<ItemVendido> topItens;
}

/// Carrega e agrega os dados do painel que independem do período.
final dadosBrutosPainelProvider =
    FutureProvider<DadosBrutosPainel>((ref) async {
  final pedidos = await ref.watch(pedidosProvider.future);
  final plataformas = await ref.watch(plataformasComFaixasProvider.future);
  final produtos = await ref.watch(produtosProvider.future);
  final kits = await ref.watch(kitsProvider.future);
  final faixasAbelinha = await ref.watch(faixasAbelinhaProvider.future);
  final caixa = await ref.watch(dadosCaixaProvider.future);

  final faixasPorPlataforma = {
    for (final e in plataformas.entries) e.key.id: e.value,
  };
  final produtosPorId = {for (final p in produtos) p.id: p};
  final pontos = pontosAtencao(
    destinos: caixa.destinos,
    produtos: produtos,
    kits: kits,
    produtosPorId: produtosPorId,
    plataformas: plataformas.keys.toList(),
    faixasPorPlataforma: faixasPorPlataforma,
    faixasAbelinha: faixasAbelinha,
  );
  final destinos = [
    for (final d in caixa.destinos)
      DestinoComSaldo(
        d,
        saldoDestino(
          d.id,
          saques: caixa.saques,
          investimentos: caixa.investimentos,
          comprasInsumo: caixa.comprasInsumo,
          retiradas: caixa.retiradas,
        ).saldo,
      ),
  ];
  var sacado = zero;
  for (final s in caixa.saques) {
    sacado += s.valor;
  }
  return DadosBrutosPainel(
    pedidos: pedidos,
    faixasPorPlataforma: faixasPorPlataforma,
    nomesPlataformas: {for (final p in plataformas.keys) p.id: p.nome},
    coresPlataformas: {for (final p in plataformas.keys) p.id: p.cor},
    nomesProdutos: {for (final p in produtos) p.id: p.nome},
    nomesKits: {for (final k in kits) k.id: k.nome},
    pontos: pontos,
    destinosComSaldo: destinos,
    totalSacado: sacado,
  );
});

/// Dados do painel para o período atual. Nulo enquanto nunca carregou;
/// durante recarga mantém o valor anterior (sem piscar spinner).
final dadosPainelProvider = Provider<DadosPainel?>((ref) {
  final brutos = ref.watch(dadosBrutosPainelProvider).valueOrNull;
  if (brutos == null) return null;
  final periodo = ref.watch(periodoPainelProvider);
  final pedidos = filtrarPedidosPeriodo(
    brutos.pedidos,
    periodo,
    DateTime.now(),
  );
  final vendasBrutas =
      vendasPorPlataforma(pedidos, brutos.faixasPorPlataforma);
  var maior = Decimal.one;
  for (final v in vendasBrutas) {
    if (v.bruto > maior) maior = v.bruto;
  }
  return DadosPainel(
    kpis: kpisPainel(pedidos, brutos.faixasPorPlataforma),
    qtdPedidos: pedidos.length,
    vendas: [
      for (final v in vendasBrutas)
        VendaPlataformaPainel(
          nome: brutos.nomesPlataformas[v.plataformaId] ?? v.plataformaId,
          cor: brutos.coresPlataformas[v.plataformaId],
          bruto: v.bruto,
          liquido: v.liquido,
          fracao: v.bruto.dividir(maior).toDouble().clamp(0.0, 1.0),
        ),
    ],
    pontos: brutos.pontos,
    destinosComSaldo: brutos.destinosComSaldo,
    totalSacado: brutos.totalSacado,
    topItens: itensMaisVendidos(
      pedidos,
      nomesProdutos: brutos.nomesProdutos,
      nomesKits: brutos.nomesKits,
    ),
  );
});
