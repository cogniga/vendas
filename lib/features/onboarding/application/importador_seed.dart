import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:sales/domain/calculos/abelinhas.dart';
import 'package:sales/domain/calculos/decimais.dart';
import 'package:sales/domain/calculos/produto_venda.dart' as calc;
import 'package:sales/domain/entidades/compra_insumo.dart';
import 'package:sales/domain/entidades/configuracoes.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/investimento.dart';
import 'package:sales/domain/entidades/pedido.dart';
import 'package:sales/domain/entidades/pedido_item.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/domain/entidades/preco_plataforma.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/domain/entidades/produto_venda.dart';
import 'package:sales/domain/entidades/produto_venda_item.dart';
import 'package:sales/domain/entidades/saque.dart';
import 'package:sales/domain/entidades/saque_rateio.dart';

/// Caminho do asset com os dados iniciais (a planilha migrada).
const String kCaminhoSeed = 'assets/seed/dados-iniciais.json';

/// Importador do seed (design.md §9).
///
/// Lê [kCaminhoSeed] e importa para a empresa indicada na ordem: configurações
/// → plataformas/faixas → destinos → regra de abelinhas → produtos
/// (`produto_online`) → produtos de venda → compras → investimentos → pedidos
/// → saques. Como a RPC `criar_empresa` já cria plataformas, faixas, destinos
/// e regra de abelinhas padrão, estes são **atualizados casando pelo nome** em
/// vez de duplicar. As referências textuais do arquivo (código do produto,
/// nome da plataforma/destino, nome do kit) são resolvidas para UUIDs durante
/// a importação. Os snapshots dos itens de pedido e o rateio do saque usam os
/// cálculos puros de `lib/domain/calculos`.
class ImportadorSeed {
  /// Cria o importador com os repositórios injetados.
  ImportadorSeed({
    required ConfiguracoesRepository configuracoesRepository,
    required PlataformaRepository plataformaRepository,
    required DestinoRepository destinoRepository,
    required FaixaAbelinhaRepository faixaAbelinhaRepository,
    required ProdutoRepository produtoRepository,
    required ProdutoVendaRepository produtoVendaRepository,
    required CompraInsumoRepository compraInsumoRepository,
    required InvestimentoRepository investimentoRepository,
    required PedidoRepository pedidoRepository,
    required SaqueRepository saqueRepository,
  })  : _configuracoesRepo = configuracoesRepository,
        _plataformaRepo = plataformaRepository,
        _destinoRepo = destinoRepository,
        _faixaAbelinhaRepo = faixaAbelinhaRepository,
        _produtoRepo = produtoRepository,
        _produtoVendaRepo = produtoVendaRepository,
        _compraInsumoRepo = compraInsumoRepository,
        _investimentoRepo = investimentoRepository,
        _pedidoRepo = pedidoRepository,
        _saqueRepo = saqueRepository;

  final ConfiguracoesRepository _configuracoesRepo;
  final PlataformaRepository _plataformaRepo;
  final DestinoRepository _destinoRepo;
  final FaixaAbelinhaRepository _faixaAbelinhaRepo;
  final ProdutoRepository _produtoRepo;
  final ProdutoVendaRepository _produtoVendaRepo;
  final CompraInsumoRepository _compraInsumoRepo;
  final InvestimentoRepository _investimentoRepo;
  final PedidoRepository _pedidoRepo;
  final SaqueRepository _saqueRepo;

  /// Importa o seed para a empresa [empresaId].
  ///
  /// Lê o JSON do asset e delega para [importarDados].
  Future<void> importar(String empresaId) async {
    final texto = await rootBundle.loadString(kCaminhoSeed);
    final dados = json.decode(texto) as Map<String, dynamic>;
    await importarDados(empresaId, dados);
  }

