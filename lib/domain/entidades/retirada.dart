import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales/domain/entidades/conversores.dart';

part 'retirada.freezed.dart';
part 'retirada.g.dart';

/// Retirada de um destino do caixa — tabela `retiradas`.
@freezed
class Retirada with _$Retirada {
  const factory Retirada({
    required String id,
    @JsonKey(name: 'empresa_id') required String empresaId,
    required DateTime data,
    @JsonKey(name: 'destino_id') required String destinoId,
    @DecimalConverter() required Decimal valor,
    @Default('') String descricao,
  }) = _Retirada;

  factory Retirada.fromJson(Map<String, dynamic> json) =>
      _$RetiradaFromJson(json);
}
