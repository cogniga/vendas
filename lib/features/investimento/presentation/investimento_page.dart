import 'package:flutter/material.dart';
import 'package:sales/core/widgets/page_header.dart';

/// Placeholder da tela de Investimento (FEAT-003/features).
class InvestimentoPage extends StatelessWidget {
  const InvestimentoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: 'Investimento'),
        Text('Em construção'),
      ],
    );
  }
}
