import 'package:decimal/decimal.dart';
import 'package:sales/domain/calculos/decimais.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/domain/entidades/produto.dart';

/// Regra de abelinhas e suas análises (design.md §6.6 e §6.7).
///
/// Funções puras (dart + decimal + entidades). "Abelinhas" é a unidade de
/// valor interna; `v` é o valor em R$ de 1 abelinha.

/// Abelinhas pela regra de faixas: primeira faixa com `custo <= custoAte`;
/// senão a última (indicando que o custo está acima da tabela).
Decimal abelinhasRegra(Decimal custo, List<FaixaAbelinha> faixas) {
  final ordenadas = [...faixas]
    ..sort((a, b) => a.custoAte.compareTo(b.custoAte));
  for (final f in ordenadas) {
    if (custo <= f.custoAte) return f.abelinhas;
  }
  return ordenadas.last.abelinhas;
}

/// Indica se o [custo] está acima do teto da maior faixa.
bool acimaDaTabela(Decimal custo, List<FaixaAbelinha> faixas) {
  final maior = faixas
      .map((f) => f.custoAte)
      .reduce((a, b) => a > b ? a : b);
  return custo > maior;
}

/// Abelinhas do produto: o ajuste manual, se houver, senão a regra.
Decimal abelinhasProduto(Produto produto, List<FaixaAbelinha> faixas) =>
    produto.abelinhasManual ?? abelinhasRegra(produto.custo, faixas);

/// ROI de um produto: `(abelinhas * v - custo) / custo`.
Decimal roiProduto(Produto produto, Decimal v, List<FaixaAbelinha> faixas) {
  final ab = abelinhasProduto(produto, faixas);
  final venda = ab * v;
  return (venda - produto.custo).dividir(produto.custo);
}

/// Análise de uma faixa de abelinhas (design.md §6.6).
class AnaliseFaixa {
  const AnaliseFaixa({
    required this.custoAte,
    required this.abelinhas,
    required this.limiteInferior,
    required this.produtos,
    required this.venda,
    required this.roiMedio,
    required this.roiNoLimite,
    required this.abelinhaMinima,
    required this.situacao,
  });

  /// Teto de custo da faixa.
  final Decimal custoAte;

  /// Abelinhas atribuídas à faixa.
  final Decimal abelinhas;

  /// Limite inferior de custo (teto anterior + 0,01; 0 na primeira).
  final Decimal limiteInferior;

  /// Nº de produtos com custo no intervalo `(limiteInferior, custoAte]`.
  final int produtos;

  /// Venda gerada pelas abelinhas da faixa: `abelinhas * v`.
  final Decimal venda;

  /// ROI médio dos produtos do intervalo usando as abelinhas da faixa.
  final Decimal roiMedio;

  /// ROI no teto: `(venda - custoAte) / custoAte`.
  final Decimal roiNoLimite;

  /// Abelinha mínima para empatar no teto: `custoAte / abelinhas`.
  final Decimal abelinhaMinima;

  /// Situação textual (Lucro / Empata no teto / Prejuízo…).
  final String situacao;
}

/// Análise por faixa de custo (design.md §6.6). Para cada faixa calcula venda,
/// ROI médio dos produtos no intervalo, ROI no teto e situação.
List<AnaliseFaixa> analisePorFaixa(
  List<Produto> produtos,
  List<FaixaAbelinha> faixas,
  Decimal v,
) {
  final ordenadas = [...faixas]
    ..sort((a, b) => a.custoAte.compareTo(b.custoAte));
  final comCusto = produtos.where((p) => p.custo > zero).toList();
  final analises = <AnaliseFaixa>[];
  var limiteInferior = zero;
  final centavo = Decimal.parse('0.01');
  for (final f in ordenadas) {
    final teto = f.custoAte;
    final qtd = f.abelinhas;
    final noIntervalo = comCusto.where((p) {
      final acimaInferior = limiteInferior == zero || p.custo > limiteInferior;
      return acimaInferior && p.custo <= teto;
    }).toList();
    final venda = qtd * v;
    final rois = noIntervalo
        .map((p) => (qtd * v - p.custo).dividir(p.custo))
        .toList();
    final roiMedio = rois.isEmpty
        ? zero
        : rois.reduce((a, b) => a + b).dividir(
            Decimal.fromInt(rois.length),
          );
    final roiNoLimite = (venda - teto).dividir(teto);
    final abelinhaMinima = qtd > zero ? teto.dividir(qtd) : zero;
    final String situacao;
    if (venda > teto) {
      situacao = 'Lucro';
    } else if (venda == teto) {
      situacao = 'Empata no teto';
    } else if (venda > limiteInferior) {
      situacao = 'Prejuízo > R\$ ${venda.arred2()}';
    } else {
      situacao = 'Prejuízo';
    }
    analises.add(
      AnaliseFaixa(
        custoAte: teto,
        abelinhas: qtd,
        limiteInferior: limiteInferior,
        produtos: noIntervalo.length,
        venda: venda,
        roiMedio: roiMedio,
        roiNoLimite: roiNoLimite,
        abelinhaMinima: abelinhaMinima,
        situacao: situacao,
      ),
    );
    limiteInferior = teto + centavo;
  }
  return analises;
}

