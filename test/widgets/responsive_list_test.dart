import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales/core/theme/tema_app.dart';
import 'package:sales/core/widgets/responsive_list.dart';

/// Monta a [ResponsiveList] dentro de uma largura fixa para checar o modo.
Widget _montar(double largura) {
  final colunas = <ColunaLista<String>>[
    ColunaLista(
      label: 'Nome',
      principal: true,
      builder: (item) => Text(item, key: ValueKey('nome-$item')),
    ),
    ColunaLista(
      label: 'Custo',
      builder: (item) => Text('R\$ $item'),
    ),
  ];

  return ProviderScope(
    child: MaterialApp(
      theme: TemaApp.claro(),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: largura,
            child: ResponsiveList<String>(
              itens: const ['Alfa', 'Beta', 'Gama'],
              colunas: colunas,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('1440 px usa modo tabela (mostra rótulos de coluna)', (
    tester,
  ) async {
    await tester.pumpWidget(_montar(1440));
    await tester.pumpAndSettle();

    // No cabeçalho da tabela aparecem os labels de coluna.
    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('Custo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('1000 px ainda usa tabela (acima do limiar)', (tester) async {
    await tester.pumpWidget(_montar(1000));
    await tester.pumpAndSettle();

    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('Custo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('400 px usa modo cartão (sem cabeçalho de coluna "Nome")', (
    tester,
  ) async {
    await tester.pumpWidget(_montar(400));
    await tester.pumpAndSettle();

    // Em cartões a coluna principal vira título; não há cabeçalho "Nome".
    expect(find.text('Nome'), findsNothing);
    // O rótulo da coluna secundária aparece uma vez por cartão (3 itens).
    expect(find.text('Custo'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
