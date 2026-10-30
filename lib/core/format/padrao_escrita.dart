/// Normalização de texto — padrão de escrita (design.md §8).
///
/// - [titulo]: Título com conectivos minúsculos, siglas em maiúsculas, palavras
///   com dígito preservadas. Usado em nomes (produto, marca, fornecedor, kit,
///   distribuidor, insumo).
/// - [frase]: só a primeira letra maiúscula (resto como digitado). Usado em
///   categoria, descrição, destino, observações.
/// - [maius]: tudo maiúsculo. Usado em código, cliente/nº do pedido, nota.
class PadraoEscrita {
  const PadraoEscrita._();

  static const Set<String> conectivos = {
    'de', 'da', 'do', 'das', 'dos', 'e', 'em', 'com', 'para', 'p/', 'a', 'o',
    'as', 'os', 'no', 'na', 'nos', 'nas', 'por', 'sem', 'ao',
  };

  static const Set<String> siglas = {
    'HD', 'UV', 'FPS', 'SPF', 'CNPJ', 'CPF', 'NF',
  };

  /// Colapsa espaços múltiplos e remove espaços nas pontas.
  static String _colapsar(String t) => t.trim().replaceAll(RegExp(r'\s+'), ' ');

  static bool _temDigito(String p) => p.contains(RegExp(r'\d'));

  /// Título com conectivos minúsculos (pt_BR).
  static String titulo(String texto) {
    final t = _colapsar(texto);
    if (t.isEmpty) return t;
    final palavras = t.split(' ');
    final resultado = <String>[];
    for (var i = 0; i < palavras.length; i++) {
      final p = palavras[i];
      if (p.isEmpty) continue;
      if (_temDigito(p)) {
        // Palavra com dígito: mantém como está.
        resultado.add(p);
      } else if (siglas.contains(p.toUpperCase())) {
        resultado.add(p.toUpperCase());
      } else if (i > 0 && conectivos.contains(p.toLowerCase())) {
        resultado.add(p.toLowerCase());
      } else {
        resultado.add(_capitalizar(p));
      }
    }
    return resultado.join(' ');
  }

  /// Só a primeira letra maiúscula; o resto permanece como digitado.
  static String frase(String texto) {
    final t = _colapsar(texto);
    if (t.isEmpty) return t;
    return t[0].toUpperCase() + t.substring(1);
  }

  /// Tudo maiúsculo.
  static String maius(String texto) => _colapsar(texto).toUpperCase();

  static String _capitalizar(String p) {
    final lower = p.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }
}
