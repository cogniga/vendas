# Implementation Plan — Grupo CONFIGURAÇÃO (Balcão Revenda)

Escopo: as três telas do grupo CONFIGURAÇÃO — PLATAFORMAS E TAXAS (R6), REGRA DE ABELINHAS (R9) e DADOS E CONFIGURAÇÕES (R14+R12). Trabalhar direto no repositório, branch `main`, SEM push.

## Estado verificado na exploração (base verde)

- `flutter analyze` → **No issues found**. `flutter test` → **54 testes passando**. Esta é a linha de base a preservar.
- **REGRA DE ABELINHAS (R9) JÁ ESTÁ IMPLEMENTADA** — não é placeholder. `lib/features/abelinhas/presentation/abelinhas_page.dart` + `application/abelinhas_controller.dart` + `application/abelinhas_providers.dart` existem e cobrem: campo "Valor de 1 🐝" com debounce 300ms (via `AbelinhasController.digitarValor`), KPIs via `analiseGeral`, lista de faixas editável (`ResponsiveList` + `analisePorFaixa`), adicionar/remover faixa, quadro "Quando dá lucro e quando dá prejuízo", botão Salvar que persiste via `faixaAbelinhaRepository.substituir` + `configuracoesRepository.atualizar`. Portanto R9 é tratada como **verificação/ajuste fino**, não reescrita (ver passos 7–8). Não reescrever do zero.
- **PLATAFORMAS (R6)** e **CONFIGURAÇÕES (R14+R12)** são placeholders ("Em construção") — implementação real.

## Decisões de design (com justificativa)

1. **Export/Import JSON sem dependência nova.** O protótipo (`V.dados`, docs/prototipo/balcao-revenda.html linha ~689) faz exatamente isto: botão "Copiar dados (JSON)" (clipboard) + `<textarea>` para colar e "Importar". Adoto a mesma abordagem: **Exportar** monta o JSON da empresa e copia para a área de transferência (`Clipboard.setData` de `package:flutter/services.dart`, já disponível) e também mostra num campo copiável; **Importar** lê o JSON colado num `TextField` multiline e popula via repositórios. Justificativa: zero dependência nova (nada de `file_picker`/`share_plus`), funciona em desktop/web/android, e é fiel ao protótipo. `pubspec.yaml` NÃO muda.
2. **Formato do JSON de export = o mesmo que `ImportadorSeed.importarDados` consome.** Assim o import reaproveita `ImportadorSeed.importarDados(empresaId, mapa)` (chaves `configuracoes`, `plataformas`, `destinos`, `faixas_abelinha`, `produtos`, `produtos_venda`, `compras_insumo`, `investimentos`, `pedidos`, `saques`). O exportador monta esse mapa a partir dos repositórios. Decisão: criar um `ExportadorDados` (serviço) em `lib/features/configuracoes/application/` que lê os repositórios e produz o mapa; o import decodifica e chama `importarDados`. Isso evita duplicar a lógica de importação.
3. **Plataformas salvam ao editar (autosave com debounce ~500ms), como no protótipo** — não há botão "Salvar" por cartão no protótipo (ele persiste em `data-plat`/`data-tier`/`data-cfg` ao digitar). Uso um controller por tela que agrega edições e grava: nome → `renomear`; cor+obs → `atualizarAparencia`; faixas → `substituirFaixas`. Debounce evita escrever a cada tecla.
4. **Nova plataforma cria com 1 faixa padrão** (mínimo 1 faixa, R6.2). Ao criar, insere a plataforma (`criar`) e já grava uma faixa inicial sem limite (`precoAte: null`, fixa 0, pct 0) via `substituirFaixas`, para a tela nunca mostrar plataforma com zero faixas.
5. **Excluir plataforma**: capturar `ErroRepositorio` de `excluir(id)` (já bloqueia quando usada em pedidos/saques) e mostrar `mensagem` num SnackBar/diálogo. Não bloquear excluir a última? R6.1 diz "mínimo 1" — impedir excluir quando só resta 1 plataforma, com aviso.
6. **Providers na camada `application/`**, nada de chamada Supabase dentro de widget (convenção do projeto, igual a produtos/composição). Reuso de `empresaAtualProvider` e dos repositórios via seus providers.

## Invariante de layout (CRÍTICO — aplica-se a TODAS as páginas)

