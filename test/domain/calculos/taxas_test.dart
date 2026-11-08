import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales/domain/calculos/taxas.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';

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

    test('até 50 · 50,01 a 100 · acima de 100 (início calculado)', () {
      const d = Decimal.parse;
      // Ordem de edição bagunçada: a sem limite no meio.
      expect(iniciosDasFaixas([d('100'), null, d('50')]), [
        d('50.01'),
        d('100.01'),
        Decimal.zero,
      ]);
      expect(iniciosDasFaixas([null]), [Decimal.zero]);
      expect(iniciosDasFaixas([]), isEmpty);
    });

    test('outras taxas (frete TikTok) somam ao percentual', () {
      const d = Decimal.parse;
      final f = FaixaTaxa(
        id: 'f',
        empresaId: 'e',
        plataformaId: 'p',
        taxaFixa: d('4'),
        taxaPercentual: d('10'),
        taxaOutras: d('6'),
      );
      // 4 + 100 × (10% + 6%) = 20,00
      expect(taxa([f], d('100')), d('20'));
      // Sem outras (nulo) = só o percentual: 4 + 10 = 14,00
      expect(taxa([f.copyWith(taxaOutras: null)], d('100')), d('14'));
      // Preço mínimo para custo 12: (12 + 4) / (1 - 0,16) = 19,047…
      expect(precoMinimo([f], d('12')).round(scale: 2), d('19.05'));
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
