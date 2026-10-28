import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales/domain/entidades/conversores.dart';

part 'destino.freezed.dart';
part 'destino.g.dart';

/// Destino de rateio do caixa — tabela `destinos`.
@freezed
class Destino with _$Destino {
  const factory Destino({
    required String id,
    @JsonKey(name: 'empresa_id') required String empresaId,
    required String nome,
    required String cor,
    @DecimalConverter() required Decimal percentual,
    @Default(0) int ordem,
  }) = _Destino;

  factory Destino.fromJson(Map<String, dynamic> json) =>
      _$DestinoFromJson(json);
}
