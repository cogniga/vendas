// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'painel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$KpisPainel {
  /// `Σ precoVenda`.
  Decimal get faturamento => throw _privateConstructorUsedError;

  /// `Σ taxaEfetiva`.
  Decimal get taxas => throw _privateConstructorUsedError;

  /// `Σ liquido`.
  Decimal get liquido => throw _privateConstructorUsedError;

  /// `Σ custo`.
  Decimal get custo => throw _privateConstructorUsedError;

  /// `Σ lucro`.
  Decimal get lucro => throw _privateConstructorUsedError;

  /// `lucro / faturamento`, em fração.
  Decimal get margem => throw _privateConstructorUsedError;

  /// Create a copy of KpisPainel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KpisPainelCopyWith<KpisPainel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KpisPainelCopyWith<$Res> {
  factory $KpisPainelCopyWith(
    KpisPainel value,
    $Res Function(KpisPainel) then,
  ) = _$KpisPainelCopyWithImpl<$Res, KpisPainel>;
  @useResult
  $Res call({
    Decimal faturamento,
    Decimal taxas,
    Decimal liquido,
    Decimal custo,
    Decimal lucro,
    Decimal margem,
  });
}

/// @nodoc
class _$KpisPainelCopyWithImpl<$Res, $Val extends KpisPainel>
    implements $KpisPainelCopyWith<$Res> {
  _$KpisPainelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KpisPainel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? faturamento = null,
    Object? taxas = null,
    Object? liquido = null,
    Object? custo = null,
    Object? lucro = null,
    Object? margem = null,
  }) {
    return _then(
      _value.copyWith(
            faturamento: null == faturamento
                ? _value.faturamento
                : faturamento // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            taxas: null == taxas
                ? _value.taxas
                : taxas // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            liquido: null == liquido
                ? _value.liquido
                : liquido // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            custo: null == custo
                ? _value.custo
                : custo // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            lucro: null == lucro
                ? _value.lucro
                : lucro // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            margem: null == margem
                ? _value.margem
                : margem // ignore: cast_nullable_to_non_nullable
                      as Decimal,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KpisPainelImplCopyWith<$Res>
    implements $KpisPainelCopyWith<$Res> {
  factory _$$KpisPainelImplCopyWith(
    _$KpisPainelImpl value,
    $Res Function(_$KpisPainelImpl) then,
  ) = __$$KpisPainelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Decimal faturamento,
    Decimal taxas,
    Decimal liquido,
    Decimal custo,
    Decimal lucro,
    Decimal margem,
  });
}

/// @nodoc
class __$$KpisPainelImplCopyWithImpl<$Res>
    extends _$KpisPainelCopyWithImpl<$Res, _$KpisPainelImpl>
    implements _$$KpisPainelImplCopyWith<$Res> {
  __$$KpisPainelImplCopyWithImpl(
    _$KpisPainelImpl _value,
    $Res Function(_$KpisPainelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KpisPainel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? faturamento = null,
    Object? taxas = null,
    Object? liquido = null,
    Object? custo = null,
    Object? lucro = null,
    Object? margem = null,
  }) {
    return _then(
      _$KpisPainelImpl(
        faturamento: null == faturamento
            ? _value.faturamento
            : faturamento // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        taxas: null == taxas
            ? _value.taxas
            : taxas // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        liquido: null == liquido
            ? _value.liquido
            : liquido // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        custo: null == custo
            ? _value.custo
            : custo // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        lucro: null == lucro
            ? _value.lucro
            : lucro // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        margem: null == margem
            ? _value.margem
            : margem // ignore: cast_nullable_to_non_nullable
                  as Decimal,
      ),
    );
  }
}

/// @nodoc

class _$KpisPainelImpl implements _KpisPainel {
  const _$KpisPainelImpl({
    required this.faturamento,
    required this.taxas,
    required this.liquido,
    required this.custo,
    required this.lucro,
    required this.margem,
  });

  /// `Σ precoVenda`.
  @override
  final Decimal faturamento;

  /// `Σ taxaEfetiva`.
  @override
  final Decimal taxas;

  /// `Σ liquido`.
  @override
  final Decimal liquido;

  /// `Σ custo`.
  @override
  final Decimal custo;

  /// `Σ lucro`.
  @override
  final Decimal lucro;

  /// `lucro / faturamento`, em fração.
  @override
  final Decimal margem;

  @override
  String toString() {
    return 'KpisPainel(faturamento: $faturamento, taxas: $taxas, liquido: $liquido, custo: $custo, lucro: $lucro, margem: $margem)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KpisPainelImpl &&
            (identical(other.faturamento, faturamento) ||
                other.faturamento == faturamento) &&
            (identical(other.taxas, taxas) || other.taxas == taxas) &&
            (identical(other.liquido, liquido) || other.liquido == liquido) &&
            (identical(other.custo, custo) || other.custo == custo) &&
            (identical(other.lucro, lucro) || other.lucro == lucro) &&
            (identical(other.margem, margem) || other.margem == margem));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    faturamento,
    taxas,
    liquido,
    custo,
    lucro,
    margem,
  );

  /// Create a copy of KpisPainel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KpisPainelImplCopyWith<_$KpisPainelImpl> get copyWith =>
      __$$KpisPainelImplCopyWithImpl<_$KpisPainelImpl>(this, _$identity);
}

abstract class _KpisPainel implements KpisPainel {
  const factory _KpisPainel({
    required final Decimal faturamento,
    required final Decimal taxas,
    required final Decimal liquido,
    required final Decimal custo,
    required final Decimal lucro,
    required final Decimal margem,
  }) = _$KpisPainelImpl;

