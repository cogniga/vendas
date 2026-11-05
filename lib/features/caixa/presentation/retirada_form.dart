import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/format/padrao_escrita.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/money_field.dart';
import 'package:sales/core/widgets/painel_lateral.dart';
import 'package:sales/core/widgets/text_case_field.dart';
import 'package:sales/data/repositorios/retirada_repository.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:sales/domain/entidades/retirada.dart';

/// Abre o formulário de retirada do caixa como painel lateral.
///
/// Devolve `true` quando salvou.
Future<bool?> abrirRetiradaForm(
  BuildContext context, {
  required String empresaId,
  required List<Destino> destinos,
}) {
  return abrirPainelLateral<bool>(
    context,
    titulo: 'Nova retirada',
    corpo: (context, fechar) => _RetiradaForm(
      empresaId: empresaId,
      destinos: destinos,
      aoFechar: fechar,
    ),
  );
}

class _RetiradaForm extends ConsumerStatefulWidget {
  const _RetiradaForm({
    required this.empresaId,
    required this.destinos,
    required this.aoFechar,
  });

  final String empresaId;
  final List<Destino> destinos;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool? resultado) aoFechar;

  @override
  ConsumerState<_RetiradaForm> createState() => _RetiradaFormState();
}

class _RetiradaFormState extends ConsumerState<_RetiradaForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descricao;

  late DateTime _data;
  String? _destinoId;
  Decimal? _valor;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _descricao = TextEditingController();
    _data = DateTime.now();
    _destinoId =
        widget.destinos.isNotEmpty ? widget.destinos.first.id : null;
  }

  @override
  void dispose() {
    _descricao.dispose();
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
    if (_destinoId == null) return;
    setState(() => _salvando = true);
    final retirada = Retirada(
      id: '',
      empresaId: widget.empresaId,
      data: _data,
      destinoId: _destinoId!,
      valor: _valor ?? Decimal.zero,
      descricao: PadraoEscrita.frase(_descricao.text),
    );
    try {
      await ref.read(retiradaRepositoryProvider).criar(retirada);
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
              initialValue: _destinoId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Destino'),
              items: [
                for (final d in widget.destinos)
                  DropdownMenuItem<String>(value: d.id, child: Text(d.nome)),
              ],
              onChanged: (v) => setState(() => _destinoId = v),
              validator: (v) => v == null ? 'Escolha o destino' : null,
            ),
            const SizedBox(height: Espacos.g12),
            MoneyField(
              label: r'Valor (R$)',
              initial: _valor,
              onChanged: (v) => _valor = v,
            ),
            const SizedBox(height: Espacos.g12),
            TextCaseField(
              caso: CasoTexto.frase,
              controller: _descricao,
              label: 'Descrição',
            ),
          ],
        ),
      ),
    );
  }
}
