import 'package:flutter/material.dart';
import 'package:sales/core/format/padrao_escrita.dart';

/// Padrão de escrita aplicado por um [TextCaseField] ao perder o foco (§8).
enum CasoTexto { titulo, frase, maius }

/// Campo de texto que normaliza o conteúdo pelo padrão de escrita quando perde
/// o foco, usando [PadraoEscrita].
class TextCaseField extends StatefulWidget {
  const TextCaseField({
    required this.caso,
    this.controller,
    this.label,
    this.initial,
    this.onChanged,
    super.key,
  });

  final CasoTexto caso;
  final TextEditingController? controller;
  final String? label;
  final String? initial;
  final ValueChanged<String>? onChanged;

  @override
  State<TextCaseField> createState() => _TextCaseFieldState();
}

class _TextCaseFieldState extends State<TextCaseField> {
  TextEditingController? _interno;
  final FocusNode _foco = FocusNode();

  TextEditingController get _controller =>
      widget.controller ?? (_interno ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    if (widget.initial != null && _controller.text.isEmpty) {
      _controller.text = widget.initial!;
    }
    _foco.addListener(_aoMudarFoco);
  }

  @override
  void dispose() {
    _foco
      ..removeListener(_aoMudarFoco)
      ..dispose();
    _interno?.dispose();
    super.dispose();
  }

  void _aoMudarFoco() {
    if (_foco.hasFocus) return;
    final normalizado = switch (widget.caso) {
      CasoTexto.titulo => PadraoEscrita.titulo(_controller.text),
      CasoTexto.frase => PadraoEscrita.frase(_controller.text),
      CasoTexto.maius => PadraoEscrita.maius(_controller.text),
    };
    if (normalizado != _controller.text) {
      _controller.text = normalizado;
      widget.onChanged?.call(normalizado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _foco,
      decoration: InputDecoration(labelText: widget.label),
      onChanged: widget.onChanged,
    );
  }
}
