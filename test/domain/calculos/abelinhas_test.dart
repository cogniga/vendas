import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales/domain/calculos/abelinhas.dart';

import '../seed_helper.dart';
import 'tolerancia.dart';

void main() {
  late Seed seed;

  setUpAll(() {
    seed = Seed.carregar();
  });

  group('análise geral (design.md §6.6)', () {
    test('v = 10,00: ROI médio 86,5%, 99 com lucro, mínima 10,00', () {
      final geral = analiseGeral(
        seed.produtos(),
        seed.faixasAbelinha(),
        Decimal.fromInt(10),
      );
      esperaPct(geral.roiMedioGeral, '86.5');
      expect(geral.comLucro, 99);
      expect(geral.comPrejuizo, 0);
      esperaValor(geral.abelinhaMinimaSemPrejuizo, '10.00');
    });

    test('v = 8,00: ROI médio 49,2%, 9 com prejuízo', () {
      final geral = analiseGeral(
        seed.produtos(),
        seed.faixasAbelinha(),
        Decimal.fromInt(8),
      );
      esperaPct(geral.roiMedioGeral, '49.2');
      expect(geral.comPrejuizo, 9);
    });
  });

  group('análise por faixa (design.md §6.6, v = 10,00)', () {
    test('faixa até 5,00 e faixa 5,01 a 8,00', () {
      final faixas = analisePorFaixa(
        seed.produtos(),
        seed.faixasAbelinha(),
        Decimal.fromInt(10),
      );
      final ate5 = faixas.firstWhere(
        (f) => f.custoAte == Decimal.parse('5'),
      );
      expect(ate5.produtos, 38);
      esperaPct(ate5.roiMedio, '141.1');
      esperaPct(ate5.roiNoLimite, '0.0');
      expect(ate5.situacao, 'Empata no teto');

      final ate8 = faixas.firstWhere(
        (f) => f.custoAte == Decimal.parse('8'),
      );
      expect(ate8.produtos, 40);
      esperaPct(ate8.roiMedio, '56.7');
      esperaPct(ate8.roiNoLimite, '25.0');
    });
  });

  group('aviso de ajuste manual (design.md §6.7)', () {
    test('Gloss Playboy: regra 1, manual 0,5, v 10 → vermelho', () {
      final aviso = avisoAjusteManual(
        regra: Decimal.one,
        manual: Decimal.parse('0.5'),
        custo: Decimal.parse('6.45'),
        v: Decimal.fromInt(10),
      );
      expect(aviso.cor, 'vermelho');
      esperaValor(aviso.lucroManual, '-1.45');
      esperaPct(aviso.roiRegra, '55.0');
      esperaPct(aviso.roiManual, '-22.5');
      esperaValor(aviso.minimo, '1');
    });
  });
}
