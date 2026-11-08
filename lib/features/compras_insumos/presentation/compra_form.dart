import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/format/padrao_escrita.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/money_field.dart';
import 'package:sales/core/widgets/painel_lateral.dart';
import 'package:sales/core/widgets/text_case_field.dart';
import 'package:sales/data/repositorios/compra_insumo_repository.dart';
import 'package:sales/data/repositorios/padrao_nome_provider.dart';
import 'package:sales/domain/calculos/decimais.dart';
import 'package:sales/domain/entidades/compra_insumo.dart';
import 'package:sales/domain/entidades/destino.dart';

/// Tipos de insumo (mesma ordem do protótipo).
const _tiposInsumo = <String>[
  'Embalagem',
  'Etiqueta',
  'Impressão',
  'Fita / lacre',
  'Brinde',
  'Outros',
];

/// Abre o formulário de compra de insumo como painel lateral.
///
/// [compra] nulo cria um novo registro. Devolve `true` quando salvou.
Future<bool?> abrirCompraForm(
  BuildContext context, {
  required String empresaId,
  required List<Destino> destinos,
  CompraInsumo? compra,
}) {
  return abrirPainelLateral<bool>(
    context,
    titulo: compra == null ? 'Registrar compra' : 'Editar compra',
    corpo: (context, fechar) => _CompraForm(
      empresaId: empresaId,
      destinos: destinos,
      compra: compra,
      aoFechar: fechar,
    ),
  );
}

class _CompraForm extends ConsumerStatefulWidget {
  const _CompraForm({
    required this.empresaId,
    required this.destinos,
    required this.compra,
    required this.aoFechar,
  });

  final String empresaId;
  final List<Destino> destinos;
  final CompraInsumo? compra;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool? resultado) aoFechar;

  @override
  ConsumerState<_CompraForm> createState() => _CompraFormState();
}

class _CompraFormState extends ConsumerState<_CompraForm> {
  late final TextEditingController _produto;
  late final TextEditingController _descricao;
  late final TextEditingController _pacotes;
  late final TextEditingController _itens;

  late DateTime _data;
  late String _tipo;
  Decimal? _valorTotal;
  String? _destinoId;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final c = widget.compra;
    _produto = TextEditingController(text: c?.produto ?? '');
    _descricao = TextEditingController(text: c?.descricao ?? '');
    _pacotes = TextEditingController(text: '${c?.pacotes ?? 1}');
    _itens = TextEditingController(text: '${c?.itens ?? 1}');
    _data = c?.data ?? DateTime.now();
    _tipo = c?.tipo ?? 'Embalagem';
    _valorTotal = c?.valorTotal;
    _destinoId = c?.destinoId;
  }

  @override
  void dispose() {
    _produto.dispose();
    _descricao.dispose();
    _pacotes.dispose();
    _itens.dispose();
    super.dispose();
  }

  Decimal get _valorUnitario {
    final total = _valorTotal ?? Decimal.zero;
    final itens = int.tryParse(_itens.text.trim()) ?? 0;
    if (itens == 0) return Decimal.zero;
    return total.dividir(Decimal.fromInt(itens));
  }

  Future<void> _salvar() async {
    setState(() => _salvando = true);
    final atual = widget.compra;
    final compra = CompraInsumo(
      id: atual?.id ?? '',
      empresaId: widget.empresaId,
      data: _data,
      produto: PadraoEscrita.nome(_produto.text, ref.read(padraoNomeProvider)),
      descricao: PadraoEscrita.frase(_descricao.text),
      tipo: _tipo,
      valorTotal: _valorTotal ?? Decimal.zero,
      pacotes: int.tryParse(_pacotes.text.trim()) ?? 1,
      itens: int.tryParse(_itens.text.trim()) ?? 1,
      destinoId: _destinoId,
    );
    final repo = ref.read(compraInsumoRepositoryProvider);
    try {
      if (atual == null || atual.id.isEmpty) {
        await repo.criar(compra);
      } else {
        await repo.atualizar(compra);
      }
      if (!mounted) return;
      widget.aoFechar(true);
    } on Object {
      if (!mounted) return;
      setState(() => _salvando = false);
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

    return CorpoPainelLateral(
      rodape: RodapePainel(
        rotuloPrimario: 'Salvar',
        carregando: _salvando,
        aoConfirmar: _salvar,
        aoCancelar: () => widget.aoFechar(null),
      ),
      corpo: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _campoData(),
          const SizedBox(height: Espacos.g12),
          DropdownButtonFormField<String>(
            initialValue: _tipo,
            decoration: const InputDecoration(labelText: 'Tipo'),
            items: [
              for (final t in _tiposInsumo)
                DropdownMenuItem(value: t, child: Text(t)),
            ],
            onChanged: (v) => setState(() => _tipo = v ?? 'Embalagem'),
          ),
          const SizedBox(height: Espacos.g12),
          TextCaseField(
            caso: CasoTexto.nome,
            padraoNome: ref.watch(padraoNomeProvider),
            controller: _produto,
            label: 'Produto',
          ),
          const SizedBox(height: Espacos.g12),
          TextCaseField(
            caso: CasoTexto.frase,
            controller: _descricao,
            label: 'Descrição / medida',
          ),
          const SizedBox(height: Espacos.g12),
          MoneyField(
            label: r'Valor da compra (R$)',
            initial: _valorTotal,
            onChanged: (v) => setState(() => _valorTotal = v),
          ),
          const SizedBox(height: Espacos.g12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _pacotes,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade (pacotes)',
                  ),
                ),
              ),
              const SizedBox(width: Espacos.g12),
              Expanded(
                child: TextFormField(
                  controller: _itens,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total de itens',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: Espacos.g12),
          DropdownButtonFormField<String?>(
            initialValue: _destinoId,
            decoration: const InputDecoration(labelText: 'Pago com'),
            items: [
              const DropdownMenuItem<String?>(
                child: Text('— não descontar do caixa —'),
              ),
              for (final d in widget.destinos)
                DropdownMenuItem<String?>(value: d.id, child: Text(d.nome)),
            ],
            onChanged: (v) => setState(() => _destinoId = v),
          ),
          const SizedBox(height: Espacos.g16),
          Text(
            'Valor unitário: ${Formatos.moedaDecimal(_valorUnitario)} '
            'por item',
            style: textos.bodySmall?.copyWith(color: cores.muted),
          ),
        ],
      ),
    );
  }

  Widget _campoData() {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: _data,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (d != null) setState(() => _data = d);
      },
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Data'),
        child: Text(Formatos.data(_data)),
      ),
    );
  }
}
