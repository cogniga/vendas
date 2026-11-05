import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Chave de persistência do id da empresa escolhida pelo usuário.
const _chaveEmpresa = 'empresa_selecionada_id';

/// Guarda o id da empresa selecionada pelo usuário (tela Dados e
/// configurações), persistido com `shared_preferences`.
///
/// `null` enquanto o usuário não escolheu nenhuma. Quando definido, o
/// `empresaAtualProvider` passa a usar essa empresa em todo o sistema.
class EmpresaSelecionadaController extends StateNotifier<String?> {
  EmpresaSelecionadaController() : super(null) {
    _carregar();
  }

  Future<void> _carregar() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_chaveEmpresa);
  }

  /// Define a empresa escolhida e persiste.
  Future<void> definir(String empresaId) async {
    state = empresaId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveEmpresa, empresaId);
  }

  /// Limpa a escolha.
  Future<void> limpar() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveEmpresa);
  }
}

/// Id da empresa selecionada (ou `null`).
final empresaSelecionadaProvider =
    StateNotifierProvider<EmpresaSelecionadaController, String?>(
  (ref) => EmpresaSelecionadaController(),
);
