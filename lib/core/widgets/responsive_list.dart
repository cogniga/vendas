import 'package:flutter/material.dart';
import 'package:sales/core/theme/tokens.dart';

/// Definição de uma coluna de [ResponsiveList].
class ColunaLista<T> {
  const ColunaLista({
    required this.label,
    required this.builder,
    this.alinhamento,
    this.principal = false,
    this.cabecalho,
  });

  /// Rótulo do cabeçalho (tabela) e rótulo do par rótulo/valor (cartão).
  final String label;

  /// Constrói a célula para o item.
  final Widget Function(T item) builder;

  /// Alinhamento da célula; por padrão à esquerda (`centerLeft`).
  final Alignment? alinhamento;

  /// Coluna principal: vira o título do cartão em modo estreito.
  final bool principal;

  /// Cabeçalho customizado (ex.: bolinha de cor + nome da plataforma). Quando
  /// nulo, usa [label] como texto. Em modo cartão, o rótulo continua [label].
  final Widget? cabecalho;
}

/// Lista responsiva que decide pela **largura disponível do próprio widget**
/// (via [LayoutBuilder]): acima de [limiarCartao] mostra uma tabela; abaixo,
/// cartões. Nunca usa rolagem horizontal.
class ResponsiveList<T> extends StatelessWidget {
  const ResponsiveList({
    required this.itens,
    required this.colunas,
    this.acoes,
    this.limiarCartao = 780,
    this.semMoldura = false,
    super.key,
  });

  final List<T> itens;
  final List<ColunaLista<T>> colunas;

  /// Ações por item (ex.: editar/excluir), à direita.
  final Widget Function(T item)? acoes;

  /// Largura mínima (do widget) para usar o modo tabela.
  final double limiarCartao;

  /// Quando `true`, a tabela não desenha o próprio cartão (borda, fundo,
  /// radius): é usada dentro de um painel externo, encostada à toolbar, sem
  /// borda dupla. O protótipo (`.panel > .toolbar + table.ptable`) usa esse
  /// layout em Pedidos. As demais telas mantêm o padrão (`false`).
  final bool semMoldura;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tabela = constraints.maxWidth >= limiarCartao;
        return tabela ? _Tabela<T>(this) : _Cartoes<T>(this, constraints);
      },
    );
  }
}

class _Tabela<T> extends StatelessWidget {
  const _Tabela(this.lista);

  final ResponsiveList<T> lista;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final semMoldura = lista.semMoldura;

    // Padding das células: protótipo `th 10x14` / `td 11x14`.
    // No modo com moldura mantém o espaçamento mais folgado já em uso nas
    // demais telas (16/12) para não alterar seu layout.
    final padH = semMoldura ? Espacos.g12 + 2 : Espacos.g16; // 14 : 16
    final padVCabecalho = semMoldura ? 10.0 : Espacos.g12;
    final padVCelula = semMoldura ? 11.0 : Espacos.g12;

    Widget celula(ColunaLista<T> c, Widget filho) {
      return Expanded(
        child: Padding(
          // Respiro entre colunas vizinhas, para valores à direita não
          // encostarem no texto da coluna seguinte à esquerda.
          padding: const EdgeInsets.only(right: Espacos.g12),
          child: Align(
            alignment: c.alinhamento ?? Alignment.centerLeft,
            child: filho,
          ),
        ),
      );
    }

    final conteudo = Column(
      children: [
        Container(
          color: cores.surface2,
          padding: EdgeInsets.symmetric(
            horizontal: padH,
            vertical: padVCabecalho,
          ),
          child: Row(
            children: [
              for (final c in lista.colunas)
                celula(
                  c,
                  c.cabecalho ?? Text(c.label, style: textos.labelLarge),
                ),
              if (lista.acoes != null)
                const SizedBox(width: 120, child: SizedBox.shrink()),
            ],
          ),
        ),
        for (var i = 0; i < lista.itens.length; i++) ...[
          if (i > 0) Divider(height: 1, color: cores.line),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: padH,
              vertical: padVCelula,
            ),
            child: Row(
              children: [
                for (final c in lista.colunas)
                  celula(c, c.builder(lista.itens[i])),
                if (lista.acoes != null)
                  SizedBox(
                    width: 120,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: lista.acoes!(lista.itens[i]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );

    if (semMoldura) return conteudo;

    return Container(
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: conteudo,
    );
  }
}

class _Cartoes<T> extends StatelessWidget {
  const _Cartoes(this.lista, this.constraints);

  final ResponsiveList<T> lista;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    // 4 colunas em telas médias, 2 em estreitas (< 600).
    final colunasGrade = constraints.maxWidth < 600 ? 2 : 4;

    final principais =
        lista.colunas.where((c) => c.principal).toList(growable: false);
    final secundarias =
        lista.colunas.where((c) => !c.principal).toList(growable: false);

    return Column(
      children: [
        for (var i = 0; i < lista.itens.length; i++) ...[
          if (i > 0) const SizedBox(height: Espacos.g12),
          Container(
            padding: const EdgeInsets.all(Espacos.g16),
            decoration: BoxDecoration(
              color: cores.surface,
              borderRadius: BorderRadius.circular(Raios.cartao),
              border: Border.all(color: cores.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DefaultTextStyle.merge(
                        style: textos.titleMedium,
                        child: principais.isEmpty
                            ? const SizedBox.shrink()
                            : principais.first.builder(lista.itens[i]),
                      ),
                    ),
                    if (lista.acoes != null) lista.acoes!(lista.itens[i]),
                  ],
                ),
                if (secundarias.isNotEmpty) ...[
                  const SizedBox(height: Espacos.g12),
                  _Grade(
                    colunas: colunasGrade,
                    filhos: [
                      for (final c in secundarias)
                        _ParRotulo(
                          label: c.label,
                          valor: c.builder(lista.itens[i]),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Par rótulo/valor empilhado para o modo cartão.
class _ParRotulo extends StatelessWidget {
  const _ParRotulo({required this.label, required this.valor});

  final String label;
  final Widget valor;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: textos.labelLarge),
        const SizedBox(height: Espacos.base),
        DefaultTextStyle.merge(style: textos.bodyMedium, child: valor),
      ],
    );
  }
}

/// Grade simples de N colunas usando [Wrap] (sem rolagem horizontal).
class _Grade extends StatelessWidget {
  const _Grade({required this.colunas, required this.filhos});

  final int colunas;
  final List<Widget> filhos;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const espaco = Espacos.g12;
        final largura =
            (constraints.maxWidth - espaco * (colunas - 1)) / colunas;
        return Wrap(
          spacing: espaco,
          runSpacing: espaco,
          children: [
            for (final f in filhos)
              SizedBox(width: largura < 0 ? 0 : largura, child: f),
          ],
        );
      },
    );
  }
}
