import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/format/padrao_escrita.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/money_field.dart';
import 'package:sales/core/widgets/painel_lateral.dart';
import 'package:sales/core/widgets/text_case_field.dart';
import 'package:sales/data/repositorios/investimento_repository.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:sales/domain/entidades/investimento.dart';

/// Abre o formulário de investimento como painel lateral (560 px).
///
/// [investimento] nulo cria um novo registro. Devolve `true` quando salvou.
Future<bool?> abrirInvestimentoForm(
  BuildContext context, {
  required String empresaId,
  required List<Destino> destinos,
  Investimento? investimento,
}) {
  return abrirPainelLateral<bool>(
    context,
    titulo:
        investimento == null ? 'Novo investimento' : 'Editar investimento',
    corpo: (context, fechar) => _InvestimentoForm(
      empresaId: empresaId,
      destinos: destinos,
      investimento: investimento,
      aoFechar: fechar,
    ),
  );
}

class _InvestimentoForm extends ConsumerStatefulWidget {
  const _InvestimentoForm({
    required this.empresaId,
    required this.destinos,
    required this.investimento,
    required this.aoFechar,
  });

  final String empresaId;
  final List<Destino> destinos;
  final Investimento? investimento;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool? resultado) aoFechar;

  @override
  ConsumerState<_InvestimentoForm> createState() => _InvestimentoFormState();
}

class _InvestimentoFormState extends ConsumerState<_InvestimentoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _distribuidor;
  late final TextEditingController _nota;
  late final TextEditingController _obs;

  late DateTime _data;
  Decimal? _valor;
  String? _destinoId;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final i = widget.investimento;
    _distribuidor = TextEditingController(text: i?.distribuidor ?? '');
    _nota = TextEditingController(text: i?.nota ?? '');
    _obs = TextEditingController(text: i?.obs ?? '');
    _data = i?.data ?? DateTime.now();
    _valor = i?.valor;
    _destinoId = i?.destinoId;
  }

  @override
  void dispose() {
    _distribuidor.dispose();
    _nota.dispose();
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

  Future<void> _salvar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _salvando = true);
    final repo = ref.read(investimentoRepositoryProvider);
    final atual = widget.investimento;
    final investimento = Investimento(
      id: atual?.id ?? '',
      empresaId: widget.empresaId,
      data: _data,
      distribuidor: PadraoEscrita.titulo(_distribuidor.text),
      valor: _valor ?? Decimal.zero,
      nota: PadraoEscrita.maius(_nota.text),
      destinoId: _destinoId,
      obs: PadraoEscrita.frase(_obs.text),
    );
    try {
      if (atual == null) {
        await repo.criar(investimento);
      } else {
        await repo.atualizar(investimento);
      }
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
            TextCaseField(
              caso: CasoTexto.titulo,
              controller: _distribuidor,
              label: 'Distribuidor',
            ),
            const SizedBox(height: Espacos.g12),
            MoneyField(
              label: r'Valor (R$)',
              initial: _valor,
              onChanged: (v) => _valor = v,
            ),
            const SizedBox(height: Espacos.g12),
            TextCaseField(
              caso: CasoTexto.maius,
              controller: _nota,
              label: 'Nota / nº do pedido',
            ),
            const SizedBox(height: Espacos.g12),
            DropdownButtonFormField<String?>(
              initialValue: _destinoId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Pago com (destino do caixa)',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  child: Text('— não descontar do caixa —'),
                ),
                for (final d in widget.destinos)
                  DropdownMenuItem<String?>(value: d.id, child: Text(d.nome)),
              ],
              onChanged: (v) => setState(() => _destinoId = v),
            ),
            const SizedBox(height: Espacos.g12),
            TextCaseField(
              caso: CasoTexto.frase,
              controller: _obs,
              label: 'Observação',
            ),
          ],
        ),
      ),
    );
  }
}
