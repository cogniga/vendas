import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/data/repositorios/configuracoes_repository.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/data/repositorios/faixa_abelinha_repository.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/features/abelinhas/application/abelinhas_providers.dart';
import 'package:sales/features/produtos/application/produtos_providers.dart';

/// Estado da tela de Regra de abelinhas: valor de 1 abelinha aplicado ao vivo,
/// faixas em edição e o controle de salvamento.
class EstadoAbelinhas {
  const EstadoAbelinhas({
    required this.valorAbelinha,
    required this.faixas,
    this.salvando = false,
    this.erro,
  });

  /// Valor de 1 🐝 (R$) atualmente aplicado (após debounce).
  final Decimal valorAbelinha;

  /// Faixas em edição (memória), ordenadas por `custoAte`.
  final List<FaixaAbelinha> faixas;

  /// Indica salvamento em andamento.
  final bool salvando;

  /// Mensagem de erro do último salvamento (ou `null`).
  final String? erro;

  EstadoAbelinhas copyWith({
    Decimal? valorAbelinha,
    List<FaixaAbelinha>? faixas,
    bool? salvando,
    Object? erro = _sentinela,
  }) {
    return EstadoAbelinhas(
      valorAbelinha: valorAbelinha ?? this.valorAbelinha,
      faixas: faixas ?? this.faixas,
      salvando: salvando ?? this.salvando,
      erro: erro == _sentinela ? this.erro : erro as String?,
    );
  }

  static const Object _sentinela = Object();
}

/// Controla a edição da regra de abelinhas (design §6.6, R9).
///
/// Mantém o valor de 1 abelinha com debounce (~300 ms) aceitando vírgula e as
/// faixas em memória; salva substituindo as faixas e persistindo o valor nas
/// configurações. Invalida os providers de produtos/abelinhas ao concluir.
class AbelinhasController extends StateNotifier<EstadoAbelinhas> {
  /// Cria o controller com o [Ref] e os dados iniciais.
  AbelinhasController(this._ref, DadosAbelinhas dados)
      : super(
          EstadoAbelinhas(
            valorAbelinha: dados.valorAbelinha,
            faixas: _ordenar(dados.faixas),
          ),
        );

  final Ref _ref;
  Timer? _debounce;

  static const Duration _debounceMs = Duration(milliseconds: 300);

  static List<FaixaAbelinha> _ordenar(List<FaixaAbelinha> faixas) =>
      [...faixas]..sort((a, b) => a.custoAte.compareTo(b.custoAte));

  /// Aplica o texto do valor de 1 abelinha (aceita vírgula) com debounce.
  void digitarValor(String texto) {
    _debounce?.cancel();
    _debounce = Timer(_debounceMs, () {
      final novo = Formatos.parseDecimal(texto);
      if (novo == null) return;
      if (mounted) state = state.copyWith(valorAbelinha: novo);
    });
  }

  /// Altera o teto de custo da faixa no índice [indice].
  void alterarCustoAte(int indice, Decimal custoAte) {
    final faixas = [...state.faixas];
    faixas[indice] = faixas[indice].copyWith(custoAte: custoAte);
    state = state.copyWith(faixas: faixas);
  }

  /// Altera as abelinhas da faixa no índice [indice].
  void alterarAbelinhas(int indice, Decimal abelinhas) {
    final faixas = [...state.faixas];
    faixas[indice] = faixas[indice].copyWith(abelinhas: abelinhas);
    state = state.copyWith(faixas: faixas);
  }

  /// Adiciona uma faixa nova (teto acima da maior existente).
  void adicionarFaixa() {
    final maiorTeto = state.faixas.isEmpty
        ? Decimal.zero
        : state.faixas.last.custoAte;
    final novaFaixa = FaixaAbelinha(
      id: '',
      empresaId: '',
      custoAte: maiorTeto + Decimal.fromInt(4),
      abelinhas: Decimal.parse('0.5'),
    );
    state = state.copyWith(faixas: [...state.faixas, novaFaixa]);
  }

  /// Remove a faixa no índice [indice].
  void removerFaixa(int indice) {
    final faixas = [...state.faixas]..removeAt(indice);
    state = state.copyWith(faixas: faixas);
  }

  /// Persiste as faixas (substituir) e o valor de 1 abelinha (configurações).
  Future<bool> salvar() async {
    state = state.copyWith(salvando: true, erro: null);
    try {
      final empresa = await _ref.read(empresaAtualProvider.future);
      if (empresa == null) {
        state = state.copyWith(
          salvando: false,
          erro: 'Nenhuma empresa ativa.',
        );
        return false;
      }
      final faixas = _ordenar(state.faixas);
      await _ref
          .read(faixaAbelinhaRepositoryProvider)
          .substituir(empresa.id, faixas);
      final config =
          await _ref.read(configuracoesRepositoryProvider).obter(empresa.id);
      await _ref.read(configuracoesRepositoryProvider).atualizar(
            config.copyWith(valorAbelinha: state.valorAbelinha),
          );
      _ref
        ..invalidate(produtosProvider)
        ..invalidate(faixasAbelinhaProvider)
        ..invalidate(configuracoesProvider)
        ..invalidate(dadosAbelinhasProvider);
      state = state.copyWith(salvando: false, faixas: faixas);
      return true;
    } on Object catch (e) {
      state = state.copyWith(salvando: false, erro: _mensagem(e));
      return false;
    }
  }

  String _mensagem(Object erro) {
    final texto = erro.toString();
    return texto.startsWith('ErroRepositorio: ')
        ? texto.substring('ErroRepositorio: '.length)
        : 'Não foi possível salvar. Tente de novo.';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

/// Provider do [AbelinhasController]. Família pelos dados carregados, para
/// inicializar o estado com as faixas/valor da empresa.
final abelinhasControllerProvider = StateNotifierProvider.autoDispose
    .family<AbelinhasController, EstadoAbelinhas, DadosAbelinhas>(
  AbelinhasController.new,
);
