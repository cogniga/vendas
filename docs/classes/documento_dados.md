# Documentação de classes — Camada dados (repositórios)

> Regra do projeto: cada classe tem documentação única, atualizada a cada
> alteração. Este arquivo agrupa as classes e providers da camada
> `lib/data/repositorios`. Todos os repositórios recebem o `SupabaseClient`
> por construtor e filtram `empresa_id` em toda consulta (RLS por empresa).

## documento_ErroRepositorio
- **Arquivo:** `lib/data/repositorios/erros_repositorio.dart`
- **Responsabilidade:** `Exception` com `mensagem` amigável (pt_BR) para a
  interface. Factory `ErroRepositorio.dePostgrest(PostgrestException, {mensagemUnique})`
  traduz erros do Postgres; violação de chave única (code `23505`) com
  `mensagemUnique` vira essa mensagem específica.
- **Observações:** `supabase_flutter` só é importado aqui e nos repositórios,
  nunca em widgets.

## documento_EmpresaRepository
- **Arquivo:** `lib/data/repositorios/empresa_repository.dart`
- **Responsabilidade:** tenant. `criarEmpresa(String nome) → Future<String>`
  (RPC `criar_empresa`, retorna o uuid); `listarMinhas() → Future<List<Empresa>>`
  (join `membros → empresas` filtrando `user_id` do usuário atual);
  `obterPorId(String id) → Future<Empresa?>`.
- **Provider:** `empresaRepositoryProvider` (`Provider<EmpresaRepository>`).

## documento_empresaAtualProvider
- **Arquivo:** `lib/data/repositorios/empresa_atual_provider.dart`
- **Responsabilidade:** `FutureProvider<Empresa?>` com a empresa ativa.
  Decisão: usa a **primeira** empresa de `listarMinhas()` (ordem do banco);
  `null` quando o usuário ainda não tem empresa (dispara onboarding). O tipo
  já está preparado para, no futuro, escolher entre várias empresas.

## documento_ConfiguracoesRepository
- **Arquivo:** `lib/data/repositorios/configuracoes_repository.dart`
- **Responsabilidade:** `obter(String empresaId) → Future<Configuracoes>`
  (select por `empresa_id`); `atualizar(Configuracoes config) → Future<void>`
  (update por `empresa_id`).
- **Provider:** `configuracoesRepositoryProvider`.

## documento_FaixaAbelinhaRepository
- **Arquivo:** `lib/data/repositorios/faixa_abelinha_repository.dart`
- **Responsabilidade:** `listar(String empresaId) → Future<List<FaixaAbelinha>>`
  (order `custo_ate` asc); `substituir(String empresaId, List<FaixaAbelinha>) →
  Future<void>` (delete por `empresa_id` + insert em lote).
- **Provider:** `faixaAbelinhaRepositoryProvider`.

## documento_ProdutoRepository
- **Arquivo:** `lib/data/repositorios/produto_repository.dart`
- **Responsabilidade:** tabela `produto_online` (DECISÃO D1).
  `listar(String empresaId) → Future<List<Produto>>` (order `nome`);
  `obter(String id) → Future<Produto?>`; `criar(Produto) → Future<Produto>`;
  `atualizar(Produto) → Future<Produto>`; `excluir(String id) → Future<void>`;
  `kitsQueUsam(String produtoId) → Future<List<String>>` (nomes de kits via
  join `produtos_venda_itens → produtos_venda`, para o aviso R3.9). Violação do
  código único lança `ErroRepositorio('Já existe um produto com o código X')`.
- **Provider:** `produtoRepositoryProvider`.

## documento_PlataformaRepository
- **Arquivo:** `lib/data/repositorios/plataforma_repository.dart`
- **Responsabilidade:** `listarComFaixas(String empresaId) →
  Future<Map<Plataforma, List<FaixaTaxa>>>` (plataformas order `ordem`; faixas
  por plataforma, sem limite por último); `criar(String empresaId, String nome)
  → Future<Plataforma>`; `renomear(String id, String nome) → Future<void>`;
  `mudarCor(String id, String cor) → Future<void>`; `excluir(String id) →
  Future<void>` (bloqueia com `ErroRepositorio` se referenciada por pedidos ou
  saques — checa `count` antes); `substituirFaixas(String plataformaId, String
  empresaId, List<FaixaTaxa>) → Future<void>` (delete + insert em lote).
