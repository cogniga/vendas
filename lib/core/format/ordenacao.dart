/// Ordenação alfabética no padrão brasileiro.
///
/// O `order by` do Postgres compara byte a byte (maiúsculas antes de
/// minúsculas e acentuadas no fim). Aqui a comparação ignora maiúsculas e
/// acentos e trata números de forma natural ("Kit 2" antes de "Kit 10").
library;

const _acentos = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n',
};

/// Texto em minúsculas, sem acentos e com espaços colapsados.
String chaveAlfabetica(String texto) => texto
    .trim()
    .toLowerCase()
    .split('')
    .map((c) => _acentos[c] ?? c)
    .join()
    .replaceAll(RegExp(r'\s+'), ' ');

final _pedacos = RegExp(r'\d+|\D+');

/// Compara dois textos em ordem alfabética pt-BR (natural para números).
/// Empate na chave desempata pelo texto original, para ser estável.
int compararAlfabetico(String a, String b) {
  final pa = _pedacos.allMatches(chaveAlfabetica(a)).map((m) => m[0]!).toList();
  final pb = _pedacos.allMatches(chaveAlfabetica(b)).map((m) => m[0]!).toList();
  for (var i = 0; i < pa.length && i < pb.length; i++) {
    final x = pa[i];
    final y = pb[i];
    final nx = int.tryParse(x);
    final ny = int.tryParse(y);
    final c = nx != null && ny != null ? nx.compareTo(ny) : x.compareTo(y);
    if (c != 0) return c;
  }
  final c = pa.length.compareTo(pb.length);
  return c != 0 ? c : a.compareTo(b);
}

/// Cópia de [itens] ordenada alfabeticamente pelo texto de [chave].
List<T> ordenarAlfabetico<T>(Iterable<T> itens, String Function(T) chave) =>
    [...itens]..sort((a, b) => compararAlfabetico(chave(a), chave(b)));
