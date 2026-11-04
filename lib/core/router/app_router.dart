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
import 'package:supabase_flutter/supabase_flutter.dart';

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
      final indoParaLogin = state.matchedLocation == Rotas.login;
      final indoParaOnboarding =
          state.matchedLocation == Rotas.onboarding;

      // Atalho de desenvolvimento (adm/adm): libera o app sem Supabase.
      // Como não há empresa real, vai direto ao painel (pula onboarding).
      final sessaoLocal = ref.read(sessaoLocalProvider);
      if (sessaoLocal) {
        return (indoParaLogin || indoParaOnboarding) ? Rotas.painel : null;
      }

      final sessao = Supabase.instance.client.auth.currentSession;
      final temSessao = sessao != null;

      // Sem sessão: só o login é permitido.
      if (!temSessao) {
        return indoParaLogin ? null : Rotas.login;
      }

      // Sessão anônima: entra direto no app. A empresa é criada
      // automaticamente por empresaAtualProvider, então não há onboarding.
      final anonimo = sessao.user.isAnonymous;
      if (anonimo) {
        return (indoParaLogin || indoParaOnboarding) ? Rotas.painel : null;
      }

      // Com sessão mas em /login: decide pelo estado da empresa abaixo.
      final empresa = ref.read(empresaAtualProvider);

      // Enquanto a empresa ainda carrega, segura na tela atual se já for
      // login/onboarding; caso contrário, mantém no login até resolver, para
      // não montar o painel/shell com dados incompletos (causa de erro).
      if (empresa.isLoading) {
        return (indoParaLogin || indoParaOnboarding) ? null : Rotas.login;
      }

      // Falha ao buscar a empresa: estado seguro é o onboarding.
      if (empresa.hasError) {
        return indoParaOnboarding ? null : Rotas.onboarding;
      }

      final temEmpresa = empresa.valueOrNull != null;

      // Com sessão e sem empresa: vai para o onboarding.
      if (!temEmpresa) {
        return indoParaOnboarding ? null : Rotas.onboarding;
      }

      // Já tem empresa: não deixa parado no login nem no onboarding.
      if (indoParaLogin || indoParaOnboarding) {
        return Rotas.painel;
      }

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
            builder: (context, state) => const PainelPage(),
          ),
          GoRoute(
            path: Rotas.pedidos,
            builder: (context, state) => const PedidosPage(),
            routes: [
              GoRoute(
                path: 'novo',
                builder: (context, state) => const PedidosPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => const PedidosPage(),
              ),
            ],
          ),
          GoRoute(
            path: Rotas.composicao,
            builder: (context, state) => const ComposicaoPage(),
            routes: [
              GoRoute(
                path: 'novo',
                builder: (context, state) => const ComposicaoPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => const ComposicaoPage(),
              ),
            ],
          ),
          GoRoute(
            path: Rotas.produtos,
            builder: (context, state) => const ProdutosPage(),
          ),
          GoRoute(
            path: Rotas.insumos,
            builder: (context, state) => const InsumosPage(),
          ),
          GoRoute(
            path: Rotas.investimento,
            builder: (context, state) => const InvestimentoPage(),
          ),
          GoRoute(
            path: Rotas.caixa,
            builder: (context, state) => const CaixaPage(),
          ),
          GoRoute(
            path: Rotas.plataformas,
            builder: (context, state) => const PlataformasPage(),
          ),
          GoRoute(
            path: Rotas.abelinhas,
            builder: (context, state) => const AbelinhasPage(),
          ),
          GoRoute(
            path: Rotas.configuracoes,
            builder: (context, state) => const ConfiguracoesPage(),
          ),
        ],
      ),
    ],
  );
});
