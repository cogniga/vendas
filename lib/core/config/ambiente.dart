import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Configuração de ambiente do Supabase.
///
/// Resolve as credenciais em duas camadas, nesta ordem de prioridade:
/// 1. `--dart-define=SUPABASE_URL=...` e `--dart-define=SUPABASE_ANON_KEY=...`
///    (recomendado para builds de produção/CI — nada fica no bundle).
/// 2. O arquivo local `env/supabase.json` (empacotado como asset), para que o
///    app funcione ao rodar pelo botão "Run" do editor sem passar flags.
///
/// Chame [carregar] uma vez em `main()` antes de usar [supabaseUrl] /
/// [supabaseAnonKey].
class Ambiente {
  Ambiente._();

  static const String _defineUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _defineAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static String _url = _defineUrl;
  static String _anonKey = _defineAnonKey;

  /// URL do projeto Supabase resolvida.
  static String get supabaseUrl => _url;

  /// Chave pública (publishable/anon) do projeto Supabase resolvida.
  static String get supabaseAnonKey => _anonKey;

  /// Indica se as credenciais obrigatórias estão disponíveis.
  static bool get supabaseConfigurado =>
      _url.isNotEmpty &&
      _anonKey.isNotEmpty &&
      !_url.contains('SEU-PROJETO') &&
      !_anonKey.contains('COLE_AQUI');

  /// Carrega as credenciais: usa os `--dart-define` quando presentes; senão,
  /// tenta ler `env/supabase.json` do bundle. Seguro para chamar mais de uma
  /// vez. Nunca lança — em caso de falha, mantém valores vazios.
  static Future<void> carregar() async {
    if (_defineUrl.isNotEmpty && _defineAnonKey.isNotEmpty) {
      _url = _defineUrl;
      _anonKey = _defineAnonKey;
      return;
    }
    try {
      final conteudo = await rootBundle.loadString('env/supabase.json');
      final mapa = json.decode(conteudo) as Map<String, dynamic>;
      _url = (mapa['SUPABASE_URL'] as String?)?.trim() ?? '';
      _anonKey = (mapa['SUPABASE_ANON_KEY'] as String?)?.trim() ?? '';
    } on Object {
      // Sem asset ou JSON inválido: segue com valores vazios e a tela de
      // configuração ausente orienta o usuário.
      _url = _defineUrl;
      _anonKey = _defineAnonKey;
    }
  }
}
