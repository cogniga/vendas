import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sales/data/repositorios/compra_insumo_repository.dart';
import 'package:sales/data/repositorios/configuracoes_repository.dart';
import 'package:sales/data/repositorios/destino_repository.dart';
import 'package:sales/data/repositorios/faixa_abelinha_repository.dart';
import 'package:sales/data/repositorios/investimento_repository.dart';
import 'package:sales/data/repositorios/pedido_repository.dart';
import 'package:sales/data/repositorios/plataforma_repository.dart';
import 'package:sales/data/repositorios/produto_repository.dart';
import 'package:sales/data/repositorios/produto_venda_repository.dart';
import 'package:sales/data/repositorios/saque_repository.dart';
import 'package:sales/domain/entidades/compra_insumo.dart';
import 'package:sales/domain/entidades/configuracoes.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/investimento.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/domain/entidades/produto_venda.dart';
import 'package:sales/domain/entidades/saque.dart';
import 'package:sales/features/onboarding/application/importador_seed.dart';

// Mocks dos repositórios (sem servidor nem rootBundle).
class _MockConfiguracoes extends Mock implements ConfiguracoesRepository {}

class _MockPlataforma extends Mock implements PlataformaRepository {}

class _MockDestino extends Mock implements DestinoRepository {}

class _MockFaixaAbelinha extends Mock implements FaixaAbelinhaRepository {}

class _MockProduto extends Mock implements ProdutoRepository {}

class _MockProdutoVenda extends Mock implements ProdutoVendaRepository {}

class _MockCompra extends Mock implements CompraInsumoRepository {}

class _MockInvestimento extends Mock implements InvestimentoRepository {}

class _MockPedido extends Mock implements PedidoRepository {}

class _MockSaque extends Mock implements SaqueRepository {}

class _FakeConfiguracoes extends Fake implements Configuracoes {}

class _FakeCompraInsumo extends Fake implements CompraInsumo {}

class _FakeInvestimento extends Fake implements Investimento {}

class _FakePedido extends Fake implements Pedido {}

class _FakeSaque extends Fake implements Saque {}

const _empresaId = 'emp-1';

Map<String, dynamic> _dados() => {
      'configuracoes': {
        'embalagem_padrao': 0.9,
        'impressao_padrao': 1,
        'valor_abelinha': 10,
      },
      'faixas_abelinha': [
        {'custo_ate': 8, 'abelinhas': 1},
        {'custo_ate': 5, 'abelinhas': 0.5},
      ],
      'plataformas': [
        {
          'nome': 'Shopee',
          'cor': '#F0846A',
          'obs': 'ok',
          'faixas': [
            {'preco_ate': null, 'taxa_fixa': 4, 'taxa_percentual': 20},
          ],
        },
      ],
      'destinos': [
        {'nome': 'Cartão, empréstimos', 'cor': '#6A9FD8', 'percentual': 40},
        {'nome': 'Compras de produtos', 'cor': '#6FB59A', 'percentual': 30},
        {'nome': 'Pró-labore', 'cor': '#E5BF55', 'percentual': 30},
      ],
      'produtos': [
        {'codigo': 'BATOM', 'nome': 'Batom', 'custo': 4},
        {'codigo': 'GLOSS', 'nome': 'Gloss', 'custo': 6},
      ],
      'produtos_venda': [
        {
          'nome': 'Batom Bolsinha',
          'embalagem': 0.9,
          'impressao': 1,
          'outros': 0,
          'preco': 26.49,
          'desconto': 1,
          'cupom': 2,
          'meta_lucro': 200,
          'fatia_roas': 0.3,
          'margem_alvo': 30,
          'itens': [
            {'produto': 'BATOM', 'quantidade': 1},
          ],
          'precos_plataforma': [
            {'plataforma': 'Shopee', 'vendidos_iniciais': 13},
          ],
        },
      ],
      'compras_insumo': [
        {
          'data': '2026-06-13',
          'tipo': 'Embalagem',
          'produto': 'Caixa',
          'valor_total': 46.99,
          'destino': 'Compras de produtos',
        },
      ],
      'investimentos': [
        {
          'data': '2026-06-08',
          'distribuidor': 'Pérolas',
          'valor': 209.19,
          'destino': 'Compras de produtos',
        },
      ],
      'pedidos': [
        {
          'data': '2026-10-12',
          'cliente': 'KT01',
          'plataforma': 'Shopee',
          'embalagem': 0.9,
          'impressao': 1,
          'outros': 0,
          'preco_venda': 110,
          'itens_taxa_fixa': 1,
          'situacao': 'concluido',
          'itens': [
            {'tipo': 'produto', 'ref': 'BATOM', 'quantidade': 1},
            {'tipo': 'produto', 'ref': 'GLOSS', 'quantidade': 2},
          ],
        },
      ],
      'saques': [
        {
          'data': '2026-10-16',
          'plataforma': 'Shopee',
          'valor': 1000,
          'rateio': [
            {'destino': 'Cartão, empréstimos', 'percentual': 40},
            {'destino': 'Compras de produtos', 'percentual': 30},
            {'destino': 'Pró-labore', 'percentual': 30},
          ],
        },
      ],
    };

