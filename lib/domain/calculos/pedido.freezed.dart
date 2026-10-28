// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pedido.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ResultadoPedido {
  /// `Σ custoUnitario * qtd` dos itens (snapshots).
  Decimal get mercadoria => throw _privateConstructorUsedError;

  /// `mercadoria + embalagem + impressao + outros`.
  Decimal get custo => throw _privateConstructorUsedError;

  /// Taxa estimada: `taxa(pl, precoVenda, itensTaxaFixa)`.
  Decimal get taxaEstimada => throw _privateConstructorUsedError;

  /// `precoVenda - taxaEstimada`.
  Decimal get liquidoEstimado => throw _privateConstructorUsedError;

  /// `liquidoInformado ?? liquidoEstimado`.
  Decimal get liquido => throw _privateConstructorUsedError;

  /// `precoVenda - liquido`.
  Decimal get taxaEfetiva => throw _privateConstructorUsedError;

  /// `liquido - custo`.
  Decimal get lucro => throw _privateConstructorUsedError;

  /// `lucro / precoVenda`, em fração.
  Decimal get margem => throw _privateConstructorUsedError;

  /// `Σ abelinhasUnitarias * qtd` dos itens.
  Decimal get abelinhasPedido => throw _privateConstructorUsedError;

  /// Create a copy of ResultadoPedido
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResultadoPedidoCopyWith<ResultadoPedido> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultadoPedidoCopyWith<$Res> {
  factory $ResultadoPedidoCopyWith(
    ResultadoPedido value,
    $Res Function(ResultadoPedido) then,
  ) = _$ResultadoPedidoCopyWithImpl<$Res, ResultadoPedido>;
  @useResult
  $Res call({
    Decimal mercadoria,
    Decimal custo,
    Decimal taxaEstimada,
    Decimal liquidoEstimado,
    Decimal liquido,
    Decimal taxaEfetiva,
    Decimal lucro,
    Decimal margem,
    Decimal abelinhasPedido,
  });
}

