import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales/domain/entidades/conversores.dart';

part 'saque_rateio.freezed.dart';
part 'saque_rateio.g.dart';

/// Rateio de um saque entre destinos (snapshot) — tabela `saques_rateio`.
@freezed
class SaqueRateio with _$SaqueRateio {
  const factory SaqueRateio({
    @JsonKey(name: 'saque_id') required String saqueId,
    @JsonKey(name: 'empresa_id') required String empresaId,
    @JsonKey(name: 'destino_id') required String destinoId,
    @DecimalConverter() required Decimal percentual,
    @DecimalConverter() required Decimal valor,
  }) = _SaqueRateio;

  factory SaqueRateio.fromJson(Map<String, dynamic> json) =>
      _$SaqueRateioFromJson(json);
}
