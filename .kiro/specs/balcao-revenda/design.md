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
