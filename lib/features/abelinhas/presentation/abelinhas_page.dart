import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/confirm_delete_button.dart';
import 'package:sales/core/widgets/kpi_card.dart';
import 'package:sales/core/widgets/page_header.dart';
import 'package:sales/core/widgets/pill.dart';
import 'package:sales/core/widgets/responsive_list.dart';
import 'package:sales/domain/calculos/abelinhas.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/features/abelinhas/application/abelinhas_controller.dart';
import 'package:sales/features/abelinhas/application/abelinhas_providers.dart';

/// Tela de Regra de abelinhas (R9): valor de 1 abelinha com recálculo ao vivo,
/// KPIs, lista de faixas editável e quadro de lucro/prejuízo.
class AbelinhasPage extends ConsumerWidget {
  const AbelinhasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dadosAsync = ref.watch(dadosAbelinhasProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(title: 'Regra de abelinhas'),
        dadosAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(Espacos.g20),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => _Erro(
            mensagem: _texto(e),
            aoTentarDeNovo: () => ref.invalidate(dadosAbelinhasProvider),
          ),
          data: (dados) => _Conteudo(dados: dados),
        ),
      ],
    );
  }

  String _texto(Object erro) {
    final texto = erro.toString();
    return texto.startsWith('ErroRepositorio: ')
        ? texto.substring('ErroRepositorio: '.length)
        : 'Não foi possível carregar. Tente de novo.';
  }
}

class _Erro extends StatelessWidget {
  const _Erro({required this.mensagem, required this.aoTentarDeNovo});

  final String mensagem;
  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Espacos.g20),
      decoration: BoxDecoration(
        color: cores.badSoft,
        borderRadius: BorderRadius.circular(Raios.cartao),
      ),
      child: Column(
        children: [
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: cores.bad),
          ),
          const SizedBox(height: Espacos.g16),
          OutlinedButton(
            onPressed: aoTentarDeNovo,
            child: const Text('Tentar de novo'),
          ),
        ],
      ),
    );
  }
}

class _Conteudo extends ConsumerWidget {
  const _Conteudo({required this.dados});

  final DadosAbelinhas dados;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlador = abelinhasControllerProvider(dados);
    final estado = ref.watch(controlador);
    final notifier = ref.read(controlador.notifier);
    final v = estado.valorAbelinha;

    final geral = analiseGeral(dados.produtos, estado.faixas, v);
    final porFaixa = _analisesNaOrdemDaTela(estado.faixas, v);
    final exemplo = _exemploReal(geral, v, estado.faixas);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CampoValor(
          valorInicial: v,
          aoDigitar: notifier.digitarValor,
        ),
        const SizedBox(height: Espacos.g16),
        KpiRow(
          cartoes: [
            KpiCard(
              label: 'ROI médio',
              value: Formatos.percentualFracao(geral.roiMedioGeral.toDouble()),
              sub: exemplo,
            ),
            KpiCard(
              label: 'Produtos com lucro',
              value: '${geral.comLucro}',
            ),
            KpiCard(
              label: 'Produtos com prejuízo',
              value: '${geral.comPrejuizo}',
            ),
            KpiCard(
              label: '🐝 mínima sem prejuízo',
              value: Formatos.moedaDecimal(geral.abelinhaMinimaSemPrejuizo),
            ),
          ],
        ),
        const SizedBox(height: Espacos.g20),
        _ListaFaixas(
          analises: porFaixa,
          aoAlterarCustoAte: notifier.alterarCustoAte,
          aoAlterarAbelinhas: notifier.alterarAbelinhas,
          aoRemover: notifier.removerFaixa,
        ),
        const SizedBox(height: Espacos.g12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: notifier.adicionarFaixa,
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Adicionar faixa'),
          ),
        ),
        const SizedBox(height: Espacos.g20),
        _QuadroLucroPrejuizo(geral: geral, porFaixa: porFaixa),
        const SizedBox(height: Espacos.g20),
        _RodapeSalvar(
          salvando: estado.salvando,
          erro: estado.erro,
          aoSalvar: () async {
            final ok = await notifier.salvar();
            if (ok && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Regra salva.')),
              );
            }
          },
        ),
      ],
    );
  }

  /// Análises por faixa na **mesma ordem das linhas em edição**.
  ///
  /// `analisePorFaixa` ordena por "Custo até"; se a tela usasse essa ordem,
  /// digitar um teto que muda a posição da faixa faria a linha (e o campo com
  /// foco) apontar para outra faixa. Aqui cada análise volta para o índice da
  /// faixa em `estado.faixas`, que só é reordenado ao salvar.
  List<AnaliseFaixa> _analisesNaOrdemDaTela(
    List<FaixaAbelinha> faixas,
    Decimal v,
  ) {
    final ordem = List<int>.generate(faixas.length, (i) => i)
      ..sort((a, b) {
        final c = faixas[a].custoAte.compareTo(faixas[b].custoAte);
        return c != 0 ? c : a.compareTo(b);
      });
    final ordenadas = [for (final i in ordem) faixas[i]];
    final analises = analisePorFaixa(dados.produtos, ordenadas, v);
    final porLinha = List<AnaliseFaixa?>.filled(faixas.length, null);
    for (var k = 0; k < ordem.length; k++) {
      porLinha[ordem[k]] = analises[k];
    }
    return porLinha.cast<AnaliseFaixa>();
  }

  /// Texto de exemplo real: produto com ROI mais próximo da média (atualiza
  /// com `v` e com as faixas em edição).
  String _exemploReal(
    AnaliseGeralAbelinhas geral,
    Decimal v,
    List<FaixaAbelinha> faixas,
  ) {
    final comCusto =
        dados.produtos.where((p) => p.custo > Decimal.zero).toList();
    if (comCusto.isEmpty) return 'Sem produtos com custo.';
    final media = geral.roiMedioGeral;
    comCusto.sort((a, b) {
      final ra = roiProduto(a, v, faixas);
      final rb = roiProduto(b, v, faixas);
      return (ra - media).abs().compareTo((rb - media).abs());
    });
    final p = comCusto.first;
    final roi = roiProduto(p, v, faixas);
    return 'Ex.: ${p.nome} · ROI '
        '${Formatos.percentualFracao(roi.toDouble())}';
  }
}

