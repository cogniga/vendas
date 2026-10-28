import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales/domain/entidades/conversores.dart';

part 'compra_insumo.freezed.dart';
part 'compra_insumo.g.dart';

/// Compra de insumos (caixas, etiquetas, papel…) — tabela `compras_insumo`.
@freezed
class CompraInsumo with _$CompraInsumo {
  const factory CompraInsumo({
    required String id,
    @JsonKey(name: 'empresa_id') required String empresaId,
    required DateTime data,
    required String produto,
    @JsonKey(name: 'valor_total')
    @DecimalConverter()
    required Decimal valorTotal,
    @Default('Embalagem') String tipo,
    @Default('') String descricao,
    @Default(1) int pacotes,
    @Default(1) int itens,
    @JsonKey(name: 'destino_id') String? destinoId,
  }) = _CompraInsumo;

  factory CompraInsumo.fromJson(Map<String, dynamic> json) =>
      _$CompraInsumoFromJson(json);
}
