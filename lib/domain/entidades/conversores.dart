import 'package:decimal/decimal.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converte valores monetários/percentuais/abelinhas entre JSON e [Decimal].
///
/// O PostgREST serializa colunas `numeric` ora como `String` (`"12.50"`), ora
/// como número (`12.5`/`0`). [fromJson] aceita ambos; [toJson] grava uma
/// `String` (via [Decimal.toString]) para preservar a precisão sem passar por
/// `double`.
class DecimalConverter implements JsonConverter<Decimal, Object> {
  const DecimalConverter();

  @override
  Decimal fromJson(Object json) {
    if (json is Decimal) return json;
    if (json is String) return Decimal.parse(json);
    if (json is int) return Decimal.fromInt(json);
    if (json is num) return Decimal.parse(json.toString());
    throw ArgumentError.value(json, 'json', 'Valor numérico inválido');
  }

  @override
  Object toJson(Decimal object) => object.toString();
}

/// Versão anulável de [DecimalConverter]; preserva `null` nos dois sentidos.
class DecimalNullableConverter
    implements JsonConverter<Decimal?, Object?> {
  const DecimalNullableConverter();

  @override
  Decimal? fromJson(Object? json) {
    if (json == null) return null;
    return const DecimalConverter().fromJson(json);
  }

  @override
  Object? toJson(Decimal? object) {
    if (object == null) return null;
    return const DecimalConverter().toJson(object);
  }
}
