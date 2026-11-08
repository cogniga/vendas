import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/format/padrao_escrita.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/data/repositorios/plataforma_repository.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/features/composicao/application/composicao_providers.dart'
    as composicao show plataformasComFaixasProvider;
import 'package:sales/features/pedidos/application/pedidos_providers.dart'
    as pedidos show plataformasComFaixasProvider;
import 'package:sales/features/plataformas/application/plataformas_providers.dart';

/// Campos editáveis de uma faixa (em edição na memória).
class FaixaEdicao {
  const FaixaEdicao({
    required this.precoAte,
    required this.taxaFixa,
    required this.taxaPercentual,
    this.taxaOutras,
  });

  /// `null` significa faixa sem limite superior.
  final Decimal? precoAte;
  final Decimal taxaFixa;
  final Decimal taxaPercentual;

  /// Outras taxas em % (ex.: frete do TikTok); `null` = não cobra.
  final Decimal? taxaOutras;

  FaixaEdicao copyWith({
    Object? precoAte = _sentinela,
    Decimal? taxaFixa,
    Decimal? taxaPercentual,
    Object? taxaOutras = _sentinela,
  }) {
    return FaixaEdicao(
      precoAte:
          precoAte == _sentinela ? this.precoAte : precoAte as Decimal?,
      taxaFixa: taxaFixa ?? this.taxaFixa,
      taxaPercentual: taxaPercentual ?? this.taxaPercentual,
      taxaOutras:
          taxaOutras == _sentinela ? this.taxaOutras : taxaOutras as Decimal?,
    );
  }

  /// Converte para a entidade persistível (ids em branco; o repositório
  /// substitui todas as faixas da plataforma).
  FaixaTaxa paraEntidade(String empresaId, String plataformaId) => FaixaTaxa(
        id: '',
        empresaId: empresaId,
        plataformaId: plataformaId,
        taxaFixa: taxaFixa,
        taxaPercentual: taxaPercentual,
        precoAte: precoAte,
        taxaOutras: taxaOutras,
      );

  static const Object _sentinela = Object();
}

/// Estado da tela de Plataformas: plataformas em edição com suas faixas,
/// mais os controles de salvamento e erro.
class EstadoPlataformas {
  const EstadoPlataformas({
    required this.plataformas,
    this.salvando = false,
    this.erro,
  });

  /// Plataformas (ordenadas por `ordem`) com suas faixas em edição.
  final Map<Plataforma, List<FaixaEdicao>> plataformas;

  /// Indica persistência em andamento.
  final bool salvando;

  /// Mensagem de erro da última operação (ou `null`).
  final String? erro;

  EstadoPlataformas copyWith({
    Map<Plataforma, List<FaixaEdicao>>? plataformas,
    bool? salvando,
    Object? erro = _sentinela,
  }) {
    return EstadoPlataformas(
      plataformas: plataformas ?? this.plataformas,
      salvando: salvando ?? this.salvando,
      erro: erro == _sentinela ? this.erro : erro as String?,
    );
  }

  static const Object _sentinela = Object();
}

/// Controla a edição das plataformas com autosave (debounce ~500 ms), como no
/// protótipo `V.plataformas` (persiste ao digitar, sem botão "Salvar").
///
/// Nada de Supabase direto: toda I/O passa pelos repositórios via seus
/// providers. Ao concluir mudanças, invalida [plataformasProvider] e
/// as listas de plataformas com faixas (Composição e Pedidos).
class PlataformasController extends StateNotifier<EstadoPlataformas> {
  /// Cria o controller com o [Ref] e o mapa inicial carregado do repositório.
  PlataformasController(this._ref, Map<Plataforma, List<FaixaTaxa>> inicial)
      : super(
          EstadoPlataformas(
            plataformas: {
              for (final entrada in inicial.entries)
                entrada.key: [
                  for (final f in entrada.value)
                    FaixaEdicao(
                      precoAte: f.precoAte,
                      taxaFixa: f.taxaFixa,
                      taxaPercentual: f.taxaPercentual,
                      taxaOutras: f.taxaOutras,
                    ),
                ],
            },
          ),
        );

