import 'package:flutter/material.dart';
import 'package:sales/core/widgets/page_header.dart';

/// Placeholder da tela de Produtos (FEAT-003/features).
class ProdutosPage extends StatelessWidget {
  const ProdutosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: 'Produtos'),
        Text('Em construção'),
      ],
    );
  }
}
