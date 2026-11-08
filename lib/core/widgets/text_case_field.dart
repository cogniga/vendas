import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sales/core/format/padrao_escrita.dart';

/// Padrão de escrita aplicado por um [TextCaseField] (§8).
///
/// [nome] segue o [PadraoNome] escolhido pela empresa (Título, MAIÚSCULAS ou
/// minúsculas) e é aplicado **enquanto digita**; os demais ao perder o foco.
enum CasoTexto { titulo, frase, maius, nome }

/// Campo de texto que normaliza o conteúdo pelo padrão de escrita, usando
/// [PadraoEscrita].
class TextCaseField extends StatefulWidget {
  const TextCaseField({
    required this.caso,
    this.controller,
    this.label,
    this.initial,
    this.onChanged,
    this.padraoNome = PadraoNome.titulo,
    this.dica,
    super.key,
  });

  /// Texto de exemplo (hint) exibido com o campo vazio.
  final String? dica;

  final CasoTexto caso;
  final TextEditingController? controller;
  final String? label;
  final String? initial;
  final ValueChanged<String>? onChanged;

  /// Padrão usado quando [caso] é [CasoTexto.nome].
  final PadraoNome padraoNome;

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
      CasoTexto.nome => PadraoEscrita.nome(_controller.text, widget.padraoNome),
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
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.dica,
      ),
      inputFormatters: widget.caso == CasoTexto.nome
          ? [_FormatadorNome(widget.padraoNome)]
          : null,
      onChanged: widget.onChanged,
    );
  }
}

/// Aplica o [PadraoNome] a cada tecla, preservando cursor e seleção.
class _FormatadorNome extends TextInputFormatter {
  _FormatadorNome(this.padrao);

  final PadraoNome padrao;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Durante a composição (acentos no macOS, IME) não mexe no texto.
    if (newValue.composing.isValid && !newValue.composing.isCollapsed) {
      return newValue;
    }
    final texto = PadraoEscrita.nomeAoDigitar(newValue.text, padrao);
    if (texto == newValue.text || texto.length != newValue.text.length) {
      return newValue;
    }
    return newValue.copyWith(text: texto);
  }
}
