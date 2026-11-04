import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/format/padrao_escrita.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/money_field.dart';
import 'package:sales/core/widgets/painel_lateral.dart';
import 'package:sales/core/widgets/text_case_field.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/features/produtos/application/produto_form_controller.dart';
import 'package:sales/features/produtos/presentation/widgets/quadro_abelinhas.dart';

/// Abre o formulário de produto como painel lateral (560 px).
///
/// [produto] nulo cria um novo registro. Devolve `true` quando salvou.
Future<bool?> abrirProdutoForm(
  BuildContext context, {
  required String empresaId,
  required List<FaixaAbelinha> faixas,
  required Decimal valorAbelinha,
  Produto? produto,
}) {
  return abrirPainelLateral<bool>(
    context,
    titulo: produto == null ? 'Novo produto' : 'Editar produto',
    corpo: (context, fechar) => _ProdutoForm(
      empresaId: empresaId,
      produto: produto,
      faixas: faixas,
      valorAbelinha: valorAbelinha,
      aoFechar: fechar,
    ),
  );
}

class _ProdutoForm extends ConsumerStatefulWidget {
  const _ProdutoForm({
    required this.empresaId,
    required this.produto,
    required this.faixas,
    required this.valorAbelinha,
    required this.aoFechar,
  });

  final String empresaId;
  final Produto? produto;
  final List<FaixaAbelinha> faixas;
  final Decimal valorAbelinha;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool? resultado) aoFechar;

  @override
  ConsumerState<_ProdutoForm> createState() => _ProdutoFormState();
}

