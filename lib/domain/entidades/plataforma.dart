import 'package:freezed_annotation/freezed_annotation.dart';

part 'plataforma.freezed.dart';
part 'plataforma.g.dart';

/// Marketplace / canal de venda — tabela `plataformas`.
@freezed
class Plataforma with _$Plataforma {
  const factory Plataforma({
    required String id,
    @JsonKey(name: 'empresa_id') required String empresaId,
    required String nome,
    @Default('#9A8FD4') String cor,
    @Default('') String obs,
    @Default(0) int ordem,
  }) = _Plataforma;

  factory Plataforma.fromJson(Map<String, dynamic> json) =>
      _$PlataformaFromJson(json);
}
