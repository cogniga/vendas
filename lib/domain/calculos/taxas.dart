import 'package:decimal/decimal.dart';
import 'package:sales/domain/calculos/decimais.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';

/// Cálculos de faixa e taxa de plataforma (design.md §6.1 e §6.2).
///
/// Funções puras: dependem apenas de `dart:core`, `package:decimal` e das
/// entidades de domínio. As faixas são sempre ordenadas por `precoAte`
/// ascendente, com a faixa sem limite (`precoAte == null`) por último.

/// Ordena as faixas por `precoAte` ascendente; a faixa sem limite vai ao fim.
List<FaixaTaxa> ordenarFaixas(List<FaixaTaxa> faixas) {
  return [...faixas]..sort((a, b) {
    if (a.precoAte == null && b.precoAte == null) return 0;
    if (a.precoAte == null) return 1;
    if (b.precoAte == null) return -1;
    return a.precoAte!.compareTo(b.precoAte!);
  });
}

/// Faixa neutra (sem taxa) usada quando a plataforma não tem faixas.
FaixaTaxa _faixaNeutra() => FaixaTaxa(
      id: '',
      empresaId: '',
      plataformaId: '',
      taxaFixa: zero,
      taxaPercentual: zero,
    );

/// Início ("De") de cada faixa, na mesma ordem de [tetos] (o "até" de cada
/// faixa; `null` = sem limite).
///
/// O início é o maior teto menor que o da faixa + R$ 0,01 (0 na primeira).
/// Para a faixa sem limite, é o maior teto existente + 0,01. Assim as faixas
/// nunca têm buraco nem sobreposição, sem precisar guardar o mínimo no banco.
List<Decimal> iniciosDasFaixas(List<Decimal?> tetos) {
  final centavo = Decimal.parse('0.01');
  final finitos = tetos.whereType<Decimal>().toList();
  return [
    for (final teto in tetos)
      () {
        final anteriores =
            finitos.where((t) => teto == null || t < teto).toList();
        if (anteriores.isEmpty) return Decimal.zero;
        return anteriores.reduce((a, b) => a > b ? a : b) + centavo;
      }(),
  ];
}

/// Faixa aplicável a [preco] (ex.: até 50 · 50,01 a 100 · acima de 100).
/// É a primeira cujo limite cobre o preço
/// (`precoAte == null || preco <= precoAte`); se nenhuma cobrir, a última.
///
/// Quando [faixas] está vazia (plataforma sem faixas ou dados ainda não
/// carregados), devolve uma faixa neutra (taxa zero) em vez de lançar.
FaixaTaxa faixa(List<FaixaTaxa> faixas, Decimal preco) {
  final ordenadas = ordenarFaixas(faixas);
  if (ordenadas.isEmpty) return _faixaNeutra();
  for (final f in ordenadas) {
    if (f.precoAte == null || preco <= f.precoAte!) return f;
  }
  return ordenadas.last;
}

/// Percentual total cobrado na faixa: percentual da plataforma + outras taxas
/// (ex.: frete do TikTok). Outras nulas contam como 0.
Decimal percentualTotal(FaixaTaxa f) =>
    f.taxaPercentual + (f.taxaOutras ?? zero);

/// Taxa cobrada pela plataforma em [preco]:
/// `taxaFixa * itensTaxaFixa + preco * (taxaPercentual + taxaOutras) / 100`.
Decimal taxa(
  List<FaixaTaxa> faixas,
  Decimal preco, {
  int itensTaxaFixa = 1,
}) {
  final f = faixa(faixas, preco);
  final fixa = f.taxaFixa * Decimal.fromInt(itensTaxaFixa);
  final percentual = (preco * percentualTotal(f)).dividir(cem);
  return fixa + percentual;
}

/// Preço mínimo que não dá prejuízo para um [custo] (design.md §6.2).
///
/// Para cada faixa `f` resolve `p = (custo + f.fixo) / (1 - f.pct/100)`,
/// válido se `p > limite da faixa anterior` e `(f.ate == null || p <= f.ate)`.
/// Retorna o menor válido; se nenhum, a fórmula com a primeira faixa.
Decimal precoMinimo(List<FaixaTaxa> faixas, Decimal custo) {
  final ordenadas = ordenarFaixas(faixas);
  final candidatos = <Decimal>[];
  var limiteAnterior = zero;
  for (final f in ordenadas) {
    final divisor = Decimal.one - percentualTotal(f).dividir(cem);
    final p = (custo + f.taxaFixa).dividir(divisor);
    final dentroLimite = f.precoAte == null || p <= f.precoAte!;
    if (p > limiteAnterior && dentroLimite) candidatos.add(p);
    if (f.precoAte != null) limiteAnterior = f.precoAte!;
  }
  if (candidatos.isEmpty) {
    final primeira = ordenadas.first;
    final divisor = Decimal.one - percentualTotal(primeira).dividir(cem);
    return (custo + primeira.taxaFixa).dividir(divisor);
  }
  return candidatos.reduce((a, b) => a < b ? a : b);
}

/// Preço (cliente paga) para atingir [margemAlvo] (em pontos) sobre o líquido
/// de um [custo] (design.md §6.2).
///
/// `liquidoNecessario = custo / (1 - m)`, `m = margemAlvo/100`; para cada
/// faixa `M = (liquidoNecessario + f.fixo) / (1 - f.pct/100)`, mesma validação
/// do [precoMinimo]; retorna o menor válido.
Decimal precoParaMargem(
  List<FaixaTaxa> faixas,
  Decimal custo,
  Decimal margemAlvo,
) {
  final ordenadas = ordenarFaixas(faixas);
  final m = margemAlvo.dividir(cem);
  final liquidoNecessario = custo.dividir(Decimal.one - m);
  final candidatos = <Decimal>[];
  var limiteAnterior = zero;
  for (final f in ordenadas) {
    final divisor = Decimal.one - percentualTotal(f).dividir(cem);
    final grande = (liquidoNecessario + f.taxaFixa).dividir(divisor);
    final dentroLimite = f.precoAte == null || grande <= f.precoAte!;
    if (grande > limiteAnterior && dentroLimite) candidatos.add(grande);
    if (f.precoAte != null) limiteAnterior = f.precoAte!;
  }
  if (candidatos.isEmpty) {
    final primeira = ordenadas.first;
    final divisor = Decimal.one - percentualTotal(primeira).dividir(cem);
    return (liquidoNecessario + primeira.taxaFixa).dividir(divisor);
  }
  return candidatos.reduce((a, b) => a < b ? a : b);
}
