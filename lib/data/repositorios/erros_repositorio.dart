import 'package:supabase_flutter/supabase_flutter.dart';

/// Erro de camada de dados com mensagem amigável para a interface.
///
/// Os repositórios capturam [PostgrestException] e outros erros do Supabase e
/// os convertem em [ErroRepositorio] via [ErroRepositorio.dePostgrest], para
/// que a camada de apresentação exiba texto em português sem conhecer o
/// Postgres.
class ErroRepositorio implements Exception {
  /// Cria um erro com a [mensagem] já pronta para exibição.
  const ErroRepositorio(this.mensagem);

  /// Converte uma [PostgrestException] em [ErroRepositorio].
  ///
  /// Quando [mensagemUnique] é informada e o erro é de violação de chave
  /// única (code `23505`), usa essa mensagem específica.
  factory ErroRepositorio.dePostgrest(
    PostgrestException erro, {
    String? mensagemUnique,
  }) {
    if (erro.code == '23505' && mensagemUnique != null) {
      return ErroRepositorio(mensagemUnique);
    }
    return ErroRepositorio(erro.message);
  }

  /// Texto amigável, em português, pronto para a interface.
  final String mensagem;

  @override
  String toString() => 'ErroRepositorio: $mensagem';
}