  /// Importa [dados] (já decodificados) para a empresa [empresaId].
  ///
  /// Separado de [importar] para permitir teste sem `rootBundle`.
  Future<void> importarDados(
    String empresaId,
    Map<String, dynamic> dados,
  ) async {
    await _importarConfiguracoes(empresaId, dados['configuracoes']);

    final plataformasPorNome =
        await _importarPlataformas(empresaId, _lista(dados['plataformas']));
    final destinosPorNome =
        await _importarDestinos(empresaId, _lista(dados['destinos']));
    final faixasAbelinha = await _importarFaixasAbelinha(
      empresaId,
      _lista(dados['faixas_abelinha']),
    );

    final produtosPorCodigo =
        await _importarProdutos(empresaId, _lista(dados['produtos']));
    final kitsPorNome = await _importarProdutosVenda(
      empresaId,
      _lista(dados['produtos_venda']),
      produtosPorCodigo,
      plataformasPorNome,
    );

    await _importarCompras(
      empresaId,
      _lista(dados['compras_insumo']),
      destinosPorNome,
    );
    await _importarInvestimentos(
      empresaId,
      _lista(dados['investimentos']),
      destinosPorNome,
    );
    await _importarPedidos(
      empresaId,
      _lista(dados['pedidos']),
      plataformasPorNome,
      produtosPorCodigo,
      kitsPorNome,
      faixasAbelinha,
    );
    await _importarSaques(
      empresaId,
      _lista(dados['saques']),
      plataformasPorNome,
      destinosPorNome,
    );
  }

  // 1) Configurações: atualiza a linha existente (criada pela RPC).
  Future<void> _importarConfiguracoes(
    String empresaId,
    Object? bruto,
  ) async {
    final mapa = bruto as Map<String, dynamic>?;
    if (mapa == null) return;
    await _configuracoesRepo.atualizar(
      Configuracoes(
        empresaId: empresaId,
        embalagemPadrao: _dec(mapa['embalagem_padrao']),
        impressaoPadrao: _dec(mapa['impressao_padrao']),
        valorAbelinha: _dec(mapa['valor_abelinha']),
      ),
    );
  }

  // 2) Plataformas + faixas: casa pelo nome; atualiza cor/obs e substitui as
  // faixas; cria quando não existe. Devolve nome -> UUID.
  Future<Map<String, String>> _importarPlataformas(
    String empresaId,
    List<Map<String, dynamic>> plataformas,
  ) async {
    final existentes = await _plataformaRepo.listarComFaixas(empresaId);
    final porNome = <String, Plataforma>{
      for (final p in existentes.keys) p.nome: p,
    };
    final resultado = <String, String>{};
    for (final bruto in plataformas) {
      final nome = bruto['nome'] as String;
      final cor = bruto['cor'] as String? ?? '#9A8FD4';
      final obs = bruto['obs'] as String? ?? '';
      final atual =
          porNome[nome] ?? await _plataformaRepo.criar(empresaId, nome);
      await _plataformaRepo.atualizarAparencia(atual.id, cor, obs);
      final faixas = _lista(bruto['faixas'])
          .map(
            (f) => FaixaTaxa(
              id: '',
              empresaId: empresaId,
              plataformaId: atual.id,
              taxaFixa: _dec(f['taxa_fixa']),
              taxaPercentual: _dec(f['taxa_percentual']),
              precoAte: _decNull(f['preco_ate']),
            ),
          )
          .toList();
      await _plataformaRepo.substituirFaixas(atual.id, empresaId, faixas);
      resultado[nome] = atual.id;
    }
    return resultado;
  }

  // 3) Destinos: casa pelo nome; atualiza percentual/cor ou cria.
  Future<Map<String, String>> _importarDestinos(
    String empresaId,
    List<Map<String, dynamic>> destinos,
  ) async {
    final existentes = await _destinoRepo.listar(empresaId);
    final porNome = <String, Destino>{
      for (final d in existentes) d.nome: d,
    };
    final resultado = <String, String>{};
    var ordem = 0;
    for (final bruto in destinos) {
      final nome = bruto['nome'] as String;
      final cor = bruto['cor'] as String? ?? '#6A9FD8';
      final percentual = _dec(bruto['percentual']);
      final atual = porNome[nome];
      if (atual == null) {
        final criado = await _destinoRepo.criar(
          Destino(
            id: '',
            empresaId: empresaId,
            nome: nome,
            cor: cor,
            percentual: percentual,
            ordem: ordem,
          ),
        );
        resultado[nome] = criado.id;
      } else {
        await _destinoRepo.atualizar(
          atual.copyWith(cor: cor, percentual: percentual, ordem: ordem),
        );
        resultado[nome] = atual.id;
      }
      ordem++;
    }
    return resultado;
  }

