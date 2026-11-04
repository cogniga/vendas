import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/format/padrao_escrita.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/data/repositorios/pedido_repository.dart';
import 'package:sales/domain/calculos/abelinhas.dart';
import 'package:sales/domain/calculos/pedido.dart';
import 'package:sales/domain/calculos/produto_venda.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/pedido_item.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/domain/entidades/produto_venda.dart';
import 'package:sales/features/pedidos/application/pedidos_providers.dart';

/// Uma linha em edição no pedido (produto avulso ou kit) com quantidade.
class _LinhaEdicao {
  _LinhaEdicao({
    required this.ehKit,
    required this.refId,
    required this.quantidade,
  });

  final bool ehKit;
  final String refId;
  int quantidade;
}

/// Editor de pedido (R5) em painel lateral largo (design §4).
///
/// Recebe [pedido] para edição ou `null` para um novo. Fecha com
/// `Navigator.pop(context, true)` quando salva.
class PedidoEditor extends ConsumerStatefulWidget {
  const PedidoEditor({this.pedido, super.key});

  final Pedido? pedido;

  @override
  ConsumerState<PedidoEditor> createState() => _PedidoEditorState();
}

class _PedidoEditorState extends ConsumerState<PedidoEditor> {
  final _clienteCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  final _precoCtrl = TextEditingController();
  final _liquidoCtrl = TextEditingController();
  final _itensTaxaCtrl = TextEditingController();
  final _buscaCtrl = TextEditingController();

  DateTime _data = DateTime.now();
  String? _plataformaId;
  SituacaoPedido _situacao = SituacaoPedido.concluido;
  final List<_LinhaEdicao> _linhas = [];

  Decimal _embalagem = Decimal.zero;
  Decimal _impressao = Decimal.zero;
  Decimal _outros = Decimal.zero;
  Decimal _precoVenda = Decimal.zero;
  Decimal? _liquidoInformado;
  int _itensTaxaFixa = 1;

  /// Enquanto true, o preço e itens cobrados são preenchidos automaticamente.
  bool _autoPreco = true;

  /// Enquanto true, os custos de envio seguem a regra automática.
  bool _autoEnvio = true;

  bool _salvando = false;
  String _busca = '';

