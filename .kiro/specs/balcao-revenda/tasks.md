# Plano de implementação — Balcão Revenda

Execute em ordem. Cada tarefa referencia requisitos (R#) e seções do design (§#). Toda tarefa de cálculo inclui testes com os vetores do design §6 antes de seguir.

- [ ] 1. Base do projeto
  - [ ] 1.1 Criar app Flutter `balcao_revenda` com plataformas macOS, Windows, Web e Android; adicionar dependências de `tech.md`; configurar `flutter_lints`/`very_good_analysis`, `build_runner`, locale `pt_BR` (`intl`, `flutter_localizations`).
  - [ ] 1.2 `core/config`: ler `SUPABASE_URL` e `SUPABASE_ANON_KEY` de `--dart-define`; inicializar `Supabase` em `main.dart`.
  - [ ] 1.3 `core/theme`: tokens de cor (claro/escuro), tipografia Plus Jakarta Sans, raios e espaçamentos (§7.1–7.3); `ThemeData` claro e escuro; provider de tema (Claro/Escuro/Auto) salvo com `shared_preferences`. _R2.4_
  - [ ] 1.4 `core/format`: moeda `R$ 1.234,56`, percentual `10,2%`, data `dd/MM/yyyy`, abelinhas `1,5 🐝`, parser de número com vírgula. Testes.
  - [ ] 1.5 `core/format/padrao_escrita.dart`: `titulo`, `frase`, `maius` (§8) com testes dos exemplos. _R12_

- [ ] 2. Supabase
  - [ ] 2.1 Aplicar `supabase/migrations/0001_schema.sql`; conferir RLS com dois usuários de teste (um não vê dados do outro). _R1.5_
  - [ ] 2.2 Entidades `freezed` em `domain/entidades` espelhando as tabelas (§2–3), com `fromJson/toJson` em snake_case e `Decimal` para dinheiro.
  - [ ] 2.3 Repositórios em `data/repositorios` (CRUD por agregado; produto de venda salva itens e preços por plataforma numa operação; pedido salva itens com snapshot; saque salva rateio).

- [ ] 3. Domínio — cálculos puros (`domain/calculos`) com testes (§6)
  - [ ] 3.1 `taxas.dart`: `faixa`, `taxa`, `precoMinimo`, `precoParaMargem` (§6.1–6.2).
  - [ ] 3.2 `produto_venda.dart`: `calcularKit(kit, produtos, plataforma, pedidos)` retornando todos os campos do §6.3; vetores do Batom/Kit 5 Sachês/Kit Maquiagem.
  - [ ] 3.3 `pedido.dart`: `calcularPedido`, preço automático, regra de embalagem/impressão em pedidos só com kits (§6.4); vetores DALILA/THAIS/Batom ML.
  - [ ] 3.4 `abelinhas.dart`: regra, valor efetivo, análise por faixa e geral, aviso de impacto (§6.6–6.7); vetores com v = 10 e v = 8.
  - [ ] 3.5 `caixa.dart`: rateio, entradas, saídas, saldos (§6.8); `painel.dart`: KPIs e pontos de atenção (§6.5, §6.9).

- [ ] 4. Shell e navegação
  - [ ] 4.1 `go_router` com rotas do §4 e guarda de autenticação/empresa.
  - [ ] 4.2 `AppShell`: menu lateral com grupos e destaque (R2.2), contadores, seletor de tema no rodapé; barra superior + gaveta em < 760 px (§7.4).
  - [ ] 4.3 Componentes compartilhados (§5): `PageHeader`, `KpiCard/KpiRow`, `Pill`, `PlatformPill`, `CodeChip`, `Ledger`, `IconAction`, `ConfirmDeleteButton`, `MoneyField`, `TextCaseField`, painel lateral de edição.
  - [ ] 4.4 `ResponsiveList<T>`: tabela ↔ cartões por largura disponível (LayoutBuilder), coluna "Ações", sem overflow horizontal; widget tests em 1440/1000/400 px. _R13_

- [ ] 5. Autenticação e onboarding (R1)
  - [ ] 5.1 Login, criar conta, recuperar senha.
  - [ ] 5.2 Onboarding: nome da empresa → RPC `criar_empresa`; escolher "Importar dados da planilha" ou "Começar vazio".
  - [ ] 5.3 Importador de `assets/seed/dados-iniciais.json` (§9): reaproveitar plataformas e destinos criados pela RPC casando por nome; resolver referências; teste de contagens.

- [ ] 6. Produtos (R3)
  - [ ] 6.1 Lista com busca, filtro de categoria, contador, colunas do R3.8, ações.
  - [ ] 6.2 Formulário (painel lateral) com normalização de texto, validação de código único, quadro de abelinhas com ✎ e aviso de impacto (§6.7).
  - [ ] 6.3 Exclusão com verificação de uso em kits.

- [ ] 7. Plataformas e taxas (R6) — cartões por plataforma, faixas editáveis, simulação, bloqueio de exclusão em uso.

- [ ] 8. Compras de insumos (R7) e Investimento (R8) — listas responsivas, formulários, KPIs.

- [ ] 9. Composição de custo (R4)
  - [ ] 9.1 Lista com uma coluna por plataforma.
  - [ ] 9.2 Editor: itens (busca, quantidade, abelinhas), custos adicionais (embalagem por insumo ou manual), preço base e metas, resumo fixo, tabela "Resultado por plataforma" com overrides, sugerido clicável; recalcular ao digitar sem perder o foco.
  - [ ] 9.3 Duplicar e excluir.

- [ ] 10. Pedidos (R5)
  - [ ] 10.1 Lista (colunas Pedido/Itens/Venda/Líquido/Lucro/Ações), busca e filtro por plataforma.
  - [ ] 10.2 Editor: itens (produtos e kits), preço automático por plataforma, custos do envio automáticos, líquido informado, resumo com abelinhas e aviso de diferença; snapshot ao salvar; "Atualizar custos pelo cadastro atual".

- [ ] 11. Regra de abelinhas (R9) — campo de valor com recálculo ao digitar, KPIs com explicação do ROI, lista de faixas responsiva e editável, quadro "quando dá lucro".

- [ ] 12. Caixa e saques (R10) — KPIs, cartões por destino, editor de destinos e "por plataforma" com mesma altura, extrato; formulários de saque (rateio ao vivo) e retirada.

- [ ] 13. Painel (R11) — período, KPIs, vendas por plataforma, pontos de atenção, caixa por destino, mais vendidos.

- [ ] 14. Configurações (R14, R12) — padrões de custo, valor da abelinha, exportar/importar JSON, quadro "Padrão de escrita", sair.

- [ ] 15. Acabamento
  - [ ] 15.1 Estados de carregamento, vazio e erro em todas as telas (§10).
  - [ ] 15.2 Revisar todas as telas nos breakpoints do §7.4, temas claro e escuro, contra `docs/telas` e o protótipo.
  - [ ] 15.3 `flutter test` verde; build macOS, Windows, Web e Android.