  // 4) Regra de abelinhas: substitui pela do arquivo (ordenada por custo_ate).
  Future<List<FaixaAbelinha>> _importarFaixasAbelinha(
    String empresaId,
    List<Map<String, dynamic>> faixas,
  ) async {
    if (faixas.isEmpty) {
      return _faixaAbelinhaRepo.listar(empresaId);
    }
    final novas = faixas
        .map(
          (f) => FaixaAbelinha(
            id: '',
            empresaId: empresaId,
            custoAte: _dec(f['custo_ate']),
            abelinhas: _dec(f['abelinhas']),
          ),
        )
        .toList()
      ..sort((a, b) => a.custoAte.compareTo(b.custoAte));
    await _faixaAbelinhaRepo.substituir(empresaId, novas);
    return novas;
  }

  // 5) Produtos (produto_online). Devolve código -> Produto persistido.
  Future<Map<String, Produto>> _importarProdutos(
    String empresaId,
    List<Map<String, dynamic>> produtos,
  ) async {
    final porCodigo = <String, Produto>{};
    for (final bruto in produtos) {
      final criado = await _produtoRepo.criar(
        Produto(
          id: '',
          empresaId: empresaId,
          codigo: bruto['codigo'] as String,
          nome: bruto['nome'] as String,
          custo: _dec(bruto['custo']),
          marca: bruto['marca'] as String? ?? '',
          categoria: bruto['categoria'] as String? ?? 'Cosméticos',
          fornecedor: bruto['fornecedor'] as String? ?? '',
          unidade: bruto['unidade'] as String? ?? 'un',
          estoque: (bruto['estoque'] as num?)?.toInt() ?? 0,
          ean: bruto['ean'] as String? ?? '',
          ativo: bruto['ativo'] as bool? ?? true,
          obs: bruto['obs'] as String? ?? '',
          abelinhasManual: _decNull(bruto['abelinhas_manual']),
        ),
      );
      porCodigo[criado.codigo] = criado;
    }
    return porCodigo;
  }

  // 6) Produtos de venda (kits) com itens e preços. Devolve nome -> kit.
  Future<Map<String, ProdutoVenda>> _importarProdutosVenda(
    String empresaId,
    List<Map<String, dynamic>> kits,
    Map<String, Produto> produtosPorCodigo,
    Map<String, String> plataformasPorNome,
  ) async {
    final porNome = <String, ProdutoVenda>{};
    for (final bruto in kits) {
      final nome = bruto['nome'] as String;
      final itens = <ProdutoVendaItem>[];
      for (final item in _lista(bruto['itens'])) {
        final produto = produtosPorCodigo[item['produto'] as String];
        if (produto == null) continue;
        itens.add(
          ProdutoVendaItem(
            id: '',
            empresaId: empresaId,
            produtoVendaId: '',
            produtoId: produto.id,
            quantidade: (item['quantidade'] as num).toInt(),
          ),
        );
      }
      final precos = <String, PrecoPlataforma>{};
      for (final preco in _lista(bruto['precos_plataforma'])) {
        final plataformaId = plataformasPorNome[preco['plataforma'] as String];
        if (plataformaId == null) continue;
        precos[plataformaId] = PrecoPlataforma(
          empresaId: empresaId,
          produtoVendaId: '',
          plataformaId: plataformaId,
          vendidosIniciais:
              (preco['vendidos_iniciais'] as num?)?.toInt() ?? 0,
        );
      }
      final kit = await _produtoVendaRepo.salvar(
        ProdutoVenda(
          id: '',
          empresaId: empresaId,
          nome: nome,
          embalagem: _dec(bruto['embalagem']),
          impressao: _dec(bruto['impressao']),
          outros: _dec(bruto['outros']),
          preco: _dec(bruto['preco']),
          desconto: _dec(bruto['desconto']),
          cupom: _dec(bruto['cupom']),
          metaLucro: _dec(bruto['meta_lucro']),
          fatiaRoas: _dec(bruto['fatia_roas']),
          margemAlvo: _dec(bruto['margem_alvo']),
          precoConcorrente: _decNull(bruto['preco_concorrente']),
          itens: itens,
          precosPorPlataforma: precos,
        ),
      );
      porNome[nome] = kit;
    }
    return porNome;
  }

