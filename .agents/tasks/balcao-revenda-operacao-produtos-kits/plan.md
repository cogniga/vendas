# Implementation Plan — Operação: Produtos (R3) e Composição de custo (R4)

App Flutter `sales` ("Balcão Revenda"). Branch main, SEM push. Baseline verde
(`flutter analyze` → "No issues found", testes passam). Lint `very_good_analysis`
(linhas ≤ 80 col, sem imports não usados, raw strings `r'...'` para textos com
`$`). `flutter gen-l10n`/build_runner NÃO é necessário (nenhuma entidade/calc
novo; tudo já tem `.g.dart`/`.freezed.dart`).

## Descobertas que mudam o enunciado

- PRODUTOS (R3) **já está implementada** e verde: `produtos_page.dart`,
  `produto_form.dart`, `produto_form_controller.dart`, `produtos_providers.dart`,
  `widgets/quadro_abelinhas.dart`. O editor usa `abrirPainelLateral` (560px), o
  quadro de abelinhas já faz o aviso de impacto §6.7 com `avisoAjusteManual`, e a
  gravação já grava `abelinhasManual=null` quando igual à regra. NÃO reescrever do
  zero — apenas **completar a lista** para cumprir R3.8 fielmente ao protótipo
  (`V.produtos`).
- COMPOSIÇÃO (R4) é só placeholder ("Em construção") — é o grosso do trabalho.
- `calcularKit` (domain) já existe e está 100% testado (vetores §6.3). NÃO alterar
  domínio. Reutilizar via `produto_venda.dart`.
- `precoParaMargem(faixas, custo, margemAlvo)` devolve **M (cliente paga)**. O
  "preço sugerido" da tabela do kit (§6.2 / proto `kitCalc.sugerido`) =
  `precoParaMargem(...) + desconto + cupom` (o preço-anúncio equivalente). Aplicar
  o botão grava esse valor no campo "preço anúncio" da plataforma.
- `ResponsiveList` decide por `LayoutBuilder` (largura do próprio widget) e trata a
  coluna de ações; a raiz da page deve ser `Column` (o `AppShell` já envolve o
  child em `SingleChildScrollView`). Pedidos é a referência de estrutura.
- Repositório de produto usa `criar`/`atualizar` separados (não `salvar`). Kit usa
  `salvar`/`obterCompleto`/`duplicar`/`excluir`. `kitsQueUsam(produtoId)` existe.
- Entidades (confirmadas): `Produto`(codigo,nome,custo:Decimal,marca,categoria,
  fornecedor,unidade,estoque:int,ean,ativo,obs,abelinhasManual:Decimal?);
  `ProdutoVenda`(nome,embalagem,impressao,outros,preco,desconto,cupom,metaLucro,
  fatiaRoas,margemAlvo:Decimal,compraInsumoId?,precoConcorrente?:Decimal,
  itens:List<ProdutoVendaItem{produtoId,quantidade}>,
  precosPorPlataforma:Map<String,PrecoPlataforma{preco?,desconto?,cupom?,
  vendidosIniciais}>). `CompraInsumo`(id,produto,descricao,valorTotal:Decimal,
  itens:int) — valor unitário da embalagem = `valorTotal / itens`.
- Sem sessão Supabase (login adm/adm) → `empresaAtualProvider` devolve `null` →
  providers devolvem vazio; a UI abre e mostra estados vazio/erro. NÃO depender de
  dados reais nem quebrar quando empresa é null.

## Pontos de atenção (layout / lint / verificação)

- Raiz de cada page = `Column` (NUNCA `ListView`/scroll vertical externo).
- Lista larga do kit (uma coluna por plataforma) precisa cair para cartões em tela
  estreita: usar `ResponsiveList` com `limiarCartao` alto (~990) — §7.4 "listas
  largas ~990".
- Recalcular ao digitar no editor do kit SEM perder o foco: manter `TextEditingController`
  por campo de plataforma e chamar `setState` em `onChanged` (como `pedido_editor`
  faz com `_precoCtrl`). Não recriar controllers no build.
- Botões só-ícone: usar `IconAction`/`ConfirmDeleteButton` (já têm Tooltip+Semantics).
- Dinheiro sempre `Decimal` + `Formatos.moedaDecimal`; percent `Formatos.percentualFracao`
  (recebe fração); abelinhas `Formatos.abelinhas`. Parse de input: `Formatos.parseDecimal`
  ou `MoneyField`.
