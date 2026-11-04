# Decisões do projeto

Registro de decisões que desviam da spec original do protótipo. Os agentes de
implementação devem seguir estas decisões.

## D1 — Tabela de produtos renomeada para `produto_online`

- **Data:** solicitado pela usuária.
- **O que mudou:** a tabela `produtos` do schema original passou a se chamar
  `produto_online` em `supabase/migrations/0001_schema.sql`.
- **Pontos ajustados no SQL:** definição da tabela, FK em
  `produtos_venda_itens.produto_id`, FK em `pedidos_itens.produto_id`, trigger
  `trg_produto_online_upd`, índice por `empresa_id` e o array da RLS.
- **NÃO confundir:** `produtos_venda`, `produtos_venda_itens`,
  `produtos_venda_precos` e `pedidos_itens.produto_venda_id` são sobre o
  "produto de venda" (kit) — permanecem com o nome original. A coluna
  `compras_insumo.produto` é texto livre (nome do insumo), não FK — inalterada.
- **Impacto no código Dart:**
  - A entidade `Produto` (`lib/domain/entidades/produto.dart`) não fixa o nome
    da tabela em código; só os comentários de doc foram atualizados.
  - **Repositórios (a implementar):** ao consultar o Supabase, usar o nome de
    tabela `produto_online` (ex.: `client.from('produto_online')`), não
    `produtos`.
  - O importador do seed e qualquer consulta de produtos devem usar
    `produto_online`.

## D2 — Credenciais do Supabase com fallback para `env/supabase.json`

- **Data:** solicitado pela usuária (app precisa pegar as chaves sozinho, sem
  passar flag a cada execução).
- **O que mudou:** `lib/core/config/ambiente.dart` resolve as credenciais em duas
  camadas: primeiro os `--dart-define` (se presentes); senão, lê o asset
  `env/supabase.json`. `Ambiente.carregar()` é chamado em `main()` antes de
  inicializar o Supabase.
- **pubspec:** `env/supabase.json` declarado como asset.
- **Consequência:** rodar pelo botão "Run" do editor (sem flag) funciona. Para
  builds de produção/CI, prefira `--dart-define-from-file=env/supabase.json` para
  não embutir a chave no bundle.
- **Segurança:** usar sempre a chave **publishable/anon** (respeita RLS), nunca a
  `service_role`/secret. `env/supabase.json` está no `.gitignore`.
- **Fonte:** Plus Jakarta Sans empacotada como asset local (`assets/fonts/`) em
  vez de baixar via `google_fonts` em runtime (removido). Entitlements do macOS
  ganharam `com.apple.security.network.client` (necessário ao Supabase).
