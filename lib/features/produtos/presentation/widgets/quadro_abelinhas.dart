import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/pill.dart';
import 'package:sales/domain/calculos/abelinhas.dart';
import 'package:sales/domain/calculos/decimais.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';

/// Quadro de abelinhas do formulário de produto (R3.3–R3.5, design §6.7).
///
/// Mostra em tempo real as abelinhas pela regra para o [custo] digitado e, ao
/// clicar em ✎, libera o campo de valor manual (passos de 0,5). Quando o valor
/// manual difere da regra, exibe o aviso de impacto via [avisoAjusteManual]
/// e, se houver, os kits afetados.
class QuadroAbelinhas extends StatelessWidget {
  const QuadroAbelinhas({
    required this.custo,
    required this.faixas,
    required this.valorAbelinha,
    required this.manual,
    required this.editandoManual,
    required this.aoEditar,
    required this.aoVoltarRegra,
    required this.aoMudarManual,
    this.kitsAfetados = const [],
    super.key,
  });

  /// Custo digitado (null se o campo está vazio/inválido).
  final Decimal? custo;

  /// Faixas da regra de abelinhas.
  final List<FaixaAbelinha> faixas;

  /// Valor em R$ de 1 abelinha (das configurações).
  final Decimal valorAbelinha;

  /// Valor manual atual (null = pela regra).
  final Decimal? manual;

  /// Se o campo de valor manual está liberado.
  final bool editandoManual;

  /// Libera o campo de valor manual.
  final VoidCallback aoEditar;

  /// Volta para a regra (zera o manual).
  final VoidCallback aoVoltarRegra;

  /// Altera o valor manual.
  final ValueChanged<Decimal?> aoMudarManual;

  /// Nomes dos kits que usam o produto (para o aviso de impacto).
  final List<String> kitsAfetados;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;

    if (custo == null || faixas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(Espacos.g16),
        decoration: BoxDecoration(
          color: cores.surface2,
          borderRadius: BorderRadius.circular(Raios.cartao),
          border: Border.all(color: cores.line),
        ),
        child: Text(
          'Informe o custo para calcular as abelinhas.',
          style: textos.bodyMedium?.copyWith(color: cores.muted),
        ),
      );
    }

    final c = custo!;
    final regra = abelinhasRegra(c, faixas);
    final acima = acimaDaTabela(c, faixas);

    return Container(
      padding: const EdgeInsets.all(Espacos.g16),
      decoration: BoxDecoration(
        color: cores.surface2,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Abelinhas', style: textos.labelLarge),
              ),
              if (!editandoManual)
                Semantics(
                  label: 'Editar abelinhas manualmente',
                  button: true,
                  child: Tooltip(
                    message: 'Editar abelinhas manualmente',
                    child: IconButton(
                      icon: Icon(
                        LucideIcons.pencil,
                        size: 16,
                        color: cores.muted,
                      ),
                      visualDensity: VisualDensity.compact,
                      onPressed: aoEditar,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Espacos.g8),
          Text(
            'Calculado pela regra (custo ${Formatos.moedaDecimal(c)}): '
            '${Formatos.abelinhas(regra.toDouble())}',
            style: textos.bodyMedium,
          ),
          if (acima) ...[
            const SizedBox(height: Espacos.g8),
            const Pill('Custo acima da última faixa', tom: TomPill.atencao),
          ],
          if (editandoManual) ...[
            const SizedBox(height: Espacos.g12),
            _CampoManual(
              valor: manual ?? regra,
              aoMudar: aoMudarManual,
            ),
            const SizedBox(height: Espacos.base),
            Text(
              'Use múltiplos de 0,5.',
              style: textos.bodySmall?.copyWith(color: cores.muted),
            ),
            const SizedBox(height: Espacos.g8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: aoVoltarRegra,
                icon: const Icon(LucideIcons.undo2, size: 16),
                label: const Text('Voltar para a regra'),
              ),
            ),
          ],
          if (manual != null && manual != regra) ...[
            const SizedBox(height: Espacos.g12),
            _AvisoImpacto(
              aviso: avisoAjusteManual(
                regra: regra,
                manual: manual!,
                custo: c,
                v: valorAbelinha,
              ),
              kitsAfetados: kitsAfetados,
            ),
          ],
        ],
      ),
    );
  }
}

/// Campo de edição do valor manual com passos de 0,5.
class _CampoManual extends StatefulWidget {
  const _CampoManual({required this.valor, required this.aoMudar});

  final Decimal valor;
  final ValueChanged<Decimal?> aoMudar;

  @override
  State<_CampoManual> createState() => _CampoManualState();
}