- Normalização de texto: `TextCaseField`(titulo/frase/maius) + `PadraoEscrita` ao salvar.
- Lint: quebrar linhas > 80 col; prefixar `r` em strings com `$` (ex. `r'Preço (R$)'`);
  remover imports não usados; `const` onde possível.
- Verificação a cada item: `flutter analyze` (esperado "No issues found!") e, no fim,
  `flutter test` (todos passam). Rodar `flutter build` não é necessário para validar
  compilação; `flutter analyze` já cobre erros de tipos/compilação deste código.

---

## PRODUTOS (R3) — completar a lista conforme protótipo `V.produtos`

- [ ] 1. Adicionar provider de "vendidos por produto" e "códigos repetidos".
      Criar `pedidosProdutosProvider` (ou reusar) que lê `empresaAtualProvider` e
      `pedidoRepositoryProvider.listar(empresa.id)`; derivar um
      `Map<String,int> vendidosPorProduto` somando, em pedidos `concluido`, a qtd de
      cada produto avulso + (qtd do kit × qtd de cada item do kit) — precisa dos kits
      (`produtoVendaRepositoryProvider.listar`). Expor também `Set<String> codigosRepetidos`
      a partir da lista de produtos (código que aparece > 1×). Colocar em
      `lib/features/produtos/application/produtos_providers.dart`.
      Files: lib/features/produtos/application/produtos_providers.dart
      Verify: `flutter analyze` → sem erros.

- [ ] 2. Enriquecer a célula "Produto" e as colunas da lista em `produtos_page.dart`
      para cumprir R3.8: na célula principal, pill `inativo` (TomPill.neutro) quando
      `!ativo` e pill `código repetido` (TomPill.atencao) quando o código estiver em
      `codigosRepetidos`; renomear header "Custo" → "Custo un."; na coluna Estoque,
      mostrar `'$estoque ${unidade}'` e abaixo `'$vendidos vendido(s)'` (muted) vindo do
      provider do item 1; na coluna Abelinhas, acrescentar o botão ✎ pequeno
      (`IconAction` LucideIcons.pencil, tooltip "Editar abelinhas") que abre o editor do
      produto (mesma ação de editar). Manter os pills "pela regra/ajustado" já existentes.
      Consumir os novos providers via `ref.watch(...).valueOrNull`.
      Files: lib/features/produtos/presentation/produtos_page.dart
      Verify: `flutter analyze` → "No issues found!".

- [ ] 3. Revisar o editor de produto (`produto_form.dart` + `quadro_abelinhas.dart`)
      contra R3.1–R3.6 e marcar conformidade (campos código/nome/marca/categoria/
      fornecedor/custo/unidade/estoque/ean/ativo/obs com normalização; validação código+nome;
      erro de código duplicado tratado pelo controller; quadro de abelinhas em tempo real,
      ✎/voltar-à-regra, aviso de impacto, kits afetados; salvar grava manual=null quando =
      regra). Só ajustar se encontrar divergência real (ex.: faltar `estoque`/`unidade`,
      texto fora do padrão). NÃO reescrever o que já cumpre.
      Files: lib/features/produtos/presentation/produto_form.dart,
      lib/features/produtos/presentation/widgets/quadro_abelinhas.dart (se necessário)
      Verify: `flutter analyze` → sem erros; abrir mentalmente contra `docs/telas/07-produtos.png`
      e `08-produto-abelinhas-impacto.png`.

- [ ] 4. Documentar as classes novas/alteradas (regra global: `documento_{Classe}`).
      Se o projeto já segue outro padrão de doc (ver se existem `documento_*`), seguir o
      existente; caso não exista, registrar as classes novas da Composição (item 10+) e as
      alterações da lista de Produtos num doc por classe. (Manter mínimo; não inventar
      estrutura se o repo não a usa.)
      Files: conforme padrão do repo (verificar antes).
      Verify: `flutter analyze` → sem erros.

---

## COMPOSIÇÃO DE CUSTO / kits (R4) — construir do zero

- [ ] 5. Criar os providers da feature em
      `lib/features/composicao/application/composicao_providers.dart`:
      `kitsProvider` (FutureProvider.autoDispose<List<ProdutoVenda>> via
      `produtoVendaRepositoryProvider.listar(empresa.id)`);
      `plataformasComFaixasProvider` (`Map<Plataforma,List<FaixaTaxa>>`);
      `produtosProvider` (lista, para montar mapa `id→Produto`);
      `faixasAbelinhaProvider`; `configuracoesProvider`;
      `comprasInsumoProvider` (`compraInsumoRepositoryProvider.listar`);
      `pedidosProvider` (para "vendidos"); e um `DadosEdicaoKit` agregador análogo a
      `DadosEdicaoPedido` (plataformas, produtosPorId, faixasAbelinha, configuracoes,
      compras, pedidos). Todos tratam empresa `null` → vazio.
      Files: lib/features/composicao/application/composicao_providers.dart
      Verify: `flutter analyze` → sem erros.