O `AppShell` (`lib/core/widgets/app_shell.dart` → `_Corpo`) já envolve o child de cada rota num `SingleChildScrollView`. Logo a RAIZ de cada `*_page.dart` DEVE ser `Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...])`. NUNCA `ListView`, NUNCA `Column` com `mainAxisSize.max`, NUNCA `Expanded`/`Spacer` na raiz (causam "RenderBox was not laid out"/"unbounded height"/overflow). Grades de cartões usam `Wrap`/`LayoutBuilder` (sem rolagem horizontal), nunca `GridView` com altura infinita. As páginas já prontas (produtos, composição, abelinhas) seguem isso — espelhar.

## Estados vazio/carregando/erro (CRÍTICO — nenhuma página pode crashar)

- Sempre consumir providers com `.when(loading:, error:, data:)` ou `valueOrNull ?? fallback`. Nunca `.last`/`.first` em lista possivelmente vazia (as funções `faixa()`/`taxa()` já toleram lista vazia — não reintroduzir `.last`).
- Empresa `null` (ainda carregando/sem empresa): os providers já retornam `[]`/`null`; a UI mostra carregando ou vazio, nunca crash.
- Erro de rede: bloco de erro com "Tentar de novo" que faz `ref.invalidate(...)` (padrão de `abelinhas_page.dart`/`composicao_page.dart`).
- Mensagens pt_BR; erros de repositório vêm como `ErroRepositorio` (strip do prefixo `ErroRepositorio: ` para exibir só a `mensagem`).

## Componentes/cálculos/repos a reutilizar (assinaturas confirmadas na exploração)

- `PageHeader(title:, subtitle:, actions: <Widget>[])`.
- `KpiCard(label:, value:, sub:)` e `KpiRow(cartoes: <KpiCard>[], larguraMinima: 170)`.
- `Pill(String, {TomPill tom})` — `TomPill.{neutro,bom,atencao,ruim,destaque}`. `PlatformPill(nome:, cor:)`.
- `IconAction(icon:, tooltip:, onPressed:, danger:false)`. `ConfirmDeleteButton(onConfirm:, tooltip:)`.
- `ResponsiveList<T>(itens:, colunas: <ColunaLista<T>>[], acoes:, limiarCartao: 780)`; `ColunaLista<T>(label:, builder:, alinhamento:, principal:)`.
- `MoneyField(onChanged:(Decimal?), label:, initial:, controller:, prefix:)` — usa `Formatos.parseDecimal`. `TextCaseField(caso: CasoTexto.{titulo,frase,maius}, controller:, label:, initial:, onChanged:)`.
- `Ledger(linhas: <LinhaLedger>[], total:)` + `LinhaLedger(rotulo, valor, {destaque})`.
- Tokens: `context.cores` (CoresApp: surface, surface2, ink, muted, line, accent, accentSoft, good, bad...); `Raios.{controle=8,cartao=14,pill=6}`; `Espacos.{base=4,g8,g12,g16,g20,paddingPainel,paddingPainelCelular}`.
- Formatos: `moedaDecimal`, `moeda`, `percentualFracao`, `percentual`, `abelinhas`, `numero`, `parseDecimal`. `PadraoEscrita.{titulo,frase,maius}`.
- Cálculo taxa (plataformas): `taxa(List<FaixaTaxa> faixas, Decimal preco, {int itensTaxaFixa=1}) -> Decimal` em `lib/domain/calculos/taxas.dart`. Simulação: `liquido = preco - taxa(faixas, preco)` para os 5 preços 19.99/59.90/89.90/149.90/249.90. `faixa()`/`taxa()` toleram lista vazia (faixa neutra).
- Cálculo abelinhas (já usados pela página R9 existente): `analiseGeral(produtos, faixas, v) -> AnaliseGeralAbelinhas{roiMedioGeral, comLucro, comPrejuizo, abelinhaMinimaSemPrejuizo}`; `analisePorFaixa(produtos, faixas, v) -> List<AnaliseFaixa>{custoAte, abelinhas, limiteInferior, produtos(int), venda, roiMedio, roiNoLimite, abelinhaMinima, situacao}`; `roiProduto(produto, v, faixas)`.
- Repositórios (providers; já filtram `empresa_id`):
  - `plataformaRepositoryProvider`: `listarComFaixas(empresaId) -> Map<Plataforma,List<FaixaTaxa>>`, `criar(empresaId, nome) -> Plataforma`, `renomear(id, nome)`, `mudarCor(id, cor)`, `atualizarAparencia(id, cor, obs)`, `substituirFaixas(plataformaId, empresaId, List<FaixaTaxa>)`, `excluir(id)` (lança `ErroRepositorio` se usada).
  - `faixaAbelinhaRepositoryProvider`: `listar(empresaId)`, `substituir(empresaId, List<FaixaAbelinha>)`.
  - `configuracoesRepositoryProvider`: `obter(empresaId) -> Configuracoes`, `atualizar(Configuracoes)`.
  - `produtoRepositoryProvider.listar(empresaId)` (p/ análises de abelinhas).
  - `empresaAtualProvider`: `FutureProvider<Empresa?>`.
  - `importadorSeedProvider` (ImportadorSeed): `importar(empresaId)` (seed do asset) e `importarDados(empresaId, Map)` (JSON colado).
  - `temaProvider`: `StateNotifierProvider<TemaController, ThemeMode>` em `lib/core/theme/tema_provider.dart`; `ref.read(temaProvider.notifier).definir(ThemeMode.{light,dark,system})`.
  - `authControllerProvider` em `lib/features/auth/application/auth_controller.dart`; `ref.read(authControllerProvider.notifier).sair()`.
