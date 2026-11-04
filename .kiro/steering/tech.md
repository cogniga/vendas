---
inclusion: always
---

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
