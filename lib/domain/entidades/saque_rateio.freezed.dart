// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saque_rateio.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SaqueRateio _$SaqueRateioFromJson(Map<String, dynamic> json) {
  return _SaqueRateio.fromJson(json);
}

/// @nodoc
mixin _$SaqueRateio {
  @JsonKey(name: 'saque_id')
  String get saqueId => throw _privateConstructorUsedError;
  @JsonKey(name: 'empresa_id')
  String get empresaId => throw _privateConstructorUsedError;
  @JsonKey(name: 'destino_id')
  String get destinoId => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get percentual => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get valor => throw _privateConstructorUsedError;

  /// Serializes this SaqueRateio to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SaqueRateio
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SaqueRateioCopyWith<SaqueRateio> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SaqueRateioCopyWith<$Res> {
  factory $SaqueRateioCopyWith(
    SaqueRateio value,
    $Res Function(SaqueRateio) then,
  ) = _$SaqueRateioCopyWithImpl<$Res, SaqueRateio>;
  @useResult
  $Res call({
    @JsonKey(name: 'saque_id') String saqueId,
    @JsonKey(name: 'empresa_id') String empresaId,
    @JsonKey(name: 'destino_id') String destinoId,
    @DecimalConverter() Decimal percentual,
    @DecimalConverter() Decimal valor,
  });
}

/// @nodoc
class _$SaqueRateioCopyWithImpl<$Res, $Val extends SaqueRateio>
    implements $SaqueRateioCopyWith<$Res> {
  _$SaqueRateioCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SaqueRateio
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? saqueId = null,
    Object? empresaId = null,
    Object? destinoId = null,
    Object? percentual = null,
    Object? valor = null,
  }) {
    return _then(
      _value.copyWith(
            saqueId: null == saqueId
                ? _value.saqueId
                : saqueId // ignore: cast_nullable_to_non_nullable
                      as String,
            empresaId: null == empresaId
                ? _value.empresaId
                : empresaId // ignore: cast_nullable_to_non_nullable
                      as String,
            destinoId: null == destinoId
                ? _value.destinoId
                : destinoId // ignore: cast_nullable_to_non_nullable
                      as String,
            percentual: null == percentual
                ? _value.percentual
                : percentual // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            valor: null == valor
                ? _value.valor
                : valor // ignore: cast_nullable_to_non_nullable
                      as Decimal,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SaqueRateioImplCopyWith<$Res>
    implements $SaqueRateioCopyWith<$Res> {
  factory _$$SaqueRateioImplCopyWith(
    _$SaqueRateioImpl value,
    $Res Function(_$SaqueRateioImpl) then,
  ) = __$$SaqueRateioImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'saque_id') String saqueId,
    @JsonKey(name: 'empresa_id') String empresaId,
    @JsonKey(name: 'destino_id') String destinoId,
    @DecimalConverter() Decimal percentual,
    @DecimalConverter() Decimal valor,
  });
}

/// @nodoc
class __$$SaqueRateioImplCopyWithImpl<$Res>
    extends _$SaqueRateioCopyWithImpl<$Res, _$SaqueRateioImpl>
    implements _$$SaqueRateioImplCopyWith<$Res> {
  __$$SaqueRateioImplCopyWithImpl(
    _$SaqueRateioImpl _value,
    $Res Function(_$SaqueRateioImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SaqueRateio
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? saqueId = null,
    Object? empresaId = null,
    Object? destinoId = null,
    Object? percentual = null,
    Object? valor = null,
  }) {
    return _then(
      _$SaqueRateioImpl(
        saqueId: null == saqueId
            ? _value.saqueId
            : saqueId // ignore: cast_nullable_to_non_nullable
                  as String,
        empresaId: null == empresaId
            ? _value.empresaId
            : empresaId // ignore: cast_nullable_to_non_nullable
                  as String,
        destinoId: null == destinoId
            ? _value.destinoId
            : destinoId // ignore: cast_nullable_to_non_nullable
                  as String,
        percentual: null == percentual
            ? _value.percentual
            : percentual // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        valor: null == valor
            ? _value.valor
            : valor // ignore: cast_nullable_to_non_nullable
                  as Decimal,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SaqueRateioImpl implements _SaqueRateio {
  const _$SaqueRateioImpl({
    @JsonKey(name: 'saque_id') required this.saqueId,
    @JsonKey(name: 'empresa_id') required this.empresaId,
    @JsonKey(name: 'destino_id') required this.destinoId,
    @DecimalConverter() required this.percentual,
    @DecimalConverter() required this.valor,
  });

  factory _$SaqueRateioImpl.fromJson(Map<String, dynamic> json) =>
      _$$SaqueRateioImplFromJson(json);

  @override
  @JsonKey(name: 'saque_id')
  final String saqueId;
  @override
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @override
  @JsonKey(name: 'destino_id')
  final String destinoId;
  @override
  @DecimalConverter()
  final Decimal percentual;
  @override
  @DecimalConverter()
  final Decimal valor;

  @override
  String toString() {
    return 'SaqueRateio(saqueId: $saqueId, empresaId: $empresaId, destinoId: $destinoId, percentual: $percentual, valor: $valor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaqueRateioImpl &&
            (identical(other.saqueId, saqueId) || other.saqueId == saqueId) &&
            (identical(other.empresaId, empresaId) ||
                other.empresaId == empresaId) &&
            (identical(other.destinoId, destinoId) ||
                other.destinoId == destinoId) &&
            (identical(other.percentual, percentual) ||
                other.percentual == percentual) &&
            (identical(other.valor, valor) || other.valor == valor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    saqueId,
    empresaId,
    destinoId,
    percentual,
    valor,
  );

  /// Create a copy of SaqueRateio
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SaqueRateioImplCopyWith<_$SaqueRateioImpl> get copyWith =>
      __$$SaqueRateioImplCopyWithImpl<_$SaqueRateioImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SaqueRateioImplToJson(this);
  }
}

abstract class _SaqueRateio implements SaqueRateio {
  const factory _SaqueRateio({
    @JsonKey(name: 'saque_id') required final String saqueId,
    @JsonKey(name: 'empresa_id') required final String empresaId,
    @JsonKey(name: 'destino_id') required final String destinoId,
    @DecimalConverter() required final Decimal percentual,
    @DecimalConverter() required final Decimal valor,
  }) = _$SaqueRateioImpl;

  factory _SaqueRateio.fromJson(Map<String, dynamic> json) =
      _$SaqueRateioImpl.fromJson;

  @override
  @JsonKey(name: 'saque_id')
  String get saqueId;
  @override
  @JsonKey(name: 'empresa_id')
  String get empresaId;
  @override
  @JsonKey(name: 'destino_id')
  String get destinoId;
  @override
  @DecimalConverter()
  Decimal get percentual;
  @override
  @DecimalConverter()
  Decimal get valor;

  /// Create a copy of SaqueRateio
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SaqueRateioImplCopyWith<_$SaqueRateioImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
