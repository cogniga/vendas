import 'package:freezed_annotation/freezed_annotation.dart';

part 'empresa.freezed.dart';
part 'empresa.g.dart';

/// Empresa (tenant) dona de todos os dados — tabela `empresas`.
@freezed
class Empresa with _$Empresa {
  const factory Empresa({
    required String id,
    required String nome,
    @JsonKey(name: 'criado_em') DateTime? criadoEm,
  }) = _Empresa;

  factory Empresa.fromJson(Map<String, dynamic> json) =>
      _$EmpresaFromJson(json);
}
