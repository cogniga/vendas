import 'package:flutter_test/flutter_test.dart';
import 'package:sales/core/format/ordenacao.dart';

void main() {
  test('ignora maiúsculas e acentos', () {
    final nomes = ['Zinco', 'BATOM', 'água micelar', 'algodão', 'Base'];
    expect(
      ordenarAlfabetico(nomes, (n) => n),
      ['água micelar', 'algodão', 'Base', 'BATOM', 'Zinco'],
    );
  });

  test('números em ordem natural', () {
    expect(
      ordenarAlfabetico(['Kit 10', 'Kit 2', 'Kit 1'], (n) => n),
      ['Kit 1', 'Kit 2', 'Kit 10'],
    );
  });

  test('espaços extras não mudam a ordem', () {
    expect(compararAlfabetico('  batom   matte', 'Batom Matte') != 0, isTrue);
    expect(chaveAlfabetica('  Batom   Mátte '), 'batom matte');
  });
}
