import 'package:flutter/material.dart';
import 'package:sales/core/widgets/page_header.dart';

/// Placeholder da Composição de custo / produtos de venda (FEAT-003/features).
class ComposicaoPage extends StatelessWidget {
  const ComposicaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: 'Composição de custo'),
        Text('Em construção'),
      ],
    );
  }
}
