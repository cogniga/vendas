import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sales/core/format/formatos.dart';

/// Campo de valor monetário que aceita vírgula decimal (pt_BR).
///
/// Expõe o valor via [Formatos.parseDecimal] em [onChanged]; emite `null`
/// quando o texto está vazio ou não é um número válido.
class MoneyField extends StatefulWidget {
  const MoneyField({
    required this.onChanged,
    this.controller,
    this.label,
    this.initial,
    this.prefix = r'R$ ',
    super.key,
  });

  final ValueChanged<Decimal?> onChanged;
  final TextEditingController? controller;
  final String? label;
  final Decimal? initial;
  final String prefix;

  @override
  State<MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<MoneyField> {
  TextEditingController? _interno;

  TextEditingController get _controller =>
      widget.controller ?? (_interno ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    if (widget.initial != null && _controller.text.isEmpty) {
      _controller.text = Formatos.numero(widget.initial!.toDouble());
    }
  }

  @override
  void dispose() {
    _interno?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]')),
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        prefixText: widget.prefix,
      ),
      onChanged: (texto) => widget.onChanged(Formatos.parseDecimal(texto)),
    );
  }
}
