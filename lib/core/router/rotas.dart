/// Caminhos de rota do app (design.md §4), centralizados para evitar strings
/// soltas espalhadas pelos widgets.
class Rotas {
  const Rotas._();

  static const String login = '/login';
  static const String onboarding = '/onboarding';

  static const String painel = '/';

  static const String pedidos = '/pedidos';
  static const String pedidoNovo = '/pedidos/novo';

  /// Caminho com o id de um pedido específico.
  static String pedido(String id) => '/pedidos/$id';

  static const String composicao = '/composicao';
  static const String composicaoNova = '/composicao/novo';

  /// Caminho com o id de um produto de venda (kit) específico.
  static String composicaoItem(String id) => '/composicao/$id';

  static const String produtos = '/produtos';
  static const String insumos = '/insumos';
  static const String investimento = '/investimento';
  static const String caixa = '/caixa';
  static const String plataformas = '/plataformas';
  static const String abelinhas = '/abelinhas';
  static const String configuracoes = '/configuracoes';
}
