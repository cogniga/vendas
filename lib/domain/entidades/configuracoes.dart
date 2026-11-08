import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sales/domain/entidades/conversores.dart';

part 'configuracoes.freezed.dart';
part 'configuracoes.g.dart';

/// Configurações da empresa (1 por empresa) — tabela `configuracoes`.
@freezed
class Configuracoes with _$Configuracoes {
  const factory Configuracoes({
    @JsonKey(name: 'empresa_id') required String empresaId,
    @JsonKey(name: 'embalagem_padrao')
    @DecimalConverter()
    required Decimal embalagemPadrao,
    @JsonKey(name: 'impressao_padrao')
    @DecimalConverter()
    required Decimal impressaoPadrao,
    @JsonKey(name: 'valor_abelinha')
    @DecimalConverter()
    required Decimal valorAbelinha,

    /// Padrão de escrita dos nomes: `titulo`, `maiusculas` ou `minusculas`.
    @JsonKey(name: 'padrao_nome') @Default('titulo') String padraoNome,
  }) = _Configuracoes;

  factory Configuracoes.fromJson(Map<String, dynamic> json) =>
      _$ConfiguracoesFromJson(json);
}
