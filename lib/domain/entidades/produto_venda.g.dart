// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produto_venda.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProdutoVendaImpl _$$ProdutoVendaImplFromJson(
  Map<String, dynamic> json,
) => _$ProdutoVendaImpl(
  id: json['id'] as String,
  empresaId: json['empresa_id'] as String,
  nome: json['nome'] as String,
  embalagem: const DecimalConverter().fromJson(json['embalagem'] as Object),
  impressao: const DecimalConverter().fromJson(json['impressao'] as Object),
  outros: const DecimalConverter().fromJson(json['outros'] as Object),
  preco: const DecimalConverter().fromJson(json['preco'] as Object),
  desconto: const DecimalConverter().fromJson(json['desconto'] as Object),
  cupom: const DecimalConverter().fromJson(json['cupom'] as Object),
  metaLucro: const DecimalConverter().fromJson(json['meta_lucro'] as Object),
  fatiaRoas: const DecimalConverter().fromJson(json['fatia_roas'] as Object),
  margemAlvo: const DecimalConverter().fromJson(json['margem_alvo'] as Object),
  compraInsumoId: json['compra_insumo_id'] as String?,
  precoConcorrente: const DecimalNullableConverter().fromJson(
    json['preco_concorrente'],
  ),
);

Map<String, dynamic> _$$ProdutoVendaImplToJson(_$ProdutoVendaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'empresa_id': instance.empresaId,
      'nome': instance.nome,
      'embalagem': const DecimalConverter().toJson(instance.embalagem),
      'impressao': const DecimalConverter().toJson(instance.impressao),
      'outros': const DecimalConverter().toJson(instance.outros),
      'preco': const DecimalConverter().toJson(instance.preco),
      'desconto': const DecimalConverter().toJson(instance.desconto),
      'cupom': const DecimalConverter().toJson(instance.cupom),
      'meta_lucro': const DecimalConverter().toJson(instance.metaLucro),
      'fatia_roas': const DecimalConverter().toJson(instance.fatiaRoas),
      'margem_alvo': const DecimalConverter().toJson(instance.margemAlvo),
      'compra_insumo_id': instance.compraInsumoId,
      'preco_concorrente': const DecimalNullableConverter().toJson(
        instance.precoConcorrente,
      ),
    };