- [ ] 6. Criar o controller de mutação do kit em
      `lib/features/composicao/application/kit_form_controller.dart`
      (StateNotifier<AsyncValue<void>>), análogo a `ProdutoFormController`: métodos
      `salvar(ProdutoVenda)`, `duplicar(String id)`, `excluir(String id)` chamando
      `produtoVendaRepositoryProvider`; invalida `kitsProvider` em sucesso; traduz erro
      para mensagem pt_BR.
      Files: lib/features/composicao/application/kit_form_controller.dart
      Verify: `flutter analyze` → sem erros.

- [ ] 7. Construir a lista da Composição em `composicao_page.dart` (substituir placeholder),
      seguindo a estrutura de `pedidos_page.dart`: raiz `Column`, `PageHeader`
      (title "Composição de custo", subtitle do protótipo `V.kits`, action FilledButton
      "Novo produto de venda"), e um `ResponsiveList<ProdutoVenda>` com `limiarCartao: 990`.
      Colunas (R4.8): **Produto de venda** (principal: nome em destaque + composição
      `'5× SACHER'` = itens `'${qtd}× ${codigoDoProduto}'` juntos por ' · '); **Investimento**
      (valor `calcularKit(...).investimento` OU `kitCusto` — calcular compra+emb+imp+outros;
      abaixo `'$n itens · ${abelinhas} 🐝'`); **uma coluna por plataforma** (label = nome da
      plataforma; valor = lucro com cor good/bad via `calcularKit(kit,produtosPorId,plat,
      faixas,faixasAbelinha).lucro`; abaixo `'${clientePaga} · ${margem}'`). Ações
      (R13.2): `IconAction` abrir (LucideIcons.eye), duplicar (LucideIcons.copy via controller)
      e `ConfirmDeleteButton`. Estados carregando/vazio/erro (usar `EstadoLista` ou o padrão
      `_Carregando/_Erro/_Vazio` de pedidos). Para abelinhas por item usar
      `abelinhasProduto(produto, faixasAbelinha)`.
      Files: lib/features/composicao/presentation/composicao_page.dart
      Verify: `flutter analyze` → "No issues found!"; comparar com `docs/telas/04-composicao.png`.

- [ ] 8. Construir o editor do kit em
      `lib/features/composicao/presentation/kit_editor.dart` como painel lateral LARGO:
      `abrirKitEditor(context, {kit})` usando `abrirPainelLateral<bool>(..., largo: true)`
      (1080px; tela cheia < 760 pelo próprio painel). Corpo = `CorpoPainelLateral` +
      `RodapePainel('Salvar produto de venda')`. Estado local em `ConsumerStatefulWidget`:
      nome (TextCaseField titulo), lista de itens `{produtoId, quantidade}`, custos
      adicionais (embalagem: `compraInsumoId?` OU valor manual; impressao; outros — iniciais
      de `configuracoes`), preço base/metas (preco, desconto, cupom, precoConcorrente?,
      margemAlvo %, metaLucro R$, fatiaRoas 0–1), e `Map<String,PrecoPlataforma>` por
      plataforma. Layout: `LayoutBuilder` com duas colunas quando largo (esquerda flex 3,
      resumo direita flex 2), empilhado quando estreito — como `pedido_editor`. Carregar
      `DadosEdicaoKit` via FutureProvider (loading/erro/data). Ao abrir kit existente usar
      `obterCompleto(id)` (itens + precos) — ou já vir de `listar`; preferir carregar
      completo no controller/provider para garantir precos.
      Files: lib/features/composicao/presentation/kit_editor.dart
      Verify: `flutter analyze` → sem erros.

- [ ] 9. Dentro do editor: painel ESQUERDO — itens do kit (busca por código/nome com
      `TextField`, lista de resultados `ListTile` "Adicionar"; cada item com código, nome,
      custo un., abelinhas un. e total, subtotal `custo×qtd`; controle −/+ onde 0 remove),
      custos adicionais (Dropdown de `CompraInsumo` → valor unitário `valorTotal/itens`
      preenche embalagem e grava `compraInsumoId`; opção "Valor manual" usa `MoneyField`;
      `MoneyField` para impressão e outros), e preço base + metas (`MoneyField` para preço/
      desconto/cupom/concorrente; TextField número para margemAlvo %, metaLucro R$, fatiaRoas).
      Recalcular `setState` a cada mudança. Validar ao salvar: nome obrigatório e ao menos 1 item
      (toast). Normalizar nome com `PadraoEscrita.titulo` ao salvar.
      Files: lib/features/composicao/presentation/kit_editor.dart
      Verify: `flutter analyze` → sem erros.

