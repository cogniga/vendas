import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales/domain/calculos/taxas.dart';

import 'plataformas_vetores.dart';
import 'tolerancia.dart';

void main() {
  group('faixa (design.md §6.1)', () {
    test('Shopee escolhe a faixa pelo preço', () {
      final faixas = faixasShopee();
      expect(faixa(faixas, Decimal.parse('23.49')).taxaFixa,
          Decimal.parse('4'));
      expect(faixa(faixas, Decimal.parse('85.00')).taxaFixa,
          Decimal.parse('16'));
      expect(faixa(faixas, Decimal.parse('250.00')).taxaFixa,
          Decimal.parse('26'));
    });

    test('faixa sem limite fica por último na ordenação', () {
      expect(faixa(faixasVendaDireta(), Decimal.parse('999')).taxaPercentual,
          Decimal.zero);
    });
  });

  group('taxa (design.md §6.1)', () {
    test('Shopee M=23,49 → 8,70', () {
      esperaValor(taxa(faixasShopee(), Decimal.parse('23.49')), '8.70');
    });

    test('itensTaxaFixa multiplica a parte fixa', () {
      // 2 × 4,00 + 23,49 × 20% = 8,00 + 4,698 = 12,698
      esperaValor(
        taxa(faixasShopee(), Decimal.parse('23.49'), itensTaxaFixa: 2),
        '12.698',
      );
    });
  });

  group('precoMinimo / precoParaMargem (design.md §6.2/§6.3)', () {
    // Investimento do Batom Bolsinha = 13,28; margem alvo 30%; desc 1; cupom 2.
    final custo = Decimal.parse('13.28');
    final margem = Decimal.parse('30');
    final extras = Decimal.parse('3'); // desconto 1 + cupom 2

    test('mínimos do Batom por plataforma', () {
      esperaValor(precoMinimo(faixasShopee(), custo), '21.60');
      esperaValor(precoMinimo(faixasTikTok(), custo), '19.64');
      esperaValor(precoMinimo(faixasMercadoLivre(), custo), '22.71');
      esperaValor(precoMinimo(faixasVendaDireta(), custo), '13.28');
    });

    test('sugeridos do Batom (30%) por plataforma', () {
      esperaValor(
        precoParaMargem(faixasShopee(), custo, margem) + extras,
        '31.71',
      );
      esperaValor(
        precoParaMargem(faixasTikTok(), custo, margem) + extras,
        '29.10',
      );
      esperaValor(
        precoParaMargem(faixasMercadoLivre(), custo, margem) + extras,
        '32.33',
      );
      esperaValor(
        precoParaMargem(faixasVendaDireta(), custo, margem) + extras,
        '21.97',
      );
    });
  });
}
