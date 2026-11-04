-- Balcão Revenda — schema inicial (Supabase / Postgres)
-- Dinheiro: numeric(12,2) · Percentual: numeric(6,2) (20 = 20%) · Abelinhas: numeric(6,2)

create extension if not exists "pgcrypto";

-- ---------- utilitários ----------
create or replace function public.set_atualizado_em() returns trigger
language plpgsql as $$ begin new.atualizado_em = now(); return new; end $$;

-- ---------- empresas e membros ----------
create table public.empresas (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  criado_em timestamptz not null default now()
);

create table public.membros (
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  papel text not null default 'dono' check (papel in ('dono','operador')),
  criado_em timestamptz not null default now(),
  primary key (empresa_id, user_id)
);

create or replace function public.is_membro(p_empresa uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.membros m where m.empresa_id = p_empresa and m.user_id = auth.uid());
$$;

-- ---------- configurações ----------
create table public.configuracoes (
  empresa_id uuid primary key references public.empresas(id) on delete cascade,
  embalagem_padrao numeric(12,2) not null default 0.90,
  impressao_padrao numeric(12,2) not null default 1.00,
  valor_abelinha numeric(12,2) not null default 10.00,
  atualizado_em timestamptz not null default now()
);

create table public.faixas_abelinha (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  custo_ate numeric(12,2) not null,
  abelinhas numeric(6,2) not null,
  criado_em timestamptz not null default now()
);

-- ---------- cadastros ----------
create table public.produto_online (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  codigo text not null,
  nome text not null,
  marca text not null default '',
  categoria text not null default 'Cosméticos',
  fornecedor text not null default '',
  custo numeric(12,2) not null default 0,
  unidade text not null default 'un',
  estoque integer not null default 0,
  ean text not null default '',
  ativo boolean not null default true,
  obs text not null default '',
  abelinhas_manual numeric(6,2),          -- null = calcula pela regra
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  unique (empresa_id, codigo)
);

create table public.plataformas (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  nome text not null,
  cor text not null default '#9A8FD4',
  obs text not null default '',
  ordem integer not null default 0,
  criado_em timestamptz not null default now()
);

create table public.faixas_taxa (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  plataforma_id uuid not null references public.plataformas(id) on delete cascade,
  preco_ate numeric(12,2),                -- null = sem limite
  taxa_fixa numeric(12,2) not null default 0,
  taxa_percentual numeric(6,2) not null default 0
);

create table public.destinos (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  nome text not null,
  cor text not null,
  percentual numeric(6,2) not null default 0,
  ordem integer not null default 0
);

create table public.compras_insumo (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  data date not null default current_date,
  tipo text not null default 'Embalagem' check (tipo in ('Embalagem','Etiqueta','Impressão','Fita / lacre','Brinde','Outros')),
  produto text not null,
  descricao text not null default '',
  valor_total numeric(12,2) not null,
  pacotes integer not null default 1,
  itens integer not null default 1 check (itens > 0),
  destino_id uuid references public.destinos(id) on delete set null,
  criado_em timestamptz not null default now()
);

