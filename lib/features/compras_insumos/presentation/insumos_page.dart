import 'package:flutter/material.dart';
import 'package:sales/core/widgets/page_header.dart';

/// Placeholder das Compras de insumos (FEAT-003/features).
class InsumosPage extends StatelessWidget {
  const InsumosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: 'Compras de insumos'),
        Text('Em construção'),
      ],
    );
  }
}
