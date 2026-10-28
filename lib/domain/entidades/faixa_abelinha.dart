import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales/domain/entidades/conversores.dart';

part 'faixa_abelinha.freezed.dart';
part 'faixa_abelinha.g.dart';

/// Faixa custo → abelinhas (ordenar por `custoAte`) — tabela
/// `faixas_abelinha`.
@freezed
class FaixaAbelinha with _$FaixaAbelinha {
  const factory FaixaAbelinha({
    required String id,
    @JsonKey(name: 'empresa_id') required String empresaId,
    @JsonKey(name: 'custo_ate')
    @DecimalConverter()
    required Decimal custoAte,
    @DecimalConverter() required Decimal abelinhas,
  }) = _FaixaAbelinha;

  factory FaixaAbelinha.fromJson(Map<String, dynamic> json) =>
      _$FaixaAbelinhaFromJson(json);
}