  final Ref _ref;

  /// Debounces de persistência por plataforma (um por id).
  final Map<String, Timer> _debounces = {};

  static const Duration _debounceMs = Duration(milliseconds: 500);

  PlataformaRepository get _repo =>
      _ref.read(plataformaRepositoryProvider);

  /// Cria uma plataforma com nome padrão e uma faixa inicial sem limite.
  Future<void> criarPlataforma() async {
    state = state.copyWith(salvando: true, erro: null);
    try {
      final empresa = await _ref.read(empresaAtualProvider.future);
      if (empresa == null) {
        state = state.copyWith(
          salvando: false,
          erro: 'Nenhuma empresa ativa.',
        );
        return;
      }
      final plataforma = await _repo.criar(empresa.id, 'Nova plataforma');
      // `criar` não cria faixa: grava uma faixa inicial sem limite.
      await _repo.substituirFaixas(plataforma.id, empresa.id, [
        FaixaTaxa(
          id: '',
          empresaId: empresa.id,
          plataformaId: plataforma.id,
          taxaFixa: Decimal.zero,
          taxaPercentual: Decimal.zero,
        ),
      ]);
      state = state.copyWith(salvando: false);
      _invalidar();
    } on Object catch (e) {
      state = state.copyWith(salvando: false, erro: _mensagem(e));
    }
  }

  /// Renomeia a plataforma [id] em memória e persiste com debounce.
  void renomear(String id, String nome) {
    _atualizarPlataforma(id, (p) => p.copyWith(nome: nome));
    _agendar(id, () async {
      await _repo.renomear(id, PadraoEscrita.titulo(nome));
      _invalidar();
    });
  }

  /// Muda cor e observação da plataforma [id]; persiste com debounce.
  void mudarAparencia(String id, String cor, String obs) {
    _atualizarPlataforma(id, (p) => p.copyWith(cor: cor, obs: obs));
    _agendar(id, () async {
      await _repo.atualizarAparencia(id, cor, obs);
      _invalidar();
    });
  }

  /// Altera uma faixa da plataforma [id] no [indice]; persiste com debounce.
  void alterarFaixa(String id, int indice, FaixaEdicao faixa) {
    _atualizarFaixas(id, (faixas) {
      final novas = [...faixas];
      novas[indice] = faixa;
      return novas;
    });
    _agendarFaixas(id);
  }

  /// Adiciona uma faixa à plataforma [id].
  ///
  /// Se ainda não existe faixa "e acima" (sem limite), a nova é a sem limite.
  /// Se já existe, a nova entra **antes** dela com teto = maior teto + 50
  /// (copiando fixo/percentual da sem limite), mantendo uma única faixa aberta.
  void adicionarFaixa(String id) {
    _atualizarFaixas(id, (faixas) {
      final indiceAberta = faixas.indexWhere((f) => f.precoAte == null);
      if (indiceAberta < 0) {
        return [
          ...faixas,
          FaixaEdicao(
            precoAte: null,
            taxaFixa: Decimal.zero,
            taxaPercentual: Decimal.zero,
          ),
        ];
      }
      final tetos = faixas.map((f) => f.precoAte).whereType<Decimal>();
      final maior = tetos.isEmpty
          ? Decimal.zero
          : tetos.reduce((a, b) => a > b ? a : b);
      final aberta = faixas[indiceAberta];
      final nova = FaixaEdicao(
        precoAte: maior + Decimal.fromInt(50),
        taxaFixa: aberta.taxaFixa,
        taxaPercentual: aberta.taxaPercentual,
        taxaOutras: aberta.taxaOutras,
      );
      return [...faixas]..insert(indiceAberta, nova);
    });
    _agendarFaixas(id);
  }

  /// Remove a faixa no [indice] da plataforma [id] (mantém mínimo 1).
  void removerFaixa(String id, int indice) {
    final faixas = _faixasDe(id);
    if (faixas == null || faixas.length <= 1) return;
    _atualizarFaixas(id, (atuais) => [...atuais]..removeAt(indice));
    _agendarFaixas(id);
  }