  // 7) Compras de insumo.
  Future<void> _importarCompras(
    String empresaId,
    List<Map<String, dynamic>> compras,
    Map<String, String> destinosPorNome,
  ) async {
    for (final bruto in compras) {
      await _compraInsumoRepo.criar(
        CompraInsumo(
          id: '',
          empresaId: empresaId,
          data: DateTime.parse(bruto['data'] as String),
          produto: bruto['produto'] as String,
          valorTotal: _dec(bruto['valor_total']),
          tipo: bruto['tipo'] as String? ?? 'Embalagem',
          descricao: bruto['descricao'] as String? ?? '',
          pacotes: (bruto['pacotes'] as num?)?.toInt() ?? 1,
          itens: (bruto['itens'] as num?)?.toInt() ?? 1,
          destinoId: destinosPorNome[bruto['destino'] as String?],
        ),
      );
    }
  }

  // 8) Investimentos.
  Future<void> _importarInvestimentos(
    String empresaId,
    List<Map<String, dynamic>> investimentos,
    Map<String, String> destinosPorNome,
  ) async {
    for (final bruto in investimentos) {
      await _investimentoRepo.criar(
        Investimento(
          id: '',
          empresaId: empresaId,
          data: DateTime.parse(bruto['data'] as String),
          distribuidor: bruto['distribuidor'] as String,
          valor: _dec(bruto['valor']),
          nota: bruto['nota'] as String? ?? '',
          destinoId: destinosPorNome[bruto['destino'] as String?],
          obs: bruto['obs'] as String? ?? '',
        ),
      );
    }
  }

  // 9) Pedidos: itens com snapshot calculado por lib/domain/calculos.
  Future<void> _importarPedidos(
    String empresaId,
    List<Map<String, dynamic>> pedidos,
    Map<String, String> plataformasPorNome,
    Map<String, Produto> produtosPorCodigo,
    Map<String, ProdutoVenda> kitsPorNome,
    List<FaixaAbelinha> faixasAbelinha,
  ) async {
    for (final bruto in pedidos) {
      final plataformaId = plataformasPorNome[bruto['plataforma'] as String];
      if (plataformaId == null) continue;
      final itens = <PedidoItem>[];
      for (final item in _lista(bruto['itens'])) {
        final pedidoItem = _itemPedido(
          empresaId,
          item,
          produtosPorCodigo,
          kitsPorNome,
          faixasAbelinha,
        );
        if (pedidoItem != null) itens.add(pedidoItem);
      }
      await _pedidoRepo.salvar(
        Pedido(
          id: '',
          empresaId: empresaId,
          data: DateTime.parse(bruto['data'] as String),
          cliente: bruto['cliente'] as String? ?? '',
          plataformaId: plataformaId,
          embalagem: _dec(bruto['embalagem']),
          impressao: _dec(bruto['impressao']),
          outros: _dec(bruto['outros']),
          precoVenda: _dec(bruto['preco_venda']),
          itensTaxaFixa: (bruto['itens_taxa_fixa'] as num?)?.toInt() ?? 1,
          liquidoInformado: _decNull(bruto['liquido_informado']),
          situacao: _situacao(bruto['situacao'] as String?),
          obs: bruto['obs'] as String? ?? '',
          itens: itens,
        ),
      );
    }
  }

