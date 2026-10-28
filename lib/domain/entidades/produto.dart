import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales/domain/entidades/conversores.dart';

part 'produto.freezed.dart';
part 'produto.g.dart';

/// Produto comprado para revenda — tabela `produtos`.
///
/// `abelinhasManual` nulo significa calcular pela regra de faixas.
@freezed
class Produto with _$Produto {
  const factory Produto({
    required String id,
    @JsonKey(name: 'empresa_id') required String empresaId,
    required String codigo,
    required String nome,
    @DecimalConverter() required Decimal custo,
    @Default('') String marca,
    @Default('Cosméticos') String categoria,
    @Default('') String fornecedor,
    @Default('un') String unidade,
    @Default(0) int estoque,
    @Default('') String ean,
    @Default(true) bool ativo,
    @Default('') String obs,
    @JsonKey(name: 'abelinhas_manual')
    @DecimalNullableConverter()
    Decimal? abelinhasManual,
  }) = _Produto;

  factory Produto.fromJson(Map<String, dynamic> json) =>
      _$ProdutoFromJson(json);
}
