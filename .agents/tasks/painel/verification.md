# Verificação do Painel

- `flutter analyze lib test`: No issues found.
- `flutter test`: All tests passed (103 testes, incluindo `test/domain/calculos/painel_test.dart` e `test/widgets/painel_page_test.dart` a 1440px e 400px, vazio, troca de período, navegação ao caixa, tema escuro).
- `flutter build macos --debug --dart-define-from-file=env/supabase.json`: sucesso.
- Não verificado: comparação visual lado a lado com os prints (app não foi aberto nesta execução).

## Diferenças deliberadas em relação ao protótipo
- Alerta "Estoque baixo" omitido: `Produto` não tem `estoque_min` (D7). Sem migration.
- Só pedidos `concluido` entram (D8); o protótipo exclui apenas "Cancelado".
- "Novo pedido" abre o `PedidoEditor` do app (diálogo), não o do protótipo.
- Se não houver dados carregados ainda, aparece um spinner só na primeira carga.