- Entidades: `Plataforma{id, empresaId, nome, cor(default #9A8FD4), obs, ordem}`; `FaixaTaxa{id, empresaId, plataformaId, taxaFixa:Decimal, taxaPercentual:Decimal, precoAte:Decimal?}` (freezed `copyWith`); `FaixaAbelinha{id, empresaId, custoAte:Decimal, abelinhas:Decimal}`; `Configuracoes{empresaId, embalagemPadrao:Decimal, impressaoPadrao:Decimal, valorAbelinha:Decimal}` (freezed `copyWith`).

## Comandos de verificação (rodar a cada passo que muda código)

- Build/lint: `flutter analyze` → deve terminar com **No issues found!**.
- Testes: `flutter test` → todos passando (base = 54; novos testes somam a isso).
- Geração (se criar entidade/provider com `@riverpod`/freezed — provavelmente NÃO necessário aqui): `dart run build_runner build --delete-conflicting-outputs`. As novas classes serão providers `StateNotifier`/`FutureProvider` escritos à mão (padrão do projeto), sem codegen.
- Execução manual (fumaça), quando possível: `flutter run -d macos --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...` e abrir cada tela do grupo Configuração; confirmar que não há overflow nem crash em empresa/listas vazias. Itens marcados "verificar em runtime" devem ser confirmados aqui.

---

# Passos (ordenados por dependência)

## A. PLATAFORMAS E TAXAS (R6)

- [ ] 1. Criar os providers da feature Plataformas na camada application.
      Criar `plataformasProvider` (FutureProvider.autoDispose<Map<Plataforma,List<FaixaTaxa>>>) lendo `empresaAtualProvider` e chamando `plataformaRepositoryProvider.listarComFaixas` (mesma forma do `plataformasComFaixasProvider` de composição — pode-se reusar aquele import em vez de duplicar; se duplicar, documentar o porquê). Retornar `{}` quando empresa null.
      Files: lib/features/plataformas/application/plataformas_providers.dart
      Verify: `flutter analyze` limpo (arquivo compila, sem uso ainda).

- [ ] 2. Criar o controller de edição de Plataformas (autosave com debounce).
      `PlataformasController extends StateNotifier<EstadoPlataformas>` (ou um controller por operação). Estado: mapa plataforma→faixas em memória + flags de salvando/erro. Métodos: `criarPlataforma()` (cria com nome padrão "Nova plataforma" + 1 faixa sem limite fixa 0/pct 0, depois invalida o provider), `renomear(id, nome)` (debounce → `renomear`), `mudarAparencia(id, cor, obs)` (debounce → `atualizarAparencia`), `alterarFaixa(platId, indice, campo, valor)` / `adicionarFaixa(platId)` / `removerFaixa(platId, indice)` (mantém mínimo 1; debounce → `substituirFaixas(platId, empresaId, faixas)`), `excluir(id)` (bloqueia se só resta 1 → mensagem; captura `ErroRepositorio` e expõe `erro`). Normalizar nome com `PadraoEscrita.titulo` ao persistir (R12 — nome de plataforma é "Nome"→Título). Invalida `plataformasProvider`, `plataformasComFaixasProvider` (composição) ao concluir mudanças estruturais.
      Files: lib/features/plataformas/application/plataformas_controller.dart
      Verify: `flutter analyze` limpo.

