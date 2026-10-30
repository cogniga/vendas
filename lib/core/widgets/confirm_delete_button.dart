import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sales/core/theme/tokens.dart';

/// Botão de exclusão em duas etapas.
///
/// O 1º clique troca o botão para "Confirmar" (vermelho) por 3 segundos; se o
/// 2º clique acontecer nesse período, chama [onConfirm]. Caso contrário volta
/// ao estado normal. Acessível via [Tooltip] + [Semantics].
class ConfirmDeleteButton extends StatefulWidget {
  const ConfirmDeleteButton({
    required this.onConfirm,
    this.tooltip = 'Excluir',
    super.key,
  });

  final VoidCallback onConfirm;
  final String tooltip;

  @override
  State<ConfirmDeleteButton> createState() => _ConfirmDeleteButtonState();
}

class _ConfirmDeleteButtonState extends State<ConfirmDeleteButton> {
  bool _confirmando = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _aoClicar() {
    if (_confirmando) {
      _timer?.cancel();
      setState(() => _confirmando = false);
      widget.onConfirm();
      return;
    }
    setState(() => _confirmando = true);
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _confirmando = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;

    if (!_confirmando) {
      return Semantics(
        label: widget.tooltip,
        button: true,
        child: Tooltip(
          message: widget.tooltip,
          child: IconButton(
            icon: Icon(LucideIcons.trash2, size: 18, color: cores.bad),
            onPressed: _aoClicar,
            splashRadius: 20,
            visualDensity: VisualDensity.compact,
          ),
        ),
      );
    }

    return Semantics(
      label: 'Confirmar exclusão',
      button: true,
      child: TextButton.icon(
        onPressed: _aoClicar,
        icon: Icon(LucideIcons.trash2, size: 16, color: cores.accentInk),
        label: const Text('Confirmar'),
        style: TextButton.styleFrom(
          backgroundColor: cores.bad,
          foregroundColor: cores.accentInk,
          padding: const EdgeInsets.symmetric(horizontal: Espacos.g12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Raios.controle),
          ),
        ),
      ),
    );
  }
}
