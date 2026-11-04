# mf_arquitetura — Balcão Revenda

> Documento de arquitetura de referência exigido pelas regras do projeto.
> Fonte canônica completa: `.kiro/steering/structure.md`, `.kiro/steering/tech.md` e
> `.kiro/specs/balcao-revenda/design.md`. Em caso de conflito, o `.kiro` prevalece.

## Visão

Aplicação Flutter multiplataforma (macOS, Windows, Web e Android) para gestão de
revenda online, com backend **Supabase** (Postgres + Auth + RLS por empresa).

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

## Camadas

- **domain**: entidades `freezed` e **cálculos puros** (`lib/domain/calculos/`), sem
  dependência de Flutter ou Supabase. Todo cálculo de negócio vive aqui, com testes de
  unidade usando os vetores de `design.md §6`.
- **data**: um repositório por agregado, usando Supabase. Nenhuma chamada ao Supabase
  dentro de widget.
- **features**: cada feature com `presentation/` (pages, widgets) e `application/`
  (providers/controllers Riverpod).
- **core**: `config` (env via `--dart-define`, client Supabase), `router` (go_router +
  guards), `theme` (tokens §7), `format` (moeda/percentual/data/abelinhas/padrão de
  escrita) e `widgets` compartilhados.

## Estrutura de pastas (pacote único em camadas)

```
lib/
├─ main.dart
├─ app.dart                     # MaterialApp.router, tema, locale pt_BR
├─ core/{config,router,theme,format,widgets}/
├─ domain/{entidades,calculos}/
├─ data/repositorios/
└─ features/{auth,painel,pedidos,composicao,produtos,compras_insumos,
             investimento,caixa,plataformas,abelinhas,configuracoes}/
test/{domain/calculos,widgets}/
supabase/migrations/0001_schema.sql
assets/seed/dados-iniciais.json
docs/{prototipo,telas}/
```

## Regras de arquitetura

- Dinheiro: `Decimal` no Dart, `numeric(12,2)` no Postgres. Percentuais `numeric(6,2)`
  (20 = 20%). Arredondar só na exibição, exceto onde a spec indica.
- Toda tabela tem `empresa_id` e RLS habilitada; nenhuma consulta sem filtro de empresa.
- `SUPABASE_URL` e `SUPABASE_ANON_KEY` só via `--dart-define` (nunca no código).
- Datas: `date` no banco; exibição `dd/MM/yyyy`.
- Responsividade por `LayoutBuilder`/helper central, nunca `MediaQuery` espalhado.
- Começar pela versão mais simples que satisfaça a spec, sempre responsiva.

## Convenções

- Arquivos `snake_case.dart`; classes `PascalCase`; nomes de domínio em **português**.
- Colunas do banco em `snake_case` português; `@JsonKey(name: ...)` quando o nome Dart difere.
- Cada classe criada deve ter um arquivo `documento_{nome_da_classe}.md` em `docs/classes/`
  mantido atualizado a cada alteração (regra do projeto).
