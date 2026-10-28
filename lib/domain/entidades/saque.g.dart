// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saque.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SaqueImpl _$$SaqueImplFromJson(Map<String, dynamic> json) => _$SaqueImpl(
  id: json['id'] as String,
  empresaId: json['empresa_id'] as String,
  data: DateTime.parse(json['data'] as String),
  plataformaId: json['plataforma_id'] as String,
  valor: const DecimalConverter().fromJson(json['valor'] as Object),
  obs: json['obs'] as String? ?? '',
);

Map<String, dynamic> _$$SaqueImplToJson(_$SaqueImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'empresa_id': instance.empresaId,
      'data': instance.data.toIso8601String(),
      'plataforma_id': instance.plataformaId,
      'valor': const DecimalConverter().toJson(instance.valor),
      'obs': instance.obs,
    };
