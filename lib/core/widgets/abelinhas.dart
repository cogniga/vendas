import 'package:flutter/material.dart';
import 'package:sales/core/format/formatos.dart';

/// Exibe uma quantidade de abelinhas formatada (`1,5 🐝`) via [Formatos].
class Abelinhas extends StatelessWidget {
  const Abelinhas(this.qtd, {super.key});

  final num qtd;

  @override
  Widget build(BuildContext context) {
    return Text(
      Formatos.abelinhas(qtd),
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
