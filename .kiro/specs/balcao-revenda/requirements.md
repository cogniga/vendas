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
