// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destino.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DestinoImpl _$$DestinoImplFromJson(Map<String, dynamic> json) =>
    _$DestinoImpl(
      id: json['id'] as String,
      empresaId: json['empresa_id'] as String,
      nome: json['nome'] as String,
      cor: json['cor'] as String,
      percentual: const DecimalConverter().fromJson(
        json['percentual'] as Object,
      ),
      ordem: (json['ordem'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$DestinoImplToJson(_$DestinoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'empresa_id': instance.empresaId,
      'nome': instance.nome,
      'cor': instance.cor,
      'percentual': const DecimalConverter().toJson(instance.percentual),
      'ordem': instance.ordem,
    };