- [ ] 10. Dentro do editor: painel DIREITO — RESUMO fixo (sticky em tela larga via coluna
      lateral): compra dos itens, embalagem, impressão, outros, **investimento por venda**
      (total), abelinhas do kit + valor em R$ (`abelinhasKit × valorAbelinha`), lucro por
      plataforma com margem (lista com dot da cor da plataforma), e "Melhor resultado:
      <plataforma>" (maior `lucro`, só quando investimento > 0). Usar o padrão `Ledger`/linhas
      de `pedido_editor._resumo`. Calcular com `calcularKit` para cada plataforma montando um
      `ProdutoVenda` em memória com os overrides atuais.
      Files: lib/features/composicao/presentation/kit_editor.dart
      Verify: `flutter analyze` → sem erros; comparar com `docs/telas/05-composicao-editor.png`.

- [ ] 11. Dentro do editor: tabela **Resultado por plataforma** (abaixo das colunas). Por
      plataforma: campos editáveis preço anúncio / desconto / cupom (em branco = base; mostrar
      o valor base como `placeholder`; manter `TextEditingController` por célula, `onChanged`
      → atualiza `precosPorPlataforma[platId]` e `setState`, sem perder foco); e colunas
      calculadas via `calcularKit`: cliente paga (`clientePaga`), taxa, líquido, lucro
      (cor good/bad), margem, ROI, preço mínimo sem lucro (`precoMinimo(faixas,investimento)`),
      preço sugerido p/ margem = `precoParaMargem(faixas,investimento,margemAlvo) + desconto +
      cupom` como **botão** que, ao clicar, grava esse valor no campo "preço anúncio" daquela
      plataforma (`setState` + atualiza controller do campo), meta (`vendidos/metaQtd`, pill
      verde se `atingido>=1`), ROAS alvo (`roasAlvo`, '—' se null). "vendidos" vem de
      `calcularKit(..., vendidosIniciais: precos.vendidosIniciais, pedidos: pedidos)`.
      Em tela estreita a tabela deve virar blocos por plataforma (sem rolagem horizontal) —
      usar `ResponsiveList` ou um layout que empilha; §7.4.
      Files: lib/features/composicao/presentation/kit_editor.dart
      Verify: `flutter analyze` → sem erros; comparar com `docs/telas/06-composicao-por-plataforma.png`.

- [ ] 12. Salvar/duplicar/excluir: no rodapé, "Salvar produto de venda" monta um
      `ProdutoVenda` coeso (itens + precosPorPlataforma, limpando overrides vazios) e chama
      `kitFormController.salvar`; fecha com `true`. Na lista, duplicar chama
      `controller.duplicar(id)` (nome "(cópia)", zera vendidos iniciais — o repo já faz) e
      invalida; excluir via `ConfirmDeleteButton` → `controller.excluir(id)`. Garantir
      `empresaId` no agregado (ler `empresaAtualProvider`); se null, toast "Nenhuma empresa
      ativa".
      Files: lib/features/composicao/presentation/kit_editor.dart,
      lib/features/composicao/presentation/composicao_page.dart
      Verify: `flutter analyze` → "No issues found!".

- [ ] 13. Verificação final: `flutter analyze` (esperado "No issues found!") e `flutter test`
      (todos os testes existentes passam — nenhum teste de domínio deve quebrar, pois o
      domínio não mudou). Conferir visualmente as 2 telas contra os PNGs em `docs/telas/` e o
      comportamento do protótipo (`V.kits`, `openKit`, `kitRender`, `kitPlats`, `kitSum`).
      Remover qualquer arquivo temporário.
      Files: —
      Verify: `flutter analyze` && `flutter test` → tudo verde.

## Ordem / dependências
- Itens 1→2→3 (Produtos) são independentes de 5→12 (Composição) e podem ir em qualquer
  ordem entre os dois grupos; item 13 fecha tudo. Dentro da Composição: 5 e 6 antes de
  7–12 (providers/controller são pré-requisito da UI); 8 cria o arcabouço do editor, 9/10/11
  preenchem as três áreas, 12 fecha o ciclo salvar/duplicar/excluir.
