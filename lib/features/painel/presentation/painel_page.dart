import 'package:flutter/material.dart';
import 'package:sales/core/widgets/page_header.dart';

/// Placeholder do Painel. Conteúdo real virá na FEAT-003/features.
class PainelPage extends StatelessWidget {
  const PainelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: 'Painel', subtitle: 'Resumo do negócio'),
        Text('Em construção'),
      ],
    );
  }
}
