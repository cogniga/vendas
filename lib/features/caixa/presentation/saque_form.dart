import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/format/padrao_escrita.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/money_field.dart';
import 'package:sales/core/widgets/painel_lateral.dart';
import 'package:sales/core/widgets/text_case_field.dart';
import 'package:sales/data/repositorios/saque_repository.dart';
import 'package:sales/domain/calculos/caixa.dart';
import 'package:sales/domain/calculos/decimais.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/domain/entidades/saque.dart';
import 'package:sales/features/caixa/presentation/cor_destino.dart';

/// Abre o formulário de saque da plataforma como painel lateral.
///
/// Devolve `true` quando salvou.
Future<bool?> abrirSaqueForm(
  BuildContext context, {
  required String empresaId,
  required List<Destino> destinos,
  required List<Plataforma> plataformas,
}) {
  return abrirPainelLateral<bool>(
    context,
    titulo: 'Novo saque',
    corpo: (context, fechar) => _SaqueForm(
      empresaId: empresaId,
      destinos: destinos,
      plataformas: plataformas,
      aoFechar: fechar,
    ),
  );
}

class _SaqueForm extends ConsumerStatefulWidget {
  const _SaqueForm({
    required this.empresaId,
    required this.destinos,
    required this.plataformas,
    required this.aoFechar,
  });

  final String empresaId;
  final List<Destino> destinos;
  final List<Plataforma> plataformas;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool? resultado) aoFechar;

  @override
  ConsumerState<_SaqueForm> createState() => _SaqueFormState();
}

class _SaqueFormState extends ConsumerState<_SaqueForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _obs;

  late DateTime _data;
  String? _plataformaId;
  Decimal? _valor;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _obs = TextEditingController();
    _data = DateTime.now();
    _plataformaId =
        widget.plataformas.isNotEmpty ? widget.plataformas.first.id : null;
  }

  @override
  void dispose() {
    _obs.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _data = d);
  }

  Saque _montar() {
    final saque = Saque(
      id: '',
      empresaId: widget.empresaId,
      data: _data,
      plataformaId: _plataformaId ?? '',
      valor: _valor ?? Decimal.zero,
      obs: PadraoEscrita.frase(_obs.text),
    );
    return saque.copyWith(rateio: rateio(saque, widget.destinos));
  }

  Future<void> _salvar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_plataformaId == null) return;
    setState(() => _salvando = true);
    try {
      await ref.read(saqueRepositoryProvider).salvar(_montar());
      if (!mounted) return;
      widget.aoFechar(true);
    } on Object {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Não foi possível salvar. Tente de novo.'),
          action: SnackBarAction(label: 'Tentar de novo', onPressed: _salvar),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CorpoPainelLateral(
      rodape: RodapePainel(
        rotuloPrimario: 'Salvar',
        carregando: _salvando,
        aoConfirmar: _salvar,
        aoCancelar: () => widget.aoFechar(null),
      ),
      corpo: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: _escolherData,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Data'),
                child: Text(Formatos.data(_data)),
              ),
            ),
            const SizedBox(height: Espacos.g12),
            DropdownButtonFormField<String>(
              initialValue: _plataformaId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Plataforma'),
              items: [
                for (final p in widget.plataformas)
                  DropdownMenuItem<String>(value: p.id, child: Text(p.nome)),
              ],
              onChanged: (v) => setState(() => _plataformaId = v),
              validator: (v) =>
                  v == null ? 'Escolha a plataforma' : null,
            ),
            const SizedBox(height: Espacos.g12),
            MoneyField(
              label: r'Valor sacado (R$)',
              initial: _valor,
              onChanged: (v) => setState(() => _valor = v),
            ),
            const SizedBox(height: Espacos.g12),
            TextCaseField(
              caso: CasoTexto.frase,
              controller: _obs,
              label: 'Observação',
            ),
            const SizedBox(height: Espacos.g16),
            _PreviewRateio(valor: _valor, destinos: widget.destinos),
          ],
        ),
      ),
    );
  }
}

/// Mostra ao vivo o rateio do valor digitado entre os destinos.
class _PreviewRateio extends StatelessWidget {
  const _PreviewRateio({required this.valor, required this.destinos});

  final Decimal? valor;
  final List<Destino> destinos;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final valorBase = valor ?? Decimal.zero;
    final saqueTemp = Saque(
      id: '',
      empresaId: '',
      data: DateTime.now(),
      plataformaId: '',
      valor: valorBase,
    );
    final linhas = rateio(saqueTemp, destinos);
    final somaPct = destinos.fold(zero, (s, d) => s + d.percentual);
    final total = linhas.fold(zero, (s, r) => s + r.valor);
    final diff = somaPct - cem;
    final sobra = (valorBase * (cem - somaPct)).dividir(cem);

    return Container(
      padding: const EdgeInsets.all(Espacos.g16),
      decoration: BoxDecoration(
        color: cores.surface2,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Rateio automático', style: textos.labelLarge),
          const SizedBox(height: Espacos.g12),
          for (var i = 0; i < destinos.length; i++) ...[
            if (i > 0) const SizedBox(height: Espacos.g8),
            Row(
              children: [
                _Bolinha(cor: destinos[i].cor),
                const SizedBox(width: Espacos.g8),
                Expanded(child: Text(destinos[i].nome)),
                Text(
                  '${Formatos.numero(destinos[i].percentual.toDouble())}%',
                  style: textos.bodySmall?.copyWith(color: cores.muted),
                ),
                const SizedBox(width: Espacos.g12),
                Text(
                  Formatos.moedaDecimal(linhas[i].valor),
                  style: textos.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
          const SizedBox(height: Espacos.g12),
          Divider(height: 1, color: cores.line),
          const SizedBox(height: Espacos.g12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total',
                  style: textos.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                Formatos.moedaDecimal(total),
                style:
                    textos.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (diff.abs() > (Decimal.one / cem).toDecimal()) ...[
            const SizedBox(height: Espacos.g12),
            Text(
              'Os destinos somam '
              '${Formatos.numero(somaPct.toDouble())}%: '
              '${Formatos.moedaDecimal(sobra)} ficaria sem destino.',
              style: textos.bodySmall?.copyWith(color: cores.warn),
            ),
          ],
        ],
      ),
    );
  }
}

class _Bolinha extends StatelessWidget {
  const _Bolinha({required this.cor});

  final String cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: corDoDestino(context, cor),
      ),
    );
  }
}
