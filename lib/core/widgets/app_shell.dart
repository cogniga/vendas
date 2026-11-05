import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sales/core/router/rotas.dart';
import 'package:sales/core/theme/tema_provider.dart';
import 'package:sales/core/theme/tokens.dart';

/// Um item navegável do menu.
class _ItemMenu {
  const _ItemMenu(this.rota, this.titulo, this.icone);
  final String rota;
  final String titulo;
  final IconData icone;
}

/// Um grupo de itens do menu (título + itens).
class _GrupoMenu {
  const _GrupoMenu(this.titulo, this.icone, this.itens);
  final String titulo;
  final IconData icone;
  final List<_ItemMenu> itens;
}

const List<_GrupoMenu> _grupos = [
  _GrupoMenu(
    'Painel',
    LucideIcons.layoutDashboard,
    [_ItemMenu(Rotas.painel, 'Painel', LucideIcons.layoutDashboard)],
  ),
  _GrupoMenu(
    'Operação',
    LucideIcons.shoppingCart,
    [
      _ItemMenu(Rotas.pedidos, 'Pedidos', LucideIcons.receipt),
      _ItemMenu(Rotas.composicao, 'Composição de custo', LucideIcons.layers),
      _ItemMenu(Rotas.produtos, 'Produtos', LucideIcons.package),
    ],
  ),
  _GrupoMenu(
    'Financeiro',
    LucideIcons.wallet,
    [
      _ItemMenu(Rotas.insumos, 'Compras de insumos', LucideIcons.box),
      _ItemMenu(Rotas.investimento, 'Investimento', LucideIcons.trendingUp),
      _ItemMenu(Rotas.caixa, 'Caixa e saques', LucideIcons.wallet),
    ],
  ),
  _GrupoMenu(
    'Configuração',
    LucideIcons.settings,
    [
      _ItemMenu(Rotas.plataformas, 'Plataformas e taxas', LucideIcons.store),
      _ItemMenu(Rotas.abelinhas, 'Regra de abelinhas', LucideIcons.sparkles),
      _ItemMenu(
        Rotas.configuracoes,
        'Dados e configurações',
        LucideIcons.settings,
      ),
    ],
  ),
];

/// Casca de navegação: menu lateral fixo (264 px ≥ 1100; 240 px 760–1099) ou
/// barra superior + gaveta em telas < 760. Decisão central por largura
/// (LayoutBuilder), sem espalhar MediaQuery.
class AppShell extends ConsumerWidget {
  const AppShell({required this.child, required this.rotaAtual, super.key});

  final Widget child;
  final String rotaAtual;

  /// Título da tela atual, derivado da rota (para a AppBar em telas estreitas).
  String get _titulo {
    for (final g in _grupos) {
      for (final i in g.itens) {
        if (_rotaCasa(i.rota)) return i.titulo;
      }
    }
    return 'Balcão Revenda';
  }

  bool _rotaCasa(String rota) {
    if (rota == Rotas.painel) return rotaAtual == Rotas.painel;
    return rotaAtual == rota || rotaAtual.startsWith('$rota/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cores = context.cores;

    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        if (largura < 760) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: cores.surface,
              foregroundColor: cores.ink,
              elevation: 0,
              title: Text(_titulo),
            ),
            drawer: Drawer(
              backgroundColor: cores.surface,
              child: SafeArea(child: _Menu(rotaAtual: rotaAtual)),
            ),
            body: _Corpo(child: child),
          );
        }

        final larguraMenu = largura >= 1100 ? 264.0 : 240.0;
        return Scaffold(
          body: Row(
            children: [
              Container(
                width: larguraMenu,
                decoration: BoxDecoration(
                  color: cores.surface,
                  border: Border(right: BorderSide(color: cores.line)),
                ),
                child: SafeArea(child: _Menu(rotaAtual: rotaAtual)),
              ),
              Expanded(child: _Corpo(child: child)),
            ],
          ),
        );
      },
    );
  }
}

/// Área de conteúdo com padding de painel responsivo.
class _Corpo extends StatelessWidget {
  const _Corpo({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = constraints.maxWidth < 600
            ? Espacos.paddingPainelCelular
            : Espacos.paddingPainel;
        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: child,
        );
      },
    );
  }
}