  // Monta um item de pedido com o snapshot calculado (design.md §6.4/§6.6).
  PedidoItem? _itemPedido(
    String empresaId,
    Map<String, dynamic> item,
    Map<String, Produto> produtosPorCodigo,
    Map<String, ProdutoVenda> kitsPorNome,
    List<FaixaAbelinha> faixasAbelinha,
  ) {
    final tipo = item['tipo'] as String;
    final ref = item['ref'] as String;
    final quantidade = (item['quantidade'] as num).toInt();
    if (tipo == 'produto') {
      final produto = produtosPorCodigo[ref];
      if (produto == null) return null;
      return PedidoItem(
        id: '',
        empresaId: empresaId,
        pedidoId: '',
        tipo: TipoPedidoItem.produto,
        quantidade: quantidade,
        custoUnitario: produto.custo,
        abelinhasUnitarias: abelinhasProduto(produto, faixasAbelinha),
        produtoId: produto.id,
      );
    }
    final kit = kitsPorNome[ref];
    if (kit == null) return null;
    final produtosPorId = <String, Produto>{
      for (final p in produtosPorCodigo.values) p.id: p,
    };
    final resultado = calc.calcularKit(
      kit,
      produtosPorId,
      // Plataforma só influencia taxa/meta; investimento e abelinhas do kit
      // independem dela, e aqui usamos apenas esses dois campos.
      Plataforma(id: '', empresaId: empresaId, nome: ''),
      const <FaixaTaxa>[],
      faixasAbelinha,
    );
    return PedidoItem(
      id: '',
      empresaId: empresaId,
      pedidoId: '',
      tipo: TipoPedidoItem.produtoVenda,
      quantidade: quantidade,
      custoUnitario: resultado.investimento,
      abelinhasUnitarias: resultado.abelinhasKit,
      produtoVendaId: kit.id,
    );
  }

  // 10) Saques com rateio pelos percentuais do arquivo.
  Future<void> _importarSaques(
    String empresaId,
    List<Map<String, dynamic>> saques,
    Map<String, String> plataformasPorNome,
    Map<String, String> destinosPorNome,
  ) async {
    for (final bruto in saques) {
      final plataformaId = plataformasPorNome[bruto['plataforma'] as String];
      if (plataformaId == null) continue;
      final valor = _dec(bruto['valor']);
      final rateio = <SaqueRateio>[];
      for (final r in _lista(bruto['rateio'])) {
        final destinoId = destinosPorNome[r['destino'] as String];
        if (destinoId == null) continue;
        final percentual = _dec(r['percentual']);
        rateio.add(
          SaqueRateio(
            saqueId: '',
            empresaId: empresaId,
            destinoId: destinoId,
            percentual: percentual,
            valor: (valor * percentual).dividir(cem),
          ),
        );
      }
      await _saqueRepo.salvar(
        Saque(
          id: '',
          empresaId: empresaId,
          data: DateTime.parse(bruto['data'] as String),
          plataformaId: plataformaId,
          valor: valor,
          obs: bruto['obs'] as String? ?? '',
          rateio: rateio,
        ),
      );
    }
  }

  SituacaoPedido _situacao(String? valor) => switch (valor) {
        'cancelado' => SituacaoPedido.cancelado,
        'devolvido' => SituacaoPedido.devolvido,
        _ => SituacaoPedido.concluido,
      };

  static List<Map<String, dynamic>> _lista(Object? valor) {
    if (valor is! List) return const [];
    return valor.cast<Map<String, dynamic>>();
  }

  static Decimal _dec(Object? valor) {
    if (valor == null) return Decimal.zero;
    return Decimal.parse(valor.toString());
  }

  static Decimal? _decNull(Object? valor) {
    if (valor == null) return null;
    return Decimal.parse(valor.toString());
  }
}

/// Provider do [ImportadorSeed], montado a partir dos repositórios.
final importadorSeedProvider = Provider<ImportadorSeed>((ref) {
  return ImportadorSeed(
    configuracoesRepository: ref.watch(configuracoesRepositoryProvider),
    plataformaRepository: ref.watch(plataformaRepositoryProvider),
    destinoRepository: ref.watch(destinoRepositoryProvider),
    faixaAbelinhaRepository: ref.watch(faixaAbelinhaRepositoryProvider),
    produtoRepository: ref.watch(produtoRepositoryProvider),
    produtoVendaRepository: ref.watch(produtoVendaRepositoryProvider),
    compraInsumoRepository: ref.watch(compraInsumoRepositoryProvider),
    investimentoRepository: ref.watch(investimentoRepositoryProvider),
    pedidoRepository: ref.watch(pedidoRepositoryProvider),
    saqueRepository: ref.watch(saqueRepositoryProvider),
  );
});
