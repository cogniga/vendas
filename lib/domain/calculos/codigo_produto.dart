/// Geração automática do código do produto a partir do nome.
///
/// Função pura (só `dart:core`). Regra:
/// 1. remove acentos e símbolos; ignora conectivos (de, da, do, e, com, p/…);
/// 2. pega as 3 primeiras letras de até 3 palavras (palavras com dígito, como
///    "50ml", entram inteiras, até 5 caracteres);
/// 3. junta com "-" em maiúsculas: "Batom Matte Vermelho" → `BAT-MAT-VER`;
/// 4. se o código já existe na empresa, acrescenta `-2`, `-3`… até ficar único.
library;

const _conectivos = {
  'a', 'o', 'as', 'os', 'de', 'da', 'do', 'das', 'dos', 'e', 'com', 'para',
  'p', 'em', 'na', 'no', 'nas', 'nos', 'por', 'sem', 'um', 'uma',
};

const _acentos = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n',
};

/// Base do código (sem sufixo de unicidade). Vazio quando o nome não tem
/// letras nem números.
String baseCodigoProduto(String nome) {
  final semAcento = nome
      .toLowerCase()
      .split('')
      .map((c) => _acentos[c] ?? c)
      .join();
  final palavras = semAcento
      .split(RegExp('[^a-z0-9]+'))
      .where((p) => p.isNotEmpty && !_conectivos.contains(p))
      .take(3);
  return palavras.map((p) {
    final temDigito = p.contains(RegExp('[0-9]'));
    final tamanho = temDigito ? 5 : 3;
    return (p.length > tamanho ? p.substring(0, tamanho) : p).toUpperCase();
  }).join('-');
}

/// Código único para [nome], considerando os [existentes] da empresa
/// (comparação sem diferenciar maiúsculas). Devolve `''` se o nome for vazio.
String gerarCodigoProduto(String nome, Iterable<String> existentes) {
  final base = baseCodigoProduto(nome);
  if (base.isEmpty) return '';
  final usados = existentes.map((c) => c.trim().toUpperCase()).toSet();
  if (!usados.contains(base)) return base;
  var n = 2;
  while (usados.contains('$base-$n')) {
    n++;
  }
  return '$base-$n';
}
