import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sales/domain/calculos/produto_venda.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/domain/entidades/produto_venda.dart';
import 'package:sales/domain/entidades/produto_venda_item.dart';

import 'plataformas_vetores.dart';
import 'tolerancia.dart';

const _empresa = '00000000-0000-0000-0000-0000000000aa';

Produto _produto(String id, String custo) => Produto(
  id: id,
  empresaId: _empresa,
  codigo: id,
  nome: id,
  custo: Decimal.parse(custo),
);

Plataforma _plataforma(String id) =>
    Plataforma(id: id, empresaId: _empresa, nome: id);

ProdutoVendaItem _item(String kitId, String produtoId, int qtd) =>
    ProdutoVendaItem(
      id: '$kitId-$produtoId',
      empresaId: _empresa,
      produtoVendaId: kitId,
      produtoId: produtoId,
      quantidade: qtd,
    );

// Faixa de abelinha simples: cobre os custos dos vetores.
List<FaixaAbelinha> _faixasAbelinha() => [
  FaixaAbelinha(
    id: 'f1',
    empresaId: _empresa,
    custoAte: Decimal.parse('5'),
    abelinhas: Decimal.parse('0.5'),
  ),
  FaixaAbelinha(
    id: 'f2',
    empresaId: _empresa,
    custoAte: Decimal.parse('8'),
    abelinhas: Decimal.parse('1'),
  ),
  FaixaAbelinha(
    id: 'f3',
    empresaId: _empresa,
    custoAte: Decimal.parse('12'),
    abelinhas: Decimal.parse('1.5'),
  ),
];

ProdutoVenda _kit({
  required String id,
  required String preco,
  required String desconto,
  required String cupom,
  required String embalagem,
  required String impressao,
  required List<ProdutoVendaItem> itens,
  String metaLucro = '200',
  String fatiaRoas = '0.3',
}) => ProdutoVenda(
  id: id,
  empresaId: _empresa,
  nome: id,
  embalagem: Decimal.parse(embalagem),
  impressao: Decimal.parse(impressao),
  outros: Decimal.zero,
  preco: Decimal.parse(preco),
  desconto: Decimal.parse(desconto),
  cupom: Decimal.parse(cupom),
  metaLucro: Decimal.parse(metaLucro),
  fatiaRoas: Decimal.parse(fatiaRoas),
  margemAlvo: Decimal.parse('30'),
  itens: itens,
);

void main() {
  final faixasAbelinha = _faixasAbelinha();

  group('Batom Bolsinha nas 4 plataformas (design.md §6.3)', () {
    final batom = _produto('BATOM', '11.38');
    final produtos = {'BATOM': batom};
    final kit = _kit(
      id: 'batom',
      preco: '26.49',
      desconto: '1',
      cupom: '2',
      embalagem: '0.90',
      impressao: '1.00',
      itens: [_item('batom', 'BATOM', 1)],
    );

    void verifica(
      String nome,
      List<FaixaTaxa> faixas,
      String taxaEsp,
      String liquidoEsp,
      String lucroEsp,
      String margemPctEsp,
      int metaQtdEsp, {
      int vendidosIniciais = 0,
    }) {
      final r = calcularKit(
        kit,
        produtos,
        _plataforma('pl'),
        faixas,
        faixasAbelinha,
        vendidosIniciais: vendidosIniciais,
      );
      esperaValor(r.investimento, '13.28');
      esperaValor(r.clientePaga, '23.49');
      esperaValor(r.taxa, taxaEsp);
      esperaValor(r.liquido, liquidoEsp);
      esperaValor(r.lucro, lucroEsp);
      esperaPct(r.margem, margemPctEsp);
      expect(r.metaQtd, metaQtdEsp, reason: '$nome metaQtd');
    }

    test('Shopee', () {
      verifica('Shopee', faixasShopee(), '8.70', '14.79', '1.51', '10.2',
          133, vendidosIniciais: 13);
    });
    test('TikTok Shop', () {
      verifica('TikTok', faixasTikTok(), '6.82', '16.67', '3.39', '20.3', 59);
    });
    test('Mercado Livre', () {
      verifica('ML', faixasMercadoLivre(), '9.54', '13.95', '0.67', '4.8',
          299);
    });
    test('Venda direta', () {
      verifica('VD', faixasVendaDireta(), '0.00', '23.49', '10.21', '43.5',
          20);
    });

    test('ROAS alvo Batom/Shopee ≈ 51,8', () {
      final r = calcularKit(
        kit,
        produtos,
        _plataforma('pl'),
        faixasShopee(),
        faixasAbelinha,
      );
      esperaUmaCasa(r.roasAlvo, '51.8');
    });
  });

  test('Kit 5 Sachês Shopee (design.md §6.3)', () {
    final sacher = _produto('SACHER', '0.77');
    final kit = _kit(
      id: 'saches',
      preco: '19.99',
      desconto: '2',
      cupom: '1',
      embalagem: '0.90',
      impressao: '1.00',
      itens: [_item('saches', 'SACHER', 5)],
    );
    final r = calcularKit(
      kit,
      {'SACHER': sacher},
      _plataforma('pl'),
      faixasShopee(),
      faixasAbelinha,
    );
    esperaValor(r.investimento, '5.75');
    esperaValor(r.taxa, '7.40');
    esperaValor(r.liquido, '9.59');
    esperaValor(r.lucro, '3.84');
    esperaPct(r.margem, '40.1');
  });

  test('Kit Maquiagem Shopee (design.md §6.3)', () {
    final produtos = {
      'BASE': _produto('BASE', '8.97'),
      'GLOSS': _produto('GLOSS', '7.35'),
      'PO': _produto('PO', '3.71'),
    };
    final kit = _kit(
      id: 'maquiagem',
      preco: '59.90',
      desconto: '15',
      cupom: '0',
      embalagem: '0.90',
      impressao: '1.00',
      itens: [
        _item('maquiagem', 'BASE', 1),
        _item('maquiagem', 'GLOSS', 1),
        _item('maquiagem', 'PO', 1),
      ],
    );
    final r = calcularKit(
      kit,
      produtos,
      _plataforma('pl'),
      faixasShopee(),
      faixasAbelinha,
    );
    esperaValor(r.investimento, '21.93');
    esperaValor(r.taxa, '12.98');
    esperaValor(r.liquido, '31.92');
    esperaValor(r.lucro, '9.99');
    esperaPct(r.margem, '31.3');
    expect(r.metaQtd, 21);
  });
}
