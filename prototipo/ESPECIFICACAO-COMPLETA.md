# Balcão Revenda — especificação completa (arquivo único)

Este arquivo junta todos os documentos do pacote para leitura ou para colar no chat do Kiro. A versão em pastas (`.kiro/…`) é a recomendada.



---

<!-- arquivo: README.md -->

# Balcão Revenda — pacote de especificação para o Kiro

Sistema de gestão de revenda online (produtos, composição de custo, pedidos por plataforma, insumos, investimento, caixa e regra de abelinhas) a ser desenvolvido em **Flutter** (macOS, Windows, Web e Android) com **Supabase**.

## Como usar no Kiro
1. Crie uma pasta vazia para o projeto e copie **todo o conteúdo deste pacote** para ela (inclusive a pasta oculta `.kiro`).
2. Abra a pasta no Kiro. Ele lê automaticamente:
   - `.kiro/steering/` — contexto permanente (produto, stack, estrutura).
   - `.kiro/specs/balcao-revenda/` — `requirements.md`, `design.md` e `tasks.md`.
3. No painel **Specs**, abra `balcao-revenda` e execute as tarefas de `tasks.md` em ordem (comece pela 1.1). Revise e aprove cada etapa.
4. Antes da tarefa 2.1, crie um projeto no Supabase e rode `supabase/migrations/0001_schema.sql` (SQL Editor ou `supabase db push`).
5. Rode o app com:
   ```bash
   flutter run -d macos --dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co --dart-define=SUPABASE_ANON_KEY=SUA_CHAVE
   ```

## Conteúdo
| Caminho | O que é |
|---|---|
| `.kiro/steering/product.md` | Visão do produto e princípios |
| `.kiro/steering/tech.md` | Stack, regras técnicas e comandos |
| `.kiro/steering/structure.md` | Estrutura de pastas e convenções |
| `.kiro/specs/balcao-revenda/requirements.md` | 14 requisitos com critérios de aceite (EARS) |
| `.kiro/specs/balcao-revenda/design.md` | Arquitetura, modelo de dados, **fórmulas com vetores de teste**, tokens de UI, breakpoints, padrão de escrita |
| `.kiro/specs/balcao-revenda/tasks.md` | Plano de implementação em 15 etapas |
| `supabase/migrations/0001_schema.sql` | Tabelas, RLS por empresa e RPC `criar_empresa` |
| `assets/seed/dados-iniciais.json` | Dados da planilha (99 produtos, 3 kits, 2 pedidos, etc.) para importar no primeiro acesso |
| `assets/seed/produtos.csv` | Mesma lista de produtos em CSV (conferência) |
| `docs/prototipo/balcao-revenda.html` | Protótipo funcional — abra no navegador |
| `docs/telas/*.png` | 18 capturas das telas (claro, escuro, meia tela e celular) |

## Onde o sistema final difere do protótipo (decisões já tomadas na spec)
- **Dados no Supabase** com login e isolamento por empresa (o protótipo salva no navegador).
- **Pedido guarda custo e abelinhas do momento da venda** (snapshot); mudanças posteriores no cadastro não alteram pedidos antigos. O pedido tem botão para atualizar os custos se o usuário quiser.
- **Situação do pedido**: Concluído (padrão), Cancelado ou Devolvido. O protótipo ainda mostra "Pago/Enviado/Entregue" no formulário — ignore.
- **Código do produto é único** por empresa. Os dois `CHSTICH` da planilha viraram `CHSTICH-AZ` e `CHSTICH-RS` no seed.
- **Estoque mínimo** foi removido.
- As taxas de **TikTok Shop** e **Mercado Livre** são exemplos — ajuste em Plataformas e taxas com os valores reais do seu contrato.


---

<!-- arquivo: .kiro/steering/product.md -->

# Produto: Balcão Revenda

Sistema de gestão para uma empresa que **compra produtos (cosméticos e acessórios) de distribuidores e revende em marketplaces**: Shopee, TikTok Shop, Mercado Livre e venda direta (WhatsApp/Instagram). Hoje tudo é controlado em planilha; o sistema substitui a planilha.

## Quem usa
- O dono da revenda (perfil financeiro, usa no computador e às vezes no celular).
- Eventualmente um operador que lança pedidos.

## O que o sistema resolve
1. **Cadastro de produtos** comprados para revenda, com custo unitário e "abelinhas" (unidade de valor interna calculada pelo custo).
2. **Composição de custo**: montar um *produto de venda* (kit) a partir de um ou mais produtos e ver custo, taxa, líquido, lucro, margem, ROI e metas **em todas as plataformas de uma vez**.
3. **Pedidos**: lançar a venda, escolher a plataforma, itens, preço e o líquido que a plataforma pagou; o sistema calcula custo, taxa estimada, lucro e abelinhas.
4. **Plataformas e taxas**: cada plataforma cobra valor fixo + percentual, por faixa de preço.
5. **Compras de insumos** (caixas, etiquetas, papel) e **investimento** (compra de mercadoria por distribuidor).
6. **Caixa e saques**: cada saque das plataformas é dividido automaticamente entre destinos (ex.: Cartão/empréstimos 40%, Compras de produtos 30%, Pró-labore 30%); compras e investimentos saem dos destinos.
7. **Regra de abelinhas**: tabela de faixas de custo → abelinhas, com análise de ROI conforme o valor de 1 abelinha.

## Princípios de produto
- Resumo antes do detalhe; números sempre em R$ no formato brasileiro (`R$ 1.234,56`).
- Estado visível por cor e forma (pills de lucro/atenção/prejuízo).
- Nenhuma lista com rolagem horizontal: em tela estreita as linhas viram cartões.
- Textos seguem o **padrão de escrita** (ver `design.md` §8).
- Idioma: **português do Brasil** em toda a interface.

## Referência visual e funcional
O protótipo funcional completo está em `docs/prototipo/balcao-revenda.html` (abra no navegador). Ele é a **fonte da verdade** de comportamento, cálculos e layout. Em caso de dúvida, reproduza o que o protótipo faz, salvo onde `design.md` diz explicitamente que muda.


---

<!-- arquivo: .kiro/steering/tech.md -->

# Stack técnica

## Plataformas-alvo
- **Desktop**: macOS e Windows (principal uso)
- **Web**
- **Android**

## Tecnologias
| Camada | Escolha |
|---|---|
| Linguagem / SDK | Dart 3, Flutter estável mais recente (3.24+) |
| Backend / banco | **Supabase** (Postgres + Auth + Row Level Security) via `supabase_flutter` |
| Estado | `flutter_riverpod` + `riverpod_annotation` / `riverpod_generator` |
| Navegação | `go_router` (rotas nomeadas, deep links na web) |
| Modelos | `freezed` + `json_serializable` |
| Dinheiro | `decimal` (nunca `double` para valores monetários) |
| Formatação | `intl` com locale `pt_BR` |
| Fonte | `google_fonts` → **Plus Jakarta Sans** |
| Ícones | `lucide_icons_flutter` (traço fino, mesmo estilo do protótipo) |
| Testes | `flutter_test`, `mocktail`; testes de unidade obrigatórios para todo cálculo |
| Lint | `flutter_lints` + `very_good_analysis` (ou equivalente rígido) |

## Regras
- Todo cálculo de negócio fica em **funções puras no domínio** (`lib/domain/calculos/`), sem dependência de Flutter ou Supabase, com testes de unidade usando os vetores de `design.md` §6.
- Valores monetários: `Decimal` no Dart, `numeric(12,2)` no Postgres. Percentuais: `numeric(6,2)` (ex.: 20 = 20%). Arredondamento só na exibição, exceto onde indicado.
- Toda tabela tem `empresa_id` e RLS habilitada; nenhuma consulta sem filtro de empresa.
- Variáveis `SUPABASE_URL` e `SUPABASE_ANON_KEY` via `--dart-define` (nunca no código).
- Datas: `date` no banco; exibição `dd/MM/yyyy`.
- Layout responsivo com os breakpoints de `design.md` §7 (não usar `MediaQuery` espalhado; usar um widget/helper central).
- Tema claro, escuro e automático com os tokens de `design.md` §7.
- Acessibilidade: todo botão só com ícone tem `Tooltip` e `Semantics(label:)`.

