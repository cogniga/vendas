import 'package:flutter/material.dart';
import 'package:sales/core/theme/tokens.dart';

/// Converte uma cor em hex (`#RRGGBB` ou `#AARRGGBB`) para [Color].
///
/// Se o texto não for um hex válido, cai na cor de destaque do tema. Mesma
/// convenção de `PlatformPill._parseCor`.
Color corDoDestino(BuildContext context, String hex) {
  var limpo = hex.trim().replaceAll('#', '').toUpperCase();
  if (limpo.length == 6) limpo = 'FF$limpo';
  if (limpo.length != 8) return context.cores.accent;
  final valor = int.tryParse(limpo, radix: 16);
  return valor == null ? context.cores.accent : Color(valor);
}
