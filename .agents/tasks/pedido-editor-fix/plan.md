# Plano: editor de pedido (perda de itens + layout do protótipo)

Leitura obrigatória antes de codar: `mf_designer.md`, `mf_arquitetura.md`, `.kiro/specs/balcao-revenda/design.md` (§6.4, §7, §8), `docs/prototipo/balcao-revenda.html` (editor de pedido ~linha 853), `docs/telas/03-pedido-editor.png`, `02-pedidos.png`, `17-celular-pedidos.png`.

## Causa raiz confirmada (evidência no código)

1. `PedidoRepository.listar` (`lib/data/repositorios/pedido_repository.dart`) faz só `from('pedidos').select()`: o `Pedido` da lista vem com `itens` vazio.
2. `PedidosPage._abrirEditor` (`pedidos_page.dart`) passa esse `Pedido` direto para `PedidoEditor(pedido: pedido)`. `_PedidoEditorState.initState` monta `_linhas` a partir de `widget.pedido.itens`, que está vazio. O editor abre sem itens, e `_salvar` bloqueia com "Adicione pelo menos um item". `obterComItens` existe mas só é chamado dentro de `salvar`.
3. Risco de apagar dados: `salvar` faz `delete` de `pedidos_itens` e re-insere `pedido.itens`. Se algum caminho salvar um pedido com itens não carregados, os itens reais somem. Hoje só a guarda "pelo menos um item" evita isso. É preciso garantir isso por construção.
4. Consequências do mesmo defeito: a coluna "Itens" da lista mostra "0 itens" (`_CelulaItens` usa `pedido.itens`). Custo e lucro da lista ficam errados, porque `calcularPedido` usa `itens`. O painel "Itens mais vendidos" (`painel_providers.dart` linha ~92 e ~175, `itensMaisVendidos`) também não recebe itens.
5. A gravação na criação está correta. As colunas do insert (`empresa_id, pedido_id, tipo, produto_id, produto_venda_id, quantidade, custo_unitario, abelinhas_unitarias`) batem com `pedidos_itens` em `0001_schema.sql` (linhas 168-180). A check constraint (produto XOR kit) é respeitada por `_montarPedido`. `PedidoItem.fromJson` usa as mesmas chaves em snake_case. Então os itens são persistidos e só a leitura está errada. O implementador deve confirmar com o teste do passo 2. Se o teste de round-trip falhar no mapeamento, corrigir ali.
6. Existem providers `pedidosProvider` duplicados: `pedidos/application/pedidos_providers.dart` (usado por painel e caixa) e `composicao/application/composicao_providers.dart:76` (autoDispose). Depois de salvar, só o de pedidos é invalidado.

## Decisões

- Corrigir em duas frentes. (a) `listar` passa a trazer os itens em 1 consulta extra (`pedidos_itens` por `empresa_id`, agrupado por `pedido_id`, igual a `ProdutoVendaRepository.listar`). Isso conserta lista e painel de uma vez. (b) O editor, ao editar, carrega o pedido completo com `obterComItens(id)`. Assim o editor não depende de a lista estar completa, e fica protegido de futuras regressões.
- Proteção contra apagar itens: `PedidoEditor` não monta o formulário até o pedido completo estar carregado, e o botão Salvar fica desabilitado enquanto carrega. Com isso, uma edição nunca grava a lista de itens de um pedido não carregado.
- Status: o enum `SituacaoPedido` (`concluido|cancelado|devolvido`, com check no banco) não muda, e não há migration. O protótipo tem Pago/Enviado/Entregue/Devolvido/Cancelado. Rótulos exibidos: concluido=`Pago`, cancelado=`Cancelado`, devolvido=`Devolvido`. `Enviado` e `Entregue` não são persistíveis sem migration e ficam fora. Registrar em `docs/decisoes.md` como **D10** (D8 e D9 já existem; o arquivo também tem um segundo "D7" duplicado, não renumerar). Dizer na decisão que acrescentar Enviado/Entregue exigiria migration alterando o check de `pedidos.situacao`.
- Layout: reaproveitar `PainelCard`, `Ledger`, `Pill`, `CodeChip`, `BotaoPequeno`, `MoneyField`, `PainelLateral` e os helpers responsivos de `lib/core/widgets`, com os tokens de `lib/core/theme/tokens.dart`. Antes de usar cada widget, ler a assinatura. Não mexer em `lib/domain/calculos/pedido.dart`.
- Mudança só em um fluxo acoplado (provider, repositório, um arquivo de editor grande). Não vale decompor em FEATs: o loop atual executa o plano, na ordem abaixo.

## Passos

- [ ] 1. Repositório: `listar` traz itens.
      Em `pedido_repository.dart`, depois de buscar `pedidos`, buscar `pedidos_itens` com `.eq('empresa_id', empresaId)`, agrupar por `pedido_id` num `Map<String, List<PedidoItem>>` e aplicar `copyWith(itens: ...)` em cada pedido (padrão de `produto_venda_repository.dart`). `obterComItens` e `salvar` continuam iguais, mas adicionar na doc de `salvar` que `pedido.itens` precisa estar completo. Manter a ordem `data desc`.
      Files: `lib/data/repositorios/pedido_repository.dart`
      Verify: `flutter analyze` sem erros; teste do passo 2.