- [ ] 3. Substituir a página de Plataformas pela implementação real (grid de cartões 2 col./1 col.).
      Raiz = `Column(mainAxisSize.min, crossAxisAlignment.stretch)`. `PageHeader(title:'Plataformas e taxas', subtitle: texto do protótipo sobre fixo+percentual por faixa, actions: [FilledButton.icon "Nova plataforma" → controller.criarPlataforma])`. Consumir `plataformasProvider.when(...)` com loading/erro/vazio. Conteúdo: grade responsiva via `LayoutBuilder` — 2 colunas quando `maxWidth >= ~900`, senão 1 (usar `Wrap` com largura calculada, NÃO GridView). Cada cartão = `_CartaoPlataforma`.
      Files: lib/features/plataformas/presentation/plataformas_page.dart
      Verify: `flutter analyze` limpo; abrir a tela no app (runtime) sem overflow.

- [ ] 4. Implementar o widget `_CartaoPlataforma` (cabeçalho, nome, cor, faixas editáveis, obs, Ledger de simulação).
      Container estilo cartão (surface, Raios.cartao, border line). Cabeçalho: um "dot" colorido (quadrado/círculo com `plataforma.cor`) + nome + `ConfirmDeleteButton`(onConfirm→controller.excluir). Campos: `TextField` Nome (ou `TextCaseField(caso: titulo)`) com onChanged→controller.renomear; seletor de Cor (ver passo 5). Lista de faixas: para cada faixa uma linha com 3 campos numéricos — "Preço até (R$)" (vazio = sem limite → `precoAte=null`), "Fixo (R$)", "Percentual" — + `IconAction`/`ConfirmDeleteButton` para remover (desabilitar remover quando só há 1 faixa). Botão "Adicionar faixa". Observação: `TextCaseField(caso: frase)` (obs é descrição). `Ledger` de simulação: para 19.99/59.90/89.90/149.90/249.90 uma `LinhaLedger('Venda de R$ X', 'taxa Y · líquido Z')` com `taxa(faixas, preco)` e `preco - taxa(...)` (usar faixas EM EDIÇÃO do estado, para refletir ao vivo). Campos numéricos: `TextField` com `keyboardType decimal` + sincronização sem roubar foco (padrão `_CampoDecimal` de abelinhas_page.dart).
      Files: lib/features/plataformas/presentation/plataformas_page.dart (mesmo arquivo; ou extrair widgets em lib/features/plataformas/presentation/cartao_plataforma.dart se ficar grande)
      Verify: `flutter analyze` limpo; runtime: editar fixo/percentual recalcula o Ledger ao vivo; preço-até vazio = sem limite.

- [ ] 5. Seletor de cor da plataforma sem dependência nova.
      O protótipo usa `<input type=color>`. Em Flutter sem pacote: oferecer uma paleta fixa de ~8 cores (hex) em chips selecionáveis (um `Wrap` de quadrados coloridos com borda quando selecionado) OU um `showDialog` com a paleta. A cor escolhida chama `controller.mudarAparencia(id, corHex, obs)`. Decisão: paleta fixa de chips (simples, acessível com `Tooltip`/`Semantics` por ser toque em cor). Garantir contraste e `Semantics(label: 'Cor X')`.
      Files: lib/features/plataformas/presentation/plataformas_page.dart (widget `_SeletorCor`)
      Verify: `flutter analyze` limpo; runtime: trocar cor atualiza o dot e persiste.

- [ ] 6. Teste de widget da página de Plataformas (estado vazio e simulação).
      Teste com `ProviderScope` sobrescrevendo `plataformasProvider` com um mapa de 1 plataforma + faixas conhecidas; verificar que os 5 valores de simulação aparecem (ou ao menos que a tela renderiza sem exceção em largura larga e estreita) e que com mapa vazio mostra o estado vazio sem crash. Seguir o padrão de `test/widgets/responsive_list_test.dart`/`app_shell_test.dart`.
      Files: test/features/plataformas_page_test.dart
      Verify: `flutter test test/features/plataformas_page_test.dart` → passa; `flutter test` total continua verde.

## B. REGRA DE ABELINHAS (R9) — já implementada: verificar e ajustar