/// @nodoc
class _$ResultadoPedidoCopyWithImpl<$Res, $Val extends ResultadoPedido>
    implements $ResultadoPedidoCopyWith<$Res> {
  _$ResultadoPedidoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResultadoPedido
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mercadoria = null,
    Object? custo = null,
    Object? taxaEstimada = null,
    Object? liquidoEstimado = null,
    Object? liquido = null,
    Object? taxaEfetiva = null,
    Object? lucro = null,
    Object? margem = null,
    Object? abelinhasPedido = null,
  }) {
    return _then(
      _value.copyWith(
            mercadoria: null == mercadoria
                ? _value.mercadoria
                : mercadoria // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            custo: null == custo
                ? _value.custo
                : custo // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            taxaEstimada: null == taxaEstimada
                ? _value.taxaEstimada
                : taxaEstimada // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            liquidoEstimado: null == liquidoEstimado
                ? _value.liquidoEstimado
                : liquidoEstimado // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            liquido: null == liquido
                ? _value.liquido
                : liquido // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            taxaEfetiva: null == taxaEfetiva
                ? _value.taxaEfetiva
                : taxaEfetiva // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            lucro: null == lucro
                ? _value.lucro
                : lucro // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            margem: null == margem
                ? _value.margem
                : margem // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            abelinhasPedido: null == abelinhasPedido
                ? _value.abelinhasPedido
                : abelinhasPedido // ignore: cast_nullable_to_non_nullable
                      as Decimal,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ResultadoPedidoImplCopyWith<$Res>
    implements $ResultadoPedidoCopyWith<$Res> {
  factory _$$ResultadoPedidoImplCopyWith(
    _$ResultadoPedidoImpl value,
    $Res Function(_$ResultadoPedidoImpl) then,
  ) = __$$ResultadoPedidoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Decimal mercadoria,
    Decimal custo,
    Decimal taxaEstimada,
    Decimal liquidoEstimado,
    Decimal liquido,
    Decimal taxaEfetiva,
    Decimal lucro,
    Decimal margem,
    Decimal abelinhasPedido,
  });
}

/// @nodoc
class __$$ResultadoPedidoImplCopyWithImpl<$Res>
    extends _$ResultadoPedidoCopyWithImpl<$Res, _$ResultadoPedidoImpl>
    implements _$$ResultadoPedidoImplCopyWith<$Res> {
  __$$ResultadoPedidoImplCopyWithImpl(
    _$ResultadoPedidoImpl _value,
    $Res Function(_$ResultadoPedidoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResultadoPedido
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mercadoria = null,
    Object? custo = null,
    Object? taxaEstimada = null,
    Object? liquidoEstimado = null,
    Object? liquido = null,
    Object? taxaEfetiva = null,
    Object? lucro = null,
    Object? margem = null,
    Object? abelinhasPedido = null,
  }) {
    return _then(
      _$ResultadoPedidoImpl(
        mercadoria: null == mercadoria
            ? _value.mercadoria
            : mercadoria // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        custo: null == custo
            ? _value.custo
            : custo // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        taxaEstimada: null == taxaEstimada
            ? _value.taxaEstimada
            : taxaEstimada // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        liquidoEstimado: null == liquidoEstimado
            ? _value.liquidoEstimado
            : liquidoEstimado // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        liquido: null == liquido
            ? _value.liquido
            : liquido // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        taxaEfetiva: null == taxaEfetiva
            ? _value.taxaEfetiva
            : taxaEfetiva // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        lucro: null == lucro
            ? _value.lucro
            : lucro // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        margem: null == margem
            ? _value.margem
            : margem // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        abelinhasPedido: null == abelinhasPedido
            ? _value.abelinhasPedido
            : abelinhasPedido // ignore: cast_nullable_to_non_nullable
                  as Decimal,
      ),
    );
  }
}

/// @nodoc

class _$ResultadoPedidoImpl implements _ResultadoPedido {
  const _$ResultadoPedidoImpl({
    required this.mercadoria,
    required this.custo,
    required this.taxaEstimada,
    required this.liquidoEstimado,
    required this.liquido,
    required this.taxaEfetiva,
    required this.lucro,
    required this.margem,
    required this.abelinhasPedido,
  });

  /// `Σ custoUnitario * qtd` dos itens (snapshots).
  @override
  final Decimal mercadoria;

  /// `mercadoria + embalagem + impressao + outros`.
  @override
  final Decimal custo;

  /// Taxa estimada: `taxa(pl, precoVenda, itensTaxaFixa)`.
  @override
  final Decimal taxaEstimada;

  /// `precoVenda - taxaEstimada`.
  @override
  final Decimal liquidoEstimado;

  /// `liquidoInformado ?? liquidoEstimado`.
  @override
  final Decimal liquido;

  /// `precoVenda - liquido`.
  @override
  final Decimal taxaEfetiva;

  /// `liquido - custo`.
  @override
  final Decimal lucro;

  /// `lucro / precoVenda`, em fração.
  @override
  final Decimal margem;

  /// `Σ abelinhasUnitarias * qtd` dos itens.
  @override
  final Decimal abelinhasPedido;

  @override
  String toString() {
    return 'ResultadoPedido(mercadoria: $mercadoria, custo: $custo, taxaEstimada: $taxaEstimada, liquidoEstimado: $liquidoEstimado, liquido: $liquido, taxaEfetiva: $taxaEfetiva, lucro: $lucro, margem: $margem, abelinhasPedido: $abelinhasPedido)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResultadoPedidoImpl &&
            (identical(other.mercadoria, mercadoria) ||
                other.mercadoria == mercadoria) &&
            (identical(other.custo, custo) || other.custo == custo) &&
            (identical(other.taxaEstimada, taxaEstimada) ||
                other.taxaEstimada == taxaEstimada) &&
            (identical(other.liquidoEstimado, liquidoEstimado) ||
                other.liquidoEstimado == liquidoEstimado) &&
            (identical(other.liquido, liquido) || other.liquido == liquido) &&
            (identical(other.taxaEfetiva, taxaEfetiva) ||
                other.taxaEfetiva == taxaEfetiva) &&
            (identical(other.lucro, lucro) || other.lucro == lucro) &&
            (identical(other.margem, margem) || other.margem == margem) &&
            (identical(other.abelinhasPedido, abelinhasPedido) ||
                other.abelinhasPedido == abelinhasPedido));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    mercadoria,
    custo,
    taxaEstimada,
    liquidoEstimado,
    liquido,
    taxaEfetiva,
    lucro,
    margem,
    abelinhasPedido,
  );

  /// Create a copy of ResultadoPedido
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResultadoPedidoImplCopyWith<_$ResultadoPedidoImpl> get copyWith =>
      __$$ResultadoPedidoImplCopyWithImpl<_$ResultadoPedidoImpl>(
        this,
        _$identity,
      );
}

abstract class _ResultadoPedido implements ResultadoPedido {
  const factory _ResultadoPedido({
    required final Decimal mercadoria,
    required final Decimal custo,
    required final Decimal taxaEstimada,
    required final Decimal liquidoEstimado,
    required final Decimal liquido,
    required final Decimal taxaEfetiva,
    required final Decimal lucro,
    required final Decimal margem,
    required final Decimal abelinhasPedido,
  }) = _$ResultadoPedidoImpl;

  /// `Σ custoUnitario * qtd` dos itens (snapshots).
  @override
  Decimal get mercadoria;

  /// `mercadoria + embalagem + impressao + outros`.
  @override
  Decimal get custo;

  /// Taxa estimada: `taxa(pl, precoVenda, itensTaxaFixa)`.
  @override
  Decimal get taxaEstimada;

  /// `precoVenda - taxaEstimada`.
  @override
  Decimal get liquidoEstimado;

  /// `liquidoInformado ?? liquidoEstimado`.
  @override
  Decimal get liquido;

  /// `precoVenda - liquido`.
  @override
  Decimal get taxaEfetiva;

  /// `liquido - custo`.
  @override
  Decimal get lucro;

  /// `lucro / precoVenda`, em fração.
  @override
  Decimal get margem;

  /// `Σ abelinhasUnitarias * qtd` dos itens.
  @override
  Decimal get abelinhasPedido;

  /// Create a copy of ResultadoPedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResultadoPedidoImplCopyWith<_$ResultadoPedidoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
