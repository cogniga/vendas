---
inclusion: always
---

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
