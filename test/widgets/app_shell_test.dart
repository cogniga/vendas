import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sales/core/router/rotas.dart';
import 'package:sales/core/theme/tema_app.dart';
import 'package:sales/core/widgets/app_shell.dart';

/// Monta o [AppShell] com um GoRouter mínimo (o AppShell navega com context.go)
/// e aplica a largura desejada à janela de teste.
Widget _app() {
  final router = GoRouter(
    initialLocation: Rotas.painel,
    routes: [
      GoRoute(
        path: Rotas.painel,
        builder: (context, state) => const AppShell(
          rotaAtual: Rotas.painel,
          child: Text('conteúdo'),
        ),
      ),
      GoRoute(
        path: Rotas.pedidos,
        builder: (context, state) => const AppShell(
          rotaAtual: Rotas.pedidos,
          child: Text('conteúdo'),
        ),
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      theme: TemaApp.claro(),
      routerConfig: router,
    ),
  );
}

void _definirLargura(WidgetTester tester, double largura) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(largura, 1000);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('< 760 mostra botão de menu e abre a gaveta', (tester) async {
    _definirLargura(tester, 500);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    // Em telas estreitas há AppBar com botão ☰ e um Drawer disponível.
    final botaoMenu = find.byIcon(Icons.menu);
    expect(botaoMenu, findsOneWidget);
    expect(find.byType(Drawer), findsNothing);

    await tester.tap(botaoMenu);
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('>= 1100 mostra menu lateral fixo e sem botão ☰', (
    tester,
  ) async {
    _definirLargura(tester, 1280);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    // Menu lateral fixo: sem botão de menu e sem Drawer.
    expect(find.byIcon(Icons.menu), findsNothing);
    expect(find.byType(Drawer), findsNothing);
    // Os títulos de grupo aparecem no menu lateral.
    expect(find.text('Operação'), findsOneWidget);
    expect(find.text('Financeiro'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
