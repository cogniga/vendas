import 'package:decimal/decimal.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';

/// Faixas de taxa das plataformas padrão (design.md §6.1), para os vetores §6.
/// `empresaId`/`plataformaId` são sintéticos; só as faixas importam no cálculo.
const _empresa = '00000000-0000-0000-0000-0000000000aa';

FaixaTaxa _faixa(
  String plataforma,
  String? precoAte,
  String fixa,
  String pct,
) {
  return FaixaTaxa(
    id: '$plataforma-${precoAte ?? 'inf'}',
    empresaId: _empresa,
    plataformaId: plataforma,
    taxaFixa: Decimal.parse(fixa),
    taxaPercentual: Decimal.parse(pct),
    precoAte: precoAte == null ? null : Decimal.parse(precoAte),
  );
}

/// Shopee: 79,99→4+20% · 99,99→16+14% · 199,99→20+14% · s/ limite→26+14%.
List<FaixaTaxa> faixasShopee() => [
  _faixa('shopee', '79.99', '4', '20'),
  _faixa('shopee', '99.99', '16', '14'),
  _faixa('shopee', '199.99', '20', '14'),
  _faixa('shopee', null, '26', '14'),
];

/// TikTok Shop: sem limite → 4 + 12%.
List<FaixaTaxa> faixasTikTok() => [_faixa('tiktok', null, '4', '12')];

/// Mercado Livre: 78,99 → 6,25 + 14% · sem limite → 0 + 14%.
List<FaixaTaxa> faixasMercadoLivre() => [
  _faixa('ml', '78.99', '6.25', '14'),
  _faixa('ml', null, '0', '14'),
];

/// Venda direta: sem limite → 0 + 0%.
List<FaixaTaxa> faixasVendaDireta() => [_faixa('vd', null, '0', '0')];
