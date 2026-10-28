import 'package:decimal/decimal.dart';
import 'package:sales/domain/calculos/decimais.dart';
import 'package:sales/domain/entidades/compra_insumo.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:sales/domain/entidades/investimento.dart';
import 'package:sales/domain/entidades/retirada.dart';
import 'package:sales/domain/entidades/saque.dart';
import 'package:sales/domain/entidades/saque_rateio.dart';

/// Cálculos de caixa: rateio de saques e saldo por destino (design.md §6.8).
///
/// Funções puras (dart + decimal + entidades).

/// Rateio de um [saque] entre [destinos]: para cada destino,
/// `valor * percentual / 100` (design.md §6.8).
List<SaqueRateio> rateio(Saque saque, List<Destino> destinos) {
  return destinos
      .map(
        (d) => SaqueRateio(
          saqueId: saque.id,
          empresaId: saque.empresaId,
          destinoId: d.id,
          percentual: d.percentual,
          valor: (saque.valor * d.percentual).dividir(cem),
        ),
      )
      .toList();
}

/// Saldo de um destino do caixa (design.md §6.8).
class SaldoDestino {
  const SaldoDestino({
    required this.destinoId,
    required this.entradas,
    required this.saidas,
    required this.saldo,
  });

  /// Destino avaliado.
  final String destinoId;

  /// Soma dos rateios de saque com este destino.
  final Decimal entradas;

  /// Soma de investimentos, compras de insumo e retiradas com este destino.
  final Decimal saidas;

  /// `entradas - saidas`.
  final Decimal saldo;
}

/// Entradas de um destino: soma dos rateios de todos os [saques].
Decimal entradasDestino(String destinoId, List<Saque> saques) {
  var total = zero;
  for (final saque in saques) {
    for (final r in saque.rateio) {
      if (r.destinoId == destinoId) total += r.valor;
    }
  }
  return total;
}

/// Saídas de um destino: investimentos + compras de insumo + retiradas.
Decimal saidasDestino(
  String destinoId, {
  List<Investimento> investimentos = const [],
  List<CompraInsumo> comprasInsumo = const [],
  List<Retirada> retiradas = const [],
}) {
  var total = zero;
  for (final i in investimentos) {
    if (i.destinoId == destinoId) total += i.valor;
  }
  for (final c in comprasInsumo) {
    if (c.destinoId == destinoId) total += c.valorTotal;
  }
  for (final r in retiradas) {
    if (r.destinoId == destinoId) total += r.valor;
  }
  return total;
}

/// Saldo de um destino (entradas − saídas).
SaldoDestino saldoDestino(
  String destinoId, {
  List<Saque> saques = const [],
  List<Investimento> investimentos = const [],
  List<CompraInsumo> comprasInsumo = const [],
  List<Retirada> retiradas = const [],
}) {
  final entradas = entradasDestino(destinoId, saques);
  final saidas = saidasDestino(
    destinoId,
    investimentos: investimentos,
    comprasInsumo: comprasInsumo,
    retiradas: retiradas,
  );
  return SaldoDestino(
    destinoId: destinoId,
    entradas: entradas,
    saidas: saidas,
    saldo: entradas - saidas,
  );
}

/// Saldo total do caixa: soma dos saldos de todos os [destinos].
Decimal saldoTotal(
  List<Destino> destinos, {
  List<Saque> saques = const [],
  List<Investimento> investimentos = const [],
  List<CompraInsumo> comprasInsumo = const [],
  List<Retirada> retiradas = const [],
}) {
  var total = zero;
  for (final d in destinos) {
    total += saldoDestino(
      d.id,
      saques: saques,
      investimentos: investimentos,
      comprasInsumo: comprasInsumo,
      retiradas: retiradas,
    ).saldo;
  }
  return total;
}
