import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/format/padrao_escrita.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/confirm_delete_button.dart';
import 'package:sales/core/widgets/pill.dart';
import 'package:sales/domain/calculos/decimais.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:sales/features/caixa/application/caixa_providers.dart';
import 'package:sales/features/caixa/application/destinos_controller.dart';
import 'package:sales/features/caixa/presentation/cor_destino.dart';

/// Paleta de cores oferecida ao trocar a cor de um destino.
const _paleta = <String>[
  '#2B7A70',
  '#9A8FD4',
  '#D98C3F',
  '#4A8FD9',
  '#C85C8E',
  '#5AA469',
  '#B5894A',
  '#7A6FD4',
];

/// Painel "Destinos e percentuais": edição dos destinos de rateio.
///
/// Edita nome, cor e percentual de cada destino, adiciona/remove e salva via
/// [DestinosController] (persistência em [destinosControllerProvider]).
class DestinosPanel extends ConsumerStatefulWidget {
  const DestinosPanel({
    required this.dados,
    required this.empresaId,
    super.key,
  });

  final DadosCaixa dados;
  final String empresaId;

  @override
  ConsumerState<DestinosPanel> createState() => _DestinosPanelState();
}

class _DestinosPanelState extends ConsumerState<DestinosPanel> {
  ArgsDestinos get _args => ArgsDestinos(
        empresaId: _empresaId,
        originais: widget.dados.destinos,
      );

  /// Empresa ativa, resolvida de qualquer registro já carregado.
  String get _empresaId {
    if (widget.dados.destinos.isNotEmpty) {
      return widget.dados.destinos.first.empresaId;
    }
    if (widget.dados.saques.isNotEmpty) {
      return widget.dados.saques.first.empresaId;
    }
    if (widget.dados.investimentos.isNotEmpty) {
      return widget.dados.investimentos.first.empresaId;
    }
    if (widget.dados.comprasInsumo.isNotEmpty) {
      return widget.dados.comprasInsumo.first.empresaId;
    }
    if (widget.dados.retiradas.isNotEmpty) {
      return widget.dados.retiradas.first.empresaId;
    }
    if (widget.dados.pedidos.isNotEmpty) {
      return widget.dados.pedidos.first.empresaId;
    }
    return widget.empresaId;
  }

