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

/// Expõe o [SupabaseClient] para as camadas de dados via Riverpod.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Stream do estado de autenticação (login/logout).
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});