/// Campo "Valor de 1 🐝 (R$)" com debounce (controller cuida do atraso).
class _CampoValor extends StatefulWidget {
  const _CampoValor({required this.valorInicial, required this.aoDigitar});

  final Decimal valorInicial;
  final ValueChanged<String> aoDigitar;

  @override
  State<_CampoValor> createState() => _CampoValorState();
}

class _CampoValorState extends State<_CampoValor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: Formatos.numero(widget.valorInicial.toDouble()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: r'Valor de 1 🐝 (R$)',
          prefixText: r'R$ ',
        ),
        onChanged: widget.aoDigitar,
      ),
    );
  }
}

/// Lista editável de faixas com as análises por faixa.
class _ListaFaixas extends StatelessWidget {
  const _ListaFaixas({
    required this.analises,
    required this.aoAlterarCustoAte,
    required this.aoAlterarAbelinhas,
    required this.aoRemover,
  });

  final List<AnaliseFaixa> analises;
  final void Function(int indice, Decimal custoAte) aoAlterarCustoAte;
  final void Function(int indice, Decimal abelinhas) aoAlterarAbelinhas;
  final void Function(int indice) aoRemover;

  @override
  Widget build(BuildContext context) {
    final indices = List<int>.generate(analises.length, (i) => i);
    return ResponsiveList<int>(
      limiarCartao: 990,
      itens: indices,
      colunas: [
        ColunaLista<int>(
          label: 'Faixa',
          principal: true,
          builder: (i) => _CelulaFaixa(analise: analises[i]),
        ),
        ColunaLista<int>(
          label: 'Custo até',
          builder: (i) => _CampoDecimal(
            valor: analises[i].custoAte,
            aoMudar: (v) => aoAlterarCustoAte(i, v),
          ),
        ),
        ColunaLista<int>(
          label: 'Abelinhas',
          builder: (i) => _CampoDecimal(
            valor: analises[i].abelinhas,
            aoMudar: (v) => aoAlterarAbelinhas(i, v),
          ),
        ),
        ColunaLista<int>(
          label: 'Venda',
          builder: (i) => Text(Formatos.moedaDecimal(analises[i].venda)),
        ),
        ColunaLista<int>(
          label: 'ROI médio',
          builder: (i) => Text(
            Formatos.percentualFracao(analises[i].roiMedio.toDouble()),
          ),
        ),
        ColunaLista<int>(
          label: 'ROI no limite',
          builder: (i) => Text(
            Formatos.percentualFracao(analises[i].roiNoLimite.toDouble()),
          ),
        ),
        ColunaLista<int>(
          label: '🐝 mín. p/ lucro',
          builder: (i) =>
              Text(Formatos.moedaDecimal(analises[i].abelinhaMinima)),
        ),
      ],
      acoes: (i) => ConfirmDeleteButton(
        tooltip: 'Remover faixa',
        onConfirm: () => aoRemover(i),
      ),
    );
  }
}

/// Célula principal da faixa: texto do intervalo + pill de situação + nº.
class _CelulaFaixa extends StatelessWidget {
  const _CelulaFaixa({required this.analise});