  @override
  void initState() {
    super.initState();
    final p = widget.pedido;
    if (p != null) {
      _data = p.data;
      _plataformaId = p.plataformaId;
      _situacao = p.situacao;
      _clienteCtrl.text = p.cliente;
      _obsCtrl.text = p.obs;
      _embalagem = p.embalagem;
      _impressao = p.impressao;
      _outros = p.outros;
      _precoVenda = p.precoVenda;
      _liquidoInformado = p.liquidoInformado;
      _itensTaxaFixa = p.itensTaxaFixa;
      _precoCtrl.text = Formatos.numero(p.precoVenda.toDouble());
      _itensTaxaCtrl.text = '${p.itensTaxaFixa}';
      if (p.liquidoInformado != null) {
        _liquidoCtrl.text = Formatos.numero(p.liquidoInformado!.toDouble());
      }
      _autoPreco = false;
      _autoEnvio = false;
      for (final item in p.itens) {
        _linhas.add(
          _LinhaEdicao(
            ehKit: item.tipo == TipoPedidoItem.produtoVenda,
            refId: item.produtoVendaId ?? item.produtoId ?? '',
            quantidade: item.quantidade,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _clienteCtrl.dispose();
    _obsCtrl.dispose();
    _precoCtrl.dispose();
    _liquidoCtrl.dispose();
    _itensTaxaCtrl.dispose();
    _buscaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dadosAsync = ref.watch(dadosEdicaoPedidoProvider);
    final larguraTela = MediaQuery.sizeOf(context).width;
    final telaCheia = larguraTela < 760;

    return Dialog(
      insetPadding: EdgeInsets.zero,
      alignment: telaCheia ? Alignment.center : Alignment.centerRight,
      shape: const RoundedRectangleBorder(),
      child: SizedBox(
        width: telaCheia ? larguraTela : 1080.0.clamp(0, larguraTela),
        height: MediaQuery.sizeOf(context).height,
        child: dadosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErroCarregar(
            onTentar: () => ref.invalidate(dadosEdicaoPedidoProvider),
          ),
          data: (dados) {
            if (dados.plataformas.isEmpty) {
              return _SemPlataformas(
                onFechar: () => Navigator.of(context).pop(false),
              );
            }
            _plataformaId ??= dados.plataformas.keys.isEmpty
                ? null
                : dados.plataformas.keys.first.id;
            if (widget.pedido == null) {
              _embalagem = dados.configuracoes?.embalagemPadrao ??
                  Decimal.zero;
              _impressao = dados.configuracoes?.impressaoPadrao ??
                  Decimal.zero;
            }
            return _corpo(dados);
          },
        ),
      ),
    );
  }

  Widget _corpo(DadosEdicaoPedido dados) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;

    return Column(
      children: [
        // Cabeçalho fixo.
        Container(
          padding: const EdgeInsets.all(Espacos.g16),
          decoration: BoxDecoration(
            color: cores.surface,
            border: Border(bottom: BorderSide(color: cores.line)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.pedido == null ? 'Novo pedido' : 'Pedido',
                  style: textos.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Espacos.paddingPainel),
            child: LayoutBuilder(
              builder: (context, c) {
                final largo = c.maxWidth >= 860;
                final esquerda = _colunaEsquerda(dados);
                final direita = _resumo(dados);
                if (!largo) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      esquerda,
                      const SizedBox(height: Espacos.g16),
                      direita,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: esquerda),
                    const SizedBox(width: Espacos.g16),
                    Expanded(flex: 2, child: direita),
                  ],
                );
              },
            ),
          ),
        ),
        // Rodapé fixo.
        Container(
          padding: const EdgeInsets.all(Espacos.g16),
          decoration: BoxDecoration(
            color: cores.surface,
            border: Border(top: BorderSide(color: cores.line)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _salvando
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: Espacos.g12),
              FilledButton(
                onPressed: _salvando ? null : () => _salvar(dados),
                child: _salvando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar pedido'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _colunaEsquerda(DadosEdicaoPedido dados) {
    final plataformas = dados.plataformas.keys.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cabeçalho do pedido.
        Wrap(
          spacing: Espacos.g12,
          runSpacing: Espacos.g12,
          children: [
            SizedBox(width: 180, child: _campoData()),
            SizedBox(
              width: 240,
              child: TextField(
                controller: _clienteCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Cliente / nº do pedido',
                ),
              ),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                initialValue: _plataformaId,
                isExpanded: true,
                decoration:
                    const InputDecoration(labelText: 'Plataforma de venda'),
                items: [
                  for (final p in plataformas)
                    DropdownMenuItem(value: p.id, child: Text(p.nome)),
                ],
                onChanged: (v) => setState(() {
                  _plataformaId = v;
                  _recalcularAuto(dados);
                }),
              ),
            ),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<SituacaoPedido>(
                initialValue: _situacao,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Situação'),
                items: const [
                  DropdownMenuItem(
                    value: SituacaoPedido.concluido,
                    child: Text('Concluído'),
                  ),
                  DropdownMenuItem(
                    value: SituacaoPedido.cancelado,
                    child: Text('Cancelado'),
                  ),
                  DropdownMenuItem(
                    value: SituacaoPedido.devolvido,
                    child: Text('Devolvido'),
                  ),
                ],
                onChanged: (v) => setState(
                  () => _situacao = v ?? SituacaoPedido.concluido,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Espacos.g20),
        _painel(
          'Itens do pedido',
          _listaItens(dados),
        ),
        const SizedBox(height: Espacos.g16),
        _painel(
          'Adicionar produto ou produto de venda',
          _picker(dados),
        ),
        const SizedBox(height: Espacos.g16),
        _painel('Custos do envio', _custosEnvio()),
        const SizedBox(height: Espacos.g16),
        _painel('Venda', _venda()),
      ],
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

  Widget _listaItens(DadosEdicaoPedido dados) {
    if (_linhas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Espacos.g12),
        child: Text('Adicione os itens que o cliente comprou.'),
      );
    }
    final cores = context.cores;
    return Column(
      children: [
        for (var i = 0; i < _linhas.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Espacos.g8),
            child: Row(
              children: [
                Expanded(child: _nomeLinha(dados, _linhas[i])),
                _controleQtd(i, dados),
              ],
            ),
          ),
        Divider(color: cores.line),
      ],
    );
  }

  Widget _nomeLinha(DadosEdicaoPedido dados, _LinhaEdicao l) {
    final textos = Theme.of(context).textTheme;
    final nome = l.ehKit
        ? _kitPorId(dados, l.refId)?.nome ?? '?'
        : _produtoPorId(dados, l.refId)?.nome ?? '?';
    final prefixo = l.ehKit ? 'kit · ' : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(nome, style: textos.bodyMedium),
        Text('$prefixo${l.quantidade} un', style: textos.bodySmall),
      ],
    );
  }