- [ ] 7. Auditar a página/controle de Abelinhas contra o protótipo (V.abelinhas) e R9, SEM reescrever.
      Confirmar presença de: campo "Valor de 1 🐝 (R$)" com debounce 300ms e aceitação de vírgula (OK no controller), KPIs (ROI médio com "Como ler" + exemplo real, lucro, prejuízo, 🐝 mínima), lista responsiva editável (custo até/abelinhas/venda/ROI médio/ROI no limite/🐝 mínima p/ lucro/situação em Pill/nº produtos), adicionar/remover faixa, quadro "Quando dá lucro e quando dá prejuízo". Itens a VERIFICAR e, se faltarem, adicionar como ajuste mínimo (não reescrita): (a) o KPI "ROI médio" trazer o bloco "Como ler" + exemplo — hoje o `sub` do KpiCard traz só o exemplo curto; o protótipo tem um texto "Como ler" mais rico. Avaliar se R9.4 exige o texto "Como ler" visível; se sim, acrescentar um pequeno bloco abaixo dos KPIs (um `_ComoLer` card) reutilizando `roiProduto`/`analiseGeral`. (b) Rótulo das faixas "R$ 5,01 a R$ 8,00" (confirmar que `_CelulaFaixa` usa `limiteInferior` corretamente — já usa). Marcar qualquer divergência como ajuste pontual.
      Files: (somente leitura nesta etapa) lib/features/abelinhas/presentation/abelinhas_page.dart, lib/features/abelinhas/application/abelinhas_controller.dart
      Verify: comparar visualmente com docs/telas/13-regra-abelinhas.png e V.abelinhas; `flutter test test/domain/calculos/abelinhas_test.dart` continua verde (não alterar os cálculos).

- [ ] 8. Aplicar ajustes mínimos identificados no passo 7 (se houver), preservando os cálculos e os testes.
      Apenas na camada de apresentação (`abelinhas_page.dart`) ou, se necessário, no controller — NUNCA em `lib/domain/calculos/abelinhas.dart` (os vetores de teste dependem dele). Ex.: adicionar bloco "Como ler" abaixo do KpiRow; garantir que digitar "1,5" no campo de valor recalcula (vírgula). Não introduzir `.last` em listas vazias.
      Files: lib/features/abelinhas/presentation/abelinhas_page.dart (e/ou abelinhas_controller.dart se o ajuste for de estado)
      Verify: `flutter analyze` limpo; `flutter test` total verde; runtime: digitar valor com vírgula recalcula KPIs/faixas com ~300ms de atraso.

## C. DADOS E CONFIGURAÇÕES (R14 + R12)

- [ ] 9. Criar o serviço Exportador e os providers da feature Configurações.
      `ExportadorDados` em application: recebe os repositórios (configuracoes, plataforma, destino, faixaAbelinha, produto, produtoVenda, compraInsumo, investimento, pedido, saque) e monta um `Map<String,dynamic>` no MESMO formato que `ImportadorSeed.importarDados` consome (chaves `configuracoes`, `plataformas` com `faixas`, `destinos`, `faixas_abelinha`, `produtos`, `produtos_venda`, `compras_insumo`, `investimentos`, `pedidos`, `saques`); serializar Decimais como String e datas como ISO `yyyy-MM-dd`. Provider `exportadorDadosProvider`. Também criar `configuracoesDaEmpresaProvider` (reutilizar o `configuracoesProvider` de composição por import, ou criar um local) e um `empresaVaziaProvider` (FutureProvider<bool>: true quando produtos/pedidos/etc. estão vazios — base para mostrar "Importar dados da planilha"). Confirmar em runtime as chaves exatas exigidas pelo importador (o importador lê `dados['plataformas']`, `['faixas']`, etc.) — marcar "verificar durante implementação" e casar 1:1 com `importador_seed.dart`.
      Files: lib/features/configuracoes/application/exportador_dados.dart, lib/features/configuracoes/application/configuracoes_providers.dart
      Verify: `flutter analyze` limpo.

- [ ] 10. Criar o controller de Configurações (padrões de custo, valor da abelinha, export/import, seed, sair).
      `ConfiguracoesController`: `salvarPadroes(embalagem, impressao)` e `salvarValorAbelinha(v)` → `configuracoesRepository.atualizar(config.copyWith(...))` e invalida `configuracoesProvider`/`dadosAbelinhasProvider`; `exportarJson() -> String` (via `ExportadorDados` + `json.encode`); `importarJson(String) -> Future<bool>` (`json.decode` → `importadorSeedProvider.importarDados(empresaId, mapa)`; captura erro e expõe mensagem; invalida os providers afetados); `restaurarSeed()` (`importadorSeedProvider.importar(empresaId)`, só quando empresa vazia). Expor estado salvando/erro/sucesso.
      Files: lib/features/configuracoes/application/configuracoes_controller.dart
      Verify: `flutter analyze` limpo.

