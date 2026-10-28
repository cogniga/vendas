// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuracoes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConfiguracoesImpl _$$ConfiguracoesImplFromJson(Map<String, dynamic> json) =>
    _$ConfiguracoesImpl(
      empresaId: json['empresa_id'] as String,
      embalagemPadrao: const DecimalConverter().fromJson(
        json['embalagem_padrao'] as Object,
      ),
      impressaoPadrao: const DecimalConverter().fromJson(
        json['impressao_padrao'] as Object,
      ),
      valorAbelinha: const DecimalConverter().fromJson(
        json['valor_abelinha'] as Object,
      ),
    );

Map<String, dynamic> _$$ConfiguracoesImplToJson(
  _$ConfiguracoesImpl instance,
) => <String, dynamic>{
  'empresa_id': instance.empresaId,
  'embalagem_padrao': const DecimalConverter().toJson(instance.embalagemPadrao),
  'impressao_padrao': const DecimalConverter().toJson(instance.impressaoPadrao),
  'valor_abelinha': const DecimalConverter().toJson(instance.valorAbelinha),
};
