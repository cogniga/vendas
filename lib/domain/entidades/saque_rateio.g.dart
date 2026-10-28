// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saque_rateio.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SaqueRateioImpl _$$SaqueRateioImplFromJson(Map<String, dynamic> json) =>
    _$SaqueRateioImpl(
      saqueId: json['saque_id'] as String,
      empresaId: json['empresa_id'] as String,
      destinoId: json['destino_id'] as String,
      percentual: const DecimalConverter().fromJson(
        json['percentual'] as Object,
      ),
      valor: const DecimalConverter().fromJson(json['valor'] as Object),
    );

Map<String, dynamic> _$$SaqueRateioImplToJson(_$SaqueRateioImpl instance) =>
    <String, dynamic>{
      'saque_id': instance.saqueId,
      'empresa_id': instance.empresaId,
      'destino_id': instance.destinoId,
      'percentual': const DecimalConverter().toJson(instance.percentual),
      'valor': const DecimalConverter().toJson(instance.valor),
    };