- [ ] 11. Substituir a página de Configurações pela implementação real.
      Raiz = `Column(mainAxisSize.min, crossAxisAlignment.stretch)`. `PageHeader(title:'Dados e configurações', subtitle:...)`. Consumir `configuracoesProvider.when(...)` com loading/erro/vazio. Seções (cartões `panel`), em grade responsiva (`LayoutBuilder` 2→1 coluna, `Wrap`):
      (a) **Padrões de custo**: `MoneyField` Embalagem padrão e Impressão padrão (initial = config), onChanged→controller.salvarPadroes (debounce).
      (b) **Valor da abelinha**: `MoneyField`/`TextField` decimal (aceita vírgula) persistindo `valorAbelinha` (compartilha com R9; ao salvar, invalidar `dadosAbelinhasProvider`).
      (c) **Tema**: três opções Claro/Escuro/Auto via `ref.watch(temaProvider)` + `ref.read(temaProvider.notifier).definir(ThemeMode.{light,dark,system})` (botões com Tooltip+Semantics, como `_SeletorTema` do AppShell — pode reusar visual).
      (d) **Backup**: botão "Exportar dados (JSON)" → `Clipboard.setData(ClipboardData(text: controller.exportarJson()))` + preencher um `TextField` multiline copiável + SnackBar "Copiado"; botão "Importar dados (JSON)" → lê o texto do `TextField` e chama `controller.importarJson`, com diálogo de confirmação (sobrescreve/acrescenta dados) e SnackBar de resultado.
      (e) **Importar dados da planilha** (seed): só visível quando `empresaVaziaProvider == true`; botão com confirmação → `controller.restaurarSeed()`.
      (f) **Padrão de escrita** (R12.2): `Ledger`/quadro com as 3 regras — Nomes→Título ("Lápis de Olhos 2 em 1"), Códigos→MAIÚSCULO ("KT01-DALILA"), Descrições→Frase ("Compras de produtos") — + a nota sobre conectivos/siglas (texto do protótipo e de design §8/`PadraoEscrita`).
      (g) **Sair**: botão → `ref.read(authControllerProvider.notifier).sair()` (o `redirect` do go_router leva ao login; com sessão anônima/local, confirmar comportamento em runtime).
      Files: lib/features/configuracoes/presentation/configuracoes_page.dart
      Verify: `flutter analyze` limpo; runtime: alterar tema reflete na hora; exportar copia JSON; importar um JSON exportado repovoa; "Importar da planilha" some quando há dados.

- [ ] 12. Teste de widget da página de Configurações (quadro de padrão de escrita + seletor de tema).
      Com `ProviderScope` (override de `configuracoesProvider` com um `Configuracoes` fixo e `empresaVaziaProvider` true/false), verificar: renderiza sem exceção; mostra as três linhas do "Padrão de escrita"; o botão "Importar dados da planilha" aparece só quando empresa vazia. Não exercitar Supabase real.
      Files: test/features/configuracoes_page_test.dart
      Verify: `flutter test test/features/configuracoes_page_test.dart` → passa; `flutter test` total verde.

## D. Fechamento

- [ ] 13. Verificação integrada final.
      Rodar `flutter analyze` (No issues found) e `flutter test` (todos verdes, ≥ 54 + os novos). Abrir as três telas no app (`flutter run -d macos --dart-define=...`) e confirmar, em janela larga e estreita: sem overflow, sem crash com empresa/listas vazias, autosave de plataformas funcionando, exclusão bloqueada mostra mensagem, export/import JSON ida-e-volta, tema muda ao vivo. Remover quaisquer arquivos temporários de verificação.
      Files: (nenhum novo)
      Verify: `flutter analyze` + `flutter test` verdes; checagem manual das 3 telas OK.

## Notas de verificação em runtime (o coder DEVE confirmar)

- Formato exato do JSON consumido por `ImportadorSeed.importarDados` (casar chaves 1:1 — ver `_importarPlataformas`/`_importarProdutos`/etc.). O exportador deve produzir exatamente essas chaves.
- Comportamento do botão "Sair" com sessão anônima/local: confirmar para onde o `redirect` leva e se é o esperado (pode ser que com sessão local o fluxo volte ao login `adm/adm`).
- `plataformaRepository.criar` cria a plataforma SEM faixa — por isso o passo 2 grava a faixa inicial logo após criar (verificar que não há faixa default do backend para não duplicar).
- Debounce de autosave: escolher ~500ms para plataformas (editar número) e manter 300ms no campo de valor da abelinha (já existente).
