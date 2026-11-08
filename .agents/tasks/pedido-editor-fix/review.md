# Editor de pedido: itens preservados e layout do protótipo

O `PedidoRepository.listar` agora traz os itens (consulta extra em `pedidos_itens` por `empresa_id`, agrupada por `pedido_id`). O editor busca o pedido completo via `pedidoCompletoProvider` e só monta o formulário depois do carregamento. A UI foi reescrita seguindo `openPed`/`pedSum` do protótipo, com `PedidoResumo` novo.

Watch for: editor com 1316 linhas (plano sugeria quebrar perto de 400; confirmed, não bloqueante). Sem verificação visual contra o PNG e sem teste contra Supabase real (declarado pelo coder).

**Verdict**: APPROVED

## High-level view

A causa raiz era leitura: `listar` devolvia pedidos sem itens e o editor montava as linhas dessa lista vazia. A correção atua em duas frentes, lista com itens e editor que carrega o completo, o que também corrige o ranking do painel e o custo/lucro da lista.

A proteção contra apagar itens é estrutural. Enquanto o pedido completo não chega, o formulário não existe e o Salvar fica desabilitado. Itens já gravados mantêm o snapshot de custo/abelinhas, inclusive quando o produto ou kit sumiu do cadastro.

O layout segue o protótipo: título "Pedido"/"Novo pedido", "Fechar" em texto, grade de 4 campos com rótulo acima, painéis, resumo à direita e empilhamento abaixo de 860 px. Os testes de widget cobrem 1440 e 400 px sem exceção de overflow.

<details>
<summary>Issues (2)</summary>

1. **Arquivo grande (confirmed, não bloqueante)** — `pedido_editor.dart` tem 1316 linhas; extrair picker e lista de itens em widgets próprios quando houver oportunidade.
2. **Sem verificação visual/real (confirmed, informativo)** — comparação com `03-pedido-editor.png` e Supabase real não foram feitas; conferir manualmente.

</details>

<details>
<summary>Details</summary>

## Perda de itens: leitura corrigida e proteção por construção

`listar` agrupa `pedidos_itens` em um mapa por `pedido_id` e aplica `copyWith(itens:)`; pedidos sem itens recebem lista vazia (`pedido_repository.dart`). `PedidoEditor` observa `pedidoCompletoProvider(id)` e `dadosEdicaoPedidoProvider`; durante o carregamento renderiza só a casca com indicador, sem `aoSalvar`, então o botão fica desabilitado. Erro mostra "Tentar de novo"; pedido inexistente mostra mensagem. Como `_PedidoForm` só inicializa `_linhas` a partir do pedido completo, `salvar` (delete + insert) nunca recebe lista de itens não carregada. A guarda "Adicione pelo menos um item" continua como segunda barreira.

`_snapshot` devolve o snapshot do `original` quando existe, então item órfão (produto/kit removido) não é descartado em `_montarPedido` e não altera o histórico. Remover (lixeira), diminuir até 0 e aumentar funcionam; itens novos usam o cadastro atual. O teste `salvar sem alterar` cobre o órfão e os snapshots; os testes de abrir/carregar/editar cobrem o caso da lista sem itens.

## Invalidação de providers

`_atualizar` invalida `pedidosProvider` (pedidos), `composicao.pedidosProvider` e `pedidoCompletoProvider(id)` após salvar e excluir. Painel e caixa fazem watch do `pedidosProvider` de pedidos, e a composição do seu, ambos cobertos. `itensMaisVendidos` já recebia `pedido.itens` e passa a receber dados reais; o teste do painel tem pedido com itens.

## Fidelidade ao protótipo

Presentes no código e verificados nos testes a 1440 e 400 px: título, "Fechar" como `TextButton`, rodapé "Cancelar"/"Salvar pedido" em `Wrap`, grade `auto-fit` de 180 px com rótulo acima (`_Campo`), pill `kit` e `CodeChip` com `BotaoPequeno` "Adicionar", dicas de custos e venda, `PedidoResumo` com custo, abelinhas, venda, lucro e margem. Sem scroll horizontal. Desvios declarados e aceitáveis: status Pago/Devolvido/Cancelado (D10, sem migration), lixeira extra com Tooltip+Semantics, coluna de resumo com rolagem própria em vez de sticky.

## Convenções

`lib/domain/calculos/pedido.dart` sem alterações no git. Nenhuma chamada Supabase em widget (usa repositório via provider). Botões de ícone (remover, −, +) têm Tooltip e Semantics. Docs: D10 em `docs/decisoes.md`, `documento_PedidoEditor.md`, `documento_PedidoResumo.md`, seções em features/dados. Evidência do coder: analyze limpo, 117 testes passando, build macOS.

</details>

<details>
<summary>File map</summary>

- `lib/data/repositorios/pedido_repository.dart`: listar com itens
- `lib/features/pedidos/application/pedidos_providers.dart`: `pedidoCompletoProvider`
- `lib/features/pedidos/presentation/pedido_editor.dart`: editor reescrito
- `lib/features/pedidos/presentation/pedido_resumo.dart`: resumo novo
- `lib/features/pedidos/presentation/pedidos_page.dart`: invalidação
- `test/data/pedido_repository_test.dart`, `test/widgets/pedido_editor_test.dart`: testes
- `docs/*`: D10 e documentos de classe

</details>