  Widget _controleQtd(int i, DadosEdicaoPedido dados) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(LucideIcons.minus, size: 16),
          onPressed: () => setState(() {
            _linhas[i].quantidade--;
            if (_linhas[i].quantidade <= 0) _linhas.removeAt(i);
            _recalcularAuto(dados);
          }),
        ),
        Text('${i < _linhas.length ? _linhas[i].quantidade : ''}'),
        IconButton(
          icon: const Icon(LucideIcons.plus, size: 16),
          onPressed: () => setState(() {
            _linhas[i].quantidade++;
            _recalcularAuto(dados);
          }),
        ),
      ],
    );
  }

  Widget _picker(DadosEdicaoPedido dados) {
    final q = _busca.trim().toLowerCase();
    final produtos = dados.produtos
        .where((p) =>
            q.isEmpty ||
            p.nome.toLowerCase().contains(q) ||
            p.codigo.toLowerCase().contains(q))
        .take(8)
        .toList();
    final kits = dados.kits
        .where((k) => q.isEmpty || k.nome.toLowerCase().contains(q))
        .take(8)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _buscaCtrl,
          decoration: const InputDecoration(
            hintText: 'Buscar produto ou kit',
            prefixIcon: Icon(LucideIcons.search, size: 18),
            isDense: true,
          ),
          onChanged: (v) => setState(() => _busca = v),
        ),
        const SizedBox(height: Espacos.g8),
        for (final k in kits)
          ListTile(
            dense: true,
            leading: const Icon(LucideIcons.package, size: 18),
            title: Text('${k.nome} (kit)'),
            trailing: const Icon(LucideIcons.plus, size: 16),
            onTap: () => _adicionar(dados, ehKit: true, refId: k.id),
          ),
        for (final p in produtos)
          ListTile(
            dense: true,
            leading: Text(p.codigo),
            title: Text(p.nome),
            trailing: const Icon(LucideIcons.plus, size: 16),
            onTap: () => _adicionar(dados, ehKit: false, refId: p.id),
          ),
      ],
    );
  }

  Widget _custosEnvio() {
    return Wrap(
      spacing: Espacos.g12,
      runSpacing: Espacos.g12,
      children: [
        SizedBox(
          width: 180,
          child: _campoMoeda(
            r'Embalagem (R$)',
            _embalagem,
            (v) => setState(() {
              _embalagem = v ?? Decimal.zero;
              _autoEnvio = false;
            }),
          ),
        ),
        SizedBox(
          width: 180,
          child: _campoMoeda(
            r'Impressão (R$)',
            _impressao,
            (v) => setState(() {
              _impressao = v ?? Decimal.zero;
              _autoEnvio = false;
            }),
          ),
        ),
        SizedBox(
          width: 180,
          child: _campoMoeda(
            r'Outros (R$)',
            _outros,
            (v) => setState(() => _outros = v ?? Decimal.zero),
          ),
        ),
      ],
    );
  }

  Widget _venda() {
    return Wrap(
      spacing: Espacos.g12,
      runSpacing: Espacos.g12,
      children: [
        SizedBox(
          width: 200,
          child: TextField(
            controller: _precoCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: r'Preço de venda (R$)',
            ),
            onChanged: (v) => setState(() {
              _precoVenda = Formatos.parseDecimal(v) ?? Decimal.zero;
              _autoPreco = false;
            }),
          ),
        ),
        SizedBox(
          width: 200,
          child: TextField(
            controller: _itensTaxaCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Itens cobrados com taxa fixa',
            ),
            onChanged: (v) => setState(() {
              _itensTaxaFixa = int.tryParse(v) ?? 1;
              _autoPreco = false;
            }),
          ),
        ),
        SizedBox(
          width: 200,
          child: TextField(
            controller: _liquidoCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: r'Líquido recebido (R$)',
            ),
            onChanged: (v) => setState(
              () => _liquidoInformado = Formatos.parseDecimal(v),
            ),
          ),
        ),
        SizedBox(
          width: 420,
          child: TextField(
            controller: _obsCtrl,
            decoration: const InputDecoration(labelText: 'Observação'),
          ),
        ),
      ],
    );
  }

  Widget _resumo(DadosEdicaoPedido dados) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final pedido = _montarPedido(dados);
    final faixas = _faixasDaPlataforma(dados);
    final r = calcularPedido(pedido, faixas);
    final v = dados.configuracoes?.valorAbelinha ?? Decimal.zero;

    Widget linha(String rotulo, String valor, {bool forte = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                rotulo,
                style: forte
                    ? textos.bodyMedium?.copyWith(fontWeight: FontWeight.w600)
                    : textos.bodySmall,
              ),
            ),
            Text(
              valor,
              style: forte
                  ? textos.bodyMedium?.copyWith(fontWeight: FontWeight.w600)
                  : textos.bodyMedium,
            ),
          ],
        ),
      );
    }

    final lucroNegativo = r.lucro < Decimal.zero;

    return Container(
      padding: const EdgeInsets.all(Espacos.g16),
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Custo do pedido', style: textos.labelLarge),
          linha('Mercadoria', Formatos.moedaDecimal(r.mercadoria)),
          linha(
            'Embalagem + impressão + outros',
            Formatos.moedaDecimal(_embalagem + _impressao + _outros),
          ),
          linha('Custo total', Formatos.moedaDecimal(r.custo), forte: true),
          const SizedBox(height: Espacos.g12),
          Text('Abelinhas do pedido', style: textos.labelLarge),
          linha(
            'Total de abelinhas',
            Formatos.abelinhas(r.abelinhasPedido.toDouble()),
            forte: true,
          ),
          linha(
            'Valem com 1 🐝 = ${Formatos.moedaDecimal(v)}',
            Formatos.moedaDecimal(r.abelinhasPedido * v),
          ),
          const SizedBox(height: Espacos.g12),
          Text('Venda', style: textos.labelLarge),
          linha('Preço de venda', Formatos.moedaDecimal(pedido.precoVenda)),
          linha(
            'Taxa estimada',
            Formatos.moedaDecimal(r.taxaEstimada),
          ),
          linha(
            'Líquido estimado',
            Formatos.moedaDecimal(r.liquidoEstimado),
          ),
          linha(
            'Líquido considerado',
            '${Formatos.moedaDecimal(r.liquido)} '
                '${_liquidoInformado != null ? '(informado)' : '(estimado)'}',
          ),
          linha('Taxa efetiva', Formatos.moedaDecimal(r.taxaEfetiva)),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Lucro do pedido', style: textos.titleMedium),
              Text(
                Formatos.moedaDecimal(r.lucro),
                style: textos.titleMedium?.copyWith(
                  color: lucroNegativo ? cores.bad : cores.good,
                ),
              ),
            ],
          ),
          Text(
            'Margem sobre a venda: '
            '${Formatos.percentualFracao(r.margem.toDouble())}',
            style: textos.bodySmall,
          ),
          if (_avisoLiquido(r) != null) ...[
            const SizedBox(height: Espacos.g12),
            Container(
              padding: const EdgeInsets.all(Espacos.g12),
              decoration: BoxDecoration(
                color: cores.warnSoft,
                borderRadius: BorderRadius.circular(Raios.controle),
              ),
              child: Text(
                _avisoLiquido(r)!,
                style: textos.bodySmall?.copyWith(color: cores.warn),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _avisoLiquido(ResultadoPedido r) {
    if (_liquidoInformado == null) return null;
    final dif = (r.liquido - r.liquidoEstimado).abs();
    if (dif > Decimal.parse('0.5')) {
      return 'O líquido informado difere ${Formatos.moedaDecimal(dif)} da '
          'estimativa. Se for recorrente, revise as faixas em '
          'Plataformas e taxas.';
    }
    return null;
  }

  Widget _painel(String titulo, Widget corpo) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(Espacos.g16),
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(titulo, style: textos.titleMedium),
          const SizedBox(height: Espacos.g8),
          corpo,
        ],
      ),
    );
  }

  Widget _campoMoeda(
    String label,
    Decimal valor,
    ValueChanged<Decimal?> onChanged,
  ) {
    return TextFormField(
      initialValue: valor == Decimal.zero
          ? ''
          : Formatos.numero(valor.toDouble()),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      onChanged: (v) => onChanged(Formatos.parseDecimal(v)),
    );
  }

  // ---- lógica ----

  Produto? _produtoPorId(DadosEdicaoPedido dados, String id) {
    for (final p in dados.produtos) {
      if (p.id == id) return p;
    }
    return null;
  }

  ProdutoVenda? _kitPorId(DadosEdicaoPedido dados, String id) {
    for (final k in dados.kits) {
      if (k.id == id) return k;
    }
    return null;
  }

  Plataforma? _plataformaAtual(DadosEdicaoPedido dados) {
    for (final p in dados.plataformas.keys) {
      if (p.id == _plataformaId) return p;
    }
    return dados.plataformas.keys.isEmpty
        ? null
        : dados.plataformas.keys.first;
  }

  List<FaixaTaxa> _faixasDaPlataforma(DadosEdicaoPedido dados) {
    for (final e in dados.plataformas.entries) {
      if (e.key.id == _plataformaId) return e.value;
    }
    return const [];
  }

  Map<String, Produto> _produtosPorId(DadosEdicaoPedido dados) => {
        for (final p in dados.produtos) p.id: p,
      };

  void _adicionar(
    DadosEdicaoPedido dados, {
    required bool ehKit,
    required String refId,
  }) {
    setState(() {
      final existente = _linhas.firstWhere(
        (l) => l.ehKit == ehKit && l.refId == refId,
        orElse: () => _LinhaEdicao(ehKit: ehKit, refId: refId, quantidade: 0),
      );
      if (existente.quantidade == 0) {
        existente.quantidade = 1;
        _linhas.add(existente);
      } else {
        existente.quantidade++;
      }
      _recalcularAuto(dados);
    });
  }

  /// Recalcula preço/itens cobrados e custos de envio conforme as regras
  /// automáticas (design §6.4), só enquanto o usuário não editou à mão.
  void _recalcularAuto(DadosEdicaoPedido dados) {
    final soKits = _linhas.isNotEmpty && _linhas.every((l) => l.ehKit);
    final temProdutoAvulso = _linhas.any((l) => !l.ehKit);

    if (_autoEnvio) {
      if (soKits) {
        _embalagem = Decimal.zero;
        _impressao = Decimal.zero;
      } else if (temProdutoAvulso) {
        _embalagem = dados.configuracoes?.embalagemPadrao ?? Decimal.zero;
        _impressao = dados.configuracoes?.impressaoPadrao ?? Decimal.zero;
      }
    }

    if (_autoPreco) {
      final plataforma = _plataformaAtual(dados);
      final kitsComQtd = <ProdutoVenda, int>{};
      for (final l in _linhas.where((l) => l.ehKit)) {
        final k = _kitPorId(dados, l.refId);
        if (k != null) kitsComQtd[k] = l.quantidade;
      }
      if (plataforma != null && kitsComQtd.isNotEmpty) {
        _precoVenda = precoAutomatico(
          kitsComQtd,
          _produtosPorId(dados),
          plataforma,
          _faixasDaPlataforma(dados),
          dados.faixasAbelinha,
        );
        _itensTaxaFixa = itensTaxaFixaAutomatico(kitsComQtd);
        _precoCtrl.text = Formatos.numero(_precoVenda.toDouble());
        _itensTaxaCtrl.text = '$_itensTaxaFixa';
      }
    }
  }

  /// Monta um [Pedido] em memória com os snapshots calculados, para cálculo
  /// e para salvar.
  Pedido _montarPedido(DadosEdicaoPedido dados) {
    final plataforma = _plataformaAtual(dados);
    final faixas = _faixasDaPlataforma(dados);
    final produtosPorId = _produtosPorId(dados);
    final itens = <PedidoItem>[];

    for (final l in _linhas) {
      Decimal custo;
      Decimal abelinhas;
      if (l.ehKit) {
        final k = _kitPorId(dados, l.refId);
        if (k == null || plataforma == null) continue;
        final r = calcularKit(
          k,
          produtosPorId,
          plataforma,
          faixas,
          dados.faixasAbelinha,
        );
        custo = r.investimento;
        abelinhas = r.abelinhasKit;
      } else {
        final p = _produtoPorId(dados, l.refId);
        if (p == null) continue;
        custo = p.custo;
        abelinhas = abelinhasProduto(p, dados.faixasAbelinha);
      }
      itens.add(
        PedidoItem(
          id: '',
          empresaId: '',
          pedidoId: widget.pedido?.id ?? '',
          tipo: l.ehKit
              ? TipoPedidoItem.produtoVenda
              : TipoPedidoItem.produto,
          quantidade: l.quantidade,
          custoUnitario: custo,
          abelinhasUnitarias: abelinhas,
          produtoId: l.ehKit ? null : l.refId,
          produtoVendaId: l.ehKit ? l.refId : null,
        ),
      );
    }

    return Pedido(
      id: widget.pedido?.id ?? '',
      empresaId: widget.pedido?.empresaId ?? '',
      data: _data,
      cliente: _clienteCtrl.text,
      plataformaId: _plataformaId ?? '',
      embalagem: _embalagem,
      impressao: _impressao,
      outros: _outros,
      precoVenda: _precoVenda,
      itensTaxaFixa: _itensTaxaFixa,
      liquidoInformado: _liquidoInformado,
      situacao: _situacao,
      obs: _obsCtrl.text,
      itens: itens,
    );
  }

  Future<void> _salvar(DadosEdicaoPedido dados) async {
    final cliente = _clienteCtrl.text.trim();
    if (cliente.isEmpty) {
      _toast('Informe o cliente ou nº do pedido');
      return;
    }
    if (_linhas.isEmpty) {
      _toast('Adicione pelo menos um item');
      return;
    }
    final empresa = await ref.read(empresaAtualProvider.future);
    if (empresa == null) {
      _toast('Nenhuma empresa ativa. Entre com a conta do Supabase.');
      return;
    }

    setState(() => _salvando = true);
    try {
      final base = _montarPedido(dados);
      final pedido = base.copyWith(
        empresaId: empresa.id,
        cliente: PadraoEscrita.maius(cliente),
        obs: _obsCtrl.text.isEmpty
            ? ''
            : PadraoEscrita.frase(_obsCtrl.text),
        itens: [
          for (final i in base.itens) i.copyWith(empresaId: empresa.id),
        ],
      );
      await ref.read(pedidoRepositoryProvider).salvar(pedido);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on Object {
      if (!mounted) return;
      setState(() => _salvando = false);
      _toast('Não foi possível salvar. Verifique a conexão e tente de novo.');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _SemPlataformas extends StatelessWidget {
  const _SemPlataformas({required this.onFechar});

  final VoidCallback onFechar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Espacos.g20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cadastre ao menos uma plataforma em "Plataformas e taxas" '
              'antes de lançar um pedido.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Espacos.g12),
            OutlinedButton(onPressed: onFechar, child: const Text('Fechar')),
          ],
        ),
      ),
    );
  }
}

class _ErroCarregar extends StatelessWidget {
  const _ErroCarregar({required this.onTentar});

  final VoidCallback onTentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Não foi possível carregar os dados do pedido.'),
          const SizedBox(height: Espacos.g12),
          OutlinedButton(
            onPressed: onTentar,
            child: const Text('Tentar de novo'),
          ),
        ],
      ),
    );
  }
}
