import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sales/core/format/formatos.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  group('Formatos.moeda', () {
    test('formata no padrão brasileiro', () {
      // O locale pt_BR usa espaço não separável (U+00A0) após o símbolo.
      final texto = Formatos.moeda(1234.56).replaceAll('\u00A0', ' ');
      expect(texto, r'R$ 1.234,56');
    });
  });

  group('Formatos.percentual', () {
    test('uma casa decimal com símbolo', () {
      expect(Formatos.percentual(10.2), '10,2%');
    });
  });

  group('Formatos.abelinhas', () {
    test('inteiro sem casas decimais', () {
      expect(Formatos.abelinhas(1), '1 🐝');
    });

    test('meia abelinha', () {
      expect(Formatos.abelinhas(1.5), '1,5 🐝');
    });
  });

  group('Formatos.parseNumero', () {
    test('aceita vírgula decimal', () {
      expect(Formatos.parseNumero('1.234,56'), 1234.56);
    });

    test('aceita vírgula simples', () {
      expect(Formatos.parseNumero('12,5'), 12.5);
    });

    test('texto vazio retorna null', () {
      expect(Formatos.parseNumero('  '), isNull);
    });
  });
}
