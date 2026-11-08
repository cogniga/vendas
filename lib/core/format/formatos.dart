import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

/// Formatadores de exibição no padrão brasileiro (design.md, tech.md).
///
/// Dinheiro `R$ 1.234,56`, percentual `10,2%`, data `dd/MM/yyyy`, abelinhas
/// `1,5 🐝`. Inclui parser de número que aceita vírgula decimal.
class Formatos {
  const Formatos._();

  static final NumberFormat _moeda =
      NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
  static final NumberFormat _numero2 =
      NumberFormat('#,##0.00', 'pt_BR');
  static final NumberFormat _numeroCurto =
      NumberFormat('#,##0.##', 'pt_BR');
  static final NumberFormat _percent1 =
      NumberFormat('#,##0.0', 'pt_BR');
  static final DateFormat _data = DateFormat('dd/MM/yyyy', 'pt_BR');

  /// `R$ 1.234,56`.
  static String moeda(num valor) => _moeda.format(valor);

  /// Formata um [Decimal] como moeda.
  static String moedaDecimal(Decimal valor) => _moeda.format(valor.toDouble());

  /// `10,2%` — recebe pontos percentuais (ex.: 10.2 → "10,2%").
  static String percentual(num pontos) => '${_percent1.format(pontos)}%';

  /// Recebe uma fração (ex.: 0.102) e devolve `10,2%`.
  static String percentualFracao(num fracao) => percentual(fracao * 100);

  /// `dd/MM/yyyy`.
  static String data(DateTime d) => _data.format(d);

  /// `1,5 🐝` — remove casas decimais desnecessárias (1 → "1 🐝").
  static String abelinhas(num qtd) {
    final texto = qtd == qtd.roundToDouble()
        ? qtd.toStringAsFixed(0)
        : _numero2.format(qtd).replaceAll(RegExp(r'0+$'), '').replaceAll(
              RegExp(r',$'),
              '',
            );
    return '$texto 🐝';
  }

  /// Número com 2 casas no padrão brasileiro, sem símbolo (valores em R$).
  static String numero(num valor) => _numero2.format(valor);

  /// Número com até 2 casas, sem zeros desnecessários: 10 → "10",
  /// 12.5 → "12,5", 33.33 → "33,33". Usado em percentuais e quantidades.
  static String numeroCurto(num valor) => _numeroCurto.format(valor);

  /// Percentual digitado/configurado em pontos (20 = 20%): "20%", "12,5%".
  static String pontos(num valor) => '${numeroCurto(valor)}%';

  /// Converte texto digitado (com vírgula ou ponto) em [double].
  ///
  /// Remove separador de milhar e aceita vírgula como decimal. Retorna `null`
  /// se o texto não representar um número.
  static double? parseNumero(String texto) {
    final normalizado = _normalizar(texto);
    return normalizado == null ? null : double.tryParse(normalizado);
  }

  /// Normaliza o texto digitado para o formato `1234.56` (ou `null`).
  static String? _normalizar(String texto) {
    final limpo = texto.trim();
    if (limpo.isEmpty) return null;
    // Remove tudo que não for dígito, vírgula, ponto ou sinal.
    var normalizado = limpo.replaceAll(RegExp(r'[^0-9,.\-]'), '');
    final temVirgula = normalizado.contains(',');
    final temPonto = normalizado.contains('.');
    if (temVirgula && temPonto) {
      // Ponto é milhar, vírgula é decimal: "1.234,56".
      normalizado = normalizado.replaceAll('.', '').replaceAll(',', '.');
    } else if (temVirgula) {
      normalizado = normalizado.replaceAll(',', '.');
    }
    return normalizado.isEmpty ? null : normalizado;
  }

  /// Converte texto digitado em [Decimal], ou `null` se inválido.
  ///
  /// Não passa por `double`: evita perda de precisão e exceções com números
  /// longos (ex.: "1e+21").
  static Decimal? parseDecimal(String texto) {
    final normalizado = _normalizar(texto);
    return normalizado == null ? null : Decimal.tryParse(normalizado);
  }
}
