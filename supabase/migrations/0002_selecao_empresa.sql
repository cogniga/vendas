-- Balcão Revenda — seleção de empresa padrão pelo usuário
-- Permite listar TODAS as empresas e vincular o usuário atual como membro
-- da empresa escolhida, para o seletor em "Dados e configurações".

-- Lista todas as empresas (id, nome, criado_em) ignorando o RLS de forma
-- controlada (security definer). Usada só para popular o seletor de empresa.
create or replace function public.listar_todas_empresas()
returns setof public.empresas
language sql
security definer
set search_path = public
as $$
  select * from public.empresas order by criado_em asc;
$$;

grant execute on function public.listar_todas_empresas() to authenticated, anon;

-- Vincula o usuário autenticado (inclui anônimo) como membro da empresa
-- [p_empresa], se ainda não for. Idempotente. Retorna o id da empresa.
create or replace function public.entrar_empresa(p_empresa uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'não autenticado';
  end if;
  if not exists (select 1 from public.empresas e where e.id = p_empresa) then
    raise exception 'empresa não encontrada';
  end if;
  insert into public.membros (empresa_id, user_id, papel)
  values (p_empresa, auth.uid(), 'dono')
  on conflict (empresa_id, user_id) do nothing;
  return p_empresa;
end $$;

grant execute on function public.entrar_empresa(uuid) to authenticated, anon;
