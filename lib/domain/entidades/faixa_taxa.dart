import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales/domain/entidades/conversores.dart';

part 'faixa_taxa.freezed.dart';
part 'faixa_taxa.g.dart';

/// Faixa de taxa de uma plataforma — tabela `faixas_taxa`.
///
/// `precoAte` nulo significa faixa sem limite superior.
@freezed
class FaixaTaxa with _$FaixaTaxa {
  const factory FaixaTaxa({
    required String id,
    @JsonKey(name: 'empresa_id') required String empresaId,
    @JsonKey(name: 'plataforma_id') required String plataformaId,
    @JsonKey(name: 'taxa_fixa')
    @DecimalConverter()
    required Decimal taxaFixa,
    @JsonKey(name: 'taxa_percentual')
    @DecimalConverter()
    required Decimal taxaPercentual,
    @JsonKey(name: 'preco_ate')
    @DecimalNullableConverter()
    Decimal? precoAte,

    /// Outras taxas em % (ex.: frete do TikTok), somadas a [taxaPercentual].
    /// Nulo/0 = não cobra (coluna `taxa_outras`, migration 0005).
    @JsonKey(name: 'taxa_outras')
    @DecimalNullableConverter()
    Decimal? taxaOutras,
  }) = _FaixaTaxa;

  factory FaixaTaxa.fromJson(Map<String, dynamic> json) =>
      _$FaixaTaxaFromJson(json);
}
