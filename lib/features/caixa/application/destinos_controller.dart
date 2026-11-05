import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/data/repositorios/destino_repository.dart';
import 'package:sales/domain/calculos/decimais.dart';
import 'package:sales/domain/entidades/destino.dart';

/// Paleta usada ao adicionar um destino novo (design do protótipo).
const _paleta = <String>[
  '#2B7A70',
  '#9A8FD4',
  '#D98C3F',
  '#4A8FD9',
  '#C85C8E',
  '#5AA469',
  '#B5894A',
  '#7A6FD4',
];

/// Estado editável da lista de destinos + flags de salvamento.
class EstadoDestinos {
  const EstadoDestinos({
    required this.destinos,
    this.salvando = false,
    this.erro = false,
  });

  /// Lista editável de destinos (inclui novos com `id` vazio).
  final List<Destino> destinos;

  /// `true` enquanto um salvamento está em andamento.
  final bool salvando;

  /// `true` quando o último salvamento falhou.
  final bool erro;

  /// Soma dos percentuais de todos os destinos.
  Decimal get somaPercentual =>
      destinos.fold(zero, (soma, d) => soma + d.percentual);

  EstadoDestinos copyWith({
    List<Destino>? destinos,
    bool? salvando,
    bool? erro,
  }) {
    return EstadoDestinos(
      destinos: destinos ?? this.destinos,
      salvando: salvando ?? this.salvando,
      erro: erro ?? this.erro,
    );
  }
}

/// Controlador da edição de destinos de rateio do caixa.
///
/// Mantém uma cópia editável dos destinos e, ao [salvar], faz o diff contra a
/// lista original: cria os novos (`id` vazio), atualiza os existentes e exclui
/// os removidos — tudo via [DestinoRepository]. Nenhuma chamada ao Supabase
/// fora do repositório.
class DestinosController extends StateNotifier<EstadoDestinos> {
  DestinosController(this._repo, this._empresaId, List<Destino> originais)
      : _originais = List.of(originais),
        super(EstadoDestinos(destinos: List.of(originais)));

  final DestinoRepository _repo;
  final String _empresaId;
  final List<Destino> _originais;

  /// Soma dos percentuais da edição atual.
  Decimal get somaPercentual => state.somaPercentual;

  /// Adiciona um destino novo (id vazio) com cor da paleta e percentual 0.
  void adicionar() {
    final cor = _paleta[state.destinos.length % _paleta.length];
    final novo = Destino(
      id: '',
      empresaId: _empresaId,
      nome: 'Novo destino',
      cor: cor,
      percentual: zero,
      ordem: state.destinos.length,
    );
    state = state.copyWith(destinos: [...state.destinos, novo]);
  }

  /// Remove o destino na posição [index].
  void remover(int index) {
    final lista = [...state.destinos]..removeAt(index);
    state = state.copyWith(destinos: lista);
  }

  /// Altera o nome do destino em [index].
  void alterarNome(int index, String nome) {
    _substituir(index, (d) => d.copyWith(nome: nome));
  }

  /// Altera a cor (hex) do destino em [index].
  void alterarCor(int index, String cor) {
    _substituir(index, (d) => d.copyWith(cor: cor));
  }

  /// Altera o percentual do destino em [index].
  void alterarPercentual(int index, Decimal percentual) {
    _substituir(index, (d) => d.copyWith(percentual: percentual));
  }

  void _substituir(int index, Destino Function(Destino) mudar) {
    final lista = [...state.destinos];
    lista[index] = mudar(lista[index]);
    state = state.copyWith(destinos: lista);
  }

  /// Persiste a edição: cria novos, atualiza existentes e exclui removidos.
  ///
  /// Devolve `true` em sucesso. Em erro, marca `erro` no estado e devolve
  /// `false`.
  Future<bool> salvar() async {
    state = state.copyWith(salvando: true, erro: false);
    try {
      final atuais = state.destinos;
      final idsAtuais =
          atuais.where((d) => d.id.isNotEmpty).map((d) => d.id).toSet();

      for (final original in _originais) {
        if (!idsAtuais.contains(original.id)) {
          await _repo.excluir(original.id);
        }
      }
      for (var i = 0; i < atuais.length; i++) {
        final d = atuais[i].copyWith(ordem: i);
        if (d.id.isEmpty) {
          await _repo.criar(d);
        } else {
          await _repo.atualizar(d);
        }
      }
      state = state.copyWith(salvando: false);
      return true;
    } on Object {
      state = state.copyWith(salvando: false, erro: true);
      return false;
    }
  }
}

/// Provider do controlador de destinos, por empresa e lista original.
///
/// A `family` usa o `empresaId` como chave; a lista original é passada como
/// argumento de criação via [DestinosController].
final destinosControllerProvider = StateNotifierProvider.autoDispose
    .family<DestinosController, EstadoDestinos, ArgsDestinos>((ref, args) {
  return DestinosController(
    ref.watch(destinoRepositoryProvider),
    args.empresaId,
    args.originais,
  );
});

/// Argumentos para criar um [DestinosController]: empresa e destinos atuais.
@immutable
class ArgsDestinos {
  const ArgsDestinos({required this.empresaId, required this.originais});

  final String empresaId;
  final List<Destino> originais;

  @override
  bool operator ==(Object other) =>
      other is ArgsDestinos && other.empresaId == empresaId;

  @override
  int get hashCode => empresaId.hashCode;
}
