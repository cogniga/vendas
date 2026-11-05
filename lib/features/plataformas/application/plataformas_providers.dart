import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/data/repositorios/plataforma_repository.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/plataforma.dart';

/// Plataformas da empresa ativa com suas faixas de taxa (R6).
///
/// Espelha o provider de plataformas-com-faixas da feature Composição;
/// mantemos uma
/// cópia local para a feature Plataformas ser independente (não importar a
/// camada `application` de outra feature), mas as duas são invalidadas em
/// conjunto pelo `PlataformasController` ao editar/criar/excluir, para que a
/// composição reflita as mudanças.
final plataformasProvider =
    FutureProvider.autoDispose<Map<Plataforma, List<FaixaTaxa>>>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return {};
  return ref.watch(plataformaRepositoryProvider).listarComFaixas(empresa.id);
});
