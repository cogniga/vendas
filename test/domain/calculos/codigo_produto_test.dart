import 'package:flutter_test/flutter_test.dart';
import 'package:sales/domain/calculos/codigo_produto.dart';

void main() {
  group('baseCodigoProduto', () {
    test('3 letras de até 3 palavras, em maiúsculas', () {
      expect(baseCodigoProduto('Batom Matte Vermelho'), 'BAT-MAT-VER');
    });

    test('remove acentos e ignora conectivos', () {
      expect(baseCodigoProduto('Sachê de Máscara Capilar'), 'SAC-MAS-CAP');
      expect(baseCodigoProduto('Kit p/ Unhas'), 'KIT-UNH');
    });

    test('palavra com número entra inteira (até 5)', () {
      expect(baseCodigoProduto('Gloss Playboy 50ml'), 'GLO-PLA-50ML');
    });

    test('nome vazio ou só símbolos gera vazio', () {
      expect(baseCodigoProduto('   '), '');
      expect(baseCodigoProduto('---'), '');
    });
  });

  group('gerarCodigoProduto', () {
    test('sem conflito devolve a base', () {
      expect(gerarCodigoProduto('Batom Matte', ['GLO-PLA']), 'BAT-MAT');
    });

    test('com conflito acrescenta sufixo sequencial', () {
      expect(
        gerarCodigoProduto('Batom Matte', ['BAT-MAT', 'bat-mat-2']),
        'BAT-MAT-3',
      );
    });

    test('nome vazio devolve vazio', () {
      expect(gerarCodigoProduto('', ['X']), '');
    });
  });
}
