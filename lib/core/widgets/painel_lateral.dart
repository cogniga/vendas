import 'package:flutter/material.dart';
import 'package:sales/core/theme/tokens.dart';

/// Largura abaixo da qual o painel lateral ocupa a tela cheia.
const double _limiarTelaCheia = 760;

/// Abre um formulário/editor como painel lateral deslizando da direita, com
/// cabeçalho (título + fechar) e rodapé fixo (Cancelar + ação primária).
///
/// Em janelas com largura `< 760` o painel vira tela cheia. A decisão de
/// largura usa [MediaQuery] centralizado aqui (não espalhado). Retorna o valor
/// passado a `Navigator.pop` quando a ação primária conclui, ou `null` se
/// cancelado/fechado.
///
/// O `corpo` recebe uma função `fechar(resultado)` para encerrar o painel
/// (usada ao salvar com sucesso). Use [CorpoPainelLateral] + [RodapePainel]
/// para o conteúdo rolável com rodapé fixo.
Future<T?> abrirPainelLateral<T>(
  BuildContext context, {
  required String titulo,
  required Widget Function(BuildContext context, void Function(T? resultado)
          fechar)
      corpo,
  double largura = 560,
  bool largo = false,
}) {
  final larguraAlvo = largo ? 1080.0 : largura;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, __) {
      return _PainelLateral<T>(titulo: titulo, corpo: corpo);
    },
    transitionBuilder: (context, animacao, _, filho) {
      final curva = CurvedAnimation(
        parent: animacao,
        curve: Curves.easeOutCubic,
      );
      final telaCheia =
          MediaQuery.sizeOf(context).width < _limiarTelaCheia;
      final alvo =
          telaCheia ? MediaQuery.sizeOf(context).width : larguraAlvo;
      return Align(
        alignment: Alignment.centerRight,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curva),
          child: SizedBox(
            width: alvo,
            height: double.infinity,
            child: filho,
          ),
        ),
      );
    },
  );
}

/// Casca visual do painel lateral: cabeçalho, corpo rolável e rodapé fixo.
class _PainelLateral<T> extends StatelessWidget {
  const _PainelLateral({required this.titulo, required this.corpo});

  final String titulo;
  final Widget Function(
    BuildContext context,
    void Function(T? resultado) fechar,
  ) corpo;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    void fechar(T? resultado) => Navigator.of(context).pop(resultado);

    return Material(
      color: cores.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Espacos.g20,
                Espacos.g16,
                Espacos.g8,
                Espacos.g16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(titulo, style: textos.titleLarge),
                  ),
                  IconButton(
                    tooltip: 'Fechar',
                    icon: const Icon(Icons.close),
                    onPressed: () => fechar(null),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: cores.line),
            Expanded(child: corpo(context, fechar)),
          ],
        ),
      ),
    );
  }
}

/// Estrutura padrão para o conteúdo de um [abrirPainelLateral]: um [corpo]
/// rolável e um [rodape] fixo (ex.: [RodapePainel]).
class CorpoPainelLateral extends StatelessWidget {
  const CorpoPainelLateral({
    required this.corpo,
    required this.rodape,
    super.key,
  });

  /// Conteúdo rolável do painel.
  final Widget corpo;

  /// Rodapé fixo (botões de ação).
  final Widget rodape;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Espacos.paddingPainel),
            child: corpo,
          ),
        ),
        Divider(height: 1, color: cores.line),
        Padding(
          padding: const EdgeInsets.all(Espacos.g16),
          child: rodape,
        ),
      ],
    );
  }
}

/// Rodapé fixo do painel: botão Cancelar à esquerda e a ação primária à
/// direita, com estado de carregamento opcional.
class RodapePainel extends StatelessWidget {
  const RodapePainel({
    required this.rotuloPrimario,
    required this.aoConfirmar,
    required this.aoCancelar,
    this.carregando = false,
    super.key,
  });

  final String rotuloPrimario;
  final VoidCallback? aoConfirmar;
  final VoidCallback aoCancelar;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: carregando ? null : aoCancelar,
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: Espacos.g8),
        FilledButton(
          onPressed: carregando ? null : aoConfirmar,
          child: carregando
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(rotuloPrimario),
        ),
      ],
    );
  }
}
