// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saque.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Saque _$SaqueFromJson(Map<String, dynamic> json) {
  return _Saque.fromJson(json);
}

/// @nodoc
mixin _$Saque {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'empresa_id')
  String get empresaId => throw _privateConstructorUsedError;
  DateTime get data => throw _privateConstructorUsedError;
  @JsonKey(name: 'plataforma_id')
  String get plataformaId => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get valor => throw _privateConstructorUsedError;
  String get obs => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<SaqueRateio> get rateio => throw _privateConstructorUsedError;

  /// Serializes this Saque to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Saque
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SaqueCopyWith<Saque> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SaqueCopyWith<$Res> {
  factory $SaqueCopyWith(Saque value, $Res Function(Saque) then) =
      _$SaqueCopyWithImpl<$Res, Saque>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    DateTime data,
    @JsonKey(name: 'plataforma_id') String plataformaId,
    @DecimalConverter() Decimal valor,
    String obs,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<SaqueRateio> rateio,
  });
}

/// @nodoc
class _$SaqueCopyWithImpl<$Res, $Val extends Saque>
    implements $SaqueCopyWith<$Res> {
  _$SaqueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Saque
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? data = null,
    Object? plataformaId = null,
    Object? valor = null,
    Object? obs = null,
    Object? rateio = null,
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
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            plataformaId: null == plataformaId
                ? _value.plataformaId
                : plataformaId // ignore: cast_nullable_to_non_nullable
                      as String,
            valor: null == valor
                ? _value.valor
                : valor // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            obs: null == obs
                ? _value.obs
                : obs // ignore: cast_nullable_to_non_nullable
                      as String,
            rateio: null == rateio
                ? _value.rateio
                : rateio // ignore: cast_nullable_to_non_nullable
                      as List<SaqueRateio>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SaqueImplCopyWith<$Res> implements $SaqueCopyWith<$Res> {
  factory _$$SaqueImplCopyWith(
    _$SaqueImpl value,
    $Res Function(_$SaqueImpl) then,
  ) = __$$SaqueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    DateTime data,
    @JsonKey(name: 'plataforma_id') String plataformaId,
    @DecimalConverter() Decimal valor,
    String obs,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<SaqueRateio> rateio,
  });
}

/// @nodoc
class __$$SaqueImplCopyWithImpl<$Res>
    extends _$SaqueCopyWithImpl<$Res, _$SaqueImpl>
    implements _$$SaqueImplCopyWith<$Res> {
  __$$SaqueImplCopyWithImpl(
    _$SaqueImpl _value,
    $Res Function(_$SaqueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Saque
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? data = null,
    Object? plataformaId = null,
    Object? valor = null,
    Object? obs = null,
    Object? rateio = null,
  }) {
    return _then(
      _$SaqueImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        empresaId: null == empresaId
            ? _value.empresaId
            : empresaId // ignore: cast_nullable_to_non_nullable
                  as String,
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        plataformaId: null == plataformaId
            ? _value.plataformaId
            : plataformaId // ignore: cast_nullable_to_non_nullable
                  as String,
        valor: null == valor
            ? _value.valor
            : valor // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        obs: null == obs
            ? _value.obs
            : obs // ignore: cast_nullable_to_non_nullable
                  as String,
        rateio: null == rateio
            ? _value._rateio
            : rateio // ignore: cast_nullable_to_non_nullable
                  as List<SaqueRateio>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SaqueImpl implements _Saque {
  const _$SaqueImpl({
    required this.id,
    @JsonKey(name: 'empresa_id') required this.empresaId,
    required this.data,
    @JsonKey(name: 'plataforma_id') required this.plataformaId,
    @DecimalConverter() required this.valor,
    this.obs = '',
    @JsonKey(includeFromJson: false, includeToJson: false)
    final List<SaqueRateio> rateio = const <SaqueRateio>[],
  }) : _rateio = rateio;

  factory _$SaqueImpl.fromJson(Map<String, dynamic> json) =>
      _$$SaqueImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @override
  final DateTime data;
  @override
  @JsonKey(name: 'plataforma_id')
  final String plataformaId;
  @override
  @DecimalConverter()
  final Decimal valor;
  @override
  @JsonKey()
  final String obs;
  final List<SaqueRateio> _rateio;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<SaqueRateio> get rateio {
    if (_rateio is EqualUnmodifiableListView) return _rateio;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rateio);
  }

  @override
  String toString() {
    return 'Saque(id: $id, empresaId: $empresaId, data: $data, plataformaId: $plataformaId, valor: $valor, obs: $obs, rateio: $rateio)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaqueImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.empresaId, empresaId) ||
                other.empresaId == empresaId) &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.plataformaId, plataformaId) ||
                other.plataformaId == plataformaId) &&
            (identical(other.valor, valor) || other.valor == valor) &&
            (identical(other.obs, obs) || other.obs == obs) &&
            const DeepCollectionEquality().equals(other._rateio, _rateio));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    empresaId,
    data,
    plataformaId,
    valor,
    obs,
    const DeepCollectionEquality().hash(_rateio),
  );

  /// Create a copy of Saque
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SaqueImplCopyWith<_$SaqueImpl> get copyWith =>
      __$$SaqueImplCopyWithImpl<_$SaqueImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SaqueImplToJson(this);
  }
}

abstract class _Saque implements Saque {
  const factory _Saque({
    required final String id,
    @JsonKey(name: 'empresa_id') required final String empresaId,
    required final DateTime data,
    @JsonKey(name: 'plataforma_id') required final String plataformaId,
    @DecimalConverter() required final Decimal valor,
    final String obs,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final List<SaqueRateio> rateio,
  }) = _$SaqueImpl;

  factory _Saque.fromJson(Map<String, dynamic> json) = _$SaqueImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'empresa_id')
  String get empresaId;
  @override
  DateTime get data;
  @override
  @JsonKey(name: 'plataforma_id')
  String get plataformaId;
  @override
  @DecimalConverter()
  Decimal get valor;
  @override
  String get obs;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<SaqueRateio> get rateio;

  /// Create a copy of Saque
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SaqueImplCopyWith<_$SaqueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
