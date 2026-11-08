import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/botao_pequeno.dart';
import 'package:sales/core/widgets/painel_card.dart';
import 'package:sales/core/widgets/pill.dart';
import 'package:sales/domain/calculos/painel.dart';
import 'package:sales/features/caixa/presentation/cor_destino.dart';
import 'package:sales/features/painel/application/painel_providers.dart';

const _tabular = [FontFeature.tabularFigures()];

/// Mensagem de lista vazia (`.empty`).
class _Vazio extends StatelessWidget {
  const _Vazio(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Center(
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.cores.muted),
        ),
      ),
    );
  }
}

/// Painel "Vendas por plataforma".
class PainelVendasPlataforma extends StatelessWidget {
  const PainelVendasPlataforma({required this.vendas, super.key});

  final List<VendaPlataformaPainel> vendas;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return PainelCard(
      titulo: 'Vendas por plataforma',
      trailing: Text('bruto · líquido', style: TextStyle(color: cores.muted)),
      corpo: vendas.isEmpty
          ? const _Vazio('Nenhum pedido no período.')
          : LayoutBuilder(
              builder: (context, c) {
                final estreito = c.maxWidth < 480;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < vendas.length; i++) ...[
                      if (i > 0) const SizedBox(height: 14),
                      _Barra(venda: vendas[i], largura: estreito ? 90 : 120),
                    ],
                  ],
                );
              },
            ),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({required this.venda, required this.largura});

  final VendaPlataformaPainel venda;
  final double largura;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final cor = venda.cor == null
        ? cores.accent
        : corDoDestino(context, venda.cor!);
    return Row(
      children: [
        SizedBox(width: largura, child: Text(venda.nome)),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 8,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: cores.surface2,
              borderRadius: BorderRadius.circular(99),
            ),
            child: FractionallySizedBox(
              widthFactor: venda.fracao,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: largura == 120 ? 110 : 90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatos.moedaDecimal(venda.bruto),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFeatures: _tabular,
                ),
              ),
              Text(
                '${Formatos.moedaDecimal(venda.liquido)} líq.',
                style: TextStyle(
                  fontSize: 12,
                  color: cores.muted,
                  fontFeatures: _tabular,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Painel "Pontos de atenção".
class PainelAtencao extends StatelessWidget {
  const PainelAtencao({required this.pontos, super.key});

  final List<PontoAtencao> pontos;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return PainelCard(
      titulo: 'Pontos de atenção',
      trailing: pontos.isEmpty
          ? const Pill('Tudo certo', tom: TomPill.bom)
          : Pill('${pontos.length}', tom: TomPill.atencao),
      corpo: pontos.isEmpty
          ? const _Vazio('Nenhum alerta.')
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < pontos.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: pontos[i].gravidade == GravidadeAtencao.ruim
                          ? cores.badSoft
                          : cores.warnSoft,
                      borderRadius: BorderRadius.circular(Raios.controle),
                    ),
                    child: Text(
                      pontos[i].mensagem,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: pontos[i].gravidade == GravidadeAtencao.ruim
                            ? cores.bad
                            : cores.warn,
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

/// Painel "Caixa por destino".
class PainelCaixa extends StatelessWidget {
  const PainelCaixa({
    required this.destinos,
    required this.totalSacado,
    required this.onAbrirCaixa,
    super.key,
  });

  final List<DestinoComSaldo> destinos;
  final Decimal totalSacado;
  final VoidCallback onAbrirCaixa;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return PainelCard(
      titulo: 'Caixa por destino',
      trailing: BotaoPequeno(rotulo: 'Abrir caixa', onPressed: onAbrirCaixa),
      corpo: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final d in destinos)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: cores.line)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: corDoDestino(context, d.destino.cor),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '${d.destino.nome} '),
                          TextSpan(
                            text: Formatos.pontos(
                              d.destino.percentual.toDouble(),
                            ),
                            style: TextStyle(color: cores.muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    Formatos.moedaDecimal(d.saldo),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFeatures: _tabular,
                      color: d.saldo < Decimal.zero ? cores.bad : null,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: cores.surface2,
              borderRadius: BorderRadius.circular(Raios.controle),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 4,
              spacing: 12,
              children: [
                const Text(
                  'Total sacado das plataformas',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  Formatos.moedaDecimal(totalSacado),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFeatures: _tabular,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Painel "Itens mais vendidos".
class PainelTopItens extends StatelessWidget {
  const PainelTopItens({required this.itens, super.key});

  final List<ItemVendido> itens;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return PainelCard(
      titulo: 'Itens mais vendidos',
      semPaddingCorpo: true,
      corpo: itens.isEmpty
          ? const _Vazio('Sem vendas.')
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: cores.surface2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _cabecalho(cores.muted, 'Item')),
                      _cabecalho(cores.muted, 'Unid.'),
                    ],
                  ),
                ),
                for (var i = 0; i < itens.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: cores.line),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(itens[i].nome)),
                        const SizedBox(width: 12),
                        Text(
                          '${itens[i].quantidade}',
                          style: const TextStyle(fontFeatures: _tabular),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _cabecalho(Color cor, String texto) => Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: cor,
        ),
      );
}