- [ ] 2. Testes do repositório e do fluxo de itens (mocktail).
      Criar `test/data/pedido_repository_test.dart`. Olhar como `test/features/caixa_page_test.dart` e `test/features/plataformas_page_test.dart` fazem fake/mock do Supabase e copiar esse padrão. Se o `SupabaseClient` for difícil de mockar, extrair uma interface mínima ou usar fakes dos repositórios, seguindo o que esses testes já fazem. Casos: (a) `listar` devolve cada pedido com seus itens agrupados por `pedido_id`; (b) pedido sem itens vem com lista vazia; (c) `salvar` insere `pedidos_itens` com as colunas certas e `tipo` correto para produto e kit.
      Files: `test/data/pedido_repository_test.dart`
      Verify: `flutter test test/data/pedido_repository_test.dart` passa.

- [ ] 3. Editor carrega o pedido completo ao editar.
      Em `pedidos_providers.dart`, criar `pedidoCompletoProvider = FutureProvider.autoDispose.family<Pedido?, String>` que chama `pedidoRepositoryProvider.obterComItens(id)`. Em `pedidos_page.dart`, `_abrirEditor` passa só o `pedidoId` (ou o pedido, mas o editor busca o completo). Em `pedido_editor.dart`: se `widget.pedido != null`, observar `pedidoCompletoProvider(id)` junto com `dadosEdicaoPedidoProvider`, usando `valueOrNull` para não piscar spinner. Mostrar o estado de carregamento enquanto algum não estiver pronto e erro com "Tentar de novo". Inicializar `_linhas` e os campos uma única vez, quando o pedido completo chegar (mover o preenchimento de `initState` para um método `_aplicarPedido(Pedido)` protegido por flag `_inicializado`). Não sobrescrever o que o usuário já digitou em rebuilds. Itens cujo produto/kit não é achado em `dados` (hoje mostra `?` e é descartado em `_montarPedido`, o que apagaria o item ao salvar) devem ser mantidos: guardar o snapshot original (`PedidoItem`) na `_LinhaEdicao` e, no `_montarPedido`, usar o snapshot quando o produto/kit não estiver disponível. Em edição, preservar também `custoUnitario` e `abelinhasUnitarias` originais para linhas que o usuário não alterou. Remover, aumentar e diminuir quantidade devem funcionar, e uma linha com qtd 0 some. Salvar com os itens atuais.
      Files: `lib/features/pedidos/application/pedidos_providers.dart`, `lib/features/pedidos/presentation/pedidos_page.dart`, `lib/features/pedidos/presentation/pedido_editor.dart`
      Verify: `flutter analyze`; testes do passo 7.

- [ ] 4. Invalidar providers depois de salvar ou excluir.
      Em `PedidosPage._abrirEditor` e `_excluir`, invalidar `pedidosProvider` (pedidos), `composicao.pedidosProvider` (import com prefixo, como em `produto_form_controller.dart`), e o provider do painel (ver `painel_providers.dart` e `painel_page.dart:28` para o nome correto). Caixa depende de `pedidosProvider` de pedidos; confirmar que o provider de caixa é recalculado. Invalidar também `pedidoCompletoProvider`.
      Files: `lib/features/pedidos/presentation/pedidos_page.dart`
      Verify: `flutter analyze`.

- [ ] 5. Painel "Itens mais vendidos" com itens.
      Confirmar em `painel_providers.dart` (~linhas 92 e 175) que `itensMaisVendidos` recebe `pedido.itens` e nomes de produtos/kits. Com o passo 1 deve funcionar sem outra mudança. Se faltar algo, ajustar ali.
      Files: `lib/features/painel/application/painel_providers.dart` (se necessário)
      Verify: `flutter test test/widgets/painel_page_test.dart`. Adicionar um caso em que o pedido tem itens e o ranking aparece.

