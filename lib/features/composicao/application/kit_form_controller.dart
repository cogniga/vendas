import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/data/repositorios/produto_venda_repository.dart';
import 'package:sales/domain/entidades/produto_venda.dart';
import 'package:sales/features/composicao/application/composicao_providers.dart';

/// Controla as mutações de [ProdutoVenda] (salvar/duplicar/excluir).
///
/// Estado `AsyncValue<void>` com o resultado da última operação. Traduz
/// `ErroRepositorio` para mensagem em pt_BR e invalida [kitsProvider] ao
/// concluir com sucesso.
class KitFormController extends StateNotifier<AsyncValue<void>> {
  /// Cria o controller com o [Ref] injetado.
  KitFormController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  ProdutoVendaRepository get _repo =>
      _ref.read(produtoVendaRepositoryProvider);

  /// Salva o kit (cria quando `id` vazio, atualiza caso contrário).
  Future<bool> salvar(ProdutoVenda kit) => _executar(() => _repo.salvar(kit));

  /// Duplica o kit [id] como `<nome> (cópia)`.
  Future<bool> duplicar(String id) => _executar(() => _repo.duplicar(id));

  /// Exclui o kit [id].
  Future<bool> excluir(String id) => _executar(() => _repo.excluir(id));

  Future<bool> _executar(Future<void> Function() acao) async {
    state = const AsyncValue.loading();
    try {
      await acao();
      _ref.invalidate(kitsProvider);
      state = const AsyncValue.data(null);
      return true;
    } on Object catch (e, s) {
      state = AsyncValue.error(_mensagem(e), s);
      return false;
    }
  }

  String _mensagem(Object erro) {
    final texto = erro.toString();
    return texto.startsWith('ErroRepositorio: ')
        ? texto.substring('ErroRepositorio: '.length)
        : 'Não foi possível salvar. Tente de novo.';
  }
}

/// Provider do [KitFormController].
final kitFormControllerProvider =
    StateNotifierProvider<KitFormController, AsyncValue<void>>((ref) {
  return KitFormController(ref);
});
