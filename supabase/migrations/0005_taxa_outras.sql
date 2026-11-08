-- Outras taxas percentuais por faixa (ex.: taxa de frete do TikTok), somadas
-- ao percentual da faixa nos cálculos. 0 = não cobra.
alter table public.faixas_taxa
  add column if not exists taxa_outras numeric(6,2) not null default 0;
