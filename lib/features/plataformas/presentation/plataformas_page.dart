import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/confirm_delete_button.dart';
import 'package:sales/core/widgets/page_header.dart';
import 'package:sales/domain/calculos/taxas.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/features/plataformas/application/plataformas_controller.dart';
import 'package:sales/features/plataformas/application/plataformas_providers.dart';

/// Preços usados na simulação de taxa/líquido de cada plataforma (protótipo).
const List<String> _precosSimulacao = [
  '19.99',
  '59.90',
  '89.90',
  '149.90',
  '249.90',
];

/// Paleta fixa de cores (igual ao protótipo), usada no seletor sem depender
/// de um pacote de color picker.
const List<String> _paleta = [
  '#f0846a',
  '#5bb8c2',
  '#e5bf55',
  '#9a8fd4',
  '#6fb59a',
  '#6a9fd8',
  '#b54a40',
  '#2b7a70',
];

/// Tela de Plataformas e taxas (R6): grade de cartões editáveis, cada um com
/// nome, cor, faixas (fixo + percentual por faixa de preço) e a simulação de
/// taxa/líquido. Autosave com debounce (sem botão "Salvar"), como no protótipo.
class PlataformasPage extends ConsumerWidget {
  const PlataformasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(plataformasProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        async.when(
          loading: () => const _Cabecalho(aoCriar: null),
          error: (_, __) => const _Cabecalho(aoCriar: null),
          data: (plataformas) => _Cabecalho(
            aoCriar: () => ref
                .read(plataformasControllerProvider(plataformas).notifier)
                .criarPlataforma(),
          ),
        ),
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(Espacos.g20),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => _Erro(
            mensagem: _texto(e),
            aoTentarDeNovo: () => ref.invalidate(plataformasProvider),
          ),
          data: (plataformas) => _Conteudo(iniciais: plataformas),
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

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.aoCriar});

  final VoidCallback? aoCriar;

  @override
  Widget build(BuildContext context) {
    return PageHeader(
      title: 'Plataformas e taxas',
      subtitle:
          'Cada plataforma cobra uma combinação de valor fixo e percentual, '
          'que pode mudar por faixa de preço. Essas regras alimentam a '
          'composição de custo e a estimativa de líquido dos pedidos.',
      actions: [
        FilledButton.icon(
          onPressed: aoCriar,
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text('Nova plataforma'),
        ),
      ],
    );
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
  const _Conteudo({required this.iniciais});

  final Map<Plataforma, List<FaixaTaxa>> iniciais;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlador = plataformasControllerProvider(iniciais);
    final estado = ref.watch(controlador);
    final notifier = ref.read(controlador.notifier);

    if (estado.plataformas.isEmpty) {
      return _Vazio(erro: estado.erro);
    }

    final entradas = estado.plataformas.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (estado.erro != null) ...[
          _AvisoErro(mensagem: estado.erro!),
          const SizedBox(height: Espacos.g16),
        ],
        LayoutBuilder(
          builder: (context, restricoes) {
            final duasColunas = restricoes.maxWidth >= 900;
            final largura = duasColunas
                ? (restricoes.maxWidth - Espacos.g16) / 2
                : restricoes.maxWidth;
            return Wrap(
              spacing: Espacos.g16,
              runSpacing: Espacos.g16,
              children: [
                for (final entrada in entradas)
                  SizedBox(
                    width: largura,
                    child: _CartaoPlataforma(
                      key: ValueKey(entrada.key.id),
                      plataforma: entrada.key,
                      faixas: entrada.value,
                      notifier: notifier,
                      podeExcluir: entradas.length > 1,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio({this.erro});

  final String? erro;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Espacos.g20),
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      child: Column(
        children: [
          Text(
            'Nenhuma plataforma ainda.',
            style: textos.titleMedium,
          ),
          const SizedBox(height: Espacos.g8),
          Text(
            'Use "Nova plataforma" para cadastrar o primeiro canal de venda.',
            textAlign: TextAlign.center,
            style: textos.bodyMedium?.copyWith(color: cores.muted),
          ),
          if (erro != null) ...[
            const SizedBox(height: Espacos.g12),
            Text(
              erro!,
              textAlign: TextAlign.center,
              style: textos.bodySmall?.copyWith(color: cores.bad),
            ),
          ],
        ],
      ),
    );
  }
}

class _AvisoErro extends StatelessWidget {
  const _AvisoErro({required this.mensagem});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return Container(
      padding: const EdgeInsets.all(Espacos.g12),
      decoration: BoxDecoration(
        color: cores.badSoft,
        borderRadius: BorderRadius.circular(Raios.controle),
      ),
      child: Text(
        mensagem,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: cores.bad),
      ),
    );
  }
}

/// Cartão de uma plataforma: cabeçalho (cor + nome + excluir), seletor de cor,
/// faixas editáveis, observação e o Ledger de simulação (recalcula ao vivo a
/// partir das faixas em edição).
class _CartaoPlataforma extends StatelessWidget {
  const _CartaoPlataforma({
    required this.plataforma,
    required this.faixas,
    required this.notifier,
    required this.podeExcluir,
    super.key,
  });

  final Plataforma plataforma;
  final List<FaixaEdicao> faixas;
  final PlataformasController notifier;
  final bool podeExcluir;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final id = plataforma.id;

    return Container(
      padding: const EdgeInsets.all(Espacos.g16),
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _corDe(plataforma.cor, cores.accent),
                  borderRadius: BorderRadius.circular(Raios.pill),
                ),
              ),
              const SizedBox(width: Espacos.g8),
              Expanded(
                child: Text(
                  plataforma.nome,
                  style: textos.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (podeExcluir)
                ConfirmDeleteButton(
                  tooltip: 'Excluir plataforma',
                  onConfirm: () => notifier.excluir(id),
                ),
            ],
          ),
          const SizedBox(height: Espacos.g12),
          _CampoTexto(
            key: ValueKey('nome-$id'),
            label: 'Nome',
            valor: plataforma.nome,
            aoMudar: (texto) => notifier.renomear(id, texto),
          ),
          const SizedBox(height: Espacos.g12),
          _SeletorCor(
            selecionada: plataforma.cor,
            aoSelecionar: (cor) =>
                notifier.mudarAparencia(id, cor, plataforma.obs),
          ),
          const SizedBox(height: Espacos.g16),
          _Faixas(
            plataformaId: id,
            faixas: faixas,
            notifier: notifier,
          ),
          const SizedBox(height: Espacos.g12),
          _CampoTexto(
            key: ValueKey('obs-$id'),
            label: 'Observação',
            valor: plataforma.obs,
            aoMudar: (texto) =>
                notifier.mudarAparencia(id, plataforma.cor, texto),
          ),
          const SizedBox(height: Espacos.g16),
          _LedgerSimulacao(faixas: faixas),
        ],
      ),
    );
  }
}

