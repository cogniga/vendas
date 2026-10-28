import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tolerância dos vetores do design.md §6.
const double tolerancia = 0.005;

/// Verifica que [valor] (Decimal) está a menos de [tolerancia] de [esperado].
void esperaValor(Decimal valor, String esperado) {
  final diff = (valor.toDouble() - Decimal.parse(esperado).toDouble()).abs();
  expect(
    diff < tolerancia,
    isTrue,
    reason: 'esperado $esperado, obtido ${valor.toDouble()}',
  );
}

/// Versão anulável de [esperaValor].
void esperaValorN(Decimal? valor, String esperado) {
  expect(valor, isNotNull, reason: 'esperava $esperado, veio null');
  esperaValor(valor!, esperado);
}

/// Tolerância dos percentuais/valores exibidos com 1 casa decimal: meia
/// unidade de exibição (0,05), para absorver o arredondamento de borda do
/// `intl` (ex.: 40,15% exibido como 40,1%).
const double toleranciaExibicao = 0.051;

/// Compara o percentual ([margem] em fração) com o valor exibido em pontos e
/// 1 casa decimal, como no design.md §6 (ex.: 0,102 → "10,2").
void esperaPct(Decimal margem, String esperadoEmPontos) {
  final pontos = margem.toDouble() * 100;
  final esperado = double.parse(esperadoEmPontos);
  expect(
    (pontos - esperado).abs() <= toleranciaExibicao,
    isTrue,
    reason: 'esperado $esperadoEmPontos%, obtido $pontos%',
  );
}

/// Compara [valor] exibido com 1 casa decimal com o esperado (ex.: ROAS).
void esperaUmaCasa(Decimal? valor, String esperado) {
  expect(valor, isNotNull, reason: 'esperava $esperado, veio null');
  final obtido = valor!.toDouble();
  expect(
    (obtido - double.parse(esperado)).abs() <= toleranciaExibicao,
    isTrue,
    reason: 'esperado $esperado, obtido $obtido',
  );
}
