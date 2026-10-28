// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faixa_taxa.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FaixaTaxaImpl _$$FaixaTaxaImplFromJson(Map<String, dynamic> json) =>
    _$FaixaTaxaImpl(
      id: json['id'] as String,
      empresaId: json['empresa_id'] as String,
      plataformaId: json['plataforma_id'] as String,
      taxaFixa: const DecimalConverter().fromJson(json['taxa_fixa'] as Object),
      taxaPercentual: const DecimalConverter().fromJson(
        json['taxa_percentual'] as Object,
      ),
      precoAte: const DecimalNullableConverter().fromJson(json['preco_ate']),
    );

Map<String, dynamic> _$$FaixaTaxaImplToJson(
  _$FaixaTaxaImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'empresa_id': instance.empresaId,
  'plataforma_id': instance.plataformaId,
  'taxa_fixa': const DecimalConverter().toJson(instance.taxaFixa),
  'taxa_percentual': const DecimalConverter().toJson(instance.taxaPercentual),
  'preco_ate': const DecimalNullableConverter().toJson(instance.precoAte),
};
