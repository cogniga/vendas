import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/format/padrao_escrita.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/botao_pequeno.dart';
import 'package:sales/core/widgets/code_chip.dart';
import 'package:sales/core/widgets/money_field.dart';
import 'package:sales/core/widgets/painel_card.dart';
import 'package:sales/core/widgets/pill.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/data/repositorios/pedido_repository.dart';
import 'package:sales/domain/calculos/abelinhas.dart';
import 'package:sales/domain/calculos/pedido.dart';
import 'package:sales/domain/calculos/produto_venda.dart';
import 'package:sales/domain/calculos/taxas.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/pedido_item.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/domain/entidades/produto_venda.dart';
import 'package:sales/features/pedidos/application/pedidos_providers.dart';
import 'package:sales/features/pedidos/presentation/pedido_resumo.dart';

/// Largura mínima do corpo para exibir as duas colunas (protótipo: 860).
const double _limiarDuasColunas = 860;

/// Largura abaixo da qual o editor ocupa a tela toda.
const double _limiarTelaCheia = 760;

/// Rótulo exibido para cada situação (D10 em `docs/decisoes.md`).
String rotuloSituacao(SituacaoPedido s) => switch (s) {
      SituacaoPedido.concluido => 'Pago',
      SituacaoPedido.devolvido => 'Devolvido',
      SituacaoPedido.cancelado => 'Cancelado',
    };

/// Uma linha em edição no pedido (produto avulso ou kit) com quantidade.
///
/// [original] guarda o item já gravado: seu snapshot de custo e abelinhas é
/// preservado ao salvar, mesmo que o produto/kit tenha mudado ou sumido.
class _LinhaEdicao {
  _LinhaEdicao({
    required this.ehKit,
    required this.refId,
    required this.quantidade,
    this.original,
  });

  final bool ehKit;
  final String refId;
  int quantidade;
  final PedidoItem? original;
}

/// Custo e abelinhas unitários de uma linha.
typedef _Snapshot = ({Decimal custo, Decimal abelinhas});

/// Editor de pedido (R5) em painel largo, fiel ao protótipo.
///
/// Recebe [pedido] para edição ou `null` para um novo. Ao editar, busca o
/// pedido completo (com itens) antes de montar o formulário, então nunca
/// depende de a lista estar completa. Fecha com `Navigator.pop(context,
/// true)` quando salva.
class PedidoEditor extends ConsumerWidget {
  const PedidoEditor({this.pedido, super.key});

  final Pedido? pedido;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = pedido?.id;
    final dadosAsync = ref.watch(dadosEdicaoPedidoProvider);
    final completoAsync =
        id == null ? null : ref.watch(pedidoCompletoProvider(id));
    final titulo = id == null ? 'Novo pedido' : 'Pedido';
    void fechar() => Navigator.of(context).pop(false);

    if (dadosAsync.hasError || (completoAsync?.hasError ?? false)) {
      return _Casca(
        titulo: titulo,
        aoFechar: fechar,
        corpo: _Mensagem(
          texto: 'Não foi possível carregar os dados do pedido.',
          acao: 'Tentar de novo',
          aoAcionar: () {
            ref.invalidate(dadosEdicaoPedidoProvider);
            if (id != null) ref.invalidate(pedidoCompletoProvider(id));
          },
        ),
      );
    }
    final dados = dadosAsync.valueOrNull;
    final completo = completoAsync?.valueOrNull;
    if (dados == null || (id != null && completoAsync!.isLoading)) {
      return _Casca(
        titulo: titulo,
        aoFechar: fechar,
        corpo: const Center(child: CircularProgressIndicator()),
      );
    }
    if (id != null && completo == null) {
      return _Casca(
        titulo: titulo,
        aoFechar: fechar,
        corpo: const _Mensagem(texto: 'Este pedido não existe mais.'),
      );
    }
    if (dados.plataformas.isEmpty) {
      return _Casca(
        titulo: titulo,
        aoFechar: fechar,
        corpo: const _Mensagem(
          texto: 'Cadastre ao menos uma plataforma em "Plataformas e taxas" '
              'antes de lançar um pedido.',
        ),
      );
    }
    return _PedidoForm(
      key: ValueKey(id ?? 'novo'),
      dados: dados,
      inicial: completo,
    );
  }
}