## Comandos
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter run -d macos --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
supabase db push          # aplica supabase/migrations
```


---

<!-- arquivo: .kiro/steering/structure.md -->

# Estrutura do projeto

```
balcao_revenda/
├─ lib/
│  ├─ main.dart
│  ├─ app.dart                     # MaterialApp.router, tema, locale pt_BR
│  ├─ core/
│  │  ├─ config/                   # env (dart-define), supabase client provider
│  │  ├─ router/                   # go_router + guards de auth
│  │  ├─ theme/                    # tokens (cores, tipografia, raios, espaçamentos), ThemeData claro/escuro
│  │  ├─ format/                   # moeda, percentual, data, abelinhas, padrão de escrita (fmtTitulo/fmtFrase/fmtMaius)
│  │  └─ widgets/                  # AppShell (menu lateral/gaveta), ResponsiveList, KpiCard, Pill, IconAction, Ledger, ConfirmDeleteButton...
│  ├─ domain/
│  │  ├─ entidades/                # freezed: Produto, ProdutoVenda, Pedido, Plataforma, FaixaTaxa, Destino, Saque...
│  │  └─ calculos/                 # funções puras: taxas, kit, pedido, abelinhas, caixa, alertas
│  ├─ data/
│  │  └─ repositorios/             # um repositório por agregado, usando Supabase
│  └─ features/
│     ├─ auth/
│     ├─ painel/
│     ├─ pedidos/
│     ├─ composicao/               # produtos de venda (kits)
│     ├─ produtos/
│     ├─ compras_insumos/
│     ├─ investimento/
│     ├─ caixa/
│     ├─ plataformas/
│     ├─ abelinhas/
│     └─ configuracoes/            # dados, backup, padrões, tema
├─ test/
│  ├─ domain/calculos/             # vetores de teste de design.md §6
│  └─ widgets/
├─ supabase/
│  └─ migrations/0001_schema.sql
├─ assets/
│  └─ seed/dados-iniciais.json     # dados da planilha para importar no primeiro acesso
└─ docs/
   ├─ prototipo/balcao-revenda.html
   └─ telas/*.png
```

## Convenções
- Arquivos `snake_case.dart`; classes `PascalCase`; nomes de domínio em **português** (Produto, Pedido, Plataforma) para casar com o banco.
- Cada feature: `presentation/` (pages, widgets) e `application/` (providers/controllers). Nada de chamada ao Supabase dentro de widget.
- Colunas do banco em `snake_case` português; `@JsonKey(name: ...)` quando o nome Dart difere.


---

<!-- arquivo: .kiro/specs/balcao-revenda/requirements.md -->

# Requisitos — Balcão Revenda

Sistema de gestão de revenda online em Flutter (desktop macOS/Windows, web e Android) com dados no Supabase. Fórmulas, modelo de dados e layout estão em `design.md`; o protótipo `docs/prototipo/balcao-revenda.html` mostra o comportamento esperado.

Notação: critérios no formato EARS (QUANDO / SE / ENQUANTO … ENTÃO O SISTEMA DEVE …).

---

## R1. Acesso, empresa e dados iniciais

**História:** Como dono da revenda, quero entrar com e-mail e senha e ter meus dados isolados, para usar o sistema em qualquer aparelho com segurança.

1. QUANDO o usuário não estiver autenticado, O SISTEMA DEVE mostrar a tela de login (e-mail e senha) com opção "Criar conta" e "Esqueci a senha" (Supabase Auth).
2. QUANDO um usuário autenticado não pertencer a nenhuma empresa, O SISTEMA DEVE pedir o nome da empresa, criá-la e vinculá-lo como `dono`.
3. QUANDO a empresa acabou de ser criada, O SISTEMA DEVE oferecer "Importar dados da planilha" (carrega `assets/seed/dados-iniciais.json`) ou "Começar vazio".
4. O SISTEMA DEVE criar, para toda empresa nova, as configurações padrão: embalagem R$ 0,90, impressão R$ 1,00, valor de 1 abelinha R$ 10,00, a regra de abelinhas padrão (design §6.6), as 4 plataformas padrão com faixas (design §6.1) e os 3 destinos padrão (40/30/30).
5. Toda leitura e escrita DEVE respeitar RLS: um usuário só acessa dados de empresas das quais é membro.
6. QUANDO o usuário clicar em "Sair", O SISTEMA DEVE encerrar a sessão e voltar ao login.

## R2. Estrutura, navegação e tema

**História:** Como usuário, quero navegar pelas seções com um menu claro e um visual consistente em qualquer tamanho de tela.

1. O SISTEMA DEVE ter menu com: **Painel** (item principal) e os grupos **Operação** (Pedidos, Composição de custo, Produtos), **Financeiro** (Compras de insumos, Investimento, Caixa e saques) e **Configuração** (Plataformas e taxas, Regra de abelinhas, Dados e configurações).
2. Os títulos de grupo DEVEM ter maior destaque que os itens (negrito, ícone em quadrado); os itens ficam recuados com linha-guia vertical; o item ativo tem fundo verde-claro, texto verde e barra lateral; o ícone do grupo ativo fica verde. Itens mostram contador (ex.: Produtos 99).
3. ENQUANTO a largura for ≥ 760 px, O SISTEMA DEVE mostrar o menu lateral fixo; ENQUANTO for < 760 px, DEVE mostrar barra superior com botão de menu (☰), logo e nome da tela, e o menu abre como gaveta lateral sobre o conteúdo.
4. O SISTEMA DEVE oferecer tema **Claro** (padrão), **Escuro** e **Auto** (segue o sistema operacional), escolhido por um seletor no rodapé do menu e salvo localmente.
5. Nenhuma tela DEVE ter rolagem horizontal da página. Listas seguem R13.

## R3. Produtos (cadastro)

**História:** Como dono, quero cadastrar os produtos que compro, com custo e abelinhas, para usar na composição de custo e nos pedidos.

1. O SISTEMA DEVE permitir criar, editar e excluir produtos com: código (único por empresa), nome, marca, categoria, fornecedor, custo unitário, unidade, estoque atual, código de barras (EAN), situação (ativo/inativo) e observações.
2. SE o código já existir na empresa, ENTÃO O SISTEMA DEVE impedir o salvamento e mostrar "Já existe um produto com o código X".
3. QUANDO o usuário digitar o custo, O SISTEMA DEVE mostrar em tempo real as abelinhas calculadas pela regra (R9) com o texto "Calculado pela regra (custo R$ X)".
4. O SISTEMA DEVE ter um botão **✎ Editar** no quadro de abelinhas que libera um campo para valor manual (múltiplos de 0,5 recomendados) e um botão "Voltar para a regra".
5. QUANDO o valor manual for diferente da regra, O SISTEMA DEVE mostrar um aviso de impacto (design §6.7): vermelho se o produto passar a dar prejuízo ou ficar ≥ 50% abaixo da regra; amarelo se abaixo da regra com lucro; verde se acima da regra. O aviso mostra venda em R$ antes/depois, lucro por unidade, ROI antes/depois, abelinhas mínimas sem prejuízo, quantas vezes mais precisaria vender (quando abaixo), e os produtos de venda (kits) afetados com o total de abelinhas antes → depois.
6. SE o valor manual for igual ao da regra, ENTÃO O SISTEMA DEVE salvar como "pela regra" (sem valor manual).
7. A lista DEVE ter busca (código, nome, marca, fornecedor), filtro por categoria e contador "N de M".
8. Cada linha mostra: nome (destaque) com código, marca e categoria abaixo; custo (fornecedor abaixo); abelinhas com botão ✎ pequeno e "pela regra"/"ajustado" abaixo (pill amarela se manual abaixo da regra, verde se acima, amarela se custo acima da última faixa); estoque com "N vendido(s)" abaixo; ações editar e excluir.
9. SE o produto estiver em algum produto de venda, ENTÃO ao excluir O SISTEMA DEVE avisar quais kits usam o produto e pedir confirmação.

## R4. Composição de custo (produtos de venda / kits)

**História:** Como dono, quero montar um produto de venda com um ou mais produtos e ver o custo e o resultado em todas as plataformas de uma vez, sem cadastrar por plataforma.

1. O produto de venda NÃO DEVE ter campo de plataforma. O SISTEMA DEVE calcular os resultados para **todas** as plataformas cadastradas; uma plataforma nova aparece automaticamente em todos os kits.
2. O SISTEMA DEVE permitir adicionar produtos por busca (código/nome), ajustar quantidade (− / +; quantidade 0 remove) e mostrar por item: código, nome, custo unitário, abelinhas por unidade e total, e subtotal.
3. Custos adicionais: embalagem (escolher uma compra de insumo — usa o valor unitário dela — ou valor manual), impressão e outros insumos. Valores iniciais vêm das configurações.
4. Preço base: preço sem desconto, desconto (R$), cupom (R$), preço do concorrente (opcional), margem desejada (%), meta de lucro (R$) e fatia do lucro para anúncios (0–1).
5. O resumo (fixo à direita em telas largas) DEVE mostrar: compra dos itens, embalagem, impressão, outros, **investimento por venda** (total), abelinhas do kit e o valor delas em R$, lucro por plataforma com margem, e "Melhor resultado: <plataforma>".
6. A tabela **Resultado por plataforma** DEVE ter, por plataforma: preço anúncio, desconto e cupom editáveis (em branco = usa o preço base, mostrando o base como placeholder), cliente paga, taxa, líquido, lucro, margem, ROI, preço mínimo sem lucro, preço sugerido para a margem desejada (botão que aplica o valor), meta (vendidos/quantidade da meta) e ROAS alvo. Fórmulas em design §6.2–6.3.
7. "Vendidos" de cada plataforma = vendidos iniciais (importados) + unidades do kit em pedidos não cancelados daquela plataforma.
8. A lista de produtos de venda mostra: nome com composição (ex.: "5× SACHER"); investimento com "N itens · X 🐝"; uma coluna por plataforma com o lucro (verde/vermelho) e "cliente paga · margem" abaixo; ações abrir, duplicar e excluir.
9. QUANDO duplicar, O SISTEMA DEVE criar cópia com nome "<nome> (cópia)" e zerar vendidos iniciais.

## R5. Pedidos

**História:** Como dono, quero lançar cada venda com a plataforma, os itens e o preço, e ver custo, taxa, líquido, lucro e abelinhas.

1. Campos: data (padrão hoje), cliente / nº do pedido (MAIÚSCULO), plataforma, itens (produtos e/ou produtos de venda com quantidade), embalagem, impressão, outros, preço de venda, itens cobrados com taxa fixa, líquido recebido (opcional), observação e situação (Concluído, Cancelado, Devolvido; padrão Concluído — não existe status "pago").
2. QUANDO o pedido for novo e tiver kits, O SISTEMA DEVE preencher o preço de venda com a soma do "cliente paga" de cada kit **na plataforma escolhida** × quantidade, e "itens cobrados com taxa fixa" com a soma das quantidades de kits; QUANDO a plataforma mudar, DEVE recalcular. QUANDO o usuário digitar o preço ou os itens cobrados, o preenchimento automático para.
3. ENQUANTO o pedido novo tiver só kits e o usuário não tiver editado os custos de envio, embalagem e impressão DEVEM ficar em 0 (o kit já inclui); se tiver produto avulso, voltam aos padrões.
4. O resumo DEVE mostrar: mercadoria, embalagem+impressão+outros, custo total; abelinhas por item e total (com valor em R$); preço de venda, taxa estimada (com % e fixo da faixa), líquido estimado, líquido considerado (pill "informado" ou "estimado"), taxa efetiva (R$ e %), **lucro do pedido** e margem sobre a venda.
5. SE o líquido informado diferir da estimativa em mais de R$ 0,50, ENTÃO O SISTEMA DEVE mostrar aviso sugerindo revisar as faixas da plataforma.
6. Ao salvar, O SISTEMA DEVE gravar em cada item o **custo unitário** e as **abelinhas unitárias** vigentes (snapshot). Mudanças posteriores em produtos não alteram pedidos já salvos; o pedido aberto oferece "Atualizar custos pelo cadastro atual".
7. A lista de pedidos (ordem: data mais recente) DEVE ter colunas: **Pedido** (cliente em destaque; data · plataforma abaixo; pill se cancelado/devolvido), **Itens** (N itens; abelinhas abaixo), **Venda** (taxa abaixo), **Líquido** (custo abaixo; pill "est." se estimado), **Lucro** (margem abaixo) e **Ações** (abrir, excluir). Busca por cliente e filtro por plataforma.
8. Pedidos cancelados ou devolvidos NÃO DEVEM entrar em faturamento, lucro, vendidos e saldos.

## R6. Plataformas e taxas

**História:** Como dono, quero configurar a cobrança de cada plataforma (fixo + percentual por faixa de preço) para que custos e líquidos sejam calculados certo.

1. O SISTEMA DEVE permitir criar, renomear, mudar cor e excluir plataformas (mínimo 1).
2. Cada plataforma tem faixas: "preço até (R$)" (vazio = sem limite), taxa fixa (R$) e percentual. Pelo menos uma faixa; adicionar/remover faixas.
3. O SISTEMA DEVE mostrar simulação de taxa e líquido para vendas de R$ 19,99, 59,90, 89,90, 149,90 e 249,90.
4. SE uma plataforma for usada em pedidos ou saques, ENTÃO a exclusão DEVE ser bloqueada com mensagem explicando.

## R7. Compras de insumos

1. O SISTEMA DEVE registrar compras com: data, tipo (Embalagem, Etiqueta, Impressão, Fita / lacre, Brinde, Outros), produto, descrição/medida, valor total, quantidade de pacotes, total de itens e "pago com" (destino do caixa ou "não descontar do caixa").
2. O valor unitário (valor ÷ itens) DEVE aparecer ao vivo no formulário e ficar disponível como opção de embalagem na composição de custo.
3. Lista: compra (produto em destaque; data · tipo · descrição abaixo), quantidade (pacotes abaixo), valor (valor por item abaixo), pago com, ações. KPI "Total em insumos".

## R8. Investimento (compra de mercadoria)

1. O SISTEMA DEVE registrar: data, distribuidor, valor, nota/nº do pedido, pago com (destino) e observação.
2. KPIs: total investido e os 3 maiores distribuidores com % do total.
3. Lista: distribuidor (data · nota · observação abaixo), valor (% do total abaixo), pago com, ações.

## R9. Regra de abelinhas

**História:** Como dono, quero definir quantas abelinhas cada produto vale pela faixa de custo e entender quando isso dá lucro ou prejuízo.

1. O SISTEMA DEVE manter faixas "custo de compra até (R$)" → abelinhas, editáveis, com adicionar/remover. Padrão: até 5,00 = 0,5; até 8,00 = 1; até 12,00 = 1,5; até 16,00 = 2; até 20,00 = 2,5; até 24,00 = 3; até 28,00 = 3,5; até 32,00 = 4.
2. O valor de um produto é a primeira faixa (ordenada por custo) em que custo ≤ "até"; acima da última, usa a última e marca o produto.
3. O SISTEMA DEVE ter o campo **Valor de 1 🐝 (R$)** que recalcula tudo enquanto o usuário digita (debounce ~300 ms, aceita vírgula), sem precisar de botão.
4. KPIs: ROI médio dos produtos (com explicação "Como ler" e um exemplo real que se atualizam com o valor), produtos com lucro, produtos com prejuízo e 🐝 mínima sem prejuízo.
5. Lista de faixas: faixa (texto "R$ 5,01 a R$ 8,00" em destaque; pill de situação e nº de produtos abaixo), custo até (editável), abelinhas (editável), venda em R$, ROI médio, ROI no limite, 🐝 mínima p/ lucro, ações.
6. Quadro "Quando dá lucro e quando dá prejuízo": faixas de valor da abelinha (todos prejuízo / parte / todos lucro), a faixa mais exigente, maior e menor lucro, produto de maior e menor ROI. Fórmulas em design §6.6.
7. QUANDO a regra mudar, todos os produtos sem valor manual DEVEM ser recalculados imediatamente.

## R10. Caixa e saques

**História:** Como dono, quero registrar os saques das plataformas e ver automaticamente para onde vai cada parte do dinheiro.

1. O SISTEMA DEVE manter destinos (nome, cor, percentual) editáveis; a soma deve dar 100% e, se não der, mostrar "Rateio soma X%" em vermelho e aviso no painel.
2. QUANDO registrar um saque (data, plataforma, valor, observação), O SISTEMA DEVE mostrar o rateio ao vivo e gravar o rateio (percentual e valor por destino) no momento do saque; mudanças futuras de percentual não alteram saques antigos.
3. O SISTEMA DEVE registrar **retiradas** (data, destino, valor, descrição).
4. Saldo por destino = entradas dos rateios − (investimentos + compras de insumos + retiradas pagos com aquele destino).
5. Layout (de cima para baixo): KPIs (sacado das plataformas, saídas do caixa, saldo em caixa); **cartões por destino** (nome, %, saldo, barra do que resta, entrou/saiu); lado a lado e com mesma altura: **Destinos e percentuais** (editor) e **Por plataforma** (líquido dos pedidos × sacado, colunas alinhadas); **Extrato** (movimento, valor, uma coluna por destino, ações — só saques e retiradas excluem aqui).

## R11. Painel

1. Filtro de período: este mês / todo o período.
2. KPIs: faturamento (nº pedidos), taxas das plataformas (% do faturamento), líquido recebido, custo dos pedidos, lucro (margem).
3. Vendas por plataforma (barra bruto e líquido), pontos de atenção (design §6.9), caixa por destino com total sacado, itens mais vendidos (6).

## R12. Padrão de escrita (normalização de texto)

1. O SISTEMA DEVE aplicar ao sair do campo e ao salvar: **Nomes** (produto, kit, marca, fornecedor, insumo, distribuidor) → Título com conectivos minúsculos; **Códigos/identificadores** (código, cliente/nº do pedido, nota) → MAIÚSCULO; **Descrições/observações** (categoria, descrição, destino, observação) → primeira letra maiúscula. Regras exatas em design §8.
2. A tela de configurações DEVE mostrar o quadro "Padrão de escrita" com as regras e exemplos.

## R13. Listas responsivas e ações

1. ENQUANTO a largura útil permitir, listas aparecem como tabela com cabeçalho; caso contrário, cada linha vira **cartão**: título no topo, ações no canto superior direito, demais campos em grade com rótulo (4 colunas em tela média, 2 em < 600 px). Breakpoints em design §7.4.
2. Ações sempre como **botões de ícone** (olho = abrir, lápis = editar, duas folhas = duplicar, lixeira = excluir) com tooltip e coluna "Ações".
3. Excluir pede confirmação no próprio botão (vira "Confirmar" vermelho por 3 s) ou diálogo; nunca exclui no primeiro clique.

## R14. Dados, backup e configurações

1. Configurações: embalagem e impressão padrão, valor da abelinha, tema.
2. "Exportar dados (JSON)" e "Importar dados (JSON)" da empresa; "Importar dados da planilha" (seed) só quando a empresa estiver vazia.
3. Erros de rede/servidor: mensagem clara ("Não foi possível salvar. Verifique a conexão e tente de novo.") e nada perdido no formulário aberto.

## Fora do escopo (v1)
Integração automática com APIs das plataformas, emissão de nota fiscal, controle de estoque com entrada automática por investimento, multi-moeda.


---

<!-- arquivo: .kiro/specs/balcao-revenda/design.md -->

# Design — Balcão Revenda

Referências: `requirements.md` (o quê), protótipo `docs/prototipo/balcao-revenda.html` (como se comporta e se parece), telas em `docs/telas/`.

---

## 1. Arquitetura

```
Flutter (macOS · Windows · Web · Android)
 ├─ presentation (pages/widgets por feature)  ── Riverpod ──┐
 ├─ application  (controllers/providers)                     │
 ├─ domain       (entidades freezed + cálculos PUROS)  ◄─────┘
 └─ data         (repositórios Supabase)
                     │  supabase_flutter (PostgREST + Auth)
                     ▼
Supabase: Postgres + RLS por empresa + Auth (e-mail/senha)
```

- **Cálculos sempre no cliente**, em `lib/domain/calculos/`, como funções puras testadas (§6). O banco guarda dados de entrada e snapshots; não guarda resultados derivados (exceto snapshots de pedido e rateio de saque).
- Cada repositório expõe `Stream`/`Future` tipados; providers Riverpod fazem cache por empresa.
- Empresa ativa: provider `empresaAtualProvider` (primeira empresa do usuário; preparar para várias).
- Sem modo offline na v1; mostrar estado de carregamento (skeleton) e erro com "Tentar de novo".

## 2. Modelo de dados (Supabase / Postgres)

DDL completo em `supabase/migrations/0001_schema.sql`. Resumo:

| Tabela | Campos principais | Observações |
|---|---|---|
| `empresas` | id, nome, criado_em | |
| `membros` | empresa_id, user_id, papel (`dono`/`operador`) | PK composta |
| `configuracoes` | empresa_id (PK), embalagem_padrao, impressao_padrao, valor_abelinha | 1 por empresa |
| `faixas_abelinha` | id, empresa_id, custo_ate, abelinhas | ordenar por custo_ate |
| `produtos` | id, empresa_id, codigo, nome, marca, categoria, fornecedor, custo, unidade, estoque, ean, ativo, obs, abelinhas_manual (null = pela regra) | `unique(empresa_id, codigo)` |
| `plataformas` | id, empresa_id, nome, cor (hex), obs, ordem | |
| `faixas_taxa` | id, empresa_id, plataforma_id, preco_ate (null = sem limite), taxa_fixa, taxa_percentual | |
| `produtos_venda` | id, empresa_id, nome, embalagem, compra_insumo_id, impressao, outros, preco, desconto, cupom, preco_concorrente, meta_lucro, fatia_roas, margem_alvo | o "kit" |
| `produtos_venda_itens` | id, empresa_id, produto_venda_id, produto_id, quantidade | |
| `produtos_venda_precos` | empresa_id, produto_venda_id, plataforma_id, preco?, desconto?, cupom?, vendidos_iniciais | null = usa base; PK (produto_venda_id, plataforma_id) |
| `pedidos` | id, empresa_id, data, cliente, plataforma_id, embalagem, impressao, outros, preco_venda, itens_taxa_fixa, liquido_informado?, situacao (`concluido`/`cancelado`/`devolvido`), obs | |
| `pedidos_itens` | id, empresa_id, pedido_id, tipo (`produto`/`produto_venda`), produto_id?, produto_venda_id?, quantidade, custo_unitario, abelinhas_unitarias | snapshots no salvamento |
| `compras_insumo` | id, empresa_id, data, tipo, produto, descricao, valor_total, pacotes, itens, destino_id? | |
| `investimentos` | id, empresa_id, data, distribuidor, valor, nota, destino_id?, obs | |
| `destinos` | id, empresa_id, nome, cor, percentual, ordem | |
| `saques` | id, empresa_id, data, plataforma_id, valor, obs | |
| `saques_rateio` | saque_id, empresa_id, destino_id, percentual, valor | snapshot; PK (saque_id, destino_id) |
| `retiradas` | id, empresa_id, data, destino_id, valor, descricao | |

Tipos: dinheiro `numeric(12,2)`; percentuais `numeric(6,2)`; abelinhas `numeric(6,2)`; `fatia_roas numeric(5,4)`. Todas com `criado_em timestamptz default now()` e `atualizado_em` (trigger).

**RLS**: todas as tabelas com `empresa_id` usam a função `public.is_membro(empresa_id)`; políticas `select/insert/update/delete` para membros. `empresas` visível só para membros; criação via RPC `criar_empresa(nome)` (security definer) que cria empresa, membro dono, configurações e padrões (§6.1, §6.6, destinos).

## 3. Entidades de domínio (Dart)

Espelham as tabelas (freezed). Pontos de atenção:
- `Produto.abelinhasManual` (`Decimal?`): null = regra.
- `ProdutoVenda` carrega `itens` e `precosPorPlataforma` (`Map<String, PrecoPlataforma>`).
- `Pedido` carrega `itens`; `PedidoItem` tem `custoUnitario` e `abelinhasUnitarias` (snapshot).
- `Saque` carrega `rateio`.

## 4. Telas (rotas `go_router`)

| Rota | Tela | Requisito |
|---|---|---|
| `/login` | Login / criar conta | R1 |
| `/onboarding` | Nome da empresa + importar planilha | R1 |
| `/` | Painel | R11 |
| `/pedidos`, `/pedidos/novo`, `/pedidos/:id` | Lista e editor | R5 |
| `/composicao`, `/composicao/novo`, `/composicao/:id` | Lista e editor do produto de venda | R4 |
| `/produtos` (+ painel lateral de edição) | Produtos | R3 |
| `/insumos` | Compras de insumos | R7 |
| `/investimento` | Investimento | R8 |
| `/caixa` | Caixa e saques | R10 |
| `/plataformas` | Plataformas e taxas | R6 |
| `/abelinhas` | Regra de abelinhas | R9 |
| `/configuracoes` | Dados, backup, padrões, padrão de escrita | R12, R14 |

Editores (pedido, produto de venda) abrem como **painel lateral largo** (até 1080 px) em desktop e como tela cheia em < 760 px; formulários simples (produto, insumo, investimento, saque, retirada) como painel lateral de 560 px. Rodapé do painel fixo com "Cancelar" e ação primária.

## 5. Componentes compartilhados (`core/widgets`)

- `AppShell`: menu lateral (264 px; 240 px entre 760–1100) ou barra superior + gaveta (< 760).
- `PageHeader(title, subtitle, actions)`.
- `KpiCard(label, value, sub)` e `KpiRow` (Wrap, cartões `flex 1 1 170px`).
- `ResponsiveList<T>`: recebe colunas (`label`, `builder`, `alinhamento`, `principal`) e ações; renderiza tabela ou cartões conforme largura (§7.4).
- `IconAction(icon, tooltip, danger)` e `ConfirmDeleteButton` (1º clique vira "Confirmar" por 3 s).
- `Pill(texto, tom: neutro|bom|atencao|ruim|destaque)`, `PlatformPill`, `CodeChip`.
- `Ledger` (linhas chave/valor com linha total destacada).
- `MoneyField` (aceita vírgula), `TextCaseField(case: titulo|frase|maius)` que normaliza ao perder foco (§8).
- `Abelinhas(qtd)` → "1,5 🐝".

## 6. Regras de cálculo (domínio) e vetores de teste

Notação: valores em R$; `pct` em pontos percentuais (20 = 20%). Arredondar só para exibir (2 casas), exceto onde dito.

### 6.1 Faixa e taxa de plataforma
```
faixas ordenadas por preco_ate asc (null por último)
faixa(plataforma, preco) = primeira com preco_ate == null || preco <= preco_ate (senão a última)
taxa(plataforma, preco, itensTaxaFixa = 1) = faixa.taxa_fixa * itensTaxaFixa + preco * faixa.pct / 100
```
Plataformas padrão:
| Plataforma | Faixas (até → fixo, %) | Cor |
|---|---|---|
| Shopee | 79,99 → 4,00 + 20% · 99,99 → 16,00 + 14% · 199,99 → 20,00 + 14% · sem limite → 26,00 + 14% | #F0846A |
| TikTok Shop | sem limite → 4,00 + 12% *(exemplo, usuário ajusta)* | #5BB8C2 |
| Mercado Livre | 78,99 → 6,25 + 14% · sem limite → 0 + 14% *(exemplo)* | #E5BF55 |
| Venda direta | sem limite → 0 + 0% | #9A8FD4 |

### 6.2 Preço mínimo e preço sugerido
```
precoMinimo(pl, custo):     para cada faixa f (ordenada): p = (custo + f.fixo) / (1 - f.pct/100)
                            válido se p > limite da faixa anterior e (f.ate == null || p <= f.ate); retorna o menor válido
                            fallback: fórmula com a 1ª faixa
precoParaMargem(pl, custo, m):  liquidoNecessario = custo / (1 - m)        // m = margemAlvo/100, margem sobre o líquido
                            para cada faixa: M = (liquidoNecessario + f.fixo) / (1 - f.pct/100), mesma validação; menor válido
sugerido (preço anúncio) = precoParaMargem + desconto + cupom
```

### 6.3 Produto de venda (kit) por plataforma
```
compra       = Σ produto.custo * qtd
investimento = compra + embalagem + impressao + outros
preco/desconto/cupom = override da plataforma se preenchido, senão base
M (cliente paga) = preco - desconto - cupom
f = faixa(pl, M);  taxas = M*f.pct/100 + f.fixo
liquido = M - taxas;  lucro = liquido - investimento
margem = lucro / liquido;  roi = lucro / investimento
metaQtd = lucro > 0 ? ceil(metaLucro / lucro) : indefinido
metaFaturamento = preco * metaQtd;  atingido = vendidos / metaQtd
roasAlvo = lucro > 0 && fatia > 0 ? M / (lucro * fatia) : indefinido
custoAnuncio = lucro * fatia
vendidos(pl) = vendidosIniciais(pl) + Σ qtd do kit em pedidos não cancelados/devolvidos da plataforma
abelinhasKit = Σ abelinhas(produto) * qtd
```

**Vetores (devem passar):**
| Kit | Investimento | Plataforma | Cliente paga | Taxa | Líquido | Lucro | Margem | Mínimo | Sugerido (30%) | Meta |
|---|---|---|---|---|---|---|---|---|---|---|
| Batom Bolsinha (1× BATOM 11,38; emb 0,90; imp 1,00; preço 26,49; desc 1; cupom 2; meta 200) | 13,28 | Shopee | 23,49 | 8,70 | 14,79 | 1,51 | 10,2% | 21,60 | 31,71 | 13/133 (vendidos iniciais 13) |
| idem | 13,28 | TikTok Shop | 23,49 | 6,82 | 16,67 | 3,39 | 20,3% | 19,64 | 29,10 | 0/59 |
| idem | 13,28 | Mercado Livre | 23,49 | 9,54 | 13,95 | 0,67 | 4,8% | 22,71 | 32,33 | 0/299 |
| idem | 13,28 | Venda direta | 23,49 | 0,00 | 23,49 | 10,21 | 43,5% | 13,28 | 21,97 | 0/20 |
| Kit 5 Sachês (5× SACHER 0,77; preço 19,99; desc 2; cupom 1) | 5,75 | Shopee | 16,99 | 7,40 | 9,59 | 3,84 | 40,1% | 12,19 | — | — |
| Kit Maquiagem (BASE 8,97 + GLOSS 7,35 + PO 3,71; preço 59,90; desc 15) | 21,93 | Shopee | 44,90 | 12,98 | 31,92 | 9,99 | 31,3% | 32,41 | — | 21 |

ROAS alvo Batom/Shopee (fatia 0,3) = 23,49 / (1,512 × 0,3) ≈ **51,8**.

### 6.4 Pedido
```
custoLinha = produto: custo_unitario (snapshot) | kit: investimento do kit (snapshot)
mercadoria = Σ custoLinha * qtd
custo = mercadoria + embalagem + impressao + outros
taxaEstimada = taxa(pl, precoVenda, itensTaxaFixa)
liquidoEstimado = precoVenda - taxaEstimada
liquido = liquidoInformado ?? liquidoEstimado
taxaEfetiva = precoVenda - liquido
lucro = liquido - custo;  margem = lucro / precoVenda
abelinhasPedido = Σ abelinhas_unitarias * qtd   (kit: Σ abelinhas dos produtos do kit)
```
Preço automático (novo pedido): `Σ M(kit, plataforma) * qtd` dos kits; `itensTaxaFixa = Σ qtd dos kits`.

**Vetores:**
| Pedido | Itens | Custo | Venda | Líquido | Lucro | Abelinhas |
|---|---|---|---|---|---|---|
| KT01-DALILA (TikTok; emb 0,90; imp 1,00; informado 85,85) | K2, L1×2, C1, PB, PB3 (49,36) | 51,26 | 110,00 | 85,85 | 34,59 | 7,5 🐝 |
| KT01-THAIS (TikTok; informado 97,40) | K2, GLOSS, CT1, LPV1, L1 (41,76) | 43,66 | 110,00 | 97,40 | 53,74 | 6 🐝 |
| Kit Batom no Mercado Livre (só kit, emb/imp 0, sem informado) | 1× Batom Bolsinha | 13,28 | 31,90 (preço ML 34,90 − 3) | 21,18 (taxa 10,72) | 7,90 | 1,5 🐝 |

### 6.5 Painel
Considera pedidos `concluido` no período. Faturamento = Σ preço; taxas = Σ taxaEfetiva; líquido; custo; lucro; margem = lucro/faturamento. Vetor (dados da planilha, todo o período): faturamento 220,00 · taxas 36,75 (16,7%) · líquido 183,25 · custo 94,92 · lucro 88,33 (40,1%).

### 6.6 Abelinhas
```
abelinhasRegra(custo): faixas por custo_ate asc; primeira com custo <= custo_ate → abelinhas; senão última (flag acimaDaTabela)
abelinhas(produto) = produto.abelinhasManual ?? abelinhasRegra(produto.custo)
v = valor de 1 abelinha
ROI(produto) = (abelinhas * v - custo) / custo
Por faixa i (limite inferior = teto anterior + 0,01; 1ª = 0):
  venda = qtd * v
  roiMedio = média de ROI dos produtos com custo no intervalo (usando a qtd da faixa)
  roiNoLimite = (venda - teto) / teto
  abelinhaMinima = teto / qtd
  situação: venda > teto → "Lucro" | venda == teto → "Empata no teto" | venda > limiteInferior → "Prejuízo > R$ venda" | senão "Prejuízo"
Geral (produtos com custo > 0): roiMedioGeral = média ROI; lucro/prejuízo = ROI >= 0;
  necessário(p) = custo / abelinhas;  todos lucram se v >= max(necessário); todos perdem se v < min(necessário)
Exemplo do card: produto com ROI mais próximo da média
```
**Vetores (v = 10,00, regra padrão, 99 produtos da planilha):** ROI médio 86,5% · 99 com lucro · 0 com prejuízo · 🐝 mínima sem prejuízo 10,00 · faixa "até 5,00": 38 produtos, ROI médio 141,1%, ROI no limite 0,0%, situação "Empata no teto" · faixa "5,01 a 8,00": 40 produtos, ROI médio 56,7%, no limite 25,0%. Com v = 8,00: ROI médio 49,2%, 9 produtos com prejuízo. Limites: custo 5,00 → 0,5; 5,01 → 1; 8,01 → 1,5; 21,69 → 3; 40,00 → 4 (acima).

### 6.7 Aviso de impacto do ajuste manual de abelinhas
```
R = regra, O = manual, c = custo, v = valor
dif = O - R; difPct = dif / R; lucroO = O*v - c; minimo = ceil((c/v)*2)/2
vermelho: lucroO < 0  ("passa a dar prejuízo")  ou difPct <= -50% ("muito abaixo da regra")
amarelo:  dif < 0 com lucro ("bom para promoção, com lucro menor") + "vender (R*v-c)/lucroO × mais unidades para o mesmo lucro"
verde:    dif > 0 ("lucro maior por unidade") + "confira se o cliente aceita pagar mais abelinhas"
sempre: venda O*v vs R*v, lucro antes/depois, ROI antes/depois, kits afetados (abelinhas antes → depois)
```
Vetor: Gloss Playboy custo 6,45, regra 1, manual 0,5, v 10 → vermelho, prejuízo 1,45/un, ROI 55,0% → −22,5%, mínimo 1 🐝.

### 6.8 Caixa
```
rateio(saque) = destinos.map(d → valor * d.percentual / 100)  (gravado no saque)
entradas(d) = Σ rateios do destino; saidas(d) = Σ investimentos + compras_insumo + retiradas com destino d
saldo(d) = entradas - saidas
```
Vetor (planilha): saque TikTok 3.286,06 em 16/10/2026 com 40/30/30 → 1.314,42 / 985,82 / 985,82; saídas em Compras de produtos: 209,19 + 46,99 → saldo 729,64; saldo total 3.029,88.

### 6.9 Pontos de atenção (painel)
- Soma dos destinos ≠ 100%.
- Kit com lucro < 0 em alguma plataforma (lista plataformas e preço mínimo).
- Kit com margem < 15% em alguma plataforma.
- Códigos de produto repetidos (não deve ocorrer com a constraint, mas tratar dados importados).

## 7. Interface

### 7.1 Tokens de cor
| Token | Claro | Escuro | Uso |
|---|---|---|---|
| bg | #F5F6F8 | #111418 | fundo |
| surface | #FFFFFF | #181C21 | cartões, painéis |
| surface2 | #F1F3F5 | #20252C | cabeçalho de tabela, hover, chips |
| ink | #1C2128 | #E9ECF0 | texto |
| muted | #687280 | #9AA3AE | texto secundário |
| line | #E7E9EE | #2A3038 | bordas |
| accent | #2B7A70 | #6CC3B6 | ação principal, item ativo |
| accentInk | #FFFFFF | #0D1F1C | texto sobre accent |
| accentSoft | #E8F3F1 | #1C2F2C | fundo do ativo, aviso informativo |
| good / goodSoft | #2E7D55 / #E9F5EE | #6FCF9A / #17291F | lucro |
| warn / warnSoft | #9A6212 / #FBF3E4 | #E3B065 / #2E2615 | atenção |
| bad / badSoft | #B54A40 / #FCECEA | #EE8F86 / #331D1B | prejuízo, excluir |

Cores dos destinos padrão: #6A9FD8, #6FB59A, #E5BF55.

### 7.2 Tipografia (Plus Jakarta Sans)
Título de página 26/600 (−0,02em); título de painel 15/600; KPI 22/600 tabular; corpo 14/400; rótulos 12,5/500 muted; sublinha de lista 12/400 muted; código 11,5/600 em chip. Números sempre com `FontFeature.tabularFigures()`.

### 7.3 Forma
Raios: 8 (controles), 14 (cartões/painéis), 6 (pills). Sombra leve `0 1px 2px rgba(16,24,40,.04)`. Espaçamento base 4; gaps 8/12/16/20; padding de painel 20 (16 no celular).

### 7.4 Breakpoints
| Largura da janela | Menu | Listas |
|---|---|---|
| ≥ 1380 | lateral 264 | tabela (todas) |
| 1200–1379 | lateral 264 | tabela, exceto Composição e Abelinhas (cartões) |
| 1100–1199 | lateral 264 | cartões 4 colunas |
| 760–1099 | lateral 240 | cartões 4 colunas |
| 600–759 | barra superior + gaveta | cartões 4 colunas |
| < 600 | barra superior + gaveta | cartões 2 colunas |

Implementar `ResponsiveList` decidindo pela **largura disponível do próprio widget** (LayoutBuilder) com limiar por lista (padrão ~780 px de largura útil; listas largas ~990 px), não pela janela.

### 7.5 Telas-chave (ver `docs/telas/*.png` e o protótipo)
- **Painel**: KPIs em linha; grade 2 colunas de painéis.
- **Editor de produto de venda**: nome; à esquerda itens, buscar/adicionar, custos adicionais, preço base e metas; à direita resumo fixo; abaixo tabela "Resultado por plataforma".
- **Editor de pedido**: data, cliente, plataforma, situação; à esquerda itens, adicionar, custos do envio, venda; à direita resumo (custo, abelinhas, venda, lucro).
- **Caixa**: KPIs; cartões de destino; editor de destinos e "por plataforma" lado a lado com mesma altura; extrato.

## 8. Padrão de escrita (normalização)

```
CONECTIVOS = de, da, do, das, dos, e, em, com, para, p/, a, o, as, os, no, na, nos, nas, por, sem, ao
SIGLAS = HD, UV, FPS, SPF, CNPJ, CPF, NF
titulo(t): espaços colapsados; por palavra: contém dígito → mantém; sigla → MAIÚSCULA;
           conectivo e não é a 1ª palavra → minúscula; senão minúscula com 1ª letra maiúscula (pt_BR)
frase(t):  espaços colapsados; só a 1ª letra maiúscula (resto como digitado)
maius(t):  tudo maiúsculo
```
| Campo | Regra |
|---|---|
| produto.nome, marca, fornecedor; produto_venda.nome; compras_insumo.produto; investimentos.distribuidor | titulo |
| produto.codigo; pedidos.cliente; investimentos.nota | maius |
| produto.categoria, obs; compras_insumo.descricao; destinos.nome; observações | frase |

Exemplos: "CREME DE MÃOS para pele seca" → "Creme de Mãos para Pele Seca"; "cr01" → "CR01"; "MÁSCARA P/ CILIOS" → "Máscara p/ Cilios"; "Po facial Banana 10g" → "Po Facial Banana 10g". Textos da interface (botões, títulos): só a primeira letra maiúscula.

## 9. Importação inicial (seed)

`assets/seed/dados-iniciais.json` contém, já normalizados e com acentos corrigidos: 99 produtos (códigos duplicados `CHSTICH` renomeados para `CHSTICH-AZ` e `CHSTICH-RS`), 3 produtos de venda (com vendidos iniciais na Shopee: 13, 2, 1), 2 pedidos TikTok, 1 compra de insumo, 1 investimento, 1 saque com rateio, destinos, plataformas, faixas de taxa, regra de abelinhas e configurações. Referências entre registros usam `ref` textuais (ex.: código do produto, nome da plataforma); o importador resolve para UUIDs na ordem: configurações → plataformas/faixas → destinos → produtos → produtos de venda → compras → investimentos → pedidos → saques. Como a RPC `criar_empresa` já cria plataformas, faixas, destinos e regra de abelinhas padrão, o importador **atualiza os existentes casando pelo nome** em vez de duplicar. Nos itens de pedido importados, o snapshot (`custo_unitario`, `abelinhas_unitarias`) é calculado com o cadastro importado; o rateio do saque é gravado com os percentuais do arquivo.

## 10. Erros e estados
- Carregando: skeletons nas listas e KPIs.
- Vazio: mensagem e ação ("Nenhum pedido. Use “Novo pedido” para lançar o primeiro.").
- Erro de rede: snackbar com "Tentar de novo"; formulário mantém os dados.
- Validação: mensagens específicas ao lado do campo ("Informe código e nome do produto").
- Exclusão bloqueada por vínculo (plataforma usada, produto em kit): diálogo explicando.

## 11. Testes
- `test/domain/calculos/*_test.dart`: todos os vetores do §6 (tolerância 0,005).
- Testes de `titulo/frase/maius` com os exemplos do §8.
- Widget tests: `ResponsiveList` em 1440, 1000 e 400 px (tabela vs cartões, sem overflow horizontal); `AppShell` mostra gaveta em < 760.
- Teste de integração do importador do seed (contagens: 99 produtos, 3 kits, 2 pedidos).


---

<!-- arquivo: .kiro/specs/balcao-revenda/tasks.md -->

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


---

<!-- arquivo: supabase/migrations/0001_schema.sql -->

## Migração SQL

```sql
-- Balcão Revenda — schema inicial (Supabase / Postgres)
-- Dinheiro: numeric(12,2) · Percentual: numeric(6,2) (20 = 20%) · Abelinhas: numeric(6,2)

create extension if not exists "pgcrypto";

-- ---------- utilitários ----------
create or replace function public.set_atualizado_em() returns trigger
language plpgsql as $$ begin new.atualizado_em = now(); return new; end $$;

-- ---------- empresas e membros ----------
create table public.empresas (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  criado_em timestamptz not null default now()
);

create table public.membros (
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  papel text not null default 'dono' check (papel in ('dono','operador')),
  criado_em timestamptz not null default now(),
  primary key (empresa_id, user_id)
);

create or replace function public.is_membro(p_empresa uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.membros m where m.empresa_id = p_empresa and m.user_id = auth.uid());
$$;

-- ---------- configurações ----------
create table public.configuracoes (
  empresa_id uuid primary key references public.empresas(id) on delete cascade,
  embalagem_padrao numeric(12,2) not null default 0.90,
  impressao_padrao numeric(12,2) not null default 1.00,
  valor_abelinha numeric(12,2) not null default 10.00,
  atualizado_em timestamptz not null default now()
);

create table public.faixas_abelinha (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  custo_ate numeric(12,2) not null,
  abelinhas numeric(6,2) not null,
  criado_em timestamptz not null default now()
);

-- ---------- cadastros ----------
create table public.produtos (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  codigo text not null,
  nome text not null,
  marca text not null default '',
  categoria text not null default 'Cosméticos',
  fornecedor text not null default '',
  custo numeric(12,2) not null default 0,
  unidade text not null default 'un',
  estoque integer not null default 0,
  ean text not null default '',
  ativo boolean not null default true,
  obs text not null default '',
  abelinhas_manual numeric(6,2),          -- null = calcula pela regra
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  unique (empresa_id, codigo)
);

create table public.plataformas (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  nome text not null,
  cor text not null default '#9A8FD4',
  obs text not null default '',
  ordem integer not null default 0,
  criado_em timestamptz not null default now()
);

create table public.faixas_taxa (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  plataforma_id uuid not null references public.plataformas(id) on delete cascade,
  preco_ate numeric(12,2),                -- null = sem limite
  taxa_fixa numeric(12,2) not null default 0,
  taxa_percentual numeric(6,2) not null default 0
);

create table public.destinos (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  nome text not null,
  cor text not null,
  percentual numeric(6,2) not null default 0,
  ordem integer not null default 0
);

create table public.compras_insumo (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  data date not null default current_date,
  tipo text not null default 'Embalagem' check (tipo in ('Embalagem','Etiqueta','Impressão','Fita / lacre','Brinde','Outros')),
  produto text not null,
  descricao text not null default '',
  valor_total numeric(12,2) not null,
  pacotes integer not null default 1,
  itens integer not null default 1 check (itens > 0),
  destino_id uuid references public.destinos(id) on delete set null,
  criado_em timestamptz not null default now()
);

-- ---------- produtos de venda (kits) ----------
create table public.produtos_venda (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  nome text not null,
  embalagem numeric(12,2) not null default 0,
  compra_insumo_id uuid references public.compras_insumo(id) on delete set null,
  impressao numeric(12,2) not null default 0,
  outros numeric(12,2) not null default 0,
  preco numeric(12,2) not null default 0,
  desconto numeric(12,2) not null default 0,
  cupom numeric(12,2) not null default 0,
  preco_concorrente numeric(12,2),
  meta_lucro numeric(12,2) not null default 200,
  fatia_roas numeric(5,4) not null default 0.3,
  margem_alvo numeric(6,2) not null default 30,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create table public.produtos_venda_itens (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  produto_venda_id uuid not null references public.produtos_venda(id) on delete cascade,
  produto_id uuid not null references public.produtos(id) on delete restrict,
  quantidade integer not null check (quantidade > 0)
);

create table public.produtos_venda_precos (
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  produto_venda_id uuid not null references public.produtos_venda(id) on delete cascade,
  plataforma_id uuid not null references public.plataformas(id) on delete cascade,
  preco numeric(12,2),          -- null = usa o preço base
  desconto numeric(12,2),
  cupom numeric(12,2),
  vendidos_iniciais integer not null default 0,
  primary key (produto_venda_id, plataforma_id)
);

-- ---------- pedidos ----------
create table public.pedidos (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  data date not null default current_date,
  cliente text not null,
  plataforma_id uuid not null references public.plataformas(id) on delete restrict,
  embalagem numeric(12,2) not null default 0,
  impressao numeric(12,2) not null default 0,
  outros numeric(12,2) not null default 0,
  preco_venda numeric(12,2) not null default 0,
  itens_taxa_fixa integer not null default 1,
  liquido_informado numeric(12,2),
  situacao text not null default 'concluido' check (situacao in ('concluido','cancelado','devolvido')),
  obs text not null default '',
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create table public.pedidos_itens (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  pedido_id uuid not null references public.pedidos(id) on delete cascade,
  tipo text not null check (tipo in ('produto','produto_venda')),
  produto_id uuid references public.produtos(id) on delete restrict,
  produto_venda_id uuid references public.produtos_venda(id) on delete restrict,
  quantidade integer not null check (quantidade > 0),
  custo_unitario numeric(12,2) not null,         -- snapshot no salvamento
  abelinhas_unitarias numeric(6,2) not null,     -- snapshot no salvamento
  check ((tipo = 'produto' and produto_id is not null and produto_venda_id is null)
      or (tipo = 'produto_venda' and produto_venda_id is not null and produto_id is null))
);

-- ---------- financeiro ----------
create table public.investimentos (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  data date not null default current_date,
  distribuidor text not null,
  valor numeric(12,2) not null,
  nota text not null default '',
  destino_id uuid references public.destinos(id) on delete set null,
  obs text not null default '',
  criado_em timestamptz not null default now()
);

create table public.saques (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  data date not null default current_date,
  plataforma_id uuid not null references public.plataformas(id) on delete restrict,
  valor numeric(12,2) not null,
  obs text not null default '',
  criado_em timestamptz not null default now()
);

create table public.saques_rateio (
  saque_id uuid not null references public.saques(id) on delete cascade,
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  destino_id uuid not null references public.destinos(id) on delete restrict,
  percentual numeric(6,2) not null,
  valor numeric(12,2) not null,
  primary key (saque_id, destino_id)
);

create table public.retiradas (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  data date not null default current_date,
  destino_id uuid not null references public.destinos(id) on delete restrict,
  valor numeric(12,2) not null,
  descricao text not null default '',
  criado_em timestamptz not null default now()
);

-- ---------- triggers atualizado_em ----------
create trigger trg_produtos_upd before update on public.produtos for each row execute function public.set_atualizado_em();
create trigger trg_pv_upd before update on public.produtos_venda for each row execute function public.set_atualizado_em();
create trigger trg_pedidos_upd before update on public.pedidos for each row execute function public.set_atualizado_em();
create trigger trg_config_upd before update on public.configuracoes for each row execute function public.set_atualizado_em();

-- ---------- índices ----------
create index on public.produtos (empresa_id);
create index on public.pedidos (empresa_id, data desc);
create index on public.pedidos_itens (pedido_id);
create index on public.produtos_venda_itens (produto_venda_id);
create index on public.faixas_taxa (plataforma_id);
create index on public.saques (empresa_id, data desc);

-- ---------- RLS ----------
do $$
declare t text;
begin
  foreach t in array array['configuracoes','faixas_abelinha','produtos','plataformas','faixas_taxa','destinos',
    'compras_insumo','produtos_venda','produtos_venda_itens','produtos_venda_precos','pedidos','pedidos_itens',
    'investimentos','saques','saques_rateio','retiradas']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('create policy %I on public.%I for all using (public.is_membro(empresa_id)) with check (public.is_membro(empresa_id))', t||'_membros', t);
  end loop;
end $$;

alter table public.empresas enable row level security;
create policy empresas_membros on public.empresas for select using (public.is_membro(id));
create policy empresas_update on public.empresas for update using (public.is_membro(id));

alter table public.membros enable row level security;
create policy membros_proprios on public.membros for select using (user_id = auth.uid() or public.is_membro(empresa_id));

-- ---------- RPC: criar empresa com padrões ----------
create or replace function public.criar_empresa(p_nome text) returns uuid
language plpgsql security definer set search_path = public as $$
declare v_emp uuid; v_pl uuid;
begin
  if auth.uid() is null then raise exception 'não autenticado'; end if;
  insert into empresas(nome) values (p_nome) returning id into v_emp;
  insert into membros(empresa_id, user_id, papel) values (v_emp, auth.uid(), 'dono');
  insert into configuracoes(empresa_id) values (v_emp);

  insert into faixas_abelinha(empresa_id, custo_ate, abelinhas) values
    (v_emp,5,0.5),(v_emp,8,1),(v_emp,12,1.5),(v_emp,16,2),(v_emp,20,2.5),(v_emp,24,3),(v_emp,28,3.5),(v_emp,32,4);

  insert into plataformas(empresa_id,nome,cor,obs,ordem) values (v_emp,'Shopee','#F0846A','Faixas da planilha (taxa fixa + %).',1) returning id into v_pl;
  insert into faixas_taxa(empresa_id,plataforma_id,preco_ate,taxa_fixa,taxa_percentual) values
    (v_emp,v_pl,79.99,4,20),(v_emp,v_pl,99.99,16,14),(v_emp,v_pl,199.99,20,14),(v_emp,v_pl,null,26,14);
  insert into plataformas(empresa_id,nome,cor,obs,ordem) values (v_emp,'TikTok Shop','#5BB8C2','Valores de exemplo: ajuste com a taxa do seu contrato.',2) returning id into v_pl;
  insert into faixas_taxa(empresa_id,plataforma_id,preco_ate,taxa_fixa,taxa_percentual) values (v_emp,v_pl,null,4,12);
  insert into plataformas(empresa_id,nome,cor,obs,ordem) values (v_emp,'Mercado Livre','#E5BF55','Valores de exemplo: ajuste conforme categoria e tipo de anúncio.',3) returning id into v_pl;
  insert into faixas_taxa(empresa_id,plataforma_id,preco_ate,taxa_fixa,taxa_percentual) values (v_emp,v_pl,78.99,6.25,14),(v_emp,v_pl,null,0,14);
  insert into plataformas(empresa_id,nome,cor,obs,ordem) values (v_emp,'Venda direta','#9A8FD4','Sem taxa (WhatsApp, Instagram, balcão).',4) returning id into v_pl;
  insert into faixas_taxa(empresa_id,plataforma_id,preco_ate,taxa_fixa,taxa_percentual) values (v_emp,v_pl,null,0,0);

  insert into destinos(empresa_id,nome,cor,percentual,ordem) values
    (v_emp,'Cartão, empréstimos','#6A9FD8',40,1),(v_emp,'Compras de produtos','#6FB59A',30,2),(v_emp,'Pró-labore','#E5BF55',30,3);
  return v_emp;
end $$;

grant execute on function public.criar_empresa(text) to authenticated;
```
