import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/config/ambiente.dart';
import 'package:sales/core/config/tela_config_ausente.dart';
import 'package:sales/core/router/app_router.dart';
import 'package:sales/core/theme/tema_app.dart';
import 'package:sales/core/theme/tema_provider.dart';

/// Raiz da aplicação: navegação (go_router), tema claro/escuro/auto e locale
/// pt_BR.
///
/// Enquanto o Supabase não estiver configurado, exibe [TelaConfigAusente]
/// (sem roteador, para orientar a configuração).
class BalcaoRevendaApp extends ConsumerWidget {
  const BalcaoRevendaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modoTema = ref.watch(temaProvider);

    const locais = [Locale('pt', 'BR')];
    const delegates = [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];

    if (!Ambiente.supabaseConfigurado) {
      return MaterialApp(
        title: 'Balcão Revenda',
        debugShowCheckedModeBanner: false,
        theme: TemaApp.claro(),
        darkTheme: TemaApp.escuro(),
        themeMode: modoTema,
        locale: const Locale('pt', 'BR'),
        supportedLocales: locais,
        localizationsDelegates: delegates,
        home: const TelaConfigAusente(),
      );
    }

    return MaterialApp.router(
      title: 'Balcão Revenda',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro(),
      darkTheme: TemaApp.escuro(),
      themeMode: modoTema,
      locale: const Locale('pt', 'BR'),
      supportedLocales: locais,
      localizationsDelegates: delegates,
      routerConfig: ref.watch(goRouterProvider),
    );
  }
}
