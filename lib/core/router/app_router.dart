import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales/core/config/sessao_local.dart';
import 'package:sales/core/config/supabase_config.dart';
import 'package:sales/core/router/rotas.dart';
import 'package:sales/core/widgets/app_shell.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/features/abelinhas/presentation/abelinhas_page.dart';
import 'package:sales/features/auth/presentation/login_page.dart';
import 'package:sales/features/caixa/presentation/caixa_page.dart';
import 'package:sales/features/composicao/presentation/composicao_page.dart';
import 'package:sales/features/compras_insumos/presentation/insumos_page.dart';
import 'package:sales/features/configuracoes/presentation/configuracoes_page.dart';
import 'package:sales/features/investimento/presentation/investimento_page.dart';
import 'package:sales/features/onboarding/presentation/onboarding_page.dart';
import 'package:sales/features/painel/presentation/painel_page.dart';
import 'package:sales/features/pedidos/presentation/pedidos_page.dart';
import 'package:sales/features/plataformas/presentation/plataformas_page.dart';
import 'package:sales/features/produtos/presentation/produtos_page.dart';

/// Rebaseia o [GoRouter] quando o estado de auth ou a empresa atual mudam.
///
/// Escuta [authStateProvider] e [empresaAtualProvider] via `ref.listen` e
/// notifica o roteador para reavaliar o `redirect`.
class _RefreshRoteador extends ChangeNotifier {
  _RefreshRoteador(Ref ref) {
    ref
      ..listen(authStateProvider, (_, _) => notifyListeners())
      ..listen(sessaoLocalProvider, (_, _) => notifyListeners())
      ..listen(empresaAtualProvider, (_, _) => notifyListeners());
  }
}

/// Monta o [GoRouter] com as rotas do design §4 e as guardas de auth.
final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RefreshRoteador(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Rotas.painel,
    refreshListenable: refresh,
    redirect: (context, state) {
      // Modo sem login/sessão (RLS desligado): entra direto no app. As telas
      // (login/onboarding) continuam acessíveis por rota, mas o padrão é ir
      // ao painel. A empresa ativa vem de empresaAtualProvider (seleção em
      // Dados e configurações ou a primeira de todas).
      final indoParaLogin = state.matchedLocation == Rotas.login;
      final indoParaOnboarding =
          state.matchedLocation == Rotas.onboarding;
      if (indoParaLogin || indoParaOnboarding) return Rotas.painel;
      return null;
    },
    routes: [
      GoRoute(
        path: Rotas.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Rotas.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(rotaAtual: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: Rotas.painel,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PainelPage()),
          ),
          GoRoute(
            path: Rotas.pedidos,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PedidosPage()),
            routes: [
              GoRoute(
                path: 'novo',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: PedidosPage()),
              ),
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: PedidosPage()),
              ),
            ],
          ),
          GoRoute(
            path: Rotas.composicao,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ComposicaoPage()),
            routes: [
              GoRoute(
                path: 'novo',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ComposicaoPage()),
              ),
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ComposicaoPage()),
              ),
            ],
          ),
          GoRoute(
            path: Rotas.produtos,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProdutosPage()),
          ),
          GoRoute(
            path: Rotas.insumos,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InsumosPage()),
          ),
          GoRoute(
            path: Rotas.investimento,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InvestimentoPage()),
          ),
          GoRoute(
            path: Rotas.caixa,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CaixaPage()),
          ),
          GoRoute(
            path: Rotas.plataformas,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PlataformasPage()),
          ),
          GoRoute(
            path: Rotas.abelinhas,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AbelinhasPage()),
          ),
          GoRoute(
            path: Rotas.configuracoes,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ConfiguracoesPage()),
          ),
        ],
      ),
    ],
  );
});
