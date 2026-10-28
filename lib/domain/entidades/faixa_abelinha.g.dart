// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faixa_abelinha.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FaixaAbelinhaImpl _$$FaixaAbelinhaImplFromJson(Map<String, dynamic> json) =>
    _$FaixaAbelinhaImpl(
      id: json['id'] as String,
      empresaId: json['empresa_id'] as String,
      custoAte: const DecimalConverter().fromJson(json['custo_ate'] as Object),
      abelinhas: const DecimalConverter().fromJson(json['abelinhas'] as Object),
    );

Map<String, dynamic> _$$FaixaAbelinhaImplToJson(_$FaixaAbelinhaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'empresa_id': instance.empresaId,
      'custo_ate': const DecimalConverter().toJson(instance.custoAte),
      'abelinhas': const DecimalConverter().toJson(instance.abelinhas),
    };