- [ ] 6. Layout do editor idêntico ao protótipo.
      Reescrever a UI de `pedido_editor.dart` (quebrar em widgets privados ou arquivos em `lib/features/pedidos/presentation/` se passar de ~400 linhas por arquivo; cada classe nova pública ganha `docs/classes/documento_<Classe>.md` no formato de `docs/classes/documento_PainelCard.md`). Conferir cada item com o HTML e os PNGs:
      - Modal largo com título "Novo pedido" (edição: "Editar pedido" ou o título do protótipo, ver HTML ~linha 853), botão de texto "Fechar" no canto superior direito (sem ícone X, com Tooltip+Semantics se houver ícone); rodapé "Cancelar" (OutlinedButton) + "Salvar pedido" (FilledButton).
      - Linha de 4 campos (Data, Cliente / nº do pedido, Plataforma de venda, Status) em uma linha em telas largas, com o rótulo ACIMA do input (não `labelText` flutuante); em tela estreita empilha. Status usa rótulos Pago/Cancelado/Devolvido (D10).
      - Coluna esquerda: painel "Itens do pedido" (vazio: "Adicione os itens que o cliente comprou."; linhas com nome, controle de quantidade, custo unitário, remover com Tooltip+Semantics); painel "Adicionar produto ou produto de venda" com busca "Buscar produto ou kit", linhas com pill verde `kit` ou `CodeChip` cinza para produto, nome + info secundária em muted, custo em negrito à direita, `BotaoPequeno` "Adicionar" (outlined); seção de custos Embalagem (R$), Impressão (R$), Outros (R$) com as dicas "Brinde, fita, frete pago por você" e "Kits já incluem embalagem e impressão no custo, então aqui fica zerado quando o pedido tem só kits."; painel "Venda" com Preço de venda (R$), Itens cobrados com taxa fixa, Líquido recebido (R$), Observação e as dicas exatas do briefing.
      - Coluna direita sticky: "Custo do pedido" (Mercadoria, Embalagem + impressão + outros, caixa cinza "Custo total"); "Abelinhas do pedido" (linha por item, ou "Nenhum item ainda"; "Total de abelinhas"; "Valem com 1🐝 = R$ 10,00"); "Venda" (Preço de venda, "Taxa estimada <Plataforma> (20% + R$ 4,00)", Líquido estimado, "Líquido considerado" com pill `estimado`, Taxa efetiva); caixa cinza "Lucro do pedido" (vermelho se negativo); "Margem sobre a venda: —" quando não há venda. Usar `Ledger` onde couber.
      - Responsivo: largura >= breakpoint largo = 2 colunas (resumo sticky à direita, via `Positioned`/`SingleChildScrollView` com coluna fixa, sem `IntrinsicHeight` em volta de `LayoutBuilder`); estreito = tudo empilhado com resumo abaixo; nunca rolagem horizontal. Usar o helper central de breakpoints em vez de `MediaQuery` espalhado (ver `lib/core/widgets/responsive_list.dart` e `app_shell.dart`). Raiz de página em `Column(mainAxisSize: min, stretch)`.
      - Campos monetários com `MoneyField` (ler a assinatura). Preencher o texto dos controllers sem recriar `TextFormField` a cada rebuild (hoje `_campoMoeda` usa `initialValue`, que não atualiza quando o auto-envio muda; usar controllers).
      - Cálculo continua em `calcularPedido`. Taxa estimada com nome da plataforma e fórmula vindos da faixa aplicável (ler `FaixaTaxa` e a tela de Composição, que já mostra "(20% + R$ 4,00)").
      Files: `lib/features/pedidos/presentation/pedido_editor.dart` (+ novos widgets, se quebrar), `docs/classes/documento_*.md`, `docs/decisoes.md` (D10), `docs/classes/documento_features.md` (atualizar a seção de Pedidos)
      Verify: `flutter analyze`; `flutter test`; abrir o editor em largura 1280 e 390 nos testes de widget sem overflow.

- [ ] 7. Testes de widget do editor.
      Criar `test/widgets/pedido_editor_test.dart` (padrão de `test/widgets/composicao_page_test.dart`, com overrides de providers e mocktail). Casos: (a) abrir um pedido existente mostra nome e quantidade dos itens (com `pedidoCompletoProvider` sobrescrito, e também com o pedido da lista sem itens para provar que o editor busca o completo); (b) enquanto carrega, aparece o indicador e Salvar fica desabilitado; (c) remover um item, mudar a quantidade e adicionar um novo, salvar, e o repositório mock recebe `salvar` com os itens esperados (`captureAny`); (d) salvar sem alterar mantém os itens e os snapshots originais; (e) item cujo produto não existe mais é preservado ao salvar; (f) textos obrigatórios do layout ("Itens do pedido", "Adicionar produto ou produto de venda", "Custo do pedido", "Abelinhas do pedido", "Líquido considerado", "Fechar", "Cancelar", "Salvar pedido"); (g) larguras 1280 e 390 sem exceção de overflow.
      Files: `test/widgets/pedido_editor_test.dart`
      Verify: `flutter test test/widgets/pedido_editor_test.dart` passa.

- [ ] 8. Verificação final.
      Rodar `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs` (só se mexer em freezed; não deve ser necessário), `flutter analyze`, `flutter test` (inclui `test/domain/calculos/pedido_test.dart` sem alteração). Conferir `git diff` sem mudanças em `lib/domain/calculos/pedido.dart`. Escrever `.agents/tasks/pedido-editor-fix/review.json` não é papel do implementador; o revisor escreve por último com `{"verdict":"APPROVED"|"CHANGES_REQUESTED",findings,reviewDoc}`.
      Verify: `flutter analyze && flutter test` verdes.

## Notas

- Não é necessária migration de banco.
- Limite do que foi verificado neste planejamento: li o repositório, o provider, a página de pedidos e a maior parte do editor (até `_SemPlataformas`), o schema e `PedidoItem`. Não abri ainda os PNGs nem o HTML do editor em detalhe nem as assinaturas dos widgets de `core/widgets`; o implementador deve fazer isso no passo 6.