/// Análise geral das abelinhas (design.md §6.6), sobre produtos com custo > 0.
class AnaliseGeralAbelinhas {
  const AnaliseGeralAbelinhas({
    required this.roiMedioGeral,
    required this.comLucro,
    required this.comPrejuizo,
    required this.abelinhaMinimaSemPrejuizo,
  });

  /// Média dos ROIs de todos os produtos com custo > 0.
  final Decimal roiMedioGeral;

  /// Quantidade de produtos com ROI >= 0.
  final int comLucro;

  /// Quantidade de produtos com ROI < 0.
  final int comPrejuizo;

  /// Maior `custo / abelinhas` — valor de 1 abelinha para ninguém dar
  /// prejuízo.
  final Decimal abelinhaMinimaSemPrejuizo;
}

/// Calcula a análise geral (design.md §6.6).
AnaliseGeralAbelinhas analiseGeral(
  List<Produto> produtos,
  List<FaixaAbelinha> faixas,
  Decimal v,
) {
  final comCusto = produtos.where((p) => p.custo > zero).toList();
  final rois = comCusto.map((p) => roiProduto(p, v, faixas)).toList();
  final roiMedio = rois.isEmpty
      ? zero
      : rois.reduce((a, b) => a + b).dividir(Decimal.fromInt(rois.length));
  final comLucro = rois.where((r) => r >= zero).length;
  final comPrejuizo = rois.where((r) => r < zero).length;
  final necessarios = comCusto
      .map((p) => p.custo.dividir(abelinhasProduto(p, faixas)))
      .toList();
  final minima = necessarios.isEmpty
      ? zero
      : necessarios.reduce((a, b) => a > b ? a : b);
  return AnaliseGeralAbelinhas(
    roiMedioGeral: roiMedio,
    comLucro: comLucro,
    comPrejuizo: comPrejuizo,
    abelinhaMinimaSemPrejuizo: minima,
  );
}

/// Aviso de impacto do ajuste manual de abelinhas (design.md §6.7).
class AvisoAjusteManual {
  const AvisoAjusteManual({
    required this.regra,
    required this.manual,
    required this.diferenca,
    required this.diferencaPct,
    required this.lucroManual,
    required this.lucroRegra,
    required this.roiManual,
    required this.roiRegra,
    required this.vendaManual,
    required this.vendaRegra,
    required this.minimo,
    required this.cor,
  });

  /// Abelinhas pela regra (`R`).
  final Decimal regra;

  /// Abelinhas manuais (`O`).
  final Decimal manual;

  /// `O - R`.
  final Decimal diferenca;

  /// `(O - R) / R`, em fração (−0,5 = −50%).
  final Decimal diferencaPct;

  /// Lucro por unidade com as abelinhas manuais: `O*v - custo`.
  final Decimal lucroManual;

  /// Lucro por unidade pela regra: `R*v - custo`.
  final Decimal lucroRegra;

  /// ROI com as abelinhas manuais.
  final Decimal roiManual;

  /// ROI pela regra.
  final Decimal roiRegra;

  /// Venda por unidade manual: `O*v`.
  final Decimal vendaManual;

  /// Venda por unidade pela regra: `R*v`.
  final Decimal vendaRegra;

  /// Mínimo de abelinhas sem prejuízo: `ceil((custo/v) * 2) / 2`.
  final Decimal minimo;

  /// Severidade do aviso: `vermelho`, `amarelo` ou `verde`.
  final String cor;
}

/// Monta o aviso de impacto de um ajuste manual (design.md §6.7).
AvisoAjusteManual avisoAjusteManual({
  required Decimal regra,
  required Decimal manual,
  required Decimal custo,
  required Decimal v,
}) {
  final dif = manual - regra;
  final difPct = regra > zero ? dif.dividir(regra) : zero;
  final lucroManual = manual * v - custo;
  final lucroRegra = regra * v - custo;
  final roiManual = (manual * v - custo).dividir(custo);
  final roiRegra = (regra * v - custo).dividir(custo);
  final meioNegativo = Decimal.parse('-0.5');
  final String cor;
  if (lucroManual < zero || difPct <= meioNegativo) {
    cor = 'vermelho';
  } else if (dif < zero) {
    cor = 'amarelo';
  } else {
    cor = 'verde';
  }
  // minimo = ceil((custo / v) * 2) / 2
  final dobro = (custo.dividir(v) * Decimal.fromInt(2)).ceil();
  final minimo = dobro.dividir(Decimal.fromInt(2));
  return AvisoAjusteManual(
    regra: regra,
    manual: manual,
    diferenca: dif,
    diferencaPct: difPct,
    lucroManual: lucroManual,
    lucroRegra: lucroRegra,
    roiManual: roiManual,
    roiRegra: roiRegra,
    vendaManual: manual * v,
    vendaRegra: regra * v,
    minimo: minimo,
    cor: cor,
  );
}
