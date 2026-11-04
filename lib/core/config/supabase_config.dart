import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/config/ambiente.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Inicializa o cliente Supabase usando as variáveis de [Ambiente].
///
/// Deve ser chamado uma vez em `main()` antes de `runApp`. Se as variáveis não
/// estiverem configuradas, a inicialização é ignorada para permitir que a
/// aplicação abra e mostre uma mensagem de configuração ausente.
Future<void> inicializarSupabase() async {
  if (!Ambiente.supabaseConfigurado) {
    return;
  }
  await Supabase.initialize(
    url: Ambiente.supabaseUrl,
    // ignore: deprecated_member_use
    anonKey: Ambiente.supabaseAnonKey,
  );
}

/// Garante uma sessão anônima no Supabase quando não houver usuário logado.
///
/// Permite acessar as tabelas (sob RLS) sem uma tela de login real. É seguro:
/// o usuário anônimo é um usuário de verdade, então a RLS continua valendo.
/// Não lança em caso de falha (ex.: anônimo desabilitado no projeto) — apenas
/// registra o erro e segue; a camada de dados tratará a ausência de sessão.
Future<void> garantirSessaoAnonima() async {
  if (!Ambiente.supabaseConfigurado) return;
  final auth = Supabase.instance.client.auth;
  if (auth.currentSession != null) return;
  try {
    await auth.signInAnonymously();
  } on Object catch (_) {
    // Anônimo pode estar desabilitado no projeto; segue sem sessão.
  }
}

/// Expõe o [SupabaseClient] para as camadas de dados via Riverpod.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Stream do estado de autenticação (login/logout).
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});
