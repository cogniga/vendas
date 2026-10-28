// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investimento.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvestimentoImpl _$$InvestimentoImplFromJson(Map<String, dynamic> json) =>
    _$InvestimentoImpl(
      id: json['id'] as String,
      empresaId: json['empresa_id'] as String,
      data: DateTime.parse(json['data'] as String),
      distribuidor: json['distribuidor'] as String,
      valor: const DecimalConverter().fromJson(json['valor'] as Object),
      nota: json['nota'] as String? ?? '',
      destinoId: json['destino_id'] as String?,
      obs: json['obs'] as String? ?? '',
    );

Map<String, dynamic> _$$InvestimentoImplToJson(_$InvestimentoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'empresa_id': instance.empresaId,
      'data': instance.data.toIso8601String(),
      'distribuidor': instance.distribuidor,
      'valor': const DecimalConverter().toJson(instance.valor),
      'nota': instance.nota,
      'destino_id': instance.destinoId,
      'obs': instance.obs,
    };