/// Lista de faixas editáveis (preço até / fixo / percentual) + adicionar.
class _Faixas extends StatelessWidget {
  const _Faixas({
    required this.plataformaId,
    required this.faixas,
    required this.notifier,
  });

  final String plataformaId;
  final List<FaixaEdicao> faixas;
  final PlataformasController notifier;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final podeRemover = faixas.length > 1;
    final inicios = iniciosDasFaixas([for (final f in faixas) f.precoAte]);
    final abertas = faixas.where((f) => f.precoAte == null).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                r'De (R$)',
                style: textos.bodySmall?.copyWith(color: cores.muted),
              ),
            ),
            const SizedBox(width: Espacos.g8),
            Expanded(
              child: Text(
                r'Até (R$)',
                style: textos.bodySmall?.copyWith(color: cores.muted),
              ),
            ),
            const SizedBox(width: Espacos.g8),
            Expanded(
              child: Text(
                r'Fixo (R$)',
                style: textos.bodySmall?.copyWith(color: cores.muted),
              ),
            ),
            const SizedBox(width: Espacos.g8),
            Expanded(
              child: Text(
                'Percentual',
                style: textos.bodySmall?.copyWith(color: cores.muted),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
        const SizedBox(height: Espacos.g8),
        for (var i = 0; i < faixas.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: Espacos.g8),
            child: Row(
              children: [
                Expanded(
                  child: _InicioFaixa(
                    key: ValueKey('de-$plataformaId-$i'),
                    valor: inicios[i],
                  ),
                ),
                const SizedBox(width: Espacos.g8),
                Expanded(
                  child: _CampoDecimal(
                    key: ValueKey('ate-$plataformaId-$i'),
                    valor: faixas[i].precoAte,
                    aceitaVazio: true,
                    dica: 'e acima',
                    aoMudar: (v) => notifier.alterarFaixa(
                      plataformaId,
                      i,
                      faixas[i].copyWith(precoAte: v),
                    ),
                  ),
                ),
                const SizedBox(width: Espacos.g8),
                Expanded(
                  child: _CampoDecimal(
                    key: ValueKey('fixo-$plataformaId-$i'),
                    valor: faixas[i].taxaFixa,
                    aoMudar: (v) => notifier.alterarFaixa(
                      plataformaId,
                      i,
                      faixas[i].copyWith(taxaFixa: v ?? Decimal.zero),
                    ),
                  ),
                ),
                const SizedBox(width: Espacos.g8),
                Expanded(
                  child: _CampoDecimal(
                    key: ValueKey('pct-$plataformaId-$i'),
                    valor: faixas[i].taxaPercentual,
                    aoMudar: (v) => notifier.alterarFaixa(
                      plataformaId,
                      i,
                      faixas[i].copyWith(taxaPercentual: v ?? Decimal.zero),
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: podeRemover
                      ? ConfirmDeleteButton(
                          tooltip: 'Remover faixa',
                          onConfirm: () =>
                              notifier.removerFaixa(plataformaId, i),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: Espacos.g8),
          child: Text(
            abertas > 1
                ? 'Só uma faixa pode ficar com "Até" vazio (e acima). '
                    'Preencha o teto das outras.'
                : 'Deixe "Até" vazio na última faixa para valer de '
                    'aquele valor em diante.',
            style: textos.bodySmall?.copyWith(
              color: abertas > 1 ? cores.bad : cores.muted,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => notifier.adicionarFaixa(plataformaId),
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('Adicionar faixa'),
          ),
        ),
      ],
    );
  }
}

/// Simulação de taxa e líquido para os preços de referência, recalculada a
/// partir das faixas em edição.
///
/// Segue o formato do Ledger (linhas rótulo/valor), mas com o valor em um
/// [Flexible] que quebra a linha quando o cartão fica estreito, para respeitar
/// a invariante de layout (sem overflow / sem rolagem horizontal).
class _LedgerSimulacao extends StatelessWidget {
  const _LedgerSimulacao({required this.faixas});

  final List<FaixaEdicao> faixas;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final entidades = [
      for (final f in faixas) f.paraEntidade('', ''),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final texto in _precosSimulacao)
          _buildLinha(context, Decimal.parse(texto), entidades, cores, textos),
      ],
    );
  }

  Widget _buildLinha(
    BuildContext context,
    Decimal preco,
    List<FaixaTaxa> entidades,
    CoresApp cores,
    TextTheme textos,
  ) {
    final t = taxa(entidades, preco);
    final liquido = preco - t;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Espacos.base),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Formatos.moedaDecimal(preco),
            style: textos.bodyMedium?.copyWith(color: cores.muted),
          ),
          const SizedBox(width: Espacos.g12),
          Expanded(
            child: Text(
              'taxa ${Formatos.moedaDecimal(t)} · '
              'líq. ${Formatos.moedaDecimal(liquido)}',
              textAlign: TextAlign.right,
              style: textos.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

/// Seletor de cor por chips de paleta fixa (acessível com Tooltip/Semantics).
class _SeletorCor extends StatelessWidget {
  const _SeletorCor({required this.selecionada, required this.aoSelecionar});

  final String selecionada;
  final ValueChanged<String> aoSelecionar;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final paleta = {..._paleta, selecionada}.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Cor',
          style: textos.bodySmall?.copyWith(color: cores.muted),
        ),
        const SizedBox(height: Espacos.g8),
        Wrap(
          spacing: Espacos.g8,
          runSpacing: Espacos.g8,
          children: [
            for (final hex in paleta)
              _ChipCor(
                hex: hex,
                selecionada: hex.toLowerCase() == selecionada.toLowerCase(),
                aoTocar: () => aoSelecionar(hex),
              ),
          ],
        ),
      ],
    );
  }
}