/// Conteúdo do menu: grupos, itens e seletor de tema no rodapé.
class _Menu extends ConsumerWidget {
  const _Menu({required this.rotaAtual});

  final String rotaAtual;

  bool _rotaCasa(String rota) {
    if (rota == Rotas.painel) return rotaAtual == Rotas.painel;
    return rotaAtual == rota || rotaAtual.startsWith('$rota/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cores = context.cores;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(Espacos.g16),
          child: Row(
            children: [
              Icon(LucideIcons.store, size: 20, color: cores.accent),
              const SizedBox(width: Espacos.g8),
              Expanded(
                child: Text(
                  'Balcão Revenda',
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: Espacos.g8),
            children: [
              for (final grupo in _grupos) _grupoWidget(context, grupo),
            ],
          ),
        ),
        Divider(height: 1, color: cores.line),
        Padding(
          padding: const EdgeInsets.all(Espacos.g12),
          child: _SeletorTema(),
        ),
      ],
    );
  }

  Widget _grupoWidget(BuildContext context, _GrupoMenu grupo) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    // Painel é item único: sem rótulo de grupo, o próprio item aparece.
    final grupoDeUmItem =
        grupo.itens.length == 1 && grupo.itens.first.rota == Rotas.painel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Espacos.g12),
        if (!grupoDeUmItem)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Espacos.g8,
              vertical: Espacos.base,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: cores.surface2,
                    borderRadius: BorderRadius.circular(Raios.pill),
                  ),
                  child: Icon(grupo.icone, size: 14, color: cores.muted),
                ),
                const SizedBox(width: Espacos.g8),
                Expanded(
                  child: Text(
                    grupo.titulo,
                    style: textos.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cores.ink,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        for (final item in grupo.itens)
          _itemWidget(context, item, recuado: !grupoDeUmItem),
      ],
    );
  }

  Widget _itemWidget(
    BuildContext context,
    _ItemMenu item, {
    required bool recuado,
  }) {
    final cores = context.cores;
    final ativo = _rotaCasa(item.rota);
    final corTexto = ativo ? cores.accent : cores.ink;

    return Padding(
      padding: EdgeInsets.only(
        left: recuado ? Espacos.g16 : 0,
        top: 2,
        bottom: 2,
      ),
      child: Material(
        color: ativo ? cores.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(Raios.controle),
        child: InkWell(
          borderRadius: BorderRadius.circular(Raios.controle),
          onTap: () {
            // Fecha a gaveta em telas estreitas antes de navegar.
            final scaffold = Scaffold.maybeOf(context);
            if (scaffold?.hasDrawer ?? false) Navigator.of(context).pop();
            context.go(item.rota);
          },
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 3,
                  color: ativo ? cores.accent : Colors.transparent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Espacos.g12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(item.icone, size: 18, color: corTexto),
                        const SizedBox(width: Espacos.g12),
                        Expanded(
                          child: Text(
                            item.titulo,
                            style: TextStyle(
                              color: corTexto,
                              fontWeight:
                                  ativo ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Seletor de tema (Claro / Escuro / Auto) no rodapé do menu.
class _SeletorTema extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modo = ref.watch(temaProvider);
    final cores = context.cores;

    Widget botao(IconData icone, ThemeMode valor, String rotulo) {
      final ativo = modo == valor;
      return Expanded(
        child: Semantics(
          label: rotulo,
          button: true,
          child: Tooltip(
            message: rotulo,
            child: InkWell(
              borderRadius: BorderRadius.circular(Raios.controle),
              onTap: () => ref.read(temaProvider.notifier).definir(valor),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: Espacos.g8),
                decoration: BoxDecoration(
                  color: ativo ? cores.accentSoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(Raios.controle),
                ),
                child: Icon(
                  icone,
                  size: 18,
                  color: ativo ? cores.accent : cores.muted,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(Espacos.base),
      decoration: BoxDecoration(
        color: cores.surface2,
        borderRadius: BorderRadius.circular(Raios.controle),
      ),
      child: Row(
        children: [
          botao(LucideIcons.sun, ThemeMode.light, 'Tema claro'),
          botao(LucideIcons.moon, ThemeMode.dark, 'Tema escuro'),
          botao(LucideIcons.monitor, ThemeMode.system, 'Tema automático'),
        ],
      ),
    );
  }
}
