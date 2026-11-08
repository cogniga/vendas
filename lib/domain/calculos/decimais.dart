import 'package:decimal/decimal.dart';

/// Utilidades de [Decimal] para os cálculos puros do domínio.
///
/// Divisão em `package:decimal` devolve um `Rational`; aqui convertemos de
/// volta a [Decimal] com uma escala interna ampla (sem perda relevante) e só
/// arredondamos na exibição, conforme design.md §6.
extension CalculoDecimal on Decimal {
  /// Divide preservando precisão (escala interna de 20 casas quando a divisão
  /// não é exata). Usado nos cálculos de margem, ROI etc.
  ///
  /// Divisão por zero devolve zero (em vez de lançar), para que dados
  /// transitórios ou incompletos — como uma faixa recém-editada com "Custo
  /// até" ou "Abelinhas" ainda em branco — nunca derrubem a tela.
  Decimal dividir(Decimal outro) {
    if (outro.compareTo(Decimal.zero) == 0) return Decimal.zero;
    return (this / outro).toDecimal(scaleOnInfinitePrecision: 20);
  }

  /// Arredonda para 2 casas (meio para cima), como na exibição em R$.
  Decimal arred2() => round(scale: 2);
}

/// Zero reutilizável.
final Decimal zero = Decimal.zero;

/// Cem reutilizável (base dos percentuais em pontos: 20 = 20%).
final Decimal cem = Decimal.fromInt(100);
