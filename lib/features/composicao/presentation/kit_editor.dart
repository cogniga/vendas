import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/format/padrao_escrita.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/botao_pequeno.dart';
import 'package:sales/core/widgets/code_chip.dart';
import 'package:sales/core/widgets/ledger.dart';
import 'package:sales/core/widgets/painel_lateral.dart';
import 'package:sales/core/widgets/pill.dart';
import 'package:sales/core/widgets/platform_pill.dart';
import 'package:sales/core/widgets/text_case_field.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/data/repositorios/padrao_nome_provider.dart';
import 'package:sales/domain/calculos/abelinhas.dart';
import 'package:sales/domain/calculos/decimais.dart';
import 'package:sales/domain/calculos/produto_venda.dart';
import 'package:sales/domain/calculos/taxas.dart';
import 'package:sales/domain/entidades/compra_insumo.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/domain/entidades/preco_plataforma.dart';
import 'package:sales/domain/entidades/produto_venda.dart';
import 'package:sales/domain/entidades/produto_venda_item.dart';
import 'package:sales/features/composicao/application/composicao_providers.dart';
import 'package:sales/features/composicao/application/kit_form_controller.dart';

/// Abre o editor de produto de venda (kit) como painel lateral largo.
///
/// Passe [kit] para editar ou `null` para um novo. Retorna `true` quando o
/// kit foi salvo.
Future<bool?> abrirKitEditor(
  BuildContext context, {
  ProdutoVenda? kit,
}) {
  return abrirPainelLateral<bool>(
    context,
    titulo: kit == null ? 'Novo produto de venda' : 'Composição de custo',
    largo: true,
    corpo: (context, fechar) => _KitEditor(kit: kit, fechar: fechar),
  );
}

/// Um item em edição (produto + quantidade) do kit.
class _LinhaItem {
  _LinhaItem({required this.produtoId, required this.quantidade});

  final String produtoId;
  int quantidade;
}

class _KitEditor extends ConsumerStatefulWidget {
  const _KitEditor({required this.kit, required this.fechar});

  final ProdutoVenda? kit;
  final ValueSetter<bool?> fechar;

  @override
  ConsumerState<_KitEditor> createState() => _KitEditorState();
}

class _KitEditorState extends ConsumerState<_KitEditor> {
  final _nomeCtrl = TextEditingController();
  final _buscaCtrl = TextEditingController();
  final _margemCtrl = TextEditingController();
  final _metaLucroCtrl = TextEditingController();
  final _fatiaCtrl = TextEditingController();

  /// Controllers das células de preço/desconto/cupom por plataforma.
  /// Chave: `'<platId>_<campo>'`.
  final Map<String, TextEditingController> _celulas = {};

  final List<_LinhaItem> _itens = [];
  String _busca = '';

  String? _compraInsumoId;
  Decimal _embalagem = Decimal.zero;
  Decimal _impressao = Decimal.zero;
  Decimal _outros = Decimal.zero;

  Decimal _preco = Decimal.zero;
  Decimal _desconto = Decimal.zero;
  Decimal _cupom = Decimal.zero;
  Decimal? _precoConcorrente;

  Decimal _margemAlvo = Decimal.fromInt(30);
  Decimal _metaLucro = Decimal.fromInt(200);
  Decimal _fatiaRoas = Decimal.parse('0.3');

  /// Override por plataforma (preço/desconto/cupom e vendidos iniciais).
  final Map<String, PrecoPlataforma> _precos = {};

