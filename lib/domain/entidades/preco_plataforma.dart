import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales/domain/entidades/conversores.dart';

part 'preco_plataforma.freezed.dart';
part 'preco_plataforma.g.dart';

/// Preço de um produto de venda por plataforma — tabela
/// `produtos_venda_precos`.
///
/// `preco`/`desconto`/`cupom` nulos significam usar os valores base.
@freezed
class PrecoPlataforma with _$PrecoPlataforma {
  const factory PrecoPlataforma({
    @JsonKey(name: 'empresa_id') required String empresaId,
    @JsonKey(name: 'produto_venda_id') required String produtoVendaId,
    @JsonKey(name: 'plataforma_id') required String plataformaId,
    @DecimalNullableConverter() Decimal? preco,
    @DecimalNullableConverter() Decimal? desconto,
    @DecimalNullableConverter() Decimal? cupom,
    @JsonKey(name: 'vendidos_iniciais') @Default(0) int vendidosIniciais,
  }) = _PrecoPlataforma;

  factory PrecoPlataforma.fromJson(Map<String, dynamic> json) =>
      _$PrecoPlataformaFromJson(json);
}