void main() {
  setUpAll(() {
    registerFallbackValue(
      Produto(
        id: '',
        empresaId: '',
        codigo: '',
        nome: '',
        custo: Decimal.zero,
      ),
    );
    registerFallbackValue(
      Destino(
        id: '',
        empresaId: '',
        nome: '',
        cor: '#000000',
        percentual: Decimal.zero,
      ),
    );
    registerFallbackValue(
      ProdutoVenda(
        id: '',
        empresaId: '',
        nome: '',
        embalagem: Decimal.zero,
        impressao: Decimal.zero,
        outros: Decimal.zero,
        preco: Decimal.zero,
        desconto: Decimal.zero,
        cupom: Decimal.zero,
        metaLucro: Decimal.zero,
        fatiaRoas: Decimal.zero,
        margemAlvo: Decimal.zero,
      ),
    );
    registerFallbackValue(<FaixaTaxa>[]);
    registerFallbackValue(<FaixaAbelinha>[]);
    registerFallbackValue(_FakeConfiguracoes());
    registerFallbackValue(_FakeCompraInsumo());
    registerFallbackValue(_FakeInvestimento());
    registerFallbackValue(_FakePedido());
    registerFallbackValue(_FakeSaque());
  });

  late _MockConfiguracoes configuracoes;
  late _MockPlataforma plataforma;
  late _MockDestino destino;
  late _MockFaixaAbelinha faixaAbelinha;
  late _MockProduto produto;
  late _MockProdutoVenda produtoVenda;
  late _MockCompra compra;
  late _MockInvestimento investimento;
  late _MockPedido pedido;
  late _MockSaque saque;
  late ImportadorSeed importador;
  late List<String> ordem;

  setUp(() {
    configuracoes = _MockConfiguracoes();
    plataforma = _MockPlataforma();
    destino = _MockDestino();
    faixaAbelinha = _MockFaixaAbelinha();
    produto = _MockProduto();
    produtoVenda = _MockProdutoVenda();
    compra = _MockCompra();
    investimento = _MockInvestimento();
    pedido = _MockPedido();
    saque = _MockSaque();
    ordem = [];

    when(() => configuracoes.atualizar(any())).thenAnswer((inv) async {
      ordem.add('configuracoes');
    });

    when(() => plataforma.listarComFaixas(any())).thenAnswer((_) async => {});
    when(() => plataforma.criar(any(), any())).thenAnswer((inv) async {
      ordem.add('plataforma');
      return Plataforma(
        id: 'pl-${inv.positionalArguments[1]}',
        empresaId: _empresaId,
        nome: inv.positionalArguments[1] as String,
      );
    });
    when(
      () => plataforma.atualizarAparencia(any(), any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => plataforma.substituirFaixas(any(), any(), any()),
    ).thenAnswer((_) async {
      ordem.add('faixas_taxa');
    });

    when(() => destino.listar(any())).thenAnswer((_) async => []);
    when(() => destino.criar(any())).thenAnswer((inv) async {
      ordem.add('destino');
      final d = inv.positionalArguments[0] as Destino;
      return d.copyWith(id: 'dest-${d.nome}');
    });

    when(() => faixaAbelinha.listar(any())).thenAnswer((_) async => []);
    when(() => faixaAbelinha.substituir(any(), any())).thenAnswer((_) async {
      ordem.add('faixas_abelinha');
    });

    when(() => produto.criar(any())).thenAnswer((inv) async {
      ordem.add('produto');
      final p = inv.positionalArguments[0] as Produto;
      return p.copyWith(id: 'prod-${p.codigo}');
    });

    when(() => produtoVenda.salvar(any())).thenAnswer((inv) async {
      ordem.add('produto_venda');
      final k = inv.positionalArguments[0] as ProdutoVenda;
      return k.copyWith(id: 'kit-${k.nome}');
    });

    when(() => compra.criar(any())).thenAnswer((inv) async {
      ordem.add('compra');
      return inv.positionalArguments[0] as CompraInsumo;
    });

    when(() => investimento.criar(any())).thenAnswer((inv) async {
      ordem.add('investimento');
      return inv.positionalArguments[0] as Investimento;
    });

    when(() => pedido.salvar(any())).thenAnswer((inv) async {
      ordem.add('pedido');
      return inv.positionalArguments[0] as Pedido;
    });

    when(() => saque.salvar(any())).thenAnswer((inv) async {
      ordem.add('saque');
      return inv.positionalArguments[0] as Saque;
    });

    importador = ImportadorSeed(
      configuracoesRepository: configuracoes,
      plataformaRepository: plataforma,
      destinoRepository: destino,
      faixaAbelinhaRepository: faixaAbelinha,
      produtoRepository: produto,
      produtoVendaRepository: produtoVenda,
      compraInsumoRepository: compra,
      investimentoRepository: investimento,
      pedidoRepository: pedido,
      saqueRepository: saque,
    );
  });

  test('importa na ordem definida (§9)', () async {
    await importador.importarDados(_empresaId, _dados());

    // configuracoes antes de plataformas; plataformas antes de produtos;
    // produtos antes de produtos de venda; pedidos antes de saques.
    expect(ordem.first, 'configuracoes');
    expect(
      ordem.indexOf('plataforma') < ordem.indexOf('produto'),
      isTrue,
    );
    expect(
      ordem.indexOf('produto') < ordem.indexOf('produto_venda'),
      isTrue,
    );
    expect(
      ordem.indexOf('produto_venda') < ordem.indexOf('compra'),
      isTrue,
    );
    expect(ordem.indexOf('pedido') < ordem.indexOf('saque'), isTrue);
  });

  test('resolve refs e grava snapshots dos itens de pedido', () async {
    final capturados = <Pedido>[];
    when(() => pedido.salvar(any())).thenAnswer((inv) async {
      final p = inv.positionalArguments[0] as Pedido;
      capturados.add(p);
      return p;
    });

    await importador.importarDados(_empresaId, _dados());

    expect(capturados, hasLength(1));
    final p = capturados.single;
    // Plataforma resolvida para o UUID gerado.
    expect(p.plataformaId, 'pl-Shopee');
    expect(p.itens, hasLength(2));
    // produto 'BATOM' (custo 4) -> snapshot custo_unitario = 4;
    // faixa custo_ate 5 => 0,5 abelinhas.
    final batom = p.itens.first;
    expect(batom.produtoId, 'prod-BATOM');
    expect(batom.tipo, TipoPedidoItem.produto);
    expect(batom.custoUnitario, Decimal.fromInt(4));
    expect(batom.abelinhasUnitarias, Decimal.parse('0.5'));
    // produto 'GLOSS' (custo 6) -> faixa custo_ate 8 => 1 abelinha.
    final gloss = p.itens[1];
    expect(gloss.custoUnitario, Decimal.fromInt(6));
    expect(gloss.abelinhasUnitarias, Decimal.fromInt(1));
  });

  test('grava rateio do saque com os percentuais do arquivo', () async {
    final capturados = <Saque>[];
    when(() => saque.salvar(any())).thenAnswer((inv) async {
      final s = inv.positionalArguments[0] as Saque;
      capturados.add(s);
      return s;
    });

    await importador.importarDados(_empresaId, _dados());

    final s = capturados.single;
    expect(s.plataformaId, 'pl-Shopee');
    expect(s.rateio, hasLength(3));
    // valor 1000 * 40% = 400; destino resolvido para o UUID.
    final cartao = s.rateio.first;
    expect(cartao.destinoId, 'dest-Cartão, empréstimos');
    expect(cartao.valor, Decimal.fromInt(400));
  });

  test('atualiza plataforma/destino existentes sem duplicar', () async {
    // Plataforma Shopee já existe (criada pela RPC).
    when(() => plataforma.listarComFaixas(any())).thenAnswer(
      (_) async => {
        const Plataforma(
          id: 'pl-exist',
          empresaId: _empresaId,
          nome: 'Shopee',
        ): const [],
      },
    );
    when(() => destino.listar(any())).thenAnswer(
      (_) async => [
        Destino(
          id: 'dest-exist',
          empresaId: _empresaId,
          nome: 'Cartão, empréstimos',
          cor: '#000000',
          percentual: Decimal.zero,
        ),
      ],
    );
    when(() => destino.atualizar(any())).thenAnswer(
      (inv) async => inv.positionalArguments[0] as Destino,
    );

    await importador.importarDados(_empresaId, _dados());

    // Não deve chamar criar plataforma (já existia).
    verifyNever(() => plataforma.criar(any(), any()));
    // Destino existente é atualizado (não criado).
    verify(() => destino.atualizar(any())).called(1);
  });
}
