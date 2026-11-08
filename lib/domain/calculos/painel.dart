import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/domain/calculos/decimais.dart';
import 'package:sales/domain/calculos/pedido.dart';
import 'package:sales/domain/calculos/produto_venda.dart';
import 'package:sales/domain/calculos/taxas.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/domain/entidades/produto_venda.dart';

part 'painel.freezed.dart';

/// KPIs do painel, sobre pedidos `concluido` no período (design.md §6.5).
@freezed
class KpisPainel with _$KpisPainel {
  const factory KpisPainel({
    /// `Σ precoVenda`.
    required Decimal faturamento,

    /// `Σ taxaEfetiva`.
    required Decimal taxas,

    /// `Σ liquido`.
    required Decimal liquido,

    /// `Σ custo`.
    required Decimal custo,

    /// `Σ lucro`.
    required Decimal lucro,

    /// `lucro / faturamento`, em fração.
    required Decimal margem,
  }) = _KpisPainel;
}

/// Calcula os KPIs do painel para os [pedidos] `concluido` (design.md §6.5).
/// [faixasPorPlataforma] mapeia `plataformaId` → faixas de taxa.
KpisPainel kpisPainel(
  List<Pedido> pedidos,
  Map<String, List<FaixaTaxa>> faixasPorPlataforma,
) {
  var faturamento = zero;
  var taxas = zero;
  var liquido = zero;
  var custo = zero;
  var lucro = zero;
  for (final pedido in pedidos) {
    if (pedido.situacao != SituacaoPedido.concluido) continue;
    final faixas = faixasPorPlataforma[pedido.plataformaId] ?? const [];
    final r = calcularPedido(pedido, faixas);
    faturamento += pedido.precoVenda;
    taxas += r.taxaEfetiva;
    liquido += r.liquido;
    custo += r.custo;
    lucro += r.lucro;
  }
  final margem = faturamento == zero ? zero : lucro.dividir(faturamento);
  return KpisPainel(
    faturamento: faturamento,
    taxas: taxas,
    liquido: liquido,
    custo: custo,
    lucro: lucro,
    margem: margem,
  );
}

/// Período considerado no painel.
enum PeriodoPainel { mes, tudo }

/// Pedidos `concluido` dentro do [periodo] (mês de [hoje] ou todo o período).
List<Pedido> filtrarPedidosPeriodo(
  List<Pedido> pedidos,
  PeriodoPainel periodo,
  DateTime hoje,
) {
  return pedidos.where((p) {
    if (p.situacao != SituacaoPedido.concluido) return false;
    if (periodo == PeriodoPainel.tudo) return true;
    return p.data.year == hoje.year && p.data.month == hoje.month;
  }).toList();
}

/// Venda agregada de uma plataforma.
class VendaPlataforma {
  const VendaPlataforma({
    required this.plataformaId,
    required this.bruto,
    required this.liquido,
    required this.pedidos,
  });

  final String plataformaId;
  final Decimal bruto;
  final Decimal liquido;
  final int pedidos;
}

/// Agrupa [pedidos] por plataforma, na ordem em que aparecem.
List<VendaPlataforma> vendasPorPlataforma(
  List<Pedido> pedidos,
  Map<String, List<FaixaTaxa>> faixasPorPlataforma,
) {
  final bruto = <String, Decimal>{};
  final liquido = <String, Decimal>{};
  final qtd = <String, int>{};
  for (final pedido in pedidos) {
    final faixas = faixasPorPlataforma[pedido.plataformaId] ?? const [];
    final r = calcularPedido(pedido, faixas);
    final id = pedido.plataformaId;
    bruto[id] = (bruto[id] ?? zero) + pedido.precoVenda;
    liquido[id] = (liquido[id] ?? zero) + r.liquido;
    qtd[id] = (qtd[id] ?? 0) + 1;
  }
  return [
    for (final id in bruto.keys)
      VendaPlataforma(
        plataformaId: id,
        bruto: bruto[id]!,
        liquido: liquido[id]!,
        pedidos: qtd[id]!,
      ),
  ];
}

/// Item mais vendido (nome resolvido e unidades).
class ItemVendido {
  const ItemVendido({required this.nome, required this.quantidade});

  final String nome;
  final int quantidade;
}

