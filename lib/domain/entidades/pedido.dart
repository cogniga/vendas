import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales/domain/entidades/conversores.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/pedido_item.dart';

part 'pedido.freezed.dart';
part 'pedido.g.dart';

/// Pedido de venda — tabela `pedidos`.
///
/// `itens` é carregado pelo repositório (não vem na linha da tabela).
@freezed
class Pedido with _$Pedido {
  const factory Pedido({
    required String id,
    @JsonKey(name: 'empresa_id') required String empresaId,
    required DateTime data,
    required String cliente,
    @JsonKey(name: 'plataforma_id') required String plataformaId,
    @DecimalConverter() required Decimal embalagem,
    @DecimalConverter() required Decimal impressao,
    @DecimalConverter() required Decimal outros,
    @JsonKey(name: 'preco_venda')
    @DecimalConverter()
    required Decimal precoVenda,
    @JsonKey(name: 'itens_taxa_fixa') @Default(1) int itensTaxaFixa,
    @JsonKey(name: 'liquido_informado')
    @DecimalNullableConverter()
    Decimal? liquidoInformado,
    @Default(SituacaoPedido.concluido) SituacaoPedido situacao,
    @Default('') String obs,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(<PedidoItem>[])
    List<PedidoItem> itens,
  }) = _Pedido;

  factory Pedido.fromJson(Map<String, dynamic> json) =>
      _$PedidoFromJson(json);
}
