import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Credenciais do login local provisório (atalho de desenvolvimento).
///
/// ATENÇÃO: isto é TEMPORÁRIO e INSEGURO. Serve apenas para destravar a
/// navegação e o desenvolvimento das telas sem depender do Supabase Auth.
/// Deve ser removido antes de qualquer uso real, voltando ao login do
/// Supabase. Com login local NÃO há sessão no Supabase, então telas que leem
/// ou gravam dados protegidos por RLS não funcionarão com este atalho.
class SessaoLocal {
  const SessaoLocal._();

  /// Usuário fixo do atalho.
  static const String usuario = 'adm';

  /// Senha fixa do atalho.
  static const String senha = 'adm';

  /// Valida as credenciais locais.
  static bool valida(String usuarioInformado, String senhaInformada) =>
      usuarioInformado.trim() == usuario && senhaInformada == senha;
}

/// Mantém se o usuário entrou pelo login local provisório.
///
/// Enquanto `true`, o roteador libera o app mesmo sem sessão no Supabase.
class SessaoLocalController extends StateNotifier<bool> {
  SessaoLocalController() : super(false);

  /// Marca a sessão local como ativa.
  void entrar() => state = true;

  /// Encerra a sessão local.
  void sair() => state = false;
}

/// `true` quando há login local ativo.
final sessaoLocalProvider =
    StateNotifierProvider<SessaoLocalController, bool>(
  (ref) => SessaoLocalController(),
);
