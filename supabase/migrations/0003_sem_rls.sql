-- Balcão Revenda — desliga o RLS (modo sem login/sessão)
-- ATENÇÃO: modo de DESENVOLVIMENTO. Sem RLS, qualquer cliente com a chave
-- publishable acessa todos os dados. Religar o RLS antes de produção.

-- ---------- desliga RLS e remove políticas de todas as tabelas ----------
do $$
declare t text;
begin
  foreach t in array array[
    'empresas','membros','configuracoes','faixas_abelinha','produto_online',
    'plataformas','faixas_taxa','destinos','compras_insumo','produtos_venda',
    'produtos_venda_itens','produtos_venda_precos','pedidos','pedidos_itens',
    'investimentos','saques','saques_rateio','retiradas']
  loop
    execute format('alter table public.%I disable row level security', t);
    -- remove quaisquer políticas remanescentes
    execute (
      select coalesce(string_agg(
        format('drop policy if exists %I on public.%I;', pol.policyname, t),
        ' '), '')
      from pg_policies pol
      where pol.schemaname = 'public' and pol.tablename = t
    );
  end loop;
end $$;

-- ---------- criar_empresa sem exigir usuário autenticado ----------
-- Recria a RPC para funcionar sem sessão: cria a empresa e os padrões, mas
-- NÃO insere em `membros` (não há usuário). Mantém o restante do seed padrão.
create or replace function public.criar_empresa(p_nome text) returns uuid
language plpgsql security definer set search_path = public as $$
declare v_emp uuid; v_pl uuid;
begin
  insert into empresas(nome) values (p_nome) returning id into v_emp;
  insert into configuracoes(empresa_id) values (v_emp);

  insert into faixas_abelinha(empresa_id, custo_ate, abelinhas) values
    (v_emp,5,0.5),(v_emp,8,1),(v_emp,12,1.5),(v_emp,16,2),
    (v_emp,20,2.5),(v_emp,24,3),(v_emp,28,3.5),(v_emp,32,4);

  insert into plataformas(empresa_id,nome,cor,obs,ordem)
    values (v_emp,'Shopee','#F0846A','Faixas da planilha (taxa fixa + %).',1)
    returning id into v_pl;
  insert into faixas_taxa(empresa_id,plataforma_id,preco_ate,taxa_fixa,taxa_percentual) values
    (v_emp,v_pl,79.99,4,20),(v_emp,v_pl,99.99,16,14),
    (v_emp,v_pl,199.99,20,14),(v_emp,v_pl,null,26,14);
  insert into plataformas(empresa_id,nome,cor,obs,ordem)
    values (v_emp,'TikTok Shop','#5BB8C2','Valores de exemplo: ajuste com a taxa do seu contrato.',2)
    returning id into v_pl;
  insert into faixas_taxa(empresa_id,plataforma_id,preco_ate,taxa_fixa,taxa_percentual)
    values (v_emp,v_pl,null,4,12);
  insert into plataformas(empresa_id,nome,cor,obs,ordem)
    values (v_emp,'Mercado Livre','#E5BF55','Valores de exemplo: ajuste conforme categoria e tipo de anúncio.',3)
    returning id into v_pl;
  insert into faixas_taxa(empresa_id,plataforma_id,preco_ate,taxa_fixa,taxa_percentual)
    values (v_emp,v_pl,78.99,6.25,14),(v_emp,v_pl,null,0,14);
  insert into plataformas(empresa_id,nome,cor,obs,ordem)
    values (v_emp,'Venda direta','#9A8FD4','Sem taxa (WhatsApp, Instagram, balcão).',4)
    returning id into v_pl;
  insert into faixas_taxa(empresa_id,plataforma_id,preco_ate,taxa_fixa,taxa_percentual)
    values (v_emp,v_pl,null,0,0);

  insert into destinos(empresa_id,nome,cor,percentual,ordem) values
    (v_emp,'Cartão, empréstimos','#6A9FD8',40,1),
    (v_emp,'Compras de produtos','#6FB59A',30,2),
    (v_emp,'Pró-labore','#E5BF55',30,3);
  return v_emp;
end $$;

grant execute on function public.criar_empresa(text) to authenticated, anon;

-- entrar_empresa vira no-op (sem membros): apenas confirma que existe.
create or replace function public.entrar_empresa(p_empresa uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (select 1 from public.empresas e where e.id = p_empresa) then
    raise exception 'empresa não encontrada';
  end if;
  return p_empresa;
end $$;

grant execute on function public.entrar_empresa(uuid) to authenticated, anon;
