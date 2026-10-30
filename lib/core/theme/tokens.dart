import 'package:flutter/material.dart';

/// Tokens de cor do design (design.md §7.1), para tema claro e escuro.
///
/// São expostos via [ThemeExtension] ([CoresApp]) para uso nos widgets sem
/// depender de constantes globais espalhadas.
@immutable
class CoresApp extends ThemeExtension<CoresApp> {
  const CoresApp({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.ink,
    required this.muted,
    required this.line,
    required this.accent,
    required this.accentInk,
    required this.accentSoft,
    required this.good,
    required this.goodSoft,
    required this.warn,
    required this.warnSoft,
    required this.bad,
    required this.badSoft,
  });

  final Color bg;
  final Color surface;
  final Color surface2;
  final Color ink;
  final Color muted;
  final Color line;
  final Color accent;
  final Color accentInk;
  final Color accentSoft;
  final Color good;
  final Color goodSoft;
  final Color warn;
  final Color warnSoft;
  final Color bad;
  final Color badSoft;

  static const CoresApp claro = CoresApp(
    bg: Color(0xFFF5F6F8),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF1F3F5),
    ink: Color(0xFF1C2128),
    muted: Color(0xFF687280),
    line: Color(0xFFE7E9EE),
    accent: Color(0xFF2B7A70),
    accentInk: Color(0xFFFFFFFF),
    accentSoft: Color(0xFFE8F3F1),
    good: Color(0xFF2E7D55),
    goodSoft: Color(0xFFE9F5EE),
    warn: Color(0xFF9A6212),
    warnSoft: Color(0xFFFBF3E4),
    bad: Color(0xFFB54A40),
    badSoft: Color(0xFFFCECEA),
  );

  static const CoresApp escuro = CoresApp(
    bg: Color(0xFF111418),
    surface: Color(0xFF181C21),
    surface2: Color(0xFF20252C),
    ink: Color(0xFFE9ECF0),
    muted: Color(0xFF9AA3AE),
    line: Color(0xFF2A3038),
    accent: Color(0xFF6CC3B6),
    accentInk: Color(0xFF0D1F1C),
    accentSoft: Color(0xFF1C2F2C),
    good: Color(0xFF6FCF9A),
    goodSoft: Color(0xFF17291F),
    warn: Color(0xFFE3B065),
    warnSoft: Color(0xFF2E2615),
    bad: Color(0xFFEE8F86),
    badSoft: Color(0xFF331D1B),
  );

  @override
  CoresApp copyWith({
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? ink,
    Color? muted,
    Color? line,
    Color? accent,
    Color? accentInk,
    Color? accentSoft,
    Color? good,
    Color? goodSoft,
    Color? warn,
    Color? warnSoft,
    Color? bad,
    Color? badSoft,
  }) {
    return CoresApp(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      line: line ?? this.line,
      accent: accent ?? this.accent,
      accentInk: accentInk ?? this.accentInk,
      accentSoft: accentSoft ?? this.accentSoft,
      good: good ?? this.good,
      goodSoft: goodSoft ?? this.goodSoft,
      warn: warn ?? this.warn,
      warnSoft: warnSoft ?? this.warnSoft,
      bad: bad ?? this.bad,
      badSoft: badSoft ?? this.badSoft,
    );
  }

  @override
  CoresApp lerp(ThemeExtension<CoresApp>? other, double t) {
    if (other is! CoresApp) return this;
    return CoresApp(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentInk: Color.lerp(accentInk, other.accentInk, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      good: Color.lerp(good, other.good, t)!,
      goodSoft: Color.lerp(goodSoft, other.goodSoft, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      warnSoft: Color.lerp(warnSoft, other.warnSoft, t)!,
      bad: Color.lerp(bad, other.bad, t)!,
      badSoft: Color.lerp(badSoft, other.badSoft, t)!,
    );
  }
}

/// Raios de borda (design.md §7.3).
class Raios {
  const Raios._();
  static const double controle = 8;
  static const double cartao = 14;
  static const double pill = 6;
}

/// Espaçamentos base (design.md §7.3).
class Espacos {
  const Espacos._();
  static const double base = 4;
  static const double g8 = 8;
  static const double g12 = 12;
  static const double g16 = 16;
  static const double g20 = 20;
  static const double paddingPainel = 20;
  static const double paddingPainelCelular = 16;
}

/// Atalho para obter as cores do tema atual.
extension CoresAppContext on BuildContext {
  CoresApp get cores => Theme.of(this).extension<CoresApp>()!;
}