  /// Exclui a plataforma [id]. Impede excluir a última (mínimo 1) e captura
  /// `ErroRepositorio` (plataforma em uso), expondo a mensagem.
  Future<void> excluir(String id) async {
    if (state.plataformas.length <= 1) {
      state = state.copyWith(
        erro: 'Mantenha pelo menos uma plataforma.',
      );
      return;
    }
    state = state.copyWith(salvando: true, erro: null);
    try {
      _debounces.remove(id)?.cancel();
      await _repo.excluir(id);
      state = state.copyWith(salvando: false);
      _invalidar();
    } on Object catch (e) {
      state = state.copyWith(salvando: false, erro: _mensagem(e));
    }
  }

  List<FaixaEdicao>? _faixasDe(String id) {
    for (final entrada in state.plataformas.entries) {
      if (entrada.key.id == id) return entrada.value;
    }
    return null;
  }

  void _atualizarPlataforma(
    String id,
    Plataforma Function(Plataforma) transformar,
  ) {
    final novo = <Plataforma, List<FaixaEdicao>>{};
    for (final entrada in state.plataformas.entries) {
      if (entrada.key.id == id) {
        novo[transformar(entrada.key)] = entrada.value;
      } else {
        novo[entrada.key] = entrada.value;
      }
    }
    state = state.copyWith(plataformas: novo, erro: null);
  }

  void _atualizarFaixas(
    String id,
    List<FaixaEdicao> Function(List<FaixaEdicao>) transformar,
  ) {
    final novo = <Plataforma, List<FaixaEdicao>>{};
    for (final entrada in state.plataformas.entries) {
      if (entrada.key.id == id) {
        novo[entrada.key] = transformar(entrada.value);
      } else {
        novo[entrada.key] = entrada.value;
      }
    }
    state = state.copyWith(plataformas: novo, erro: null);
  }

  void _agendarFaixas(String id) {
    _agendar(id, () async {
      final empresa = await _ref.read(empresaAtualProvider.future);
      final faixas = _faixasDe(id);
      if (empresa == null || faixas == null) return;
      await _repo.substituirFaixas(
        id,
        empresa.id,
        [for (final f in faixas) f.paraEntidade(empresa.id, id)],
      );
      _invalidar();
    });
  }

  void _agendar(String id, Future<void> Function() acao) {
    _debounces[id]?.cancel();
    _debounces[id] = Timer(_debounceMs, () async {
      _debounces.remove(id);
      try {
        await acao();
      } on Object catch (e) {
        if (mounted) state = state.copyWith(erro: _mensagem(e));
      }
    });
  }

  /// Recarrega TODAS as cópias de "plataformas com faixas": a da Composição
  /// e a de Pedidos (usada também por Painel e Caixa). Antes só a primeira
  /// era recarregada e pedidos seguiam com taxas antigas (ex.: sem "Outras").
  void _invalidar() {
    _ref
      ..invalidate(plataformasProvider)
      ..invalidate(composicao.plataformasComFaixasProvider)
      ..invalidate(pedidos.plataformasComFaixasProvider);
  }

  String _mensagem(Object erro) {
    final texto = erro.toString();
    return texto.startsWith('ErroRepositorio: ')
        ? texto.substring('ErroRepositorio: '.length)
        : 'Não foi possível salvar. Tente de novo.';
  }

  @override
  void dispose() {
    for (final t in _debounces.values) {
      t.cancel();
    }
    _debounces.clear();
    super.dispose();
  }
}

/// Provider do [PlataformasController]. Família pelo mapa carregado, para
/// inicializar o estado com as plataformas/faixas da empresa.
final plataformasControllerProvider = StateNotifierProvider.autoDispose.family<
    PlataformasController,
    EstadoPlataformas,
    Map<Plataforma, List<FaixaTaxa>>>(
  PlataformasController.new,
);
