import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/config/sessao_local.dart';
import 'package:sales/core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Controla a autenticação via Supabase Auth (design.md §10).
///
/// Expõe o estado da última operação como `AsyncValue<void>`: `loading`
/// enquanto a requisição corre, `error` com uma mensagem amigável em pt_BR
/// quando falha e `data` ao concluir. A navegação em si é decidida pelo
/// `redirect` do go_router (reage à mudança de sessão).
class AuthController extends StateNotifier<AsyncValue<void>> {
  /// Cria o controller com o [SupabaseClient] e o controller de sessão local.
  AuthController(this._client, this._sessaoLocal)
      : super(const AsyncValue.data(null));

  final SupabaseClient _client;
  final SessaoLocalController _sessaoLocal;

  /// Entra com e-mail e senha.
  ///
  /// Atalho de desenvolvimento: se as credenciais forem as locais
  /// (`adm`/`adm`), ativa a sessão local e NÃO chama o Supabase. Caso
  /// contrário, usa `signInWithPassword` normalmente.
  Future<void> entrar(String email, String senha) {
    if (SessaoLocal.valida(email, senha)) {
      _sessaoLocal.entrar();
      state = const AsyncValue.data(null);
      return Future<void>.value();
    }
    return _executar(() => _client.auth.signInWithPassword(
          email: email.trim(),
          password: senha,
        ));
  }

  /// Cria uma conta com e-mail e senha (`signUp`).
  Future<void> criarConta(String email, String senha) =>
      _executar(() => _client.auth.signUp(
            email: email.trim(),
            password: senha,
          ));

  /// Envia o e-mail de recuperação de senha (`resetPasswordForEmail`).
  Future<void> recuperarSenha(String email) => _executar(
        () => _client.auth.resetPasswordForEmail(email.trim()),
      );

  /// Encerra a sessão (local e do Supabase).
  Future<void> sair() {
    _sessaoLocal.sair();
    return _executar(() => _client.auth.signOut());
  }

  Future<void> _executar(Future<void> Function() acao) async {
    state = const AsyncValue.loading();
    try {
      await acao();
      if (mounted) state = const AsyncValue.data(null);
    } on AuthException catch (e) {
      if (mounted) {
        state = AsyncValue.error(_mensagem(e), StackTrace.current);
      }
    } on Object catch (_) {
      if (mounted) {
        state = AsyncValue.error(
          'Não foi possível concluir. Tente de novo.',
          StackTrace.current,
        );
      }
    }
  }

  /// Traduz uma [AuthException] do Supabase para mensagem em pt_BR (§10).
  String _mensagem(AuthException erro) {
    final texto = erro.message.toLowerCase();
    if (texto.contains('invalid login') ||
        texto.contains('invalid credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (texto.contains('email not confirmed')) {
      return 'Confirme o e-mail antes de entrar.';
    }
    if (texto.contains('user already registered') ||
        texto.contains('already registered')) {
      return 'Já existe uma conta com este e-mail.';
    }
    if (texto.contains('password should be') ||
        texto.contains('at least')) {
      return 'A senha precisa de pelo menos 6 caracteres.';
    }
    if (texto.contains('rate limit') ||
        texto.contains('too many requests')) {
      return 'Muitas tentativas. Aguarde um instante e tente de novo.';
    }
    if (texto.contains('network') || texto.contains('failed host')) {
      return 'Falha de conexão. Verifique a internet e tente de novo.';
    }
    return erro.message;
  }
}

/// Provider do [AuthController].
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(
    ref.watch(supabaseClientProvider),
    ref.watch(sessaoLocalProvider.notifier),
  );
});
