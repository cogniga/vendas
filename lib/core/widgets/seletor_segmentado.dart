import 'package:flutter/material.dart';
import 'package:sales/core/theme/tokens.dart';

/// Opção de um [SeletorSegmentado].
class OpcaoSegmentada<T> {
  const OpcaoSegmentada(this.valor, this.rotulo);

  final T valor;
  final String rotulo;
}

/// Controle segmentado do protótipo (`.tabs`): fundo surface2, padding 3,
/// opção selecionada em surface com sombra leve.
class SeletorSegmentado<T> extends StatelessWidget {
  const SeletorSegmentado({
    required this.opcoes,
    required this.selecionado,
    required this.onChanged,
    this.rotuloSemantico,
    super.key,
  });

  final List<OpcaoSegmentada<T>> opcoes;
  final T selecionado;
  final ValueChanged<T> onChanged;
  final String? rotuloSemantico;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return Semantics(
      container: true,
      label: rotuloSemantico,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: cores.surface2,
          borderRadius: BorderRadius.circular(Raios.controle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < opcoes.length; i++) ...[
              if (i > 0) const SizedBox(width: 2),
              _Segmento(
                rotulo: opcoes[i].rotulo,
                ativo: opcoes[i].valor == selecionado,
                onTap: () => onChanged(opcoes[i].valor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Segmento extends StatelessWidget {
  const _Segmento({
    required this.rotulo,
    required this.ativo,
    required this.onTap,
  });

  final String rotulo;
  final bool ativo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return Semantics(
      button: true,
      selected: ativo,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          constraints: const BoxConstraints(minHeight: 32),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: ativo ? cores.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: ativo
                ? const [
                    BoxShadow(
                      color: Color(0x0A101828),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            rotulo,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ativo ? cores.ink : cores.muted,
            ),
          ),
        ),
      ),
    );
  }
}
