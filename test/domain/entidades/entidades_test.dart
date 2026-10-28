import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales/domain/entidades/conversores.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/domain/entidades/produto_venda.dart';

void main() {
  group('DecimalConverter', () {
    const conv = DecimalConverter();

    test('aceita String preservando precisão', () {
      expect(conv.fromJson('12.50'), Decimal.parse('12.50'));
    });

    test('aceita num', () {
      expect(conv.fromJson(12.5), Decimal.parse('12.5'));
    });

    test('aceita int', () {
      expect(conv.fromJson(0), Decimal.fromInt(0));
    });

    test('toJson grava String', () {
      expect(conv.toJson(Decimal.parse('26.49')), '26.49');
    });
  });

  group('DecimalNullableConverter', () {
    const conv = DecimalNullableConverter();

    test('null → null nos dois sentidos', () {
      expect(conv.fromJson(null), isNull);
      expect(conv.toJson(null), isNull);
    });

    test('valor não nulo delega ao DecimalConverter', () {
      expect(conv.fromJson('1.50'), Decimal.parse('1.50'));
      // Decimal normaliza zeros à direita; o valor é o que importa.
      expect(conv.toJson(Decimal.parse('1.50')), '1.5');
    });
  });

  group('Produto round-trip (seed)', () {
    late Map<String, dynamic> seed;

    setUpAll(() {
      final texto = File('assets/seed/dados-iniciais.json').readAsStringSync();
      seed = json.decode(texto) as Map<String, dynamic>;
    });

    test('fromJson com numeric como num', () {
      final bruto = (seed['produtos'] as List).first as Map<String, dynamic>;
      final payload = <String, dynamic>{
        'id': '00000000-0000-0000-0000-000000000001',
        'empresa_id': '00000000-0000-0000-0000-0000000000aa',
        ...bruto,
      };

      final produto = Produto.fromJson(payload);

      expect(produto.codigo, 'SACHEB');
      // custo veio como num (0.75) no seed.
      expect(produto.custo, Decimal.parse('0.75'));
      expect(produto.abelinhasManual, isNull);

      // Round-trip: toJson grava Decimal como String; fromJson recupera igual.
      final novo = Produto.fromJson(produto.toJson());
      expect(novo, produto);
      expect(novo.custo, Decimal.parse('0.75'));
    });

    test('fromJson com numeric como String (PostgREST)', () {
      final payload = <String, dynamic>{
        'id': '00000000-0000-0000-0000-000000000001',
        'empresa_id': '00000000-0000-0000-0000-0000000000aa',
        'codigo': 'BATOM',
        'nome': 'Batom',
        'custo': '3.50',
        'abelinhas_manual': '1.50',
      };

      final produto = Produto.fromJson(payload);

      expect(produto.custo, Decimal.parse('3.50'));
      expect(produto.abelinhasManual, Decimal.parse('1.50'));
      expect(Produto.fromJson(produto.toJson()), produto);
    });
  });

  group('ProdutoVenda round-trip (seed)', () {
    late Map<String, dynamic> seed;

    setUpAll(() {
      final texto = File('assets/seed/dados-iniciais.json').readAsStringSync();
      seed = json.decode(texto) as Map<String, dynamic>;
    });

    test('preserva Decimal e fatiaRoas', () {
      final bruto =
          (seed['produtos_venda'] as List).first as Map<String, dynamic>;
      final payload = <String, dynamic>{
        'id': '00000000-0000-0000-0000-000000000010',
        'empresa_id': '00000000-0000-0000-0000-0000000000aa',
        ...bruto,
      }..removeWhere(
          (chave, _) => chave == 'itens' || chave == 'precos_plataforma',
        );

      final pv = ProdutoVenda.fromJson(payload);

      expect(pv.nome, 'Batom Bolsinha');
      expect(pv.preco, Decimal.parse('26.49'));
      expect(pv.fatiaRoas, Decimal.parse('0.3'));
      expect(pv.precoConcorrente, isNull);
      // itens/precosPorPlataforma ficam fora do payload da linha.
      expect(pv.itens, isEmpty);
      expect(pv.precosPorPlataforma, isEmpty);

      expect(ProdutoVenda.fromJson(pv.toJson()), pv);
    });
  });
}
