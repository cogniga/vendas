// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empresa.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EmpresaImpl _$$EmpresaImplFromJson(Map<String, dynamic> json) =>
    _$EmpresaImpl(
      id: json['id'] as String,
      nome: json['nome'] as String,
      criadoEm: json['criado_em'] == null
          ? null
          : DateTime.parse(json['criado_em'] as String),
    );

Map<String, dynamic> _$$EmpresaImplToJson(_$EmpresaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'criado_em': instance.criadoEm?.toIso8601String(),
    };
