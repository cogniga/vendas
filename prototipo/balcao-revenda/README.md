# Balcão Revenda — pacote de especificação para o Kiro

Sistema de gestão de revenda online (produtos, composição de custo, pedidos por plataforma, insumos, investimento, caixa e regra de abelinhas) a ser desenvolvido em **Flutter** (macOS, Windows, Web e Android) com **Supabase**.

## Como usar no Kiro
1. Crie uma pasta vazia para o projeto e copie **todo o conteúdo deste pacote** para ela (inclusive a pasta oculta `.kiro`).
2. Abra a pasta no Kiro. Ele lê automaticamente:
   - `.kiro/steering/` — contexto permanente (produto, stack, estrutura).
   - `.kiro/specs/balcao-revenda/` — `requirements.md`, `design.md` e `tasks.md`.
3. No painel **Specs**, abra `balcao-revenda` e execute as tarefas de `tasks.md` em ordem (comece pela 1.1). Revise e aprove cada etapa.
4. Antes da tarefa 2.1, crie um projeto no Supabase e rode `supabase/migrations/0001_schema.sql` (SQL Editor ou `supabase db push`).
5. Rode o app com:
   ```bash
   flutter run -d macos --dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co --dart-define=SUPABASE_ANON_KEY=SUA_CHAVE
   ```

## Conteúdo
| Caminho | O que é |
|---|---|
| `.kiro/steering/product.md` | Visão do produto e princípios |
| `.kiro/steering/tech.md` | Stack, regras técnicas e comandos |
| `.kiro/steering/structure.md` | Estrutura de pastas e convenções |
| `.kiro/specs/balcao-revenda/requirements.md` | 14 requisitos com critérios de aceite (EARS) |
| `.kiro/specs/balcao-revenda/design.md` | Arquitetura, modelo de dados, **fórmulas com vetores de teste**, tokens de UI, breakpoints, padrão de escrita |
| `.kiro/specs/balcao-revenda/tasks.md` | Plano de implementação em 15 etapas |
| `supabase/migrations/0001_schema.sql` | Tabelas, RLS por empresa e RPC `criar_empresa` |
| `assets/seed/dados-iniciais.json` | Dados da planilha (99 produtos, 3 kits, 2 pedidos, etc.) para importar no primeiro acesso |
| `assets/seed/produtos.csv` | Mesma lista de produtos em CSV (conferência) |
| `docs/prototipo/balcao-revenda.html` | Protótipo funcional — abra no navegador |
| `docs/telas/*.png` | 18 capturas das telas (claro, escuro, meia tela e celular) |

## Onde o sistema final difere do protótipo (decisões já tomadas na spec)
- **Dados no Supabase** com login e isolamento por empresa (o protótipo salva no navegador).
- **Pedido guarda custo e abelinhas do momento da venda** (snapshot); mudanças posteriores no cadastro não alteram pedidos antigos. O pedido tem botão para atualizar os custos se o usuário quiser.
- **Situação do pedido**: Concluído (padrão), Cancelado ou Devolvido. O protótipo ainda mostra "Pago/Enviado/Entregue" no formulário — ignore.
- **Código do produto é único** por empresa. Os dois `CHSTICH` da planilha viraram `CHSTICH-AZ` e `CHSTICH-RS` no seed.
- **Estoque mínimo** foi removido.
- As taxas de **TikTok Shop** e **Mercado Livre** são exemplos — ajuste em Plataformas e taxas com os valores reais do seu contrato.
