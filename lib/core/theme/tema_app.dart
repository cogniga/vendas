import 'package:flutter/material.dart';
import 'package:sales/core/theme/tokens.dart';

/// Monta os temas claro e escuro do app (design.md §7.1–7.3).
///
/// Usa a fonte Plus Jakarta Sans empacotada localmente (assets/fonts) e aplica
/// `tabularFigures` nos números. A fonte é um asset para não depender de rede.
class TemaApp {
  const TemaApp._();

  /// Família de fonte declarada no pubspec (assets/fonts).
  static const String fonte = 'Plus Jakarta Sans';

  static ThemeData claro() => _montar(CoresApp.claro, Brightness.light);
  static ThemeData escuro() => _montar(CoresApp.escuro, Brightness.dark);

  static ThemeData _montar(CoresApp c, Brightness brilho) {
    final base = ThemeData(brightness: brilho, useMaterial3: true);
    final textTheme = _textTheme(base.textTheme, c);

    return base.copyWith(
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: c.accent,
        brightness: brilho,
        surface: c.surface,
        error: c.bad,
      ),
      extensions: [c],
      textTheme: textTheme,
      dividerColor: c.line,
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Raios.cartao),
          side: BorderSide(color: c.line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Raios.controle),
          borderSide: BorderSide(color: c.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Raios.controle),
          borderSide: BorderSide(color: c.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Raios.controle),
          borderSide: BorderSide(color: c.accent, width: 1.5),
        ),
        labelStyle: TextStyle(color: c.muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.accentInk,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Raios.controle),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink,
          side: BorderSide(color: c.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Raios.controle),
          ),
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, CoresApp c) {
    const tabular = [FontFeature.tabularFigures()];
    final t = base.apply(fontFamily: fonte);
    return t.copyWith(
      // Título de página 26/600 (−0,02em).
      headlineMedium: t.headlineMedium?.copyWith(
        fontFamily: fonte,
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.52,
        color: c.ink,
      ),
      // Título de painel 15/600.
      titleMedium: t.titleMedium?.copyWith(
        fontFamily: fonte,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: c.ink,
      ),
      // KPI 22/600 tabular.
      titleLarge: t.titleLarge?.copyWith(
        fontFamily: fonte,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        fontFeatures: tabular,
        color: c.ink,
      ),
      // Corpo 14/400.
      bodyMedium: t.bodyMedium?.copyWith(
        fontFamily: fonte,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: c.ink,
      ),
      // Rótulos 12,5/500 muted.
      labelLarge: t.labelLarge?.copyWith(
        fontFamily: fonte,
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: c.muted,
      ),
      // Sublinha de lista 12/400 muted.
      bodySmall: t.bodySmall?.copyWith(
        fontFamily: fonte,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: c.muted,
      ),
    );
  }
}
