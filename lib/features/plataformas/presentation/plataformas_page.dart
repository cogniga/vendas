import 'package:flutter/material.dart';
import 'package:sales/core/widgets/page_header.dart';

/// Placeholder de Plataformas e taxas (FEAT-003/features).
class PlataformasPage extends StatelessWidget {
  const PlataformasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: 'Plataformas e taxas'),
        Text('Em construção'),
      ],
    );
  }
}
