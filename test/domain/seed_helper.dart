import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/domain/entidades/produto.dart';

/// Carrega `assets/seed/dados-iniciais.json` para os vetores §6.6 (99 produtos
/// reais) e demais testes de domínio. Lê via `File` (teste roda a partir da
/// raiz do pacote) e resolve as referências textuais em UUIDs sintéticos.
class Seed {
  Seed._(this._raiz);

  /// Lê e decodifica o seed do disco.
  factory Seed.carregar() {
    final texto = File('assets/seed/dados-iniciais.json').readAsStringSync();
    final raiz = json.decode(texto) as Map<String, dynamic>;
    return Seed._(raiz);
  }

  final Map<String, dynamic> _raiz;

  static const _empresaId = '00000000-0000-0000-0000-0000000000aa';

  /// Produtos do seed como entidades [Produto] (id derivado do código).
  List<Produto> produtos() {
    final lista = _raiz['produtos'] as List;
    return lista.map((bruto) {
      final mapa = Map<String, dynamic>.from(bruto as Map);
      final codigo = mapa['codigo'] as String;
      return Produto.fromJson(<String, dynamic>{
        'id': 'produto-$codigo',
        'empresa_id': _empresaId,
        ...mapa,
      });
    }).toList();
  }

  /// Faixas de abelinha do seed como entidades [FaixaAbelinha].
  List<FaixaAbelinha> faixasAbelinha() {
    final lista = _raiz['faixas_abelinha'] as List;
    var i = 0;
    return lista.map((bruto) {
      final mapa = Map<String, dynamic>.from(bruto as Map);
      i++;
      return FaixaAbelinha.fromJson(<String, dynamic>{
        'id': 'faixa-ab-$i',
        'empresa_id': _empresaId,
        ...mapa,
      });
    }).toList();
  }

  /// Valor de 1 abelinha definido nas configurações do seed.
  Decimal valorAbelinha() {
    final cfg = _raiz['configuracoes'] as Map;
    return const _DecimalLeitor().ler(cfg['valor_abelinha']);
  }
}

/// Converte número/`String` do JSON do seed em [Decimal] sem passar por
/// `double`.
class _DecimalLeitor {
  const _DecimalLeitor();

  Decimal ler(Object? valor) {
    if (valor is String) return Decimal.parse(valor);
    if (valor is int) return Decimal.fromInt(valor);
    if (valor is num) return Decimal.parse(valor.toString());
    throw ArgumentError.value(valor, 'valor', 'numérico inválido');
  }
}