class _PedidoForm extends ConsumerStatefulWidget {
  const _PedidoForm({required this.dados, required this.inicial, super.key});

  final DadosEdicaoPedido dados;
  final Pedido? inicial;

  @override
  ConsumerState<_PedidoForm> createState() => _PedidoFormState();
}

class _PedidoFormState extends ConsumerState<_PedidoForm> {
  final _clienteCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  final _precoCtrl = TextEditingController();
  final _liquidoCtrl = TextEditingController();
  final _itensTaxaCtrl = TextEditingController(text: '1');
  final _embalagemCtrl = TextEditingController();
  final _impressaoCtrl = TextEditingController();
  final _outrosCtrl = TextEditingController();
  final _buscaCtrl = TextEditingController();

  DateTime _data = DateTime.now();
  late String _plataformaId;
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

  /// Cache do cálculo dos kits (o custo não depende do que o usuário digita).
  final Map<String, ResultadoKit> _kitCalc = {};

  DadosEdicaoPedido get _dados => widget.dados;

  @override
  void initState() {
    super.initState();
    final p = widget.inicial;
    _plataformaId = _dados.plataformas.keys.first.id;
    if (p == null) {
      _embalagem = _dados.configuracoes?.embalagemPadrao ?? Decimal.zero;
      _impressao = _dados.configuracoes?.impressaoPadrao ?? Decimal.zero;
    } else {
      _data = p.data;
      if (_dados.plataformas.keys.any((x) => x.id == p.plataformaId)) {
        _plataformaId = p.plataformaId;
      }
      _situacao = p.situacao;
      _clienteCtrl.text = p.cliente;
      _obsCtrl.text = p.obs;
      _embalagem = p.embalagem;
      _impressao = p.impressao;
      _outros = p.outros;
      _precoVenda = p.precoVenda;
      _liquidoInformado = p.liquidoInformado;
      _itensTaxaFixa = p.itensTaxaFixa;
      _itensTaxaCtrl.text = '${p.itensTaxaFixa}';
      _precoCtrl.text = _texto(p.precoVenda);
      _liquidoCtrl.text =
          p.liquidoInformado == null ? '' : _texto(p.liquidoInformado!);
      _autoPreco = false;
      _autoEnvio = false;
      for (final item in p.itens) {
        _linhas.add(
          _LinhaEdicao(
            ehKit: item.tipo == TipoPedidoItem.produtoVenda,
            refId: item.produtoVendaId ?? item.produtoId ?? '',
            quantidade: item.quantidade,
            original: item,
          ),
        );
      }
    }
    _embalagemCtrl.text = _texto(_embalagem);
    _impressaoCtrl.text = _texto(_impressao);
    _outrosCtrl.text = _texto(_outros);
  }

