import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales/domain/calculos/decimais.dart';
import 'package:sales/domain/calculos/produto_venda.dart';
import 'package:sales/domain/calculos/taxas.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/domain/entidades/produto_venda.dart';

part 'pedido.freezed.dart';

/// Resultado do cálculo de um pedido (design.md §6.4).
@freezed
class ResultadoPedido with _$ResultadoPedido {
  const factory ResultadoPedido({
    /// `Σ custoUnitario * qtd` dos itens (snapshots).
    required Decimal mercadoria,

    /// `mercadoria + embalagem + impressao + outros`.
    required Decimal custo,

    /// Taxa estimada: `taxa(pl, precoVenda, itensTaxaFixa)`.
    required Decimal taxaEstimada,

    /// `precoVenda - taxaEstimada`.
    required Decimal liquidoEstimado,

    /// `liquidoInformado ?? liquidoEstimado`.
    required Decimal liquido,

    /// `precoVenda - liquido`.
    required Decimal taxaEfetiva,

    /// `liquido - custo`.
    required Decimal lucro,

    /// `lucro / precoVenda`, em fração.
    required Decimal margem,

    /// `Σ abelinhasUnitarias * qtd` dos itens.
    required Decimal abelinhasPedido,
  }) = _ResultadoPedido;
}

/// Calcula um pedido a partir dos snapshots gravados nos itens (design.md
/// §6.4). [faixasTaxa] são as faixas da plataforma do pedido.
ResultadoPedido calcularPedido(Pedido pedido, List<FaixaTaxa> faixasTaxa) {
  var mercadoria = zero;
  var abelinhasPedido = zero;
  for (final item in pedido.itens) {
    final qtd = Decimal.fromInt(item.quantidade);
    mercadoria += item.custoUnitario * qtd;
    abelinhasPedido += item.abelinhasUnitarias * qtd;
  }
  final custo =
      mercadoria + pedido.embalagem + pedido.impressao + pedido.outros;
  final taxaEstimada = taxa(
    faixasTaxa,
    pedido.precoVenda,
    itensTaxaFixa: pedido.itensTaxaFixa,
  );
  final liquidoEstimado = pedido.precoVenda - taxaEstimada;
  final liquido = pedido.liquidoInformado ?? liquidoEstimado;
  final taxaEfetiva = pedido.precoVenda - liquido;
  final lucro = liquido - custo;
  final margem = pedido.precoVenda == zero
      ? zero
      : lucro.dividir(pedido.precoVenda);
  return ResultadoPedido(
    mercadoria: mercadoria,
    custo: custo,
    taxaEstimada: taxaEstimada,
    liquidoEstimado: liquidoEstimado,
    liquido: liquido,
    taxaEfetiva: taxaEfetiva,
    lucro: lucro,
    margem: margem,
    abelinhasPedido: abelinhasPedido,
  );
}

/// Preço automático de um pedido novo composto só por kits: soma de
/// `M(kit, plataforma) * qtd` (design.md §6.4). [kitsComQtd] associa cada kit
/// à sua quantidade.
Decimal precoAutomatico(
  Map<ProdutoVenda, int> kitsComQtd,
  Map<String, Produto> produtosPorId,
  Plataforma plataforma,
  List<FaixaTaxa> faixasTaxa,
  List<FaixaAbelinha> faixasAbelinha,
) {
  var total = zero;
  kitsComQtd.forEach((kit, qtd) {
    final resultado = calcularKit(
      kit,
      produtosPorId,
      plataforma,
      faixasTaxa,
      faixasAbelinha,
    );
    total += resultado.clientePaga * Decimal.fromInt(qtd);
  });
  return total;
}

/// `itensTaxaFixa` automático de um pedido novo só com kits: soma das
/// quantidades dos kits (design.md §6.4).
int itensTaxaFixaAutomatico(Map<ProdutoVenda, int> kitsComQtd) =>
    kitsComQtd.values.fold(0, (soma, qtd) => soma + qtd);
