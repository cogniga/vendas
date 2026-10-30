import 'package:flutter/material.dart';
import 'package:sales/core/widgets/page_header.dart';

/// Placeholder da Regra de abelinhas (FEAT-003/features).
class AbelinhasPage extends StatelessWidget {
  const AbelinhasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: 'Regra de abelinhas'),
        Text('Em construção'),
      ],
    );
  }
}
