import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales/domain/entidades/conversores.dart';
import 'package:sales/domain/entidades/preco_plataforma.dart';
import 'package:sales/domain/entidades/produto_venda_item.dart';

part 'produto_venda.freezed.dart';
part 'produto_venda.g.dart';

/// Produto de venda (kit) — tabela `produtos_venda`.
///
/// `itens` e `precosPorPlataforma` são carregados pelo repositório (não vêm
/// na linha da tabela); `precosPorPlataforma` usa `plataformaId` como chave.
@freezed
class ProdutoVenda with _$ProdutoVenda {
  const factory ProdutoVenda({
    required String id,
    @JsonKey(name: 'empresa_id') required String empresaId,
    required String nome,
    @DecimalConverter() required Decimal embalagem,
    @DecimalConverter() required Decimal impressao,
    @DecimalConverter() required Decimal outros,
    @DecimalConverter() required Decimal preco,
    @DecimalConverter() required Decimal desconto,
    @DecimalConverter() required Decimal cupom,
    @JsonKey(name: 'meta_lucro')
    @DecimalConverter()
    required Decimal metaLucro,
    @JsonKey(name: 'fatia_roas')
    @DecimalConverter()
    required Decimal fatiaRoas,
    @JsonKey(name: 'margem_alvo')
    @DecimalConverter()
    required Decimal margemAlvo,
    @JsonKey(name: 'compra_insumo_id') String? compraInsumoId,
    @JsonKey(name: 'preco_concorrente')
    @DecimalNullableConverter()
    Decimal? precoConcorrente,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(<ProdutoVendaItem>[])
    List<ProdutoVendaItem> itens,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(<String, PrecoPlataforma>{})
    Map<String, PrecoPlataforma> precosPorPlataforma,
  }) = _ProdutoVenda;

  factory ProdutoVenda.fromJson(Map<String, dynamic> json) =>
      _$ProdutoVendaFromJson(json);
}