  Future<void> _salvar() async {
    final ok = await ref
        .read(destinosControllerProvider(_args).notifier)
        .salvar();
    if (!mounted) return;
    if (ok) {
      // Invalida as fontes (não só o agregado) para a lista recarregar do
      // banco, e o controller para recapturar os destinos originais.
      ref
        ..invalidate(destinosCaixaProvider)
        ..invalidate(dadosCaixaProvider)
        ..invalidate(destinosControllerProvider(_args));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Destinos salvos.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar. Tente de novo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final args = _args;
    final estado = ref.watch(destinosControllerProvider(args));
    final controller = ref.read(destinosControllerProvider(args).notifier);
    final somaPct = estado.somaPercentual;
    final fechou = (somaPct - cem).abs() <= (Decimal.one / cem).toDecimal();

    return Container(
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Espacos.g16,
              Espacos.g16,
              Espacos.g16,
              Espacos.g12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Destinos e percentuais',
                    style: textos.titleMedium,
                  ),
                ),
                Pill(
                  fechou
                      ? Formatos.pontos(somaPct.toDouble())
                      : '${Formatos.pontos(somaPct.toDouble())} · '
                          'precisa somar 100%',
                  tom: fechou ? TomPill.bom : TomPill.ruim,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: cores.line),
          Padding(
            padding: const EdgeInsets.all(Espacos.g16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Tira(destinos: estado.destinos),
                const SizedBox(height: Espacos.g12),
                for (var i = 0; i < estado.destinos.length; i++) ...[
                  if (i > 0) const SizedBox(height: Espacos.g8),
                  _LinhaDestino(
                    key: ValueKey(
                      estado.destinos[i].id.isEmpty
                          ? 'novo-$i'
                          : estado.destinos[i].id,
                    ),
                    index: i,
                    nome: estado.destinos[i].nome,
                    cor: estado.destinos[i].cor,
                    percentual: estado.destinos[i].percentual,
                    onNome: (v) => controller.alterarNome(
                      i,
                      PadraoEscrita.frase(v),
                    ),
                    onCor: (v) => controller.alterarCor(i, v),
                    onPercentual: (v) =>
                        controller.alterarPercentual(i, v),
                    onRemover: () => controller.remover(i),
                  ),
                ],
                const SizedBox(height: Espacos.g12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: controller.adicionar,
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text('Adicionar destino'),
                  ),
                ),
                const SizedBox(height: Espacos.g12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: estado.salvando ? null : _salvar,
                    child: estado.salvando
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Salvar destinos'),
                  ),
                ),
                const SizedBox(height: Espacos.g8),
                Text(
                  'Mudar os percentuais vale para os próximos saques; os já '
                  'registrados guardam o rateio da época.',
                  style: textos.bodySmall?.copyWith(color: cores.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra-tira proporcional: cada destino ocupa seu percentual na largura.
class _Tira extends StatelessWidget {
  const _Tira({required this.destinos});

  final List<Destino> destinos;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return ClipRRect(
      borderRadius: BorderRadius.circular(Raios.pill),
      child: Container(
        height: 8,
        color: cores.surface2,
        child: Row(
          children: [
            for (final d in destinos)
              Expanded(
                flex: (d.percentual.toDouble() * 10)
                    .round()
                    .clamp(0, 1 << 20),
                child: Container(color: corDoDestino(context, d.cor)),
              ),
          ],
        ),
      ),
    );
  }
}

class _LinhaDestino extends StatefulWidget {
  const _LinhaDestino({
    required this.index,
    required this.nome,
    required this.cor,
    required this.percentual,
    required this.onNome,
    required this.onCor,
    required this.onPercentual,
    required this.onRemover,
    super.key,
  });

  final int index;
  final String nome;
  final String cor;
  final Decimal percentual;
  final ValueChanged<String> onNome;
  final ValueChanged<String> onCor;
  final ValueChanged<Decimal> onPercentual;
  final VoidCallback onRemover;

  @override
  State<_LinhaDestino> createState() => _LinhaDestinoState();
}

class _LinhaDestinoState extends State<_LinhaDestino> {
  late final TextEditingController _nome;
  late final TextEditingController _pct;

  @override
  void initState() {
    super.initState();
    _nome = TextEditingController(text: widget.nome);
    _pct = TextEditingController(
      text: Formatos.numeroCurto(widget.percentual.toDouble()),
    );
  }

  @override
  void dispose() {
    _nome.dispose();
    _pct.dispose();
    super.dispose();
  }

  Future<void> _escolherCor() async {
    final escolhida = await showDialog<String>(
      context: context,
      builder: (context) => _DialogoCor(atual: widget.cor),
    );
    if (escolhida != null) widget.onCor(escolhida);
  }

  @override
  Widget build(BuildContext context) {
    final cor = corDoDestino(context, widget.cor);
    return Row(
      children: [
        Tooltip(
          message: 'Cor do destino',
          child: InkWell(
            onTap: _escolherCor,
            borderRadius: BorderRadius.circular(Raios.pill),
            child: Semantics(
              label: 'Escolher cor do destino',
              button: true,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cor,
                  borderRadius: BorderRadius.circular(Raios.controle),
                  border: Border.all(color: context.cores.line),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: Espacos.g8),
        Expanded(
          child: TextFormField(
            controller: _nome,
            decoration: const InputDecoration(
              labelText: 'Destino',
              isDense: true,
            ),
            onChanged: widget.onNome,
          ),
        ),
        const SizedBox(width: Espacos.g8),
        SizedBox(
          width: 88,
          child: TextFormField(
            controller: _pct,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: '%',
              isDense: true,
            ),
            onChanged: (v) =>
                widget.onPercentual(Formatos.parseDecimal(v) ?? zero),
          ),
        ),
        ConfirmDeleteButton(
          tooltip: 'Remover destino',
          onConfirm: widget.onRemover,
        ),
      ],
    );
  }
}

/// Diálogo simples para escolher uma cor da paleta.
class _DialogoCor extends StatelessWidget {
  const _DialogoCor({required this.atual});

  final String atual;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Escolher cor'),
      content: Wrap(
        spacing: Espacos.g12,
        runSpacing: Espacos.g12,
        children: [
          for (final hex in _paleta)
            InkWell(
              onTap: () => Navigator.of(context).pop(hex),
              borderRadius: BorderRadius.circular(Raios.controle),
              child: Semantics(
                label: 'Cor $hex',
                button: true,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: corDoDestino(context, hex),
                    borderRadius: BorderRadius.circular(Raios.controle),
                    border: Border.all(
                      color: hex.toUpperCase() == atual.toUpperCase()
                          ? context.cores.ink
                          : context.cores.line,
                      width: hex.toUpperCase() == atual.toUpperCase() ? 2 : 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