  bool _iniciado = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _margemCtrl.text = Formatos.numero(_margemAlvo.toDouble());
    _metaLucroCtrl.text = Formatos.numero(_metaLucro.toDouble());
    _fatiaCtrl.text = Formatos.numero(_fatiaRoas.toDouble());
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _buscaCtrl.dispose();
    _margemCtrl.dispose();
    _metaLucroCtrl.dispose();
    _fatiaCtrl.dispose();
    for (final c in _celulas.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Preenche o estado a partir do [ProdutoVenda] existente, só uma vez.
  void _iniciarComKit(ProdutoVenda kit) {
    _nomeCtrl.text = kit.nome;
    _compraInsumoId = kit.compraInsumoId;
    _embalagem = kit.embalagem;
    _impressao = kit.impressao;
    _outros = kit.outros;
    _preco = kit.preco;
    _desconto = kit.desconto;
    _cupom = kit.cupom;
    _precoConcorrente = kit.precoConcorrente;
    _margemAlvo = kit.margemAlvo;
    _metaLucro = kit.metaLucro;
    _fatiaRoas = kit.fatiaRoas;
    _margemCtrl.text = Formatos.numero(_margemAlvo.toDouble());
    _metaLucroCtrl.text = Formatos.numero(_metaLucro.toDouble());
    _fatiaCtrl.text = Formatos.numero(_fatiaRoas.toDouble());
    for (final i in kit.itens) {
      _itens.add(_LinhaItem(produtoId: i.produtoId, quantidade: i.quantidade));
    }
    _precos.addAll(kit.precosPorPlataforma);
  }

  /// Preenche os padrões de custo de um kit novo a partir das configurações.
  void _iniciarNovo(DadosEdicaoKit dados) {
    _embalagem = dados.configuracoes?.embalagemPadrao ?? Decimal.zero;
    _impressao = dados.configuracoes?.impressaoPadrao ?? Decimal.zero;
  }

  TextEditingController _celula(String platId, String campo) {
    return _celulas.putIfAbsent(
      '${platId}_$campo',
      () {
        final override = _precos[platId];
        final valor = switch (campo) {
          'preco' => override?.preco,
          'desconto' => override?.desconto,
          _ => override?.cupom,
        };
        return TextEditingController(
          text: valor == null ? '' : Formatos.numero(valor.toDouble()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dadosAsync = ref.watch(dadosEdicaoKitProvider);
    final kitAsync = widget.kit == null
        ? const AsyncValue<ProdutoVenda?>.data(null)
        : ref.watch(kitCompletoProvider(widget.kit!.id));

    return dadosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErroCarregar(
        onTentar: () => ref.invalidate(dadosEdicaoKitProvider),
      ),
      data: (dados) => kitAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErroCarregar(
          onTentar: () =>
              ref.invalidate(kitCompletoProvider(widget.kit!.id)),
        ),
        data: (kit) {
          if (!_iniciado) {
            if (kit != null) {
              _iniciarComKit(kit);
            } else {
              _iniciarNovo(dados);
            }
            _iniciado = true;
          }
          return CorpoPainelLateral(
            corpo: _corpo(dados),
            rodape: RodapePainel(
              rotuloPrimario: 'Salvar produto de venda',
              aoConfirmar: () => _salvar(dados),
              aoCancelar: () => widget.fechar(null),
              carregando: _salvando,
            ),
          );
        },
      ),
    );
  }

  Widget _corpo(DadosEdicaoKit dados) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextCaseField(
          caso: CasoTexto.nome,
          padraoNome: ref.watch(padraoNomeProvider),
          controller: _nomeCtrl,
          label: 'Nome do anúncio',
          dica: 'Ex.: Kit 5 sachês máscara facial',
        ),
        const SizedBox(height: Espacos.g16),
        LayoutBuilder(
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
        const SizedBox(height: Espacos.g16),
        _painel(
          'Resultado por plataforma',
          _tabelaPlataformas(dados),
          dica: 'Deixe preço, desconto e cupom em branco para usar o '
              'preço base.',
        ),
      ],
    );
  }

  // ---------------------------------------------------------------- esquerda

  Widget _colunaEsquerda(DadosEdicaoKit dados) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final unidades = _itens.fold<int>(0, (s, i) => s + i.quantidade);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _painel(
          'Itens do produto de venda',
          _listaItens(dados),
          acao: _itens.isEmpty
              ? null
              : Text(
                  '$unidades ${unidades == 1 ? 'unidade' : 'unidades'}',
                  style: textos.bodySmall?.copyWith(color: cores.muted),
                ),
        ),
        const SizedBox(height: Espacos.g16),
        _painel('Adicionar itens', _picker(dados)),
        const SizedBox(height: Espacos.g16),
        _painel('Custos adicionais', _custosAdicionais(dados)),
        const SizedBox(height: Espacos.g16),
        _painel(
          'Preço base e metas',
          _precoEMetas(),
          dica: 'Vale para todas as plataformas, a menos que você mude '
              'abaixo.',
        ),
      ],
    );
  }

  Widget _listaItens(DadosEdicaoKit dados) {
    if (_itens.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Espacos.g12),
        child: Text(
          'Escolha um ou mais produtos abaixo para formar o produto de '
          'venda.',
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _itens.length; i++) _linhaItem(dados, i),
      ],
    );
  }

  Widget _linhaItem(DadosEdicaoKit dados, int i) {
    final textos = Theme.of(context).textTheme;
    final produto = dados.produtosPorId[_itens[i].produtoId];
    final nome = produto?.nome ?? '(produto removido)';
    final custo = produto?.custo ?? Decimal.zero;
    final qtd = _itens[i].quantidade;
    final abUn = produto == null
        ? Decimal.zero
        : abelinhasProduto(produto, dados.faixasAbelinha);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Espacos.g8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CodeChip(produto?.codigo ?? '?'),
                    const SizedBox(width: Espacos.g8),
                    Flexible(
                      child: Text(nome, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                Text(
                  '${Formatos.moedaDecimal(custo)} · '
                  '${Formatos.abelinhas(abUn.toDouble())} cada · '
                  '${Formatos.abelinhas(
                    (abUn * Decimal.fromInt(qtd)).toDouble(),
                  )} no total',
                  style: textos.bodySmall,
                ),
              ],
            ),
          ),
          _controleQtd(i),
          SizedBox(
            width: 84,
            child: Text(
              Formatos.moedaDecimal(custo * Decimal.fromInt(qtd)),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _controleQtd(int i) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(LucideIcons.minus, size: 16),
          tooltip: 'Diminuir',
          onPressed: () => setState(() {
            _itens[i].quantidade--;
            if (_itens[i].quantidade <= 0) _itens.removeAt(i);
          }),
        ),
        Text('${i < _itens.length ? _itens[i].quantidade : ''}'),
        IconButton(
          icon: const Icon(LucideIcons.plus, size: 16),
          tooltip: 'Aumentar',
          onPressed: () => setState(() => _itens[i].quantidade++),
        ),
      ],
    );
  }

  Widget _picker(DadosEdicaoKit dados) {
    final q = _busca.trim().toLowerCase();
    final produtos = dados.produtos
        .where((p) => p.ativo)
        .where(
          (p) =>
              q.isEmpty ||
              p.nome.toLowerCase().contains(q) ||
              p.codigo.toLowerCase().contains(q) ||
              p.marca.toLowerCase().contains(q),
        )
        .take(12)
        .toList();
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _buscaCtrl,
          decoration: const InputDecoration(
            hintText: 'Buscar produto por código ou nome',
            prefixIcon: Icon(LucideIcons.search, size: 18),
            isDense: true,
          ),
          onChanged: (v) => setState(() => _busca = v),
        ),
        const SizedBox(height: Espacos.g12),
        if (produtos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: Espacos.g8),
            child: Text('Nada encontrado.'),
          )
        else
          // Linhas `.pick`: código + nome truncado + custo em negrito +
          // botão `.btn.sm` "Adicionar", separadas por `border-top`.
          for (var i = 0; i < produtos.length; i++)
            DecoratedBox(
              decoration: BoxDecoration(
                border: i == 0
                    ? null
                    : Border(top: BorderSide(color: cores.line)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    CodeChip(produtos[i].codigo),
                    const SizedBox(width: Espacos.g8 + 2),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: produtos[i].nome),
                            TextSpan(
                              text: '  ${produtos[i].marca}',
                              style: TextStyle(color: cores.muted),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: Espacos.g8 + 2),
                    Text(
                      Formatos.moedaDecimal(produtos[i].custo),
                      style: textos.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: Espacos.g8 + 2),
                    BotaoPequeno(
                      rotulo: 'Adicionar',
                      onPressed: () => _adicionar(produtos[i].id),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _custosAdicionais(DadosEdicaoKit dados) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String?>(
          initialValue: _compraInsumoId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Embalagem'),
          items: [
            const DropdownMenuItem<String?>(child: Text('Valor manual')),
            for (final c in dados.compras)
              DropdownMenuItem<String?>(
                value: c.id,
                child: Text(
                  '${c.produto} · ${Formatos.moedaDecimal(_unitario(c))}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (v) => setState(() {
            _compraInsumoId = v;
            if (v != null) {
              final compra =
                  dados.compras.firstWhere((c) => c.id == v);
              _embalagem = _unitario(compra);
            }
          }),
        ),
        const SizedBox(height: Espacos.g12),
        Wrap(
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
                  _compraInsumoId = null;
                }),
                chave: 'embalagem_${_compraInsumoId ?? 'manual'}',
              ),
            ),
            SizedBox(
              width: 180,
              child: _campoMoeda(
                r'Impressão (R$)',
                _impressao,
                (v) => setState(() => _impressao = v ?? Decimal.zero),
              ),
            ),
            SizedBox(
              width: 180,
              child: _campoMoeda(
                r'Outros insumos (R$)',
                _outros,
                (v) => setState(() => _outros = v ?? Decimal.zero),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _precoEMetas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: Espacos.g12,
          runSpacing: Espacos.g12,
          children: [
            SizedBox(
              width: 180,
              child: _campoMoeda(
                r'Preço sem desconto (R$)',
                _preco,
                (v) => setState(() => _preco = v ?? Decimal.zero),
              ),
            ),
            SizedBox(
              width: 180,
              child: _campoMoeda(
                r'Desconto (R$)',
                _desconto,
                (v) => setState(() => _desconto = v ?? Decimal.zero),
              ),
            ),
            SizedBox(
              width: 180,
              child: _campoMoeda(
                r'Cupom (R$)',
                _cupom,
                (v) => setState(() => _cupom = v ?? Decimal.zero),
              ),
            ),
            SizedBox(
              width: 180,
              child: _campoMoeda(
                r'Preço do concorrente (R$)',
                _precoConcorrente ?? Decimal.zero,
                (v) => setState(() => _precoConcorrente = v),
              ),
            ),
            SizedBox(
              width: 180,
              child: TextField(
                controller: _margemCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Margem desejada (%)',
                ),
                onChanged: (v) => setState(
                  () => _margemAlvo =
                      Formatos.parseDecimal(v) ?? Decimal.zero,
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: TextField(
                controller: _metaLucroCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: r'Meta de lucro (R$)',
                ),
                onChanged: (v) => setState(
                  () => _metaLucro =
                      Formatos.parseDecimal(v) ?? Decimal.zero,
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: TextField(
                controller: _fatiaCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Fatia do lucro p/ anúncios',
                  helperText: '0,3 = 30% do lucro',
                ),
                onChanged: (v) => setState(
                  () => _fatiaRoas =
                      Formatos.parseDecimal(v) ?? Decimal.zero,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ resumo

  Widget _resumo(DadosEdicaoKit dados) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final kit = _montarKit();
    final compra = _compra(dados);
    final investimento =
        compra + _embalagem + _impressao + _outros;
    final abelinhas = _abelinhasKit(dados);
    final valor = dados.configuracoes?.valorAbelinha ?? Decimal.zero;

    final resultados = <Plataforma, ResultadoKit>{
      for (final e in dados.plataformas.entries)
        e.key: calcularKit(
          kit,
          dados.produtosPorId,
          e.key,
          e.value,
          dados.faixasAbelinha,
          vendidosIniciais: _precos[e.key.id]?.vendidosIniciais ?? 0,
          pedidos: dados.pedidos,
        ),
    };

    Plataforma? melhor;
    for (final e in resultados.entries) {
      if (melhor == null || e.value.lucro > resultados[melhor]!.lucro) {
        melhor = e.key;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(Espacos.g20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Custo do produto de venda', style: textos.titleMedium),
            const SizedBox(height: Espacos.base),
            Ledger(
              linhas: [
                LinhaLedger(
                  'Compra dos itens',
                  Formatos.moedaDecimal(compra),
                ),
                LinhaLedger('Embalagem', Formatos.moedaDecimal(_embalagem)),
                LinhaLedger('Impressão', Formatos.moedaDecimal(_impressao)),
                LinhaLedger(
                  'Outros insumos',
                  Formatos.moedaDecimal(_outros),
                ),
              ],
              total: LinhaLedger(
                'Investimento por venda',
                Formatos.moedaDecimal(investimento),
              ),
            ),
            const SizedBox(height: Espacos.g8),
            Text(
              'Esse custo é igual em todas as plataformas. O que muda é a '
              'taxa de cada uma.',
              style: textos.bodySmall?.copyWith(color: cores.muted),
            ),
            const SizedBox(height: Espacos.g16),
            Ledger(
              linhas: [
                LinhaLedger(
                  'Abelinhas do kit',
                  Formatos.abelinhas(abelinhas.toDouble()),
                  destaque: true,
                ),
                LinhaLedger(
                  'Valem com 1 🐝 = ${Formatos.moedaDecimal(valor)}',
                  Formatos.moedaDecimal(abelinhas * valor),
                ),
              ],
            ),
            const SizedBox(height: Espacos.g16),
            Text('Lucro por plataforma', style: textos.titleMedium),
            const SizedBox(height: Espacos.base),
            for (final e in resultados.entries) _linhaLucro(e.key, e.value),
            if (melhor != null && investimento > Decimal.zero) ...[
              const SizedBox(height: Espacos.g12),
              Container(
                padding: const EdgeInsets.all(Espacos.g12),
                decoration: BoxDecoration(
                  color: cores.accentSoft,
                  borderRadius: BorderRadius.circular(Raios.controle),
                ),
                child: Text(
                  'Melhor resultado: ${melhor.nome}, com '
                  '${Formatos.moedaDecimal(resultados[melhor]!.lucro)} '
                  'por venda.',
                  style: textos.bodySmall?.copyWith(color: cores.accent),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _linhaLucro(Plataforma p, ResultadoKit r) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final negativo = r.lucro < Decimal.zero;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: PlatformPill(nome: p.nome, cor: p.cor)),
          Text(
            Formatos.moedaDecimal(r.lucro),
            style: textos.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: negativo ? cores.bad : cores.good,
            ),
          ),
          const SizedBox(width: Espacos.g8),
          Text(
            Formatos.percentualFracao(r.margem.toDouble()),
            style: textos.bodySmall,
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------- tabela por plataforma

  Widget _tabelaPlataformas(DadosEdicaoKit dados) {
    return LayoutBuilder(
      builder: (context, c) {
        final largo = c.maxWidth >= 860;
        if (largo) return _tabelaLarga(dados);
        return _blocosPlataforma(dados);
      },
    );
  }

  Widget _tabelaLarga(DadosEdicaoKit dados) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final kit = _montarKit();

    // Cabeçalho `th`: 12px muted w500, fundo surface-2, padding 10x14.
    final estiloCab = textos.bodySmall?.copyWith(
      color: cores.muted,
      fontWeight: FontWeight.w500,
    );

    Widget cab(String t) => Expanded(
          child: Text(t, style: estiloCab, textAlign: TextAlign.right),
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(Raios.controle),
      child: Column(
        children: [
          Container(
            color: cores.surface2,
            padding: const EdgeInsets.symmetric(
              horizontal: Espacos.g12 + 2,
              vertical: 10,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('Plataforma', style: estiloCab),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Preço anúncio', style: estiloCab),
                ),
                cab('Cliente paga'),
                cab('Taxa'),
                cab('Líquido'),
                cab('Lucro'),
                cab('Margem'),
                cab('ROI'),
                cab('Preço mínimo'),
                cab('Sugerido'),
                cab('Meta'),
                cab('ROAS alvo'),
              ],
            ),
          ),
          for (final e in dados.plataformas.entries) ...[
            Divider(height: 1, color: cores.line),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Espacos.g12 + 2,
                vertical: 11,
              ),
              child: _linhaTabela(dados, kit, e.key, e.value),
            ),
          ],
        ],
      ),
    );
  }

  Widget _linhaTabela(
    DadosEdicaoKit dados,
    ProdutoVenda kit,
    Plataforma p,
    List<FaixaTaxa> faixas,
  ) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final r = _resultado(dados, kit, p, faixas);
    final investimento = r.investimento;
    final minimo = precoMinimo(faixas, investimento);
    final sugerido = _sugerido(p.id, faixas, investimento);
    final negativo = r.lucro < Decimal.zero;

    Widget val(String t, {Color? cor, bool forte = false}) => Expanded(
          child: Text(
            t,
            textAlign: TextAlign.right,
            style: textos.bodySmall?.copyWith(
              color: cor,
              fontWeight: forte ? FontWeight.w600 : null,
            ),
          ),
        );

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerLeft,
            child: PlatformPill(nome: p.nome, cor: p.cor),
          ),
        ),
        Expanded(flex: 2, child: _camposPreco(p.id)),
        val(Formatos.moedaDecimal(r.clientePaga)),
        val(Formatos.moedaDecimal(r.taxa)),
        val(Formatos.moedaDecimal(r.liquido)),
        val(
          Formatos.moedaDecimal(r.lucro),
          cor: negativo ? cores.bad : cores.good,
          forte: true,
        ),
        val(Formatos.percentualFracao(r.margem.toDouble())),
        val(Formatos.percentualFracao(r.roi.toDouble())),
        val(Formatos.moedaDecimal(minimo)),
        Expanded(child: _botaoSugerido(p.id, sugerido)),
        Expanded(child: _pillMeta(r)),
        val(
          r.roasAlvo == null
              ? '—'
              : Formatos.numero(r.roasAlvo!.toDouble()),
        ),
      ],
    );
  }

  Widget _blocosPlataforma(DadosEdicaoKit dados) {
    final kit = _montarKit();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final e in dados.plataformas.entries) ...[
          _blocoPlataforma(dados, kit, e.key, e.value),
          const SizedBox(height: Espacos.g12),
        ],
      ],
    );
  }

  Widget _blocoPlataforma(
    DadosEdicaoKit dados,
    ProdutoVenda kit,
    Plataforma p,
    List<FaixaTaxa> faixas,
  ) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final r = _resultado(dados, kit, p, faixas);
    final minimo = precoMinimo(faixas, r.investimento);
    final sugerido = _sugerido(p.id, faixas, r.investimento);
    final negativo = r.lucro < Decimal.zero;

    Widget par(String rotulo, Widget valor) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(rotulo, style: textos.bodySmall),
            valor,
          ],
        );

    return Container(
      padding: const EdgeInsets.all(Espacos.g12),
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlatformPill(nome: p.nome, cor: p.cor),
          const SizedBox(height: Espacos.g8),
          _camposPreco(p.id),
          const SizedBox(height: Espacos.g8),
          par('Cliente paga', Text(Formatos.moedaDecimal(r.clientePaga))),
          par('Taxa', Text(Formatos.moedaDecimal(r.taxa))),
          par('Líquido', Text(Formatos.moedaDecimal(r.liquido))),
          par(
            'Lucro',
            Text(
              Formatos.moedaDecimal(r.lucro),
              style: textos.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: negativo ? cores.bad : cores.good,
              ),
            ),
          ),
          par('Margem', Text(Formatos.percentualFracao(r.margem.toDouble()))),
          par('ROI', Text(Formatos.percentualFracao(r.roi.toDouble()))),
          par('Preço mínimo', Text(Formatos.moedaDecimal(minimo))),
          par('Sugerido', _botaoSugerido(p.id, sugerido)),
          par('Meta', _pillMeta(r)),
          par(
            'ROAS alvo',
            Text(
              r.roasAlvo == null
                  ? '—'
                  : Formatos.numero(r.roasAlvo!.toDouble()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _camposPreco(String platId) {
    Widget campo(String campo, String label) {
      return SizedBox(
        width: 84,
        child: TextField(
          controller: _celula(platId, campo),
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            isDense: true,
            labelText: label,
            hintText: Formatos.numero(_baseDe(campo).toDouble()),
          ),
          onChanged: (v) => _onPrecoCelula(platId, campo, v),
        ),
      );
    }

    return Wrap(
      spacing: Espacos.g8,
      runSpacing: Espacos.g8,
      children: [
        campo('preco', 'Preço'),
        campo('desconto', 'Desc.'),
        campo('cupom', 'Cupom'),
      ],
    );
  }

  Widget _botaoSugerido(String platId, Decimal? sugerido) {
    if (sugerido == null) {
      return const Align(
        alignment: Alignment.centerRight,
        child: Text('—'),
      );
    }
    return Align(
      alignment: Alignment.centerRight,
      child: BotaoPequeno(
        rotulo: Formatos.moedaDecimal(sugerido),
        tooltip: 'Preço para '
            '${Formatos.numero(_margemAlvo.toDouble())}% de margem',
        onPressed: () => _usarSugerido(platId, sugerido),
      ),
    );
  }

  Widget _pillMeta(ResultadoKit r) {
    if (r.metaQtd == null) {
      return const Align(
        alignment: Alignment.centerRight,
        child: Text('—'),
      );
    }
    return Align(
      alignment: Alignment.centerRight,
      child: Pill(
        '${r.vendidos}/${r.metaQtd}',
        tom: r.atingido >= Decimal.one ? TomPill.bom : TomPill.neutro,
      ),
    );
  }

  // ------------------------------------------------------------------ helpers

  /// Painel do protótipo `.panel`: cabeçalho (`16x20`, título 15/600 +
  /// `.hint` opcional à direita) separado por `border-bottom` do corpo
  /// (`padding 20`). Sem card dentro de card.
  Widget _painel(String titulo, Widget corpo, {String? dica, Widget? acao}) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Espacos.g20,
              vertical: Espacos.g16,
            ),
            child: Row(
              children: [
                Expanded(child: Text(titulo, style: textos.titleMedium)),
                if (acao != null) acao,
                if (dica != null)
                  Flexible(
                    child: Text(
                      dica,
                      textAlign: TextAlign.right,
                      style: textos.bodySmall?.copyWith(color: cores.muted),
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: cores.line),
          Padding(
            padding: const EdgeInsets.all(Espacos.g20),
            child: corpo,
          ),
        ],
      ),
    );
  }

  Widget _campoMoeda(
    String label,
    Decimal valor,
    ValueChanged<Decimal?> onChanged, {
    String? chave,
  }) {
    return TextFormField(
      key: chave == null ? null : ValueKey(chave),
      initialValue:
          valor == Decimal.zero ? '' : Formatos.numero(valor.toDouble()),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      onChanged: (v) => onChanged(Formatos.parseDecimal(v)),
    );
  }

  Decimal _baseDe(String campo) => switch (campo) {
        'preco' => _preco,
        'desconto' => _desconto,
        _ => _cupom,
      };

  Decimal _unitario(CompraInsumo c) => c.itens <= 0
      ? c.valorTotal
      : c.valorTotal.dividir(Decimal.fromInt(c.itens));

  void _adicionar(String produtoId) {
    setState(() {
      final existente = _itens.where((l) => l.produtoId == produtoId);
      if (existente.isEmpty) {
        _itens.add(_LinhaItem(produtoId: produtoId, quantidade: 1));
      } else {
        existente.first.quantidade++;
      }
    });
  }

  void _onPrecoCelula(String platId, String campo, String texto) {
    setState(() {
      final atual = _precos[platId] ??
          PrecoPlataforma(
            empresaId: '',
            produtoVendaId: '',
            plataformaId: platId,
          );
      final valor =
          texto.trim().isEmpty ? null : Formatos.parseDecimal(texto);
      final novo = switch (campo) {
        'preco' => atual.copyWith(preco: valor),
        'desconto' => atual.copyWith(desconto: valor),
        _ => atual.copyWith(cupom: valor),
      };
      _precos[platId] = novo;
    });
  }

  void _usarSugerido(String platId, Decimal valor) {
    final texto = Formatos.numero(valor.toDouble());
    _celula(platId, 'preco').text = texto;
    _onPrecoCelula(platId, 'preco', texto);
  }

  Decimal? _sugerido(
    String platId,
    List<FaixaTaxa> faixas,
    Decimal investimento,
  ) {
    if (_margemAlvo >= Decimal.fromInt(100)) return null;
    final base = precoParaMargem(faixas, investimento, _margemAlvo);
    // Usa o desconto/cupom efetivo (override da plataforma, senão base),
    // como o protótipo (kitCalc) e design §6.3.
    final desconto = _precos[platId]?.desconto ?? _desconto;
    final cupom = _precos[platId]?.cupom ?? _cupom;
    return base + desconto + cupom;
  }

  Decimal _compra(DadosEdicaoKit dados) {
    var compra = Decimal.zero;
    for (final l in _itens) {
      final p = dados.produtosPorId[l.produtoId];
      if (p == null) continue;
      compra += p.custo * Decimal.fromInt(l.quantidade);
    }
    return compra;
  }

  Decimal _abelinhasKit(DadosEdicaoKit dados) {
    var total = Decimal.zero;
    for (final l in _itens) {
      final p = dados.produtosPorId[l.produtoId];
      if (p == null) continue;
      total += abelinhasProduto(p, dados.faixasAbelinha) *
          Decimal.fromInt(l.quantidade);
    }
    return total;
  }

  ResultadoKit _resultado(
    DadosEdicaoKit dados,
    ProdutoVenda kit,
    Plataforma p,
    List<FaixaTaxa> faixas,
  ) {
    return calcularKit(
      kit,
      dados.produtosPorId,
      p,
      faixas,
      dados.faixasAbelinha,
      vendidosIniciais: _precos[p.id]?.vendidosIniciais ?? 0,
      pedidos: dados.pedidos,
    );
  }

  /// Monta um [ProdutoVenda] em memória com o estado atual (sem empresa).
  ProdutoVenda _montarKit({String empresaId = ''}) {
    return ProdutoVenda(
      id: widget.kit?.id ?? '',
      empresaId: empresaId,
      nome: _nomeCtrl.text,
      embalagem: _embalagem,
      impressao: _impressao,
      outros: _outros,
      preco: _preco,
      desconto: _desconto,
      cupom: _cupom,
      metaLucro: _metaLucro,
      fatiaRoas: _fatiaRoas,
      margemAlvo: _margemAlvo,
      compraInsumoId: _compraInsumoId,
      precoConcorrente: _precoConcorrente,
      itens: [
        for (final l in _itens)
          ProdutoVendaItem(
            id: '',
            empresaId: empresaId,
            produtoVendaId: widget.kit?.id ?? '',
            produtoId: l.produtoId,
            quantidade: l.quantidade,
          ),
      ],
      precosPorPlataforma: _precosLimpos(empresaId),
    );
  }

  /// Remove overrides vazios e normaliza empresa/produtoVenda id.
  Map<String, PrecoPlataforma> _precosLimpos(String empresaId) {
    final resultado = <String, PrecoPlataforma>{};
    for (final e in _precos.entries) {
      final p = e.value;
      final temValor =
          p.preco != null || p.desconto != null || p.cupom != null;
      if (!temValor && p.vendidosIniciais == 0) continue;
      resultado[e.key] = p.copyWith(
        empresaId: empresaId,
        produtoVendaId: widget.kit?.id ?? '',
        plataformaId: e.key,
      );
    }
    return resultado;
  }

  Future<void> _salvar(DadosEdicaoKit dados) async {
    final nome = _nomeCtrl.text.trim();
    if (nome.isEmpty) {
      _toast('Dê um nome ao produto de venda');
      return;
    }
    if (_itens.isEmpty) {
      _toast('Adicione pelo menos um item');
      return;
    }
    final empresa = await ref.read(empresaAtualProvider.future);
    if (empresa == null) {
      _toast('Nenhuma empresa ativa.');
      return;
    }

    setState(() => _salvando = true);
    final kit = _montarKit(empresaId: empresa.id).copyWith(
      nome: PadraoEscrita.nome(nome, ref.read(padraoNomeProvider)),
    );
    final ok =
        await ref.read(kitFormControllerProvider.notifier).salvar(kit);
    if (!mounted) return;
    if (ok) {
      widget.fechar(true);
    } else {
      setState(() => _salvando = false);
      _toast(
        ref.read(kitFormControllerProvider).error?.toString() ??
            'Não foi possível salvar. Tente de novo.',
      );
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
          const Text('Não foi possível carregar os dados do produto.'),
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
