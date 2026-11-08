# Git e publicação

Regra definida pela dona do projeto: **toda alteração concluída deve ser commitada e enviada (push) para o repositório oficial**, sem precisar pedir.

- Repositório oficial: `https://github.com/cogniga/vendas` (remoto `origin`, branch `main`).
- Ao terminar cada alteração pedida, depois de `flutter analyze lib test` limpo e `flutter test` verde:
  1. `git add` dos arquivos alterados (inclusive `env/supabase.json`, que é versionado por decisão da dona);
  2. commit com mensagem em português descrevendo a mudança;
  3. `git push origin main`.
- Se a análise ou os testes falharem, corrigir antes de commitar; não enviar código quebrado.
- Autenticação: a conta `raquel7pay` via GitHub CLI (`gh`). Não há chave SSH nesta máquina; usar HTTPS com o token do `gh` (ex.: `GIT_ASKPASS` temporário que responde `x-access-token` / `gh auth token`), sem alterar a configuração global do git.
- Nunca usar `push --force` nem reescrever histórico já enviado sem pedido explícito.
- Se o GitHub bloquear o push (ex.: push protection por segredo), avisar a dona com o motivo e o link, sem contornar por conta própria.
- Não versionar artefatos gerados: `build/`, `dist/`, `.dart_tool/` (já no `.gitignore`).
