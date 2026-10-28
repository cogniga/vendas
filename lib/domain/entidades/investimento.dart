import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales/domain/entidades/conversores.dart';

part 'investimento.freezed.dart';
part 'investimento.g.dart';

/// Investimento (compra de mercadoria por distribuidor) — tabela
/// `investimentos`.
@freezed
class Investimento with _$Investimento {
  const factory Investimento({
    required String id,
    @JsonKey(name: 'empresa_id') required String empresaId,
    required DateTime data,
    required String distribuidor,
    @DecimalConverter() required Decimal valor,
    @Default('') String nota,
    @JsonKey(name: 'destino_id') String? destinoId,
    @Default('') String obs,
  }) = _Investimento;

  factory Investimento.fromJson(Map<String, dynamic> json) =>
      _$InvestimentoFromJson(json);
}
