import 'package:flutter_test/flutter_test.dart';
import 'package:sales/core/format/padrao_escrita.dart';

void main() {
  group('PadraoEscrita.nome (padrão da empresa)', () {
    const texto = '  batom MATTE de   vermelho ';
    test('título, maiúsculas e minúsculas', () {
      expect(PadraoEscrita.nome(texto, PadraoNome.titulo),
          'Batom Matte de Vermelho');
      expect(PadraoEscrita.nome(texto, PadraoNome.maiusculas),
          'BATOM MATTE DE VERMELHO');
      expect(PadraoEscrita.nome(texto, PadraoNome.minusculas),
          'batom matte de vermelho');
    });

    test('ao digitar preserva espaços e tamanho', () {
      for (final p in PadraoNome.values) {
        final r = PadraoEscrita.nomeAoDigitar('batom DE ', p);
        expect(r.length, 'batom DE '.length);
        expect(r.endsWith(' '), isTrue);
      }
      expect(PadraoEscrita.nomeAoDigitar('batom DE ', PadraoNome.titulo),
          'Batom de ');
    });

    test('valor do banco desconhecido vira título', () {
      expect(PadraoNome.doBanco('xyz'), PadraoNome.titulo);
      expect(PadraoNome.doBanco('maiusculas'), PadraoNome.maiusculas);
    });
  });

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
