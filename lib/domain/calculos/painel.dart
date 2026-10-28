import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
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

/// Ponto de atenção do painel (design.md §6.9).
@freezed
class PontoAtencao with _$PontoAtencao {
  const factory PontoAtencao({
    /// Tipo: `destinos`, `kitPrejuizo`, `kitMargemBaixa`, `codigoRepetido`.
    required String tipo,

    /// Mensagem descritiva.
    required String mensagem,
  }) = _PontoAtencao;
}

/// Pontos de atenção do painel (design.md §6.9):
/// - soma dos destinos != 100%;
/// - kit com lucro < 0 em alguma plataforma (lista plataformas e mínimo);
/// - kit com margem < 15% em alguma plataforma;
/// - códigos de produto repetidos.
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
  if (somaDestinos != cem) {
    pontos.add(
      PontoAtencao(
        tipo: 'destinos',
        mensagem:
            'Soma dos destinos é ${somaDestinos.arred2()}%, não 100%.',
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
        prejuizo.add('${plataforma.nome} (mín. R\$ ${minimo.arred2()})');
      } else if (r.margem < margemMinima) {
        margemBaixa.add(plataforma.nome);
      }
    }
    if (prejuizo.isNotEmpty) {
      pontos.add(
        PontoAtencao(
          tipo: 'kitPrejuizo',
          mensagem:
              '${kit.nome} dá prejuízo em: ${prejuizo.join(', ')}.',
        ),
      );
    }
    if (margemBaixa.isNotEmpty) {
      pontos.add(
        PontoAtencao(
          tipo: 'kitMargemBaixa',
          mensagem:
              '${kit.nome} com margem < 15% em: '
              '${margemBaixa.join(', ')}.',
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
        mensagem: 'Códigos repetidos: ${repetidos.join(', ')}.',
      ),
    );
  }

  return pontos;
}