class _ProdutoFormState extends ConsumerState<_ProdutoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _codigo;
  late final TextEditingController _marca;
  late final TextEditingController _categoria;
  late final TextEditingController _fornecedor;
  late final TextEditingController _unidade;
  late final TextEditingController _ean;
  late final TextEditingController _estoque;
  late final TextEditingController _obs;

  Decimal? _custo;
  Decimal? _manual;
  bool _editandoManual = false;
  bool _ativo = true;
  List<String> _kitsAfetados = const [];

  @override
  void initState() {
    super.initState();
    final p = widget.produto;
    _nome = TextEditingController(text: p?.nome ?? '');
    _codigo = TextEditingController(text: p?.codigo ?? '');
    _marca = TextEditingController(text: p?.marca ?? '');
    _categoria = TextEditingController(text: p?.categoria ?? 'Cosméticos');
    _fornecedor = TextEditingController(text: p?.fornecedor ?? '');
    _unidade = TextEditingController(text: p?.unidade ?? 'un');
    _ean = TextEditingController(text: p?.ean ?? '');
    _estoque = TextEditingController(text: '${p?.estoque ?? 0}');
    _obs = TextEditingController(text: p?.obs ?? '');
    _custo = p?.custo;
    _manual = p?.abelinhasManual;
    _editandoManual = p?.abelinhasManual != null;
    _ativo = p?.ativo ?? true;
    if (p != null && p.id.isNotEmpty) _carregarKits(p.id);
  }

  Future<void> _carregarKits(String id) async {
    final kits =
        await ref.read(produtoFormControllerProvider.notifier).kitsQueUsam(id);
    if (mounted) setState(() => _kitsAfetados = kits);
  }

  @override
  void dispose() {
    _nome.dispose();
    _codigo.dispose();
    _marca.dispose();
    _categoria.dispose();
    _fornecedor.dispose();
    _unidade.dispose();
    _ean.dispose();
    _estoque.dispose();
    _obs.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final controller = ref.read(produtoFormControllerProvider.notifier);
    final atual = widget.produto;
    // "Pela regra" quando o manual é igual à regra (R3.6).
    final produto = (atual ?? _novo()).copyWith(
      codigo: PadraoEscrita.maius(_codigo.text),
      nome: PadraoEscrita.titulo(_nome.text),
      marca: PadraoEscrita.titulo(_marca.text),
      categoria: PadraoEscrita.frase(_categoria.text),
      fornecedor: PadraoEscrita.titulo(_fornecedor.text),
      unidade: _unidade.text.trim().isEmpty ? 'un' : _unidade.text.trim(),
      ean: _ean.text.trim(),
      estoque: int.tryParse(_estoque.text.trim()) ?? 0,
      ativo: _ativo,
      obs: PadraoEscrita.frase(_obs.text),
      custo: _custo ?? Decimal.zero,
      abelinhasManual: _manualEfetivo(),
    );
    final ok = atual == null
        ? await controller.criar(produto)
        : await controller.atualizar(produto);
    if (!mounted) return;
    if (ok) {
      widget.aoFechar(true);
      return;
    }
    final estado = ref.read(produtoFormControllerProvider);
    final erro = estado.hasError ? '${estado.error}' : 'Tente de novo';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(erro),
        action: SnackBarAction(label: 'Tentar de novo', onPressed: _salvar),
      ),
    );
  }

  /// Valor manual a persistir: null quando igual à regra (R3.6).
  Decimal? _manualEfetivo() {
    final custo = _custo;
    if (_manual == null || custo == null || widget.faixas.isEmpty) return null;
    // Importa aqui para reaproveitar o cálculo da regra sem duplicar.
    final regra = _regraPara(custo);
    return _manual == regra ? null : _manual;
  }

  Decimal _regraPara(Decimal custo) {
    final ordenadas = [...widget.faixas]
      ..sort((a, b) => a.custoAte.compareTo(b.custoAte));
    for (final f in ordenadas) {
      if (custo <= f.custoAte) return f.abelinhas;
    }
    return ordenadas.last.abelinhas;
  }

  Produto _novo() => Produto(
        id: '',
        empresaId: widget.empresaId,
        codigo: '',
        nome: '',
        custo: Decimal.zero,
      );

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(produtoFormControllerProvider);
    final carregando = estado.isLoading;

    return CorpoPainelLateral(
      rodape: RodapePainel(
        rotuloPrimario: 'Salvar',
        carregando: carregando,
        aoConfirmar: _salvar,
        aoCancelar: () => widget.aoFechar(null),
      ),
      corpo: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextCaseField(
              caso: CasoTexto.titulo,
              controller: _nome,
              label: 'Nome do produto',
            ),
            const SizedBox(height: Espacos.g12),
            TextCaseField(
              caso: CasoTexto.maius,
              controller: _codigo,
              label: 'Código',
            ),
            const SizedBox(height: Espacos.base),
            _ValidadorCodigoNome(nome: _nome, codigo: _codigo),
            const SizedBox(height: Espacos.g12),
            Row(
              children: [
                Expanded(
                  child: TextCaseField(
                    caso: CasoTexto.titulo,
                    controller: _marca,
                    label: 'Marca',
                  ),
                ),
                const SizedBox(width: Espacos.g12),
                Expanded(
                  child: TextCaseField(
                    caso: CasoTexto.frase,
                    controller: _categoria,
                    label: 'Categoria',
                  ),
                ),
              ],
            ),
            const SizedBox(height: Espacos.g12),
            TextCaseField(
              caso: CasoTexto.titulo,
              controller: _fornecedor,
              label: 'Fornecedor',
            ),
            const SizedBox(height: Espacos.g12),
            MoneyField(
              label: 'Custo unitário',
              initial: _custo,
              onChanged: (v) => setState(() => _custo = v),
            ),
            const SizedBox(height: Espacos.g12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _unidade,
                    decoration: const InputDecoration(labelText: 'Unidade'),
                  ),
                ),
                const SizedBox(width: Espacos.g12),
                Expanded(
                  child: TextFormField(
                    controller: _estoque,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Estoque'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Espacos.g12),
            TextFormField(
              controller: _ean,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'EAN'),
            ),
            const SizedBox(height: Espacos.g12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ativo'),
              value: _ativo,
              onChanged: (v) => setState(() => _ativo = v),
            ),
            const SizedBox(height: Espacos.g12),
            QuadroAbelinhas(
              custo: _custo,
              faixas: widget.faixas,
              valorAbelinha: widget.valorAbelinha,
              manual: _manual,
              editandoManual: _editandoManual,
              kitsAfetados: _kitsAfetados,
              aoEditar: () => setState(() {
                _editandoManual = true;
                _manual ??= _custo == null ? null : _regraPara(_custo!);
              }),
              aoVoltarRegra: () => setState(() {
                _editandoManual = false;
                _manual = null;
              }),
              aoMudarManual: (v) => setState(() => _manual = v),
            ),
            const SizedBox(height: Espacos.g12),
            TextCaseField(
              caso: CasoTexto.frase,
              controller: _obs,
              label: 'Observações',
            ),
          ],
        ),
      ),
    );
  }
}

/// Valida que código e nome foram informados (mensagem única R3).
class _ValidadorCodigoNome extends StatelessWidget {
  const _ValidadorCodigoNome({required this.nome, required this.codigo});

  final TextEditingController nome;
  final TextEditingController codigo;

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      validator: (_) {
        if (nome.text.trim().isEmpty || codigo.text.trim().isEmpty) {
          return 'Informe código e nome do produto';
        }
        return null;
      },
      builder: (estado) {
        if (!estado.hasError) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: Espacos.base),
          child: Text(
            estado.errorText!,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: context.cores.bad),
          ),
        );
      },
    );
  }
}
