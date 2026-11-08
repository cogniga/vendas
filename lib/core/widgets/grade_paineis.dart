import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Grade de painéis do protótipo (`.grid.g2`, CSS grid com auto-fit).
///
/// - Colunas de no mínimo [larguraMinima]. Entre as quantidades de colunas que
///   cabem, escolhe a que deixa **menos buracos** na última linha (4 painéis
///   em 3 colunas viram 2×2, em vez de 3 + 1 solto).
/// - Painéis da mesma linha ficam com a **mesma altura** (como o `stretch` do
///   CSS grid), via [_LinhaMesmaAltura] — sem `IntrinsicHeight`, que quebra com
///   `LayoutBuilder` dentro dos painéis.
/// - Se ainda sobrar painel na última linha, ele estica para ocupar a largura.
class GradePaineis extends StatelessWidget {
  const GradePaineis({
    required this.filhos,
    this.larguraMinima = 340,
    this.espaco = 16,
    super.key,
  });

  final List<Widget> filhos;
  final double larguraMinima;
  final double espaco;

  /// Quantidade de colunas para [n] painéis cabendo no máximo [cabem].
  static int colunasPara(int n, int cabem) {
    if (n == 0) return 0;
    final maximo = math.max(1, math.min(cabem, n));
    var melhor = maximo;
    var menorSobra = n;
    for (var c = maximo; c >= 1; c--) {
      final sobra = (n / c).ceil() * c - n;
      if (sobra < menorSobra) {
        menorSobra = sobra;
        melhor = c;
      }
      if (sobra == 0) break;
    }
    return melhor;
  }

  @override
  Widget build(BuildContext context) {
    if (filhos.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final cabem =
            ((constraints.maxWidth + espaco) / (larguraMinima + espaco))
                .floor();
        final colunas = colunasPara(filhos.length, cabem);
        final linhas = <Widget>[];
        for (var i = 0; i < filhos.length; i += colunas) {
          final fim = math.min(i + colunas, filhos.length);
          if (linhas.isNotEmpty) linhas.add(SizedBox(height: espaco));
          linhas.add(
            _LinhaMesmaAltura(
              espaco: espaco,
              children: filhos.sublist(i, fim),
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: linhas,
        );
      },
    );
  }
}

/// Linha que divide a largura igualmente e iguala a altura dos filhos à do
/// mais alto (2 passadas de layout; não usa medidas intrínsecas).
class _LinhaMesmaAltura extends MultiChildRenderObjectWidget {
  const _LinhaMesmaAltura({required this.espaco, required super.children});

  final double espaco;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderLinhaMesmaAltura(espaco);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderLinhaMesmaAltura renderObject,
  ) {
    renderObject.espaco = espaco;
  }
}

class _DadosLinha extends ContainerBoxParentData<RenderBox> {}

class _RenderLinhaMesmaAltura extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _DadosLinha>,
        RenderBoxContainerDefaultsMixin<RenderBox, _DadosLinha> {
  _RenderLinhaMesmaAltura(this._espaco);

  double _espaco;
  double get espaco => _espaco;
  set espaco(double valor) {
    if (valor == _espaco) return;
    _espaco = valor;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _DadosLinha) child.parentData = _DadosLinha();
  }

  @override
  void performLayout() {
    final largura = constraints.maxWidth;
    final n = childCount;
    if (n == 0) {
      size = constraints.constrain(Size(largura, 0));
      return;
    }
    final larguraFilho = math.max(0, (largura - _espaco * (n - 1)) / n);

    // 1ª passada: altura natural de cada filho.
    var altura = 0.0;
    var filho = firstChild;
    while (filho != null) {
      filho.layout(
        BoxConstraints.tightFor(width: larguraFilho.toDouble()),
        parentUsesSize: true,
      );
      altura = math.max(altura, filho.size.height);
      filho = childAfter(filho);
    }

    // 2ª passada: todos com a altura do mais alto. Usa altura MÍNIMA (não
    // fixa): com restrição fixa o filho vira "relayout boundary" e, se o
    // conteúdo crescer depois, transbordaria sem a linha ser recalculada.
    var x = 0.0;
    filho = firstChild;
    while (filho != null) {
      filho.layout(
        BoxConstraints(
          minWidth: larguraFilho.toDouble(),
          maxWidth: larguraFilho.toDouble(),
          minHeight: altura,
        ),
        parentUsesSize: true,
      );
      (filho.parentData! as _DadosLinha).offset = Offset(x, 0);
      altura = math.max(altura, filho.size.height);
      x += larguraFilho + _espaco;
      filho = childAfter(filho);
    }
    size = constraints.constrain(Size(largura, altura));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