  /// `Σ precoVenda`.
  @override
  Decimal get faturamento;

  /// `Σ taxaEfetiva`.
  @override
  Decimal get taxas;

  /// `Σ liquido`.
  @override
  Decimal get liquido;

  /// `Σ custo`.
  @override
  Decimal get custo;

  /// `Σ lucro`.
  @override
  Decimal get lucro;

  /// `lucro / faturamento`, em fração.
  @override
  Decimal get margem;

  /// Create a copy of KpisPainel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KpisPainelImplCopyWith<_$KpisPainelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PontoAtencao {
  /// Tipo: `destinos`, `kitPrejuizo`, `kitMargemBaixa`, `codigoRepetido`.
  String get tipo => throw _privateConstructorUsedError;

  /// Mensagem descritiva.
  String get mensagem => throw _privateConstructorUsedError;

  /// Gravidade (define a cor do aviso).
  GravidadeAtencao get gravidade => throw _privateConstructorUsedError;

  /// Create a copy of PontoAtencao
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PontoAtencaoCopyWith<PontoAtencao> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PontoAtencaoCopyWith<$Res> {
  factory $PontoAtencaoCopyWith(
    PontoAtencao value,
    $Res Function(PontoAtencao) then,
  ) = _$PontoAtencaoCopyWithImpl<$Res, PontoAtencao>;
  @useResult
  $Res call({String tipo, String mensagem, GravidadeAtencao gravidade});
}

/// @nodoc
class _$PontoAtencaoCopyWithImpl<$Res, $Val extends PontoAtencao>
    implements $PontoAtencaoCopyWith<$Res> {
  _$PontoAtencaoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PontoAtencao
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tipo = null,
    Object? mensagem = null,
    Object? gravidade = null,
  }) {
    return _then(
      _value.copyWith(
            tipo: null == tipo
                ? _value.tipo
                : tipo // ignore: cast_nullable_to_non_nullable
                      as String,
            mensagem: null == mensagem
                ? _value.mensagem
                : mensagem // ignore: cast_nullable_to_non_nullable
                      as String,
            gravidade: null == gravidade
                ? _value.gravidade
                : gravidade // ignore: cast_nullable_to_non_nullable
                      as GravidadeAtencao,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PontoAtencaoImplCopyWith<$Res>
    implements $PontoAtencaoCopyWith<$Res> {
  factory _$$PontoAtencaoImplCopyWith(
    _$PontoAtencaoImpl value,
    $Res Function(_$PontoAtencaoImpl) then,
  ) = __$$PontoAtencaoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String tipo, String mensagem, GravidadeAtencao gravidade});
}

/// @nodoc
class __$$PontoAtencaoImplCopyWithImpl<$Res>
    extends _$PontoAtencaoCopyWithImpl<$Res, _$PontoAtencaoImpl>
    implements _$$PontoAtencaoImplCopyWith<$Res> {
  __$$PontoAtencaoImplCopyWithImpl(
    _$PontoAtencaoImpl _value,
    $Res Function(_$PontoAtencaoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PontoAtencao
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tipo = null,
    Object? mensagem = null,
    Object? gravidade = null,
  }) {
    return _then(
      _$PontoAtencaoImpl(
        tipo: null == tipo
            ? _value.tipo
            : tipo // ignore: cast_nullable_to_non_nullable
                  as String,
        mensagem: null == mensagem
            ? _value.mensagem
            : mensagem // ignore: cast_nullable_to_non_nullable
                  as String,
        gravidade: null == gravidade
            ? _value.gravidade
            : gravidade // ignore: cast_nullable_to_non_nullable
                  as GravidadeAtencao,
      ),
    );
  }
}

/// @nodoc

class _$PontoAtencaoImpl implements _PontoAtencao {
  const _$PontoAtencaoImpl({
    required this.tipo,
    required this.mensagem,
    required this.gravidade,
  });

  /// Tipo: `destinos`, `kitPrejuizo`, `kitMargemBaixa`, `codigoRepetido`.
  @override
  final String tipo;

  /// Mensagem descritiva.
  @override
  final String mensagem;

  /// Gravidade (define a cor do aviso).
  @override
  final GravidadeAtencao gravidade;

  @override
  String toString() {
    return 'PontoAtencao(tipo: $tipo, mensagem: $mensagem, gravidade: $gravidade)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PontoAtencaoImpl &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.mensagem, mensagem) ||
                other.mensagem == mensagem) &&
            (identical(other.gravidade, gravidade) ||
                other.gravidade == gravidade));
  }

  @override
  int get hashCode => Object.hash(runtimeType, tipo, mensagem, gravidade);

  /// Create a copy of PontoAtencao
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PontoAtencaoImplCopyWith<_$PontoAtencaoImpl> get copyWith =>
      __$$PontoAtencaoImplCopyWithImpl<_$PontoAtencaoImpl>(this, _$identity);
}

abstract class _PontoAtencao implements PontoAtencao {
  const factory _PontoAtencao({
    required final String tipo,
    required final String mensagem,
    required final GravidadeAtencao gravidade,
  }) = _$PontoAtencaoImpl;

  /// Tipo: `destinos`, `kitPrejuizo`, `kitMargemBaixa`, `codigoRepetido`.
  @override
  String get tipo;

  /// Mensagem descritiva.
  @override
  String get mensagem;

  /// Gravidade (define a cor do aviso).
  @override
  GravidadeAtencao get gravidade;

  /// Create a copy of PontoAtencao
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PontoAtencaoImplCopyWith<_$PontoAtencaoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
