// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plataforma.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlataformaImpl _$$PlataformaImplFromJson(Map<String, dynamic> json) =>
    _$PlataformaImpl(
      id: json['id'] as String,
      empresaId: json['empresa_id'] as String,
      nome: json['nome'] as String,
      cor: json['cor'] as String? ?? '#9A8FD4',
      obs: json['obs'] as String? ?? '',
      ordem: (json['ordem'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$PlataformaImplToJson(_$PlataformaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'empresa_id': instance.empresaId,
      'nome': instance.nome,
      'cor': instance.cor,
      'obs': instance.obs,
      'ordem': instance.ordem,
    };