  final AnaliseFaixa analise;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final cores = context.cores;
    final inicio = analise.limiteInferior == Decimal.zero
        ? Formatos.moedaDecimal(Decimal.zero)
        : Formatos.moedaDecimal(analise.limiteInferior);
    final faixaTexto =
        '$inicio a ${Formatos.moedaDecimal(analise.custoAte)}';
    final tom = analise.situacao.startsWith('Lucro')
        ? TomPill.bom
        : analise.situacao.startsWith('Empata')
            ? TomPill.neutro
            : TomPill.ruim;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(faixaTexto, style: textos.titleMedium),
        const SizedBox(height: Espacos.base),
        Wrap(
          spacing: Espacos.g8,
          runSpacing: Espacos.base,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Pill(analise.situacao, tom: tom),
            Text(
              '${analise.produtos} produto(s)',
              style: textos.bodySmall?.copyWith(color: cores.muted),
            ),
          ],
        ),
      ],
    );
  }
}

/// Campo numérico (decimal) para editar custo/abelinhas de uma faixa.
class _CampoDecimal extends StatefulWidget {
  const _CampoDecimal({required this.valor, required this.aoMudar});

  final Decimal valor;
  final ValueChanged<Decimal> aoMudar;

  @override
  State<_CampoDecimal> createState() => _CampoDecimalState();
}

class _CampoDecimalState extends State<_CampoDecimal> {
  late final TextEditingController _controller;
  final FocusNode _foco = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: Formatos.numero(widget.valor.toDouble()),
    );
  }

  @override
  void didUpdateWidget(_CampoDecimal oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sincroniza quando o valor muda por fora (ex.: reordenar), sem roubar o
    // foco se o usuário está digitando.
    final atual = Formatos.parseDecimal(_controller.text);
    if (atual != widget.valor && !_foco.hasFocus) {
      _controller.text = Formatos.numero(widget.valor.toDouble());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _foco.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: TextField(
        controller: _controller,
        focusNode: _foco,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(isDense: true),
        onChanged: (texto) {
          final v = Formatos.parseDecimal(texto);
          if (v != null) widget.aoMudar(v);
        },
      ),
    );
  }
}

/// Quadro "Quando dá lucro e quando dá prejuízo" (R9.6).
class _QuadroLucroPrejuizo extends StatelessWidget {
  const _QuadroLucroPrejuizo({required this.geral, required this.porFaixa});

  final AnaliseGeralAbelinhas geral;
  final List<AnaliseFaixa> porFaixa;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;

    // Faixa mais exigente: maior "abelinha mínima p/ lucro".
    AnaliseFaixa? maisExigente;
    for (final f in porFaixa) {
      if (maisExigente == null ||
          f.abelinhaMinima > maisExigente.abelinhaMinima) {
        maisExigente = f;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Espacos.g16),
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quando dá lucro e quando dá prejuízo',
            style: textos.titleMedium,
          ),
          const SizedBox(height: Espacos.g12),
          Text(
            'Todos lucram quando 1 🐝 vale pelo menos '
            '${Formatos.moedaDecimal(geral.abelinhaMinimaSemPrejuizo)}.',
            style: textos.bodyMedium,
          ),
          if (maisExigente != null) ...[
            const SizedBox(height: Espacos.g8),
            Text(
              'Faixa mais exigente: até '
              '${Formatos.moedaDecimal(maisExigente.custoAte)} '
              '(precisa de '
              '${Formatos.moedaDecimal(maisExigente.abelinhaMinima)} '
              'por 🐝).',
              style: textos.bodyMedium,
            ),
          ],
          const SizedBox(height: Espacos.g8),
          Text(
            '${geral.comLucro} produto(s) com lucro · '
            '${geral.comPrejuizo} com prejuízo.',
            style: textos.bodyMedium?.copyWith(color: cores.muted),
          ),
        ],
      ),
    );
  }
}

/// Rodapé com o botão de salvar e a mensagem de erro (§10).
class _RodapeSalvar extends StatelessWidget {
  const _RodapeSalvar({
    required this.salvando,
    required this.erro,
    required this.aoSalvar,
  });

  final bool salvando;
  final String? erro;
  final VoidCallback aoSalvar;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (erro != null) ...[
          Container(
            padding: const EdgeInsets.all(Espacos.g12),
            decoration: BoxDecoration(
              color: cores.badSoft,
              borderRadius: BorderRadius.circular(Raios.controle),
            ),
            child: Text(
              erro!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cores.bad),
            ),
          ),
          const SizedBox(height: Espacos.g12),
        ],
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: salvando ? null : aoSalvar,
            child: salvando
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar regra'),
          ),
        ),
      ],
    );
  }
}
