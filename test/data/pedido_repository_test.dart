import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sales/data/repositorios/pedido_repository.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/pedido_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Linhas devolvidas pelo "banco" falso, por tabela.
Map<String, dynamic> _pedido(String id, String cliente) => {
      'id': id,
      'empresa_id': 'e1',
      'data': '2024-05-10T00:00:00.000',
      'cliente': cliente,
      'plataforma_id': 'pl1',
      'embalagem': '0',
      'impressao': '0',
      'outros': '0',
      'preco_venda': '100',
      'itens_taxa_fixa': 1,
      'liquido_informado': null,
      'situacao': 'concluido',
      'obs': '',
    };

Map<String, dynamic> _item(
  String id,
  String pedidoId, {
  String? produtoId,
  String? kitId,
  int qtd = 1,
}) =>
    {
      'id': id,
      'empresa_id': 'e1',
      'pedido_id': pedidoId,
      'tipo': kitId == null ? 'produto' : 'produto_venda',
      'produto_id': produtoId,
      'produto_venda_id': kitId,
      'quantidade': qtd,
      'custo_unitario': '4',
      'abelinhas_unitarias': '1',
    };

class _Banco {
  final pedidos = <Map<String, dynamic>>[];
  final itens = <Map<String, dynamic>>[];
  final requisicoes = <http.Request>[];
  final corposInseridos = <String, List<dynamic>>{};

  Future<http.Response> tratar(http.Request r) async {
    requisicoes.add(r);
    final tabela = r.url.pathSegments.last;
    const json = {'content-type': 'application/json; charset=utf-8'};
    switch (r.method) {
      case 'GET':
        final lista = tabela == 'pedidos' ? pedidos : itens;
        return http.Response(jsonEncode(lista), 200, headers: json, request: r);
      case 'POST':
        final corpo = jsonDecode(r.body);
        corposInseridos[tabela] = corpo is List ? corpo : [corpo];
        if (tabela == 'pedidos') {
          final linha = Map<String, dynamic>.from(corpo as Map);
          linha['id'] ??= 'novo';
          pedidos
            ..clear()
            ..add(linha);
          return http.Response(
            jsonEncode(linha),
            201,
            headers: json,
            request: r,
          );
        }
        itens
          ..clear()
          ..addAll([
            for (final (i, l) in (corpo as List).indexed)
              {...(l as Map<String, dynamic>), 'id': 'it$i'},
          ]);
        return http.Response('', 201, headers: json, request: r);
      default:
        if (tabela == 'pedidos_itens') itens.clear();
        return http.Response('', 204, request: r);
    }
  }
}

PedidoRepository _repo(_Banco banco) {
  final client = SupabaseClient(
    'http://localhost:54321',
    'anon',
    httpClient: MockClient(banco.tratar),
    authOptions: const AuthClientOptions(autoRefreshToken: false),
  );
  return PedidoRepository(client);
}

void main() {
  group('PedidoRepository.listar', () {
    test('devolve cada pedido com seus itens agrupados por pedido_id',
        () async {
      final banco = _Banco()
        ..pedidos.addAll([_pedido('a', 'A'), _pedido('b', 'B')])
        ..itens.addAll([
          _item('i1', 'a', produtoId: 'p1', qtd: 2),
          _item('i2', 'b', kitId: 'k1'),
          _item('i3', 'a', produtoId: 'p2'),
        ]);

      final lista = await _repo(banco).listar('e1');

      expect(lista, hasLength(2));
      final a = lista.firstWhere((p) => p.id == 'a');
      final b = lista.firstWhere((p) => p.id == 'b');
      expect(a.itens.map((i) => i.id), unorderedEquals(['i1', 'i3']));
      expect(a.itens.first.quantidade, 2);
      expect(b.itens.single.tipo, TipoPedidoItem.produtoVenda);
      expect(b.itens.single.produtoVendaId, 'k1');
    });

    test('pedido sem itens vem com lista vazia', () async {
      final banco = _Banco()..pedidos.add(_pedido('a', 'A'));

      final lista = await _repo(banco).listar('e1');

      expect(lista.single.itens, isEmpty);
    });
  });

  group('PedidoRepository.salvar', () {
    test('insere pedidos_itens com tipo e colunas certos para produto e kit',
        () async {
      final banco = _Banco();
      final pedido = Pedido(
        id: '',
        empresaId: 'e1',
        data: DateTime(2024, 5, 10),
        cliente: 'X',
        plataformaId: 'pl1',
        embalagem: Decimal.zero,
        impressao: Decimal.zero,
        outros: Decimal.zero,
        precoVenda: Decimal.fromInt(100),
        itens: [
          PedidoItem(
            id: '',
            empresaId: 'e1',
            pedidoId: '',
            tipo: TipoPedidoItem.produto,
            quantidade: 3,
            custoUnitario: Decimal.fromInt(4),
            abelinhasUnitarias: Decimal.one,
            produtoId: 'p1',
          ),
          PedidoItem(
            id: '',
            empresaId: 'e1',
            pedidoId: '',
            tipo: TipoPedidoItem.produtoVenda,
            quantidade: 1,
            custoUnitario: Decimal.fromInt(20),
            abelinhasUnitarias: Decimal.fromInt(5),
            produtoVendaId: 'k1',
          ),
        ],
      );

      final salvo = await _repo(banco).salvar(pedido);

      final inseridos = banco.corposInseridos['pedidos_itens']!;
      expect(inseridos, hasLength(2));
      final produto = inseridos[0] as Map<String, dynamic>;
      expect(produto['tipo'], 'produto');
      expect(produto['produto_id'], 'p1');
      expect(produto['produto_venda_id'], isNull);
      expect(produto['quantidade'], 3);
      expect(produto['pedido_id'], 'novo');
      expect(produto['empresa_id'], 'e1');
      final kit = inseridos[1] as Map<String, dynamic>;
      expect(kit['tipo'], 'produto_venda');
      expect(kit['produto_venda_id'], 'k1');
      expect(kit['produto_id'], isNull);
      expect(kit['custo_unitario'], '20');
      expect(salvo.itens, hasLength(2));
    });
  });
}
