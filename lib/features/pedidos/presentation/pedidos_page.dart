import 'package:flutter/material.dart';
import 'package:sales/core/widgets/page_header.dart';

/// Placeholder da lista/editor de Pedidos (FEAT-003/features).
class PedidosPage extends StatelessWidget {
  const PedidosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: 'Pedidos'),
        Text('Em construção'),
      ],
    );
  }
}