-- ---------- produtos de venda (kits) ----------
create table public.produtos_venda (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  nome text not null,
  embalagem numeric(12,2) not null default 0,
  compra_insumo_id uuid references public.compras_insumo(id) on delete set null,
  impressao numeric(12,2) not null default 0,
  outros numeric(12,2) not null default 0,
  preco numeric(12,2) not null default 0,
  desconto numeric(12,2) not null default 0,
  cupom numeric(12,2) not null default 0,
  preco_concorrente numeric(12,2),
  meta_lucro numeric(12,2) not null default 200,
  fatia_roas numeric(5,4) not null default 0.3,
  margem_alvo numeric(6,2) not null default 30,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create table public.produtos_venda_itens (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  produto_venda_id uuid not null references public.produtos_venda(id) on delete cascade,
  produto_id uuid not null references public.produto_online(id) on delete restrict,
  quantidade integer not null check (quantidade > 0)
);

create table public.produtos_venda_precos (
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  produto_venda_id uuid not null references public.produtos_venda(id) on delete cascade,
  plataforma_id uuid not null references public.plataformas(id) on delete cascade,
  preco numeric(12,2),          -- null = usa o preço base
  desconto numeric(12,2),
  cupom numeric(12,2),
  vendidos_iniciais integer not null default 0,
  primary key (produto_venda_id, plataforma_id)
);

-- ---------- pedidos ----------
create table public.pedidos (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  data date not null default current_date,
  cliente text not null,
  plataforma_id uuid not null references public.plataformas(id) on delete restrict,
  embalagem numeric(12,2) not null default 0,
  impressao numeric(12,2) not null default 0,
  outros numeric(12,2) not null default 0,
  preco_venda numeric(12,2) not null default 0,
  itens_taxa_fixa integer not null default 1,
  liquido_informado numeric(12,2),
  situacao text not null default 'concluido' check (situacao in ('concluido','cancelado','devolvido')),
  obs text not null default '',
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create table public.pedidos_itens (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  pedido_id uuid not null references public.pedidos(id) on delete cascade,
  tipo text not null check (tipo in ('produto','produto_venda')),
  produto_id uuid references public.produto_online(id) on delete restrict,
  produto_venda_id uuid references public.produtos_venda(id) on delete restrict,
  quantidade integer not null check (quantidade > 0),
  custo_unitario numeric(12,2) not null,         -- snapshot no salvamento
  abelinhas_unitarias numeric(6,2) not null,     -- snapshot no salvamento
  check ((tipo = 'produto' and produto_id is not null and produto_venda_id is null)
      or (tipo = 'produto_venda' and produto_venda_id is not null and produto_id is null))
);

-- ---------- financeiro ----------
create table public.investimentos (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  data date not null default current_date,
  distribuidor text not null,
  valor numeric(12,2) not null,
  nota text not null default '',
  destino_id uuid references public.destinos(id) on delete set null,
  obs text not null default '',
  criado_em timestamptz not null default now()
);

create table public.saques (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  data date not null default current_date,
  plataforma_id uuid not null references public.plataformas(id) on delete restrict,
  valor numeric(12,2) not null,
  obs text not null default '',
  criado_em timestamptz not null default now()
);

create table public.saques_rateio (
  saque_id uuid not null references public.saques(id) on delete cascade,
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  destino_id uuid not null references public.destinos(id) on delete restrict,
  percentual numeric(6,2) not null,
  valor numeric(12,2) not null,
  primary key (saque_id, destino_id)
);

create table public.retiradas (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.empresas(id) on delete cascade,
  data date not null default current_date,
  destino_id uuid not null references public.destinos(id) on delete restrict,
  valor numeric(12,2) not null,
  descricao text not null default '',
  criado_em timestamptz not null default now()
);

-- ---------- triggers atualizado_em ----------
create trigger trg_produto_online_upd before update on public.produto_online for each row execute function public.set_atualizado_em();
create trigger trg_pv_upd before update on public.produtos_venda for each row execute function public.set_atualizado_em();
create trigger trg_pedidos_upd before update on public.pedidos for each row execute function public.set_atualizado_em();
create trigger trg_config_upd before update on public.configuracoes for each row execute function public.set_atualizado_em();

-- ---------- índices ----------
create index on public.produto_online (empresa_id);
create index on public.pedidos (empresa_id, data desc);
create index on public.pedidos_itens (pedido_id);
create index on public.produtos_venda_itens (produto_venda_id);
create index on public.faixas_taxa (plataforma_id);
create index on public.saques (empresa_id, data desc);

-- ---------- RLS ----------
do $$
declare t text;
begin
  foreach t in array array['configuracoes','faixas_abelinha','produto_online','plataformas','faixas_taxa','destinos',
    'compras_insumo','produtos_venda','produtos_venda_itens','produtos_venda_precos','pedidos','pedidos_itens',
    'investimentos','saques','saques_rateio','retiradas']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('create policy %I on public.%I for all using (public.is_membro(empresa_id)) with check (public.is_membro(empresa_id))', t||'_membros', t);
  end loop;
end $$;

alter table public.empresas enable row level security;
create policy empresas_membros on public.empresas for select using (public.is_membro(id));
create policy empresas_update on public.empresas for update using (public.is_membro(id));

alter table public.membros enable row level security;
create policy membros_proprios on public.membros for select using (user_id = auth.uid() or public.is_membro(empresa_id));

-- ---------- RPC: criar empresa com padrões ----------
create or replace function public.criar_empresa(p_nome text) returns uuid
language plpgsql security definer set search_path = public as $$
declare v_emp uuid; v_pl uuid;
begin
  if auth.uid() is null then raise exception 'não autenticado'; end if;
  insert into empresas(nome) values (p_nome) returning id into v_emp;
  insert into membros(empresa_id, user_id, papel) values (v_emp, auth.uid(), 'dono');
  insert into configuracoes(empresa_id) values (v_emp);

  insert into faixas_abelinha(empresa_id, custo_ate, abelinhas) values
    (v_emp,5,0.5),(v_emp,8,1),(v_emp,12,1.5),(v_emp,16,2),(v_emp,20,2.5),(v_emp,24,3),(v_emp,28,3.5),(v_emp,32,4);

  insert into plataformas(empresa_id,nome,cor,obs,ordem) values (v_emp,'Shopee','#F0846A','Faixas da planilha (taxa fixa + %).',1) returning id into v_pl;
  insert into faixas_taxa(empresa_id,plataforma_id,preco_ate,taxa_fixa,taxa_percentual) values
    (v_emp,v_pl,79.99,4,20),(v_emp,v_pl,99.99,16,14),(v_emp,v_pl,199.99,20,14),(v_emp,v_pl,null,26,14);
  insert into plataformas(empresa_id,nome,cor,obs,ordem) values (v_emp,'TikTok Shop','#5BB8C2','Valores de exemplo: ajuste com a taxa do seu contrato.',2) returning id into v_pl;
  insert into faixas_taxa(empresa_id,plataforma_id,preco_ate,taxa_fixa,taxa_percentual) values (v_emp,v_pl,null,4,12);
  insert into plataformas(empresa_id,nome,cor,obs,ordem) values (v_emp,'Mercado Livre','#E5BF55','Valores de exemplo: ajuste conforme categoria e tipo de anúncio.',3) returning id into v_pl;
  insert into faixas_taxa(empresa_id,plataforma_id,preco_ate,taxa_fixa,taxa_percentual) values (v_emp,v_pl,78.99,6.25,14),(v_emp,v_pl,null,0,14);
  insert into plataformas(empresa_id,nome,cor,obs,ordem) values (v_emp,'Venda direta','#9A8FD4','Sem taxa (WhatsApp, Instagram, balcão).',4) returning id into v_pl;
  insert into faixas_taxa(empresa_id,plataforma_id,preco_ate,taxa_fixa,taxa_percentual) values (v_emp,v_pl,null,0,0);

  insert into destinos(empresa_id,nome,cor,percentual,ordem) values
    (v_emp,'Cartão, empréstimos','#6A9FD8',40,1),(v_emp,'Compras de produtos','#6FB59A',30,2),(v_emp,'Pró-labore','#E5BF55',30,3);
  return v_emp;
end $$;

grant execute on function public.criar_empresa(text) to authenticated;
