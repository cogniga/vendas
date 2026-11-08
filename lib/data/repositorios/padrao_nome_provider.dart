import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/format/padrao_escrita.dart';
import 'package:sales/data/repositorios/configuracoes_repository.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';

/// Padrão de escrita dos nomes da empresa ativa (`configuracoes.padrao_nome`).
///
/// Enquanto carrega, sem empresa ou em erro, vale [PadraoNome.titulo].
final padraoNomeAsyncProvider = FutureProvider<PadraoNome>((ref) async {
  final empresa = await ref.watch(empresaAtualProvider.future);
  if (empresa == null) return PadraoNome.titulo;
  final config =
      await ref.watch(configuracoesRepositoryProvider).obter(empresa.id);
  return PadraoNome.doBanco(config.padraoNome);
});

/// Valor síncrono do padrão de nomes, para os campos de formulário.
final padraoNomeProvider = Provider<PadraoNome>((ref) {
  return ref.watch(padraoNomeAsyncProvider).valueOrNull ?? PadraoNome.titulo;
});
