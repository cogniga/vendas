import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/data/repositorios/empresa_repository.dart';
import 'package:sales/domain/entidades/empresa.dart';

/// Lista de TODAS as empresas, para o seletor de empresa padrão.
final todasEmpresasProvider = FutureProvider<List<Empresa>>((ref) async {
  return ref.watch(empresaRepositoryProvider).listarTodas();
});