class _CampoManualState extends State<_CampoManual> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: Formatos.numeroCurto(widget.valor.toDouble()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ajustar(Decimal passo) {
    final atual = Formatos.parseDecimal(_controller.text) ?? widget.valor;
    var novo = atual + passo;
    if (novo < Decimal.zero) novo = Decimal.zero;
    _controller.text = Formatos.numeroCurto(novo.toDouble());
    widget.aoMudar(novo);
  }

  @override
  Widget build(BuildContext context) {
    final meio = Decimal.parse('0.5');
    return Row(
      children: [
        Semantics(
          label: 'Diminuir meia abelinha',
          button: true,
          child: Tooltip(
            message: 'Diminuir 0,5',
            child: IconButton(
              icon: const Icon(LucideIcons.minus, size: 18),
              onPressed: () => _ajustar(-meio),
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: _controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Abelinhas (manual)',
              suffixText: '🐝',
            ),
            onChanged: (texto) =>
                widget.aoMudar(Formatos.parseDecimal(texto)),
          ),
        ),
        Semantics(
          label: 'Aumentar meia abelinha',
          button: true,
          child: Tooltip(
            message: 'Aumentar 0,5',
            child: IconButton(
              icon: const Icon(LucideIcons.plus, size: 18),
              onPressed: () => _ajustar(meio),
            ),
          ),
        ),
      ],
    );
  }
}

/// Aviso de impacto do ajuste manual (design §6.7).
class _AvisoImpacto extends StatelessWidget {
  const _AvisoImpacto({required this.aviso, required this.kitsAfetados});

  final AvisoAjusteManual aviso;
  final List<String> kitsAfetados;

  TomPill get _tom => switch (aviso.cor) {
        'vermelho' => TomPill.ruim,
        'amarelo' => TomPill.atencao,
        _ => TomPill.bom,
      };

  Color _fundo(CoresApp cores) => switch (aviso.cor) {
        'vermelho' => cores.badSoft,
        'amarelo' => cores.warnSoft,
        _ => cores.goodSoft,
      };

  Color _tinta(CoresApp cores) => switch (aviso.cor) {
        'vermelho' => cores.bad,
        'amarelo' => cores.warn,
        _ => cores.good,
      };

  String get _titulo => switch (aviso.cor) {
        'vermelho' => aviso.lucroManual < Decimal.zero
            ? 'Passa a dar prejuízo'
            : 'Muito abaixo da regra',
        'amarelo' => 'Bom para promoção, com lucro menor',
        _ => 'Lucro maior por unidade',
      };

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final tinta = _tinta(cores);

    final linhas = <Widget>[
      _linha(
        context,
        'Venda por unidade',
        '${Formatos.moedaDecimal(aviso.vendaRegra)} → '
            '${Formatos.moedaDecimal(aviso.vendaManual)}',
      ),
      _linha(
        context,
        'Lucro por unidade',
        '${Formatos.moedaDecimal(aviso.lucroRegra)} → '
            '${Formatos.moedaDecimal(aviso.lucroManual)}',
      ),
      _linha(
        context,
        'ROI',
        '${Formatos.percentualFracao(aviso.roiRegra.toDouble())} → '
            '${Formatos.percentualFracao(aviso.roiManual.toDouble())}',
      ),
      _linha(
        context,
        'Mínimo sem prejuízo',
        Formatos.abelinhas(aviso.minimo.toDouble()),
      ),
    ];

    if (aviso.cor == 'amarelo' && aviso.lucroManual > Decimal.zero) {
      final vezes = aviso.lucroRegra.dividir(aviso.lucroManual);
      linhas.add(
        _linha(
          context,
          'Para o mesmo lucro',
          'vender ${Formatos.numeroCurto(vezes.toDouble())}× mais unidades',
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Espacos.g12),
      decoration: BoxDecoration(
        color: _fundo(cores),
        borderRadius: BorderRadius.circular(Raios.controle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Pill(_titulo, tom: _tom),
            ],
          ),
          const SizedBox(height: Espacos.g8),
          ...linhas,
          if (kitsAfetados.isNotEmpty) ...[
            const SizedBox(height: Espacos.g8),
            Text(
              'Kits afetados',
              style: textos.labelLarge?.copyWith(color: tinta),
            ),
            const SizedBox(height: Espacos.base),
            Text(
              kitsAfetados.join(', '),
              style: textos.bodySmall?.copyWith(color: tinta),
            ),
          ],
        ],
      ),
    );
  }

  Widget _linha(BuildContext context, String rotulo, String valor) {
    final textos = Theme.of(context).textTheme;
    final tinta = _tinta(context.cores);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              rotulo,
              style: textos.bodySmall?.copyWith(color: tinta),
            ),
          ),
          const SizedBox(width: Espacos.g8),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: textos.bodySmall?.copyWith(
                color: tinta,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
