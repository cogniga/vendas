import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales/domain/calculos/abelinhas.dart';
import 'package:sales/domain/calculos/decimais.dart';
import 'package:sales/domain/calculos/taxas.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/domain/entidades/produto_venda.dart';

part 'produto_venda.freezed.dart';

/// Resultado do cálculo de um produto de venda (kit) em uma plataforma
/// (design.md §6.3).
@freezed
class ResultadoKit with _$ResultadoKit {
  const factory ResultadoKit({
    /// Soma `produto.custo * qtd` dos itens.
    required Decimal compra,

    /// `compra + embalagem + impressao + outros`.
    required Decimal investimento,

    /// `M` — o que o cliente paga: `preco - desconto - cupom`.
    required Decimal clientePaga,

    /// Taxa da plataforma sobre `M`.
    required Decimal taxa,

    /// `M - taxa`.
    required Decimal liquido,

    /// `liquido - investimento`.
    required Decimal lucro,

    /// `lucro / liquido`, em fração.
    required Decimal margem,

    /// `lucro / investimento`, em fração.
    required Decimal roi,

    /// Faturamento da meta: `preco * metaQtd` (null se lucro <= 0).
    required Decimal metaFaturamento,

    /// Progresso: `vendidos / metaQtd`, em fração.
    required Decimal atingido,

    /// Custo de anúncio-alvo: `lucro * fatiaRoas`.
    required Decimal custoAnuncio,

    /// `Σ abelinhas(produto) * qtd`.
    required Decimal abelinhasKit,

    /// Unidades para bater a meta de lucro (null se lucro <= 0).
    int? metaQtd,

    /// ROAS-alvo: `M / (lucro * fatia)` (null se lucro <= 0 ou fatia <= 0).
    Decimal? roasAlvo,

    /// Unidades vendidas na plataforma (iniciais + pedidos válidos).
    @Default(0) int vendidos,
  }) = _ResultadoKit;
}

/// Calcula um produto de venda em uma plataforma (design.md §6.3).
///
/// [produtosPorId] mapeia `produtoId` → [Produto] para custo e abelinhas.
/// [faixasTaxa] são as faixas da [plataforma]; [faixasAbelinha] a regra de
/// abelinhas. `preco/desconto/cupom` usam o override da plataforma quando
/// preenchidos, senão os valores base do kit. [vendidosIniciais] e [pedidos]
/// alimentam o progresso da meta.
ResultadoKit calcularKit(
  ProdutoVenda kit,
  Map<String, Produto> produtosPorId,
  Plataforma plataforma,
  List<FaixaTaxa> faixasTaxa,
  List<FaixaAbelinha> faixasAbelinha, {
  int vendidosIniciais = 0,
  List<Pedido> pedidos = const [],
}) {
  var compra = zero;
  var abelinhasKit = zero;
  for (final item in kit.itens) {
    final produto = produtosPorId[item.produtoId];
    if (produto == null) continue;
    final qtd = Decimal.fromInt(item.quantidade);
    compra += produto.custo * qtd;
    abelinhasKit += abelinhasProduto(produto, faixasAbelinha) * qtd;
  }
  final investimento =
      compra + kit.embalagem + kit.impressao + kit.outros;

  final override = kit.precosPorPlataforma[plataforma.id];
  final preco = override?.preco ?? kit.preco;
  final desconto = override?.desconto ?? kit.desconto;
  final cupom = override?.cupom ?? kit.cupom;

  final clientePaga = preco - desconto - cupom;
  final taxaKit = taxa(faixasTaxa, clientePaga);
  final liquido = clientePaga - taxaKit;
  final lucro = liquido - investimento;
  final margem = liquido == zero ? zero : lucro.dividir(liquido);
  final roi = investimento == zero ? zero : lucro.dividir(investimento);

  final fatia = kit.fatiaRoas;
  final temLucro = lucro > zero;

  int? metaQtd;
  var metaFaturamento = zero;
  if (temLucro) {
    // Usa o lucro exibido (2 casas), como na planilha de origem.
    final lucroExibido = lucro.arred2();
    metaQtd = kit.metaLucro.dividir(lucroExibido).ceil().toBigInt().toInt();
    metaFaturamento = preco * Decimal.fromInt(metaQtd);
  }

  final vendidosPlataforma =
      vendidosIniciais + _vendidosEmPedidos(kit, plataforma, pedidos);
  final atingido = (metaQtd == null || metaQtd == 0)
      ? zero
      : Decimal.fromInt(vendidosPlataforma)
            .dividir(Decimal.fromInt(metaQtd));

  Decimal? roasAlvo;
  if (temLucro && fatia > zero) {
    roasAlvo = clientePaga.dividir(lucro * fatia);
  }
  final custoAnuncio = lucro * fatia;

  return ResultadoKit(
    compra: compra,
    investimento: investimento,
    clientePaga: clientePaga,
    taxa: taxaKit,
    liquido: liquido,
    lucro: lucro,
    margem: margem,
    roi: roi,
    metaQtd: metaQtd,
    metaFaturamento: metaFaturamento,
    atingido: atingido,
    roasAlvo: roasAlvo,
    custoAnuncio: custoAnuncio,
    vendidos: vendidosPlataforma,
    abelinhasKit: abelinhasKit,
  );
}

/// Soma a quantidade do [kit] vendida na [plataforma] em pedidos não
/// cancelados/devolvidos.
int _vendidosEmPedidos(
  ProdutoVenda kit,
  Plataforma plataforma,
  List<Pedido> pedidos,
) {
  var total = 0;
  for (final pedido in pedidos) {
    if (pedido.plataformaId != plataforma.id) continue;
    if (pedido.situacao != SituacaoPedido.concluido) continue;
    for (final item in pedido.itens) {
      if (item.tipo == TipoPedidoItem.produtoVenda &&
          item.produtoVendaId == kit.id) {
        total += item.quantidade;
      }
    }
  }
  return total;
}