class _ChipCor extends StatelessWidget {
  const _ChipCor({
    required this.hex,
    required this.selecionada,
    required this.aoTocar,
  });

  final String hex;
  final bool selecionada;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final cor = _corDe(hex, cores.accent);
    final rotulo = 'Cor $hex';
    return Semantics(
      label: rotulo,
      button: true,
      selected: selecionada,
      child: Tooltip(
        message: rotulo,
        child: InkWell(
          onTap: aoTocar,
          borderRadius: BorderRadius.circular(Raios.controle),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(Raios.controle),
              border: Border.all(
                color: selecionada ? cores.ink : cores.line,
                width: selecionada ? 2.5 : 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Campo de texto simples com sincronização sem roubar foco (nome/obs).
class _CampoTexto extends StatefulWidget {
  const _CampoTexto({
    required this.label,
    required this.valor,
    required this.aoMudar,
    super.key,
  });

  final String label;
  final String valor;
  final ValueChanged<String> aoMudar;

  @override
  State<_CampoTexto> createState() => _CampoTextoState();
}

class _CampoTextoState extends State<_CampoTexto> {
  late final TextEditingController _controller;
  final FocusNode _foco = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.valor);
  }

  @override
  void didUpdateWidget(_CampoTexto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.valor && !_foco.hasFocus) {
      _controller.text = widget.valor;
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
    return TextField(
      controller: _controller,
      focusNode: _foco,
      decoration: InputDecoration(
        labelText: widget.label,
        isDense: true,
      ),
      onChanged: widget.aoMudar,
    );
  }
}

/// Início da faixa ("De"), calculado a partir do teto da faixa anterior.
/// Somente leitura, com o mesmo formato visual de um campo desabilitado.
class _InicioFaixa extends StatelessWidget {
  const _InicioFaixa({required this.valor, super.key});

  final Decimal valor;

  @override
  Widget build(BuildContext context) {
    final texto = Formatos.numero(valor.toDouble());
    return Semantics(
      label: 'Início da faixa: ${Formatos.moedaDecimal(valor)}',
      child: Tooltip(
        message: r'Calculado: teto da faixa anterior + R$ 0,01',
        child: InputDecorator(
          decoration: const InputDecoration(isDense: true, enabled: false),
          child: Text(texto),
        ),
      ),
    );
  }
}

/// Campo numérico decimal com sincronização sem roubar foco. Quando
/// [aceitaVazio] é `true`, texto vazio chama [aoMudar] com `null` (sem limite).
class _CampoDecimal extends StatefulWidget {
  const _CampoDecimal({
    required this.valor,
    required this.aoMudar,
    this.aceitaVazio = false,
    this.dica,
    super.key,
  });

  final Decimal? valor;
  final ValueChanged<Decimal?> aoMudar;
  final bool aceitaVazio;
  final String? dica;

  @override
  State<_CampoDecimal> createState() => _CampoDecimalState();
}

class _CampoDecimalState extends State<_CampoDecimal> {
  late final TextEditingController _controller;
  final FocusNode _foco = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatar(widget.valor));
  }

  @override
  void didUpdateWidget(_CampoDecimal oldWidget) {
    super.didUpdateWidget(oldWidget);
    final atual = Formatos.parseDecimal(_controller.text);
    if (atual != widget.valor && !_foco.hasFocus) {
      _controller.text = _formatar(widget.valor);
    }
  }

  String _formatar(Decimal? valor) =>
      valor == null ? '' : Formatos.numero(valor.toDouble());

  @override
  void dispose() {
    _controller.dispose();
    _foco.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _foco,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        isDense: true,
        hintText: widget.dica,
      ),
      onChanged: (texto) {
        final limpo = texto.trim();
        if (limpo.isEmpty) {
          if (widget.aceitaVazio) widget.aoMudar(null);
          return;
        }
        final v = Formatos.parseDecimal(limpo);
        if (v != null) widget.aoMudar(v);
      },
    );
  }
}

/// Converte um hex (`#RRGGBB`) em [Color]; usa [fallback] se inválido.
Color _corDe(String hex, Color fallback) {
  var limpo = hex.trim().replaceAll('#', '');
  if (limpo.length == 6) limpo = 'FF$limpo';
  final valor = int.tryParse(limpo, radix: 16);
  return valor == null ? fallback : Color(valor);
}