  @override
  void dispose() {
    for (final c in [
      _clienteCtrl,
      _obsCtrl,
      _precoCtrl,
      _liquidoCtrl,
      _itensTaxaCtrl,
      _embalagemCtrl,
      _impressaoCtrl,
      _outrosCtrl,
      _buscaCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _texto(Decimal v) =>
      v == Decimal.zero ? '' : Formatos.numero(v.toDouble());

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    return _Casca(
      titulo: widget.inicial == null ? 'Novo pedido' : 'Pedido',
      aoFechar: () => Navigator.of(context).pop(false),
      aoSalvar: _salvando ? null : _salvar,
      salvando: _salvando,
      corpo: LayoutBuilder(
        builder: (context, c) {
          final largo = c.maxWidth >= _limiarDuasColunas;
          final pad =
              largo ? Espacos.paddingPainel : Espacos.paddingPainelCelular;
          if (!largo) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _cabecalho(),
                  const SizedBox(height: Espacos.g16),
                  _colunaEsquerda(),
                  const SizedBox(height: Espacos.g16),
                  _resumo(),
                ],
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _cabecalho(),
                const SizedBox(height: Espacos.g16),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 115,
                        child: SingleChildScrollView(child: _colunaEsquerda()),
                      ),
                      const SizedBox(width: Espacos.g16),
                      // Coluna do resumo rola à parte: fica sempre visível.
                      Expanded(
                        flex: 100,
                        child: SingleChildScrollView(child: _resumo()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _cabecalho() {
    final plataformas = _dados.plataformas.keys.toList();
    return _Grade(
      filhos: [
        _Campo(
          rotulo: 'Data',
          filho: InkWell(
            borderRadius: BorderRadius.circular(Raios.controle),
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
              decoration: const InputDecoration(),
              child: Text(Formatos.data(_data)),
            ),
          ),
        ),
        _Campo(
          rotulo: 'Cliente / nº do pedido',
          filho: TextField(
            controller: _clienteCtrl,
            textCapitalization: TextCapitalization.characters,
          ),
        ),
        _Campo(
          rotulo: 'Plataforma de venda',
          filho: DropdownButtonFormField<String>(
            initialValue: _plataformaId,
            isExpanded: true,
            items: [
              for (final p in plataformas)
                DropdownMenuItem(value: p.id, child: Text(p.nome)),
            ],
            onChanged: (v) => setState(() {
              _plataformaId = v ?? _plataformaId;
              _recalcularAuto();
            }),
          ),
        ),
        _Campo(
          rotulo: 'Status',
          filho: DropdownButtonFormField<SituacaoPedido>(
            initialValue: _situacao,
            isExpanded: true,
            items: [
              for (final s in SituacaoPedido.values)
                DropdownMenuItem(value: s, child: Text(rotuloSituacao(s))),
            ],
            onChanged: (v) => setState(() => _situacao = v ?? _situacao),
          ),
        ),
      ],
    );
  }

  Widget _colunaEsquerda() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PainelCard(
          titulo: 'Itens do pedido',
          semPaddingCorpo: true,
          corpo: _listaItens(),
        ),
        const SizedBox(height: Espacos.g16),
        PainelCard(
          titulo: 'Adicionar produto ou produto de venda',
          corpo: _picker(),
        ),
        const SizedBox(height: Espacos.g16),
        PainelCard(titulo: 'Custos do envio', corpo: _custosEnvio()),
        const SizedBox(height: Espacos.g16),
        PainelCard(titulo: 'Venda', corpo: _venda()),
      ],
    );
  }

  // ------------------------------------------------------------------ itens

  Widget _listaItens() {
    if (_linhas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(Espacos.g20),
        child: Text(
          'Adicione os itens que o cliente comprou.',
          style: TextStyle(color: context.cores.muted),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _linhas.length; i++)
          _linhaItem(i, ultima: i == _linhas.length - 1),
      ],
    );
  }

  Widget _linhaItem(int i, {required bool ultima}) {
    final cores = context.cores;
    final l = _linhas[i];
    final snap = _snapshot(l);
    final custo = snap?.custo ?? Decimal.zero;
    final qtd = Decimal.fromInt(l.quantidade);
    final nome = _nomeDe(l);
    final detalhe = _detalheAbelinhas(l, snap);

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _marca(l),
            const SizedBox(width: Espacos.g8),
            Flexible(child: Text(nome, overflow: TextOverflow.ellipsis)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          detalhe,
          style: TextStyle(fontSize: 12, color: cores.muted),
        ),
      ],
    );
    final total = SizedBox(
      width: 76,
      child: Text(
        Formatos.moedaDecimal(custo * qtd),
        textAlign: TextAlign.right,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
    final remover = Tooltip(
      message: 'Remover item',
      child: Semantics(
        button: true,
        label: 'Remover item',
        child: InkWell(
          borderRadius: BorderRadius.circular(Raios.controle),
          onTap: () => setState(() {
            _linhas.removeAt(i);
            _recalcularAuto();
          }),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(LucideIcons.trash2, size: 16, color: cores.muted),
          ),
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Espacos.paddingPainel,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: ultima ? null : Border(bottom: BorderSide(color: cores.line)),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth < 480) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                info,
                const SizedBox(height: 6),
                Row(
                  children: [
                    _controleQtd(i),
                    const Spacer(),
                    total,
                    remover,
                  ],
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: info),
              const SizedBox(width: Espacos.g12),
              Text(
                Formatos.moedaDecimal(custo),
                style: TextStyle(color: cores.muted),
              ),
              const SizedBox(width: Espacos.g12),
              _controleQtd(i),
              const SizedBox(width: Espacos.g12),
              total,
              remover,
            ],
          );
        },
      ),
    );
  }

  Widget _marca(_LinhaEdicao l) {
    if (l.ehKit) return const Pill('kit', tom: TomPill.bom);
    return CodeChip(_produtoPorId(l.refId)?.codigo ?? '?');
  }

  String _nomeDe(_LinhaEdicao l) {
    if (l.ehKit) return _kitPorId(l.refId)?.nome ?? '(kit removido)';
    return _produtoPorId(l.refId)?.nome ?? '(produto removido)';
  }

  String _detalheAbelinhas(_LinhaEdicao l, _Snapshot? snap) {
    final ab = snap?.abelinhas ?? Decimal.zero;
    final texto = StringBuffer(
      '${Formatos.abelinhas(ab.toDouble())} cada',
    );
    if (l.quantidade > 1) {
      final total = ab * Decimal.fromInt(l.quantidade);
      texto.write(' · ${Formatos.abelinhas(total.toDouble())} no total');
    }
    final kit = l.ehKit ? _kitPorId(l.refId) : null;
    if (kit != null) {
      final partes = <String>[];
      for (final i in kit.itens) {
        final p = _produtoPorId(i.produtoId);
        final abItem = p == null
            ? Decimal.zero
            : abelinhasProduto(p, _dados.faixasAbelinha) *
                Decimal.fromInt(i.quantidade);
        partes.add(
          '${i.quantidade}× ${p?.codigo ?? '?'} '
          '(${Formatos.abelinhas(abItem.toDouble())})',
        );
      }
      if (partes.isNotEmpty) texto.write(' · ${partes.join(' + ')}');
    }
    return texto.toString();
  }

  Widget _controleQtd(int i) {
    final cores = context.cores;
    Widget botao(String dica, IconData icone, VoidCallback aoTocar) {
      return Tooltip(
        message: dica,
        child: Semantics(
          button: true,
          label: dica,
          child: InkWell(
            onTap: aoTocar,
            child: SizedBox(
              width: 28,
              height: 28,
              child: Icon(icone, size: 14, color: cores.muted),
            ),
          ),
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.controle),
        border: Border.all(color: cores.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          botao('Diminuir', LucideIcons.minus, () => setState(() {
                _linhas[i].quantidade--;
                if (_linhas[i].quantidade <= 0) _linhas.removeAt(i);
                _recalcularAuto();
              })),
          SizedBox(
            width: 26,
            child: Text(
              '${_linhas[i].quantidade}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          botao('Aumentar', LucideIcons.plus, () => setState(() {
                _linhas[i].quantidade++;
                _recalcularAuto();
              })),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- picker

  Widget _picker() {
    final cores = context.cores;
    final q = _busca.trim().toLowerCase();
    final produtos = _dados.produtos
        .where((p) => p.ativo)
        .where(
          (p) =>
              q.isEmpty ||
              '${p.codigo} ${p.nome} ${p.marca}'.toLowerCase().contains(q),
        )
        .take(60)
        .toList();
    final kits = _dados.kits
        .where((k) => q.isEmpty || k.nome.toLowerCase().contains(q))
        .toList();

    Widget linha({
      required Widget marca,
      required InlineSpan nome,
      required Decimal custo,
      required VoidCallback aoAdicionar,
      required bool primeira,
    }) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border:
              primeira ? null : Border(top: BorderSide(color: cores.line)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: LayoutBuilder(
            builder: (context, c) {
              final custoTxt = Text(
                Formatos.moedaDecimal(custo),
                style: const TextStyle(fontWeight: FontWeight.w600),
              );
              final botao = BotaoPequeno(
                rotulo: 'Adicionar',
                onPressed: aoAdicionar,
              );
              final titulo = Text.rich(nome, overflow: TextOverflow.ellipsis);
              if (c.maxWidth < 380) {
                // Estreito: o custo e o botão descem para a linha de baixo.
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        marca,
                        const SizedBox(width: 10),
                        Expanded(child: titulo),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [custoTxt, const SizedBox(width: 10), botao],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  marca,
                  const SizedBox(width: 10),
                  Expanded(child: titulo),
                  const SizedBox(width: 10),
                  custoTxt,
                  const SizedBox(width: 10),
                  botao,
                ],
              );
            },
          ),
        ),
      );
    }

    final itens = <Widget>[];
    for (final k in kits) {
      itens.add(
        linha(
          marca: const Pill('kit', tom: TomPill.bom),
          nome: TextSpan(text: k.nome),
          custo: _calcKit(k).investimento,
          aoAdicionar: () => _adicionar(ehKit: true, refId: k.id),
          primeira: itens.isEmpty,
        ),
      );
    }
    for (final p in produtos) {
      itens.add(
        linha(
          marca: CodeChip(p.codigo),
          nome: TextSpan(
            children: [
              TextSpan(text: p.nome),
              TextSpan(
                text: '  ${p.marca}',
                style: TextStyle(color: cores.muted),
              ),
            ],
          ),
          custo: p.custo,
          aoAdicionar: () => _adicionar(ehKit: false, refId: p.id),
          primeira: itens.isEmpty,
        ),
      );
    }

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
        const SizedBox(height: Espacos.g12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: itens.isEmpty
              ? Text('Nada encontrado.', style: TextStyle(color: cores.muted))
              : SingleChildScrollView(child: Column(children: itens)),
        ),
      ],
    );
  }

  // ------------------------------------------------------- custos e venda

  Widget _custosEnvio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Grade(
          filhos: [
            _Campo(
              rotulo: r'Embalagem (R$)',
              filho: _moeda(_embalagemCtrl, (v) {
                _embalagem = v ?? Decimal.zero;
                _autoEnvio = false;
              }),
            ),
            _Campo(
              rotulo: r'Impressão (R$)',
              filho: _moeda(_impressaoCtrl, (v) {
                _impressao = v ?? Decimal.zero;
                _autoEnvio = false;
              }),
            ),
            _Campo(
              rotulo: r'Outros (R$)',
              dica: 'Brinde, fita, frete pago por você',
              filho: _moeda(_outrosCtrl, (v) {
                _outros = v ?? Decimal.zero;
                _autoEnvio = false;
              }),
            ),
          ],
        ),
        const SizedBox(height: Espacos.g12),
        Text(
          'Kits já incluem embalagem e impressão no custo, então aqui fica '
          'zerado quando o pedido tem só kits.',
          style: TextStyle(fontSize: 12, color: context.cores.muted),
        ),
      ],
    );
  }

  Widget _venda() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Grade(
          filhos: [
            _Campo(
              rotulo: r'Preço de venda (R$)',
              dica: 'Valor total pago pelo cliente. Com kit, já vem o preço '
                  'dele na plataforma',
              filho: _moeda(_precoCtrl, (v) {
                _precoVenda = v ?? Decimal.zero;
                _autoPreco = false;
              }),
            ),
            _Campo(
              rotulo: 'Itens cobrados com taxa fixa',
              dica: 'A taxa fixa é cobrada por item/anúncio',
              filho: TextField(
                controller: _itensTaxaCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) => setState(() {
                  _itensTaxaFixa = int.tryParse(v) ?? 1;
                  _autoPreco = false;
                }),
              ),
            ),
            _Campo(
              rotulo: r'Líquido recebido (R$)',
              dica: 'Valor que a plataforma informou. Em branco usa a '
                  'estimativa',
              filho: MoneyField(
                controller: _liquidoCtrl,
                prefix: '',
                onChanged: (v) => setState(() => _liquidoInformado = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: Espacos.g12),
        _Campo(
          rotulo: 'Observação',
          filho: TextField(controller: _obsCtrl),
        ),
      ],
    );
  }

  Widget _moeda(TextEditingController ctrl, void Function(Decimal?) aoMudar) {
    return MoneyField(
      controller: ctrl,
      prefix: '',
      onChanged: (v) => setState(() => aoMudar(v)),
    );
  }

  // ----------------------------------------------------------------- resumo

  Widget _resumo() {
    final pedido = _montarPedido();
    final faixas = _faixasDaPlataforma();
    final r = calcularPedido(pedido, faixas);
    final valor = _dados.configuracoes?.valorAbelinha ?? Decimal.zero;
    final plataforma = _plataformaAtual();
    final f = faixa(faixas, pedido.precoVenda);
    final semItens = _linhas.isEmpty;
    final temKit = _linhas.any((l) => l.ehKit);

    final fixo = pedido.itensTaxaFixa > 1
        ? '${Formatos.moedaDecimal(f.taxaFixa)} × ${pedido.itensTaxaFixa}'
        : Formatos.moedaDecimal(f.taxaFixa);
    final outras = f.taxaOutras ?? Decimal.zero;
    final rotuloTaxa = 'Taxa estimada ${plataforma.nome} '
        '(${_pct(f.taxaPercentual)}%'
        '${outras > Decimal.zero ? ' + ${_pct(outras)}% outras' : ''}'
        ' + $fixo)';

    final linhasAb = <(String, String)>[
      if (semItens)
        ('Nenhum item ainda', '0 🐝')
      else
        for (final l in _linhas)
          (
            '${_nomeDe(l)}${l.quantidade > 1 ? ' × ${l.quantidade}' : ''}',
            Formatos.abelinhas(
              ((_snapshot(l)?.abelinhas ?? Decimal.zero) *
                      Decimal.fromInt(l.quantidade))
                  .toDouble(),
            ),
          ),
    ];

    final efetivaPct = pedido.precoVenda > Decimal.zero
        ? Formatos.percentualFracao(
            (r.taxaEfetiva / pedido.precoVenda).toDouble(),
          )
        : '—';

    String? avisoLiquido;
    if (_liquidoInformado != null) {
      final dif = (r.liquido - r.liquidoEstimado).abs();
      if (dif > Decimal.parse('0.5')) {
        avisoLiquido = 'O líquido informado difere '
            '${Formatos.moedaDecimal(dif)} da estimativa. Se for '
            'recorrente, revise as faixas em Plataformas e taxas.';
      }
    }

    return PedidoResumo(
      mercadoria: Formatos.moedaDecimal(r.mercadoria),
      extras: Formatos.moedaDecimal(_embalagem + _impressao + _outros),
      custoTotal: Formatos.moedaDecimal(r.custo),
      linhasAbelinhas: linhasAb,
      totalAbelinhas: Formatos.abelinhas(r.abelinhasPedido.toDouble()),
      rotuloValorAbelinha: 'Valem com 1 🐝 = ${Formatos.moedaDecimal(valor)}',
      valorAbelinhas: Formatos.moedaDecimal(r.abelinhasPedido * valor),
      precoVenda: Formatos.moedaDecimal(pedido.precoVenda),
      rotuloTaxa: rotuloTaxa,
      taxaEstimada: Formatos.moedaDecimal(r.taxaEstimada),
      liquidoEstimado: Formatos.moedaDecimal(r.liquidoEstimado),
      liquidoConsiderado: Formatos.moedaDecimal(r.liquido),
      liquidoInformado: _liquidoInformado != null,
      taxaEfetiva: '${Formatos.moedaDecimal(r.taxaEfetiva)} · $efetivaPct',
      lucro: Formatos.moedaDecimal(r.lucro),
      lucroNegativo: r.lucro < Decimal.zero,
      margem: pedido.precoVenda > Decimal.zero
          ? Formatos.percentualFracao(r.margem.toDouble())
          : '—',
      avisoPreco: _autoPreco && temKit
          ? 'Preço preenchido com o valor do kit na ${plataforma.nome}. '
              'Troque a plataforma e ele recalcula; digite outro preço se '
              'a venda foi diferente.'
          : null,
      avisoLiquido: avisoLiquido,
    );
  }

  String _pct(Decimal d) => Formatos.numeroCurto(d.toDouble());

  // ----------------------------------------------------------------- lógica

  Produto? _produtoPorId(String id) {
    for (final p in _dados.produtos) {
      if (p.id == id) return p;
    }
    return null;
  }

  ProdutoVenda? _kitPorId(String id) {
    for (final k in _dados.kits) {
      if (k.id == id) return k;
    }
    return null;
  }

  Plataforma _plataformaAtual() {
    for (final p in _dados.plataformas.keys) {
      if (p.id == _plataformaId) return p;
    }
    return _dados.plataformas.keys.first;
  }

  List<FaixaTaxa> _faixasDaPlataforma() {
    for (final e in _dados.plataformas.entries) {
      if (e.key.id == _plataformaId) return e.value;
    }
    return const [];
  }

  Map<String, Produto> get _produtosPorId => {
        for (final p in _dados.produtos) p.id: p,
      };

  ResultadoKit _calcKit(ProdutoVenda k) {
    return _kitCalc[k.id] ??= calcularKit(
      k,
      _produtosPorId,
      _plataformaAtual(),
      _faixasDaPlataforma(),
      _dados.faixasAbelinha,
    );
  }

  /// Custo/abelinhas unitários da linha: o snapshot gravado, se existir;
  /// senão calculado do cadastro atual. `null` se não der para obter.
  _Snapshot? _snapshot(_LinhaEdicao l) {
    final o = l.original;
    if (o != null) {
      return (custo: o.custoUnitario, abelinhas: o.abelinhasUnitarias);
    }
    if (l.ehKit) {
      final k = _kitPorId(l.refId);
      if (k == null) return null;
      final r = _calcKit(k);
      return (custo: r.investimento, abelinhas: r.abelinhasKit);
    }
    final p = _produtoPorId(l.refId);
    if (p == null) return null;
    return (
      custo: p.custo,
      abelinhas: abelinhasProduto(p, _dados.faixasAbelinha),
    );
  }

  void _adicionar({required bool ehKit, required String refId}) {
    setState(() {
      final existente = _linhas.where(
        (l) => l.ehKit == ehKit && l.refId == refId,
      );
      if (existente.isEmpty) {
        _linhas.add(
          _LinhaEdicao(ehKit: ehKit, refId: refId, quantidade: 1),
        );
      } else {
        existente.first.quantidade++;
      }
      _recalcularAuto();
    });
  }

  void _definirMoeda(TextEditingController ctrl, Decimal v) {
    ctrl.text = _texto(v);
  }

  /// Recalcula preço/itens cobrados e custos de envio conforme as regras
  /// automáticas (design §6.4), só enquanto o usuário não editou à mão.
  void _recalcularAuto() {
    final soKits = _linhas.isNotEmpty && _linhas.every((l) => l.ehKit);
    final temProdutoAvulso = _linhas.any((l) => !l.ehKit);

    if (_autoEnvio) {
      if (soKits) {
        _embalagem = Decimal.zero;
        _impressao = Decimal.zero;
      } else if (temProdutoAvulso) {
        _embalagem = _dados.configuracoes?.embalagemPadrao ?? Decimal.zero;
        _impressao = _dados.configuracoes?.impressaoPadrao ?? Decimal.zero;
      }
      _definirMoeda(_embalagemCtrl, _embalagem);
      _definirMoeda(_impressaoCtrl, _impressao);
    }

    if (_autoPreco) {
      final kitsComQtd = <ProdutoVenda, int>{};
      for (final l in _linhas.where((l) => l.ehKit)) {
        final k = _kitPorId(l.refId);
        if (k != null) kitsComQtd[k] = l.quantidade;
      }
      if (kitsComQtd.isNotEmpty) {
        _precoVenda = precoAutomatico(
          kitsComQtd,
          _produtosPorId,
          _plataformaAtual(),
          _faixasDaPlataforma(),
          _dados.faixasAbelinha,
        );
        _itensTaxaFixa = itensTaxaFixaAutomatico(kitsComQtd);
        _definirMoeda(_precoCtrl, _precoVenda);
        _itensTaxaCtrl.text = '$_itensTaxaFixa';
      }
    }
  }

  /// Monta um [Pedido] em memória com os snapshots, para cálculo e para
  /// salvar. Linhas sem snapshot obtível são mantidas pelo original.
  Pedido _montarPedido() {
    final itens = <PedidoItem>[];
    for (final l in _linhas) {
      final snap = _snapshot(l);
      if (snap == null) continue;
      final base = l.original;
      itens.add(
        PedidoItem(
          id: base?.id ?? '',
          empresaId: base?.empresaId ?? widget.inicial?.empresaId ?? '',
          pedidoId: widget.inicial?.id ?? '',
          tipo: l.ehKit
              ? TipoPedidoItem.produtoVenda
              : TipoPedidoItem.produto,
          quantidade: l.quantidade,
          custoUnitario: snap.custo,
          abelinhasUnitarias: snap.abelinhas,
          produtoId: l.ehKit ? null : l.refId,
          produtoVendaId: l.ehKit ? l.refId : null,
        ),
      );
    }

    return Pedido(
      id: widget.inicial?.id ?? '',
      empresaId: widget.inicial?.empresaId ?? '',
      data: _data,
      cliente: _clienteCtrl.text,
      plataformaId: _plataformaId,
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

  Future<void> _salvar() async {
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
      final base = _montarPedido();
      final pedido = base.copyWith(
        empresaId: empresa.id,
        cliente: PadraoEscrita.maius(cliente),
        obs: _obsCtrl.text.isEmpty ? '' : PadraoEscrita.frase(_obsCtrl.text),
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

/// Casca do editor: título + "Fechar", corpo e rodapé Cancelar/Salvar.
class _Casca extends StatelessWidget {
  const _Casca({
    required this.titulo,
    required this.corpo,
    required this.aoFechar,
    this.aoSalvar,
    this.salvando = false,
  });

  final String titulo;
  final Widget corpo;
  final VoidCallback aoFechar;

  /// `null` desabilita o botão (carregando ou salvando).
  final VoidCallback? aoSalvar;
  final bool salvando;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final larguraTela = MediaQuery.sizeOf(context).width;
    final telaCheia = larguraTela < _limiarTelaCheia;

    return Dialog(
      insetPadding: EdgeInsets.zero,
      alignment: telaCheia ? Alignment.center : Alignment.centerRight,
      shape: const RoundedRectangleBorder(),
      backgroundColor: cores.surface,
      child: SizedBox(
        width: telaCheia ? larguraTela : 1080.0.clamp(0, larguraTela),
        height: MediaQuery.sizeOf(context).height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Espacos.g20,
                Espacos.g12,
                Espacos.g12,
                Espacos.g12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: salvando ? null : aoFechar,
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: cores.line),
            Expanded(child: corpo),
            Divider(height: 1, color: cores.line),
            Padding(
              padding: const EdgeInsets.all(Espacos.g16),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: Espacos.g12,
                runSpacing: Espacos.g8,
                children: [
                  OutlinedButton(
                    onPressed: salvando ? null : aoFechar,
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: aoSalvar,
                    child: salvando
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
        ),
      ),
    );
  }
}

/// Mensagem centralizada com ação opcional (erro, vazio).
class _Mensagem extends StatelessWidget {
  const _Mensagem({required this.texto, this.acao, this.aoAcionar});

  final String texto;
  final String? acao;
  final VoidCallback? aoAcionar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Espacos.g20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(texto, textAlign: TextAlign.center),
            if (acao != null) ...[
              const SizedBox(height: Espacos.g12),
              OutlinedButton(onPressed: aoAcionar, child: Text(acao!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Campo do protótipo (`label.f`): rótulo 12,5/500 muted acima do input e
/// dica 12 muted abaixo.
class _Campo extends StatelessWidget {
  const _Campo({required this.rotulo, required this.filho, this.dica});

  final String rotulo;
  final Widget filho;
  final String? dica;

  @override
  Widget build(BuildContext context) {
    final muted = context.cores.muted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rotulo,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: muted,
          ),
        ),
        const SizedBox(height: 6),
        filho,
        if (dica != null) ...[
          const SizedBox(height: 6),
          Text(dica!, style: TextStyle(fontSize: 12, color: muted)),
        ],
      ],
    );
  }
}

/// Grade `auto-fit minmax(180px, 1fr)` do protótipo, com até 4 colunas.
class _Grade extends StatelessWidget {
  const _Grade({required this.filhos});

  final List<Widget> filhos;

  static const double _minimo = 180;
  static const double _gap = 14;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final colunas = ((c.maxWidth + _gap) / (_minimo + _gap))
            .floor()
            .clamp(1, filhos.length);
        final largura = (c.maxWidth - _gap * (colunas - 1)) / colunas;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final f in filhos) SizedBox(width: largura, child: f),
          ],
        );
      },
    );
  }
}
