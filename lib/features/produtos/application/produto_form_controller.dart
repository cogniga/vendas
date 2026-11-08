import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/data/repositorios/produto_repository.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/features/composicao/application/composicao_providers.dart'
    as composicao;
import 'package:sales/features/pedidos/application/pedidos_providers.dart'
    as pedidos;
import 'package:sales/features/produtos/application/produtos_providers.dart';

/// Controla as mutações de [Produto] (criar/atualizar/excluir).
///
/// Estado `AsyncValue<void>` com `loading`/`error`/`data` da última operação.
/// Traduz `ErroRepositorio` (ex.: código duplicado) para mensagem em pt_BR e
/// invalida [produtosProvider] ao concluir com sucesso.
class ProdutoFormController extends StateNotifier<AsyncValue<void>> {
  /// Cria o controller com o [Ref] injetado.
  ProdutoFormController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  ProdutoRepository get _repo => _ref.read(produtoRepositoryProvider);

  /// Cria um produto novo (id vazio). Retorna `true` em sucesso.
  Future<bool> criar(Produto produto) => _executar(() => _repo.criar(produto));

  /// Atualiza um produto existente. Retorna `true` em sucesso.
  Future<bool> atualizar(Produto produto) =>
      _executar(() => _repo.atualizar(produto));

  /// Exclui o produto [id]. Retorna `true` em sucesso.
  Future<bool> excluir(String id) => _executar(() => _repo.excluir(id));

  /// Nomes dos kits (produtos de venda) que usam o produto [produtoId].
  Future<List<String>> kitsQueUsam(String produtoId) =>
      _repo.kitsQueUsam(produtoId);

  Future<bool> _executar(Future<void> Function() acao) async {
    state = const AsyncValue.loading();
    try {
      await acao();
      // Pedidos e Composição têm a própria cópia em cache da lista de
      // produtos; invalida todas para refletir a mudança em todo o app.
      _ref
        ..invalidate(produtosProvider)
        ..invalidate(pedidos.produtosProvider)
        ..invalidate(composicao.produtosProvider);
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

/// Provider do [ProdutoFormController].
final produtoFormControllerProvider =
    StateNotifierProvider<ProdutoFormController, AsyncValue<void>>((ref) {
  return ProdutoFormController(ref);
});
