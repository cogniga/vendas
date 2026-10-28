import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales/domain/entidades/conversores.dart';
import 'package:sales/domain/entidades/saque_rateio.dart';

part 'saque.freezed.dart';
part 'saque.g.dart';

/// Saque de uma plataforma — tabela `saques`.
///
/// `rateio` é carregado pelo repositório (não vem na linha da tabela).
@freezed
class Saque with _$Saque {
  const factory Saque({
    required String id,
    @JsonKey(name: 'empresa_id') required String empresaId,
    required DateTime data,
    @JsonKey(name: 'plataforma_id') required String plataformaId,
    @DecimalConverter() required Decimal valor,
    @Default('') String obs,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(<SaqueRateio>[])
    List<SaqueRateio> rateio,
  }) = _Saque;

  factory Saque.fromJson(Map<String, dynamic> json) => _$SaqueFromJson(json);
}
