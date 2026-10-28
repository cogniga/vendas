// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'faixa_abelinha.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FaixaAbelinha _$FaixaAbelinhaFromJson(Map<String, dynamic> json) {
  return _FaixaAbelinha.fromJson(json);
}

/// @nodoc
mixin _$FaixaAbelinha {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'empresa_id')
  String get empresaId => throw _privateConstructorUsedError;
  @JsonKey(name: 'custo_ate')
  @DecimalConverter()
  Decimal get custoAte => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get abelinhas => throw _privateConstructorUsedError;

  /// Serializes this FaixaAbelinha to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FaixaAbelinha
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FaixaAbelinhaCopyWith<FaixaAbelinha> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FaixaAbelinhaCopyWith<$Res> {
  factory $FaixaAbelinhaCopyWith(
    FaixaAbelinha value,
    $Res Function(FaixaAbelinha) then,
  ) = _$FaixaAbelinhaCopyWithImpl<$Res, FaixaAbelinha>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    @JsonKey(name: 'custo_ate') @DecimalConverter() Decimal custoAte,
    @DecimalConverter() Decimal abelinhas,
  });
}

/// @nodoc
class _$FaixaAbelinhaCopyWithImpl<$Res, $Val extends FaixaAbelinha>
    implements $FaixaAbelinhaCopyWith<$Res> {
  _$FaixaAbelinhaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FaixaAbelinha
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? custoAte = null,
    Object? abelinhas = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            empresaId: null == empresaId
                ? _value.empresaId
                : empresaId // ignore: cast_nullable_to_non_nullable
                      as String,
            custoAte: null == custoAte
                ? _value.custoAte
                : custoAte // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            abelinhas: null == abelinhas
                ? _value.abelinhas
                : abelinhas // ignore: cast_nullable_to_non_nullable
                      as Decimal,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FaixaAbelinhaImplCopyWith<$Res>
    implements $FaixaAbelinhaCopyWith<$Res> {
  factory _$$FaixaAbelinhaImplCopyWith(
    _$FaixaAbelinhaImpl value,
    $Res Function(_$FaixaAbelinhaImpl) then,
  ) = __$$FaixaAbelinhaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    @JsonKey(name: 'custo_ate') @DecimalConverter() Decimal custoAte,
    @DecimalConverter() Decimal abelinhas,
  });
}

/// @nodoc
class __$$FaixaAbelinhaImplCopyWithImpl<$Res>
    extends _$FaixaAbelinhaCopyWithImpl<$Res, _$FaixaAbelinhaImpl>
    implements _$$FaixaAbelinhaImplCopyWith<$Res> {
  __$$FaixaAbelinhaImplCopyWithImpl(
    _$FaixaAbelinhaImpl _value,
    $Res Function(_$FaixaAbelinhaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FaixaAbelinha
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? custoAte = null,
    Object? abelinhas = null,
  }) {
    return _then(
      _$FaixaAbelinhaImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        empresaId: null == empresaId
            ? _value.empresaId
            : empresaId // ignore: cast_nullable_to_non_nullable
                  as String,
        custoAte: null == custoAte
            ? _value.custoAte
            : custoAte // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        abelinhas: null == abelinhas
            ? _value.abelinhas
            : abelinhas // ignore: cast_nullable_to_non_nullable
                  as Decimal,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FaixaAbelinhaImpl implements _FaixaAbelinha {
  const _$FaixaAbelinhaImpl({
    required this.id,
    @JsonKey(name: 'empresa_id') required this.empresaId,
    @JsonKey(name: 'custo_ate') @DecimalConverter() required this.custoAte,
    @DecimalConverter() required this.abelinhas,
  });

  factory _$FaixaAbelinhaImpl.fromJson(Map<String, dynamic> json) =>
      _$$FaixaAbelinhaImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @override
  @JsonKey(name: 'custo_ate')
  @DecimalConverter()
  final Decimal custoAte;
  @override
  @DecimalConverter()
  final Decimal abelinhas;

  @override
  String toString() {
    return 'FaixaAbelinha(id: $id, empresaId: $empresaId, custoAte: $custoAte, abelinhas: $abelinhas)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FaixaAbelinhaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.empresaId, empresaId) ||
                other.empresaId == empresaId) &&
            (identical(other.custoAte, custoAte) ||
                other.custoAte == custoAte) &&
            (identical(other.abelinhas, abelinhas) ||
                other.abelinhas == abelinhas));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, empresaId, custoAte, abelinhas);

  /// Create a copy of FaixaAbelinha
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FaixaAbelinhaImplCopyWith<_$FaixaAbelinhaImpl> get copyWith =>
      __$$FaixaAbelinhaImplCopyWithImpl<_$FaixaAbelinhaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FaixaAbelinhaImplToJson(this);
  }
}

abstract class _FaixaAbelinha implements FaixaAbelinha {
  const factory _FaixaAbelinha({
    required final String id,
    @JsonKey(name: 'empresa_id') required final String empresaId,
    @JsonKey(name: 'custo_ate')
    @DecimalConverter()
    required final Decimal custoAte,
    @DecimalConverter() required final Decimal abelinhas,
  }) = _$FaixaAbelinhaImpl;

  factory _FaixaAbelinha.fromJson(Map<String, dynamic> json) =
      _$FaixaAbelinhaImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'empresa_id')
  String get empresaId;
  @override
  @JsonKey(name: 'custo_ate')
  @DecimalConverter()
  Decimal get custoAte;
  @override
  @DecimalConverter()
  Decimal get abelinhas;

  /// Create a copy of FaixaAbelinha
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FaixaAbelinhaImplCopyWith<_$FaixaAbelinhaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
