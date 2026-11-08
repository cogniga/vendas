# Verificação: editor de pedido (perda de itens + layout do protótipo)

## Causa raiz (confirmada lendo o código)
- `PedidoRepository.listar` só lia `pedidos`; o `Pedido` da lista vinha com `itens` vazio.
- `PedidosPage._abrirEditor` passava esse pedido ao `PedidoEditor`, que montava as linhas de `widget.pedido.itens` (vazio). Por isso os itens "sumiam" ao reabrir. A gravação (insert em `pedidos_itens`) já estava correta; só a leitura falhava. O teste de round-trip do repositório confirma o mapeamento das colunas.

## Correção
- `listar` agora busca `pedidos_itens` por `empresa_id` e agrupa por `pedido_id` (lista, painel e caixa passam a ter itens).
- `pedidoCompletoProvider` (autoDispose, family) → `obterComItens`. O editor só monta o formulário depois de carregar o pedido completo; durante o carregamento o Salvar fica desabilitado. Assim um pedido não carregado nunca regrava (apaga) itens.
- Itens já gravados mantêm o snapshot de custo/abelinhas (inclusive produto/kit que não existe mais no cadastro). Itens novos usam o cadastro atual.
- Depois de salvar/excluir: invalida `pedidosProvider` (pedidos e composição, que alimenta painel/caixa) e `pedidoCompletoProvider`.
- UI reescrita conforme `openPed`/`pedSum` do protótipo (`PedidoResumo` novo, `PainelCard`, `Ledger`, `Pill`, `CodeChip`, `BotaoPequeno`, `MoneyField`). `lib/domain/calculos/pedido.dart` não foi alterado.

## Comandos e resultados
| Comando | Resultado |
|---|---|
| `flutter analyze lib test` | `No issues found!` |
| `flutter test` | `All tests passed!` (117 testes) |
| `flutter test test/data/pedido_repository_test.dart` | 3 passam (listar agrupa itens; sem itens = lista vazia; salvar insere colunas/`tipo` certos para produto e kit) |
| `flutter test test/widgets/pedido_editor_test.dart` | 7 passam (abrir pedido existente mostra itens do pedido completo mesmo com o da lista sem itens; carregando = indicador + Salvar desabilitado; remover/mudar quantidade/adicionar e salvar; salvar sem alterar mantém itens, snapshots e item órfão; layout a 1440 px e 400 px com textos do protótipo e `takeException() == null`; pedido novo vazio) |
| `flutter build macos --debug --dart-define-from-file=env/supabase.json` | `✓ Built build/macos/Build/Products/Debug/sales.app` |

O teste de 400 px achou um overflow real (rodapé Cancelar/Salvar e linha do seletor); ambos corrigidos (rodapé em `Wrap`, linha do seletor em duas linhas abaixo de 380 px).

## Mudanças adicionais
- `pubspec.yaml`: `http: 1.6.0` em `dev_dependencies` (já era transitiva, mesma versão do lock) para o `MockClient` do teste do repositório.
- Docs: `docs/decisoes.md` (D10), `docs/classes/documento_PedidoEditor.md`, `documento_PedidoResumo.md`, seções em `documento_features.md` e `documento_dados.md`.
- Sem migration.

## Diferenças deliberadas em relação ao protótipo
1. Status: só Pago / Devolvido / Cancelado. "Enviado" e "Entregue" exigem migration no check de `pedidos.situacao` (D10).
2. Botão "Remover item" (ícone lixeira com Tooltip e Semantics) em cada linha; o protótipo só remove levando a quantidade a 0. Acrescentado porque o pedido era "tirar umas coisas".
3. Botões −/+ da quantidade têm Tooltip e Semantics (acessibilidade exigida pelo projeto).
4. Coluna do resumo "sticky" é uma coluna com rolagem própria (não `position: sticky`); o resultado visual é o mesmo (resumo sempre visível em telas largas).
5. Título do editor ao editar é "Pedido" (como `openPed`), sem "Editar pedido".
6. Pedido existente preserva o snapshot de custo/abelinhas dos itens (o protótipo guarda só ref/qtd e recalcula); decisão do plano para não alterar histórico.
7. Campos de data usam o seletor de data do Flutter em vez de `<input type=date>`.
8. Picker lista só produtos ativos (até 60), como o protótipo, e em largura < 380 px o custo e o botão "Adicionar" descem para a linha de baixo.
9. Painel "Itens mais vendidos": sem mudança de código; já usa `pedido.itens` e passa a receber os itens pelo `listar` (teste existente do painel já cobre pedido com itens).

Não verificado: comportamento contra o Supabase real (testes usam cliente HTTP falso); aparência visual comparada pixel a pixel com `docs/telas/03-pedido-editor.png` (não foi aberto o app em execução).