- **Provider:** `plataformaRepositoryProvider`.

## documento_DestinoRepository
- **Arquivo:** `lib/data/repositorios/destino_repository.dart`
- **Responsabilidade:** CRUD de `destinos`. `listar(String empresaId) →
  Future<List<Destino>>` (order `ordem`); `obter(String id) → Future<Destino?>`;
  `criar(Destino) → Future<Destino>`; `atualizar(Destino) → Future<Destino>`;
  `excluir(String id) → Future<void>`.
- **Provider:** `destinoRepositoryProvider`.

## documento_CompraInsumoRepository
- **Arquivo:** `lib/data/repositorios/compra_insumo_repository.dart`
- **Responsabilidade:** CRUD de `compras_insumo`. `listar(String empresaId) →
  Future<List<CompraInsumo>>` (order `data` desc); `obter(String id) →
  Future<CompraInsumo?>`; `criar(CompraInsumo) → Future<CompraInsumo>`;
  `atualizar(CompraInsumo) → Future<CompraInsumo>`; `excluir(String id) →
  Future<void>`.
- **Provider:** `compraInsumoRepositoryProvider`.

## documento_InvestimentoRepository
- **Arquivo:** `lib/data/repositorios/investimento_repository.dart`
- **Responsabilidade:** CRUD de `investimentos`. `listar(String empresaId) →
  Future<List<Investimento>>` (order `data` desc); `obter(String id) →
  Future<Investimento?>`; `criar(Investimento) → Future<Investimento>`;
  `atualizar(Investimento) → Future<Investimento>`; `excluir(String id) →
  Future<void>`.
- **Provider:** `investimentoRepositoryProvider`.

## documento_RetiradaRepository
- **Arquivo:** `lib/data/repositorios/retirada_repository.dart`
- **Responsabilidade:** CRUD de `retiradas`. `listar(String empresaId) →
  Future<List<Retirada>>` (order `data` desc); `obter(String id) →
  Future<Retirada?>`; `criar(Retirada) → Future<Retirada>`;
  `atualizar(Retirada) → Future<Retirada>`; `excluir(String id) →
  Future<void>`.
- **Provider:** `retiradaRepositoryProvider`.

## documento_ProdutoVendaRepository
- **Arquivo:** `lib/data/repositorios/produto_venda_repository.dart`
- **Responsabilidade:** agregado kit coeso. `listar(String empresaId) →
  Future<List<ProdutoVenda>>` (com `itens` e `precosPorPlataforma` montados);
  `obterCompleto(String id) → Future<ProdutoVenda?>`; `salvar(ProdutoVenda) →
  Future<ProdutoVenda>` (upsert `produtos_venda` + substitui
  `produtos_venda_itens` delete-then-insert + upsert `produtos_venda_precos`);
  `duplicar(String id) → Future<ProdutoVenda>` (cria `<nome> (cópia)` zerando
  `vendidos_iniciais`); `excluir(String id) → Future<void>`.
- **Provider:** `produtoVendaRepositoryProvider`.

## documento_PedidoRepository
- **Arquivo:** `lib/data/repositorios/pedido_repository.dart`
- **Responsabilidade:** `listar(String empresaId) → Future<List<Pedido>>`
  (order `data` desc); `obterComItens(String id) → Future<Pedido?>`;
  `salvar(Pedido) → Future<Pedido>` (upsert `pedidos` + substitui
  `pedidos_itens` gravando os snapshots `custo_unitario`/`abelinhas_unitarias`
  de cada item — **não** recalcula aqui, o chamador define o snapshot);
  `excluir(String id) → Future<void>`.
- **Provider:** `pedidoRepositoryProvider`.

## documento_SaqueRepository
- **Arquivo:** `lib/data/repositorios/saque_repository.dart`
- **Responsabilidade:** `listar(String empresaId) → Future<List<Saque>>`
  (order `data` desc, com `rateio` montado); `salvar(Saque) → Future<Saque>`
  (upsert `saques` + substitui `saques_rateio` delete-then-insert);
  `excluir(String id) → Future<void>`.
- **Provider:** `saqueRepositoryProvider`.
