import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Chave usada para persistir a preferência de tema localmente.
const _chaveTema = 'tema_app';

/// Controla a preferência de tema (Claro / Escuro / Auto) persistida com
/// `shared_preferences`. Exposto via [temaProvider].
class TemaController extends StateNotifier<ThemeMode> {
  TemaController() : super(ThemeMode.light) {
    _carregar();
  }

  Future<void> _carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final salvo = prefs.getString(_chaveTema);
    state = switch (salvo) {
      'escuro' => ThemeMode.dark,
      'auto' => ThemeMode.system,
      _ => ThemeMode.light,
    };
  }

  /// Define o modo e persiste a escolha.
  Future<void> definir(ThemeMode modo) async {
    state = modo;
    final prefs = await SharedPreferences.getInstance();
    final valor = switch (modo) {
      ThemeMode.dark => 'escuro',
      ThemeMode.system => 'auto',
      ThemeMode.light => 'claro',
    };
    await prefs.setString(_chaveTema, valor);
  }
}

/// Provider do modo de tema atual.
final temaProvider = StateNotifierProvider<TemaController, ThemeMode>(
  (ref) => TemaController(),
);
