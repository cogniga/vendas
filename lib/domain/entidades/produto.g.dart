// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProdutoImpl _$$ProdutoImplFromJson(Map<String, dynamic> json) =>
    _$ProdutoImpl(
      id: json['id'] as String,
      empresaId: json['empresa_id'] as String,
      codigo: json['codigo'] as String,
      nome: json['nome'] as String,
      custo: const DecimalConverter().fromJson(json['custo'] as Object),
      marca: json['marca'] as String? ?? '',
      categoria: json['categoria'] as String? ?? 'Cosméticos',
      fornecedor: json['fornecedor'] as String? ?? '',
      unidade: json['unidade'] as String? ?? 'un',
      estoque: (json['estoque'] as num?)?.toInt() ?? 0,
      ean: json['ean'] as String? ?? '',
      ativo: json['ativo'] as bool? ?? true,
      obs: json['obs'] as String? ?? '',
      abelinhasManual: const DecimalNullableConverter().fromJson(
        json['abelinhas_manual'],
      ),
    );

Map<String, dynamic> _$$ProdutoImplToJson(_$ProdutoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'empresa_id': instance.empresaId,
      'codigo': instance.codigo,
      'nome': instance.nome,
      'custo': const DecimalConverter().toJson(instance.custo),
      'marca': instance.marca,
      'categoria': instance.categoria,
      'fornecedor': instance.fornecedor,
      'unidade': instance.unidade,
      'estoque': instance.estoque,
      'ean': instance.ean,
      'ativo': instance.ativo,
      'obs': instance.obs,
      'abelinhas_manual': const DecimalNullableConverter().toJson(
        instance.abelinhasManual,
      ),
    };
