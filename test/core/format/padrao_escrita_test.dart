import 'package:flutter_test/flutter_test.dart';
import 'package:sales/core/format/padrao_escrita.dart';

void main() {
  group('PadraoEscrita.titulo', () {
    test('conectivos ficam minúsculos e demais palavras capitalizadas', () {
      expect(
        PadraoEscrita.titulo('CREME DE MÃOS para pele seca'),
        'Creme de Mãos para Pele Seca',
      );
    });

    test('mantém palavras com dígito', () {
      expect(
        PadraoEscrita.titulo('Po facial Banana 10g'),
        'Po Facial Banana 10g',
      );
    });

    test('preserva sigla e conector p/', () {
      expect(
        PadraoEscrita.titulo('MÁSCARA P/ CILIOS'),
        'Máscara p/ Cilios',
      );
    });

    test('primeira palavra conectivo é capitalizada', () {
      expect(PadraoEscrita.titulo('de olhos'), 'De Olhos');
    });
  });

  group('PadraoEscrita.maius', () {
    test('converte código para maiúsculo', () {
      expect(PadraoEscrita.maius('cr01'), 'CR01');
    });
  });

  group('PadraoEscrita.frase', () {
    test('apenas a primeira letra maiúscula', () {
      expect(
        PadraoEscrita.frase('produto de teste'),
        'Produto de teste',
      );
    });
  });
}