/// Itens mais vendidos: soma `quantidade` das linhas (sem multiplicar kits),
/// ordenados por unidades desc; empate mantém a ordem de inserção.
List<ItemVendido> itensMaisVendidos(
  List<Pedido> pedidos, {
  Map<String, String> nomesProdutos = const {},
  Map<String, String> nomesKits = const {},
  int limite = 6,
}) {
  final nomes = <String, String>{};
  final qtds = <String, int>{};
  for (final pedido in pedidos) {
    for (final item in pedido.itens) {
      final ehKit = item.tipo == TipoPedidoItem.produtoVenda;
      final ref = (ehKit ? item.produtoVendaId : item.produtoId) ?? '';
      final chave = '${item.tipo.name}$ref';
      nomes.putIfAbsent(
        chave,
        () => ehKit
            ? (nomesKits[ref] ?? '(kit removido)')
            : (nomesProdutos[ref] ?? '(produto removido)'),
      );
      qtds[chave] = (qtds[chave] ?? 0) + item.quantidade;
    }
  }
  final chaves = qtds.keys.toList();
  final ordem = {for (var i = 0; i < chaves.length; i++) chaves[i]: i};
  chaves.sort((a, b) {
    final c = qtds[b]!.compareTo(qtds[a]!);
    return c != 0 ? c : ordem[a]!.compareTo(ordem[b]!);
  });
  return [
    for (final c in chaves.take(limite))
      ItemVendido(nome: nomes[c]!, quantidade: qtds[c]!),
  ];
}

/// Gravidade de um ponto de atenção.
enum GravidadeAtencao { ruim, atencao }

/// Ponto de atenção do painel (design.md §6.9).
@freezed
class PontoAtencao with _$PontoAtencao {
  const factory PontoAtencao({
    /// Tipo: `destinos`, `kitPrejuizo`, `kitMargemBaixa`, `codigoRepetido`.
    required String tipo,

    /// Mensagem descritiva.
    required String mensagem,

    /// Gravidade (define a cor do aviso).
    required GravidadeAtencao gravidade,
  }) = _PontoAtencao;
}

/// Pontos de atenção do painel, com os textos do protótipo.
///
/// O alerta de estoque baixo é omitido: o produto não tem estoque mínimo.
List<PontoAtencao> pontosAtencao({
  required List<Destino> destinos,
  required List<Produto> produtos,
  required List<ProdutoVenda> kits,
  required Map<String, Produto> produtosPorId,
  required List<Plataforma> plataformas,
  required Map<String, List<FaixaTaxa>> faixasPorPlataforma,
  required List<FaixaAbelinha> faixasAbelinha,
}) {
  final pontos = <PontoAtencao>[];
  final margemMinima = Decimal.parse('0.15');
  final somaDestinos = destinos.fold<Decimal>(
    zero,
    (soma, d) => soma + d.percentual,
  );
  if ((somaDestinos - cem).abs() > Decimal.parse('0.01')) {
    final texto = somaDestinos.toString().replaceAll('.', ',');
    pontos.add(
      PontoAtencao(
        tipo: 'destinos',
        mensagem: 'Os destinos do caixa somam $texto%. '
            'Ajuste para 100% em Caixa e saques.',
        gravidade: GravidadeAtencao.ruim,
      ),
    );
  }
  for (final kit in kits) {
    final prejuizo = <String>[];
    final margemBaixa = <String>[];
    for (final plataforma in plataformas) {
      final faixas = faixasPorPlataforma[plataforma.id] ?? const [];
      final r = calcularKit(
        kit,
        produtosPorId,
        plataforma,
        faixas,
        faixasAbelinha,
      );
      if (r.lucro < zero) {
        final minimo = precoMinimo(faixas, r.investimento);
        prejuizo.add(
          '${plataforma.nome} (mín. ${Formatos.moedaDecimal(minimo)})',
        );
      } else if (r.margem < margemMinima) {
        margemBaixa.add(
          '${plataforma.nome} '
          '(${Formatos.percentualFracao(r.margem.toDouble())})',
        );
      }
    }
    if (prejuizo.isNotEmpty) {
      pontos.add(
        PontoAtencao(
          tipo: 'kitPrejuizo',
          mensagem: '\u201c${kit.nome}\u201d dá prejuízo em '
              '${prejuizo.join(', ')}.',
          gravidade: GravidadeAtencao.ruim,
        ),
      );
    }
    if (margemBaixa.isNotEmpty) {
      pontos.add(
        PontoAtencao(
          tipo: 'kitMargemBaixa',
          mensagem: '\u201c${kit.nome}\u201d tem margem baixa em '
              '${margemBaixa.join(', ')}.',
          gravidade: GravidadeAtencao.atencao,
        ),
      );
    }
  }
  final contagem = <String, int>{};
  for (final p in produtos) {
    contagem[p.codigo] = (contagem[p.codigo] ?? 0) + 1;
  }
  final repetidos = contagem.entries
      .where((e) => e.value > 1)
      .map((e) => e.key)
      .toList();
  if (repetidos.isNotEmpty) {
    pontos.add(
      PontoAtencao(
        tipo: 'codigoRepetido',
        mensagem: 'Códigos repetidos no cadastro: ${repetidos.join(', ')}. '
            'Cada código deve ser único.',
        gravidade: GravidadeAtencao.atencao,
      ),
    );
  }
  return pontos;
}
