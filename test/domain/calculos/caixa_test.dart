import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales/domain/calculos/caixa.dart';
import 'package:sales/domain/entidades/compra_insumo.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:sales/domain/entidades/investimento.dart';
import 'package:sales/domain/entidades/saque.dart';

import 'tolerancia.dart';

const _empresa = '00000000-0000-0000-0000-0000000000aa';

Destino _destino(String id, String nome, String pct) => Destino(
  id: id,
  empresaId: _empresa,
  nome: nome,
  cor: '#000000',
  percentual: Decimal.parse(pct),
);

void main() {
  final cartao = _destino('d1', 'Cartão, empréstimos', '40');
  final compras = _destino('d2', 'Compras de produtos', '30');
  final prolabore = _destino('d3', 'Pró-labore', '30');
  final destinos = [cartao, compras, prolabore];

  final saque = Saque(
    id: 's1',
    empresaId: _empresa,
    data: DateTime(2026, 10, 16),
    plataformaId: 'tiktok',
    valor: Decimal.parse('3286.06'),
  );

  test('rateio 40/30/30 (design.md §6.8)', () {
    final linhas = rateio(saque, destinos);
    esperaValor(linhas[0].valor, '1314.42');
    esperaValor(linhas[1].valor, '985.82');
    esperaValor(linhas[2].valor, '985.82');
  });

  test('saldo de Compras de produtos = 729,64 (design.md §6.8)', () {
    final saqueComRateio = saque.copyWith(rateio: rateio(saque, destinos));
    final investimento = Investimento(
      id: 'inv1',
      empresaId: _empresa,
      data: DateTime(2026, 6, 8),
      distribuidor: 'Pérolas Make',
      valor: Decimal.parse('209.19'),
      destinoId: compras.id,
    );
    final compra = CompraInsumo(
      id: 'c1',
      empresaId: _empresa,
      data: DateTime(2026, 6, 13),
      produto: 'Caixa Papelão Correios',
      valorTotal: Decimal.parse('46.99'),
      destinoId: compras.id,
    );

    final saldo = saldoDestino(
      compras.id,
      saques: [saqueComRateio],
      investimentos: [investimento],
      comprasInsumo: [compra],
    );
    esperaValor(saldo.entradas, '985.82');
    esperaValor(saldo.saidas, '256.18');
    esperaValor(saldo.saldo, '729.64');

    final total = saldoTotal(
      destinos,
      saques: [saqueComRateio],
      investimentos: [investimento],
      comprasInsumo: [compra],
    );
    esperaValor(total, '3029.88');
  });
}
