-- Padrão de escrita dos nomes (produto, marca, fornecedor, insumo,
-- distribuidor, kit), escolhido por empresa em Dados e configurações.
alter table public.configuracoes
  add column if not exists padrao_nome text not null default 'titulo';

alter table public.configuracoes
  drop constraint if exists configuracoes_padrao_nome_check;

alter table public.configuracoes
  add constraint configuracoes_padrao_nome_check
  check (padrao_nome in ('titulo', 'maiusculas', 'minusculas'));
