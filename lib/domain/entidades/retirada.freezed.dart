// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'retirada.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Retirada _$RetiradaFromJson(Map<String, dynamic> json) {
  return _Retirada.fromJson(json);
}

/// @nodoc
mixin _$Retirada {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'empresa_id')
  String get empresaId => throw _privateConstructorUsedError;
  DateTime get data => throw _privateConstructorUsedError;
  @JsonKey(name: 'destino_id')
  String get destinoId => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get valor => throw _privateConstructorUsedError;
  String get descricao => throw _privateConstructorUsedError;

  /// Serializes this Retirada to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Retirada
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RetiradaCopyWith<Retirada> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RetiradaCopyWith<$Res> {
  factory $RetiradaCopyWith(Retirada value, $Res Function(Retirada) then) =
      _$RetiradaCopyWithImpl<$Res, Retirada>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    DateTime data,
    @JsonKey(name: 'destino_id') String destinoId,
    @DecimalConverter() Decimal valor,
    String descricao,
  });
}

/// @nodoc
class _$RetiradaCopyWithImpl<$Res, $Val extends Retirada>
    implements $RetiradaCopyWith<$Res> {
  _$RetiradaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Retirada
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? data = null,
    Object? destinoId = null,
    Object? valor = null,
    Object? descricao = null,
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
            destinoId: null == destinoId
                ? _value.destinoId
                : destinoId // ignore: cast_nullable_to_non_nullable
                      as String,
            valor: null == valor
                ? _value.valor
                : valor // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            descricao: null == descricao
                ? _value.descricao
                : descricao // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RetiradaImplCopyWith<$Res>
    implements $RetiradaCopyWith<$Res> {
  factory _$$RetiradaImplCopyWith(
    _$RetiradaImpl value,
    $Res Function(_$RetiradaImpl) then,
  ) = __$$RetiradaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    DateTime data,
    @JsonKey(name: 'destino_id') String destinoId,
    @DecimalConverter() Decimal valor,
    String descricao,
  });
}

/// @nodoc
class __$$RetiradaImplCopyWithImpl<$Res>
    extends _$RetiradaCopyWithImpl<$Res, _$RetiradaImpl>
    implements _$$RetiradaImplCopyWith<$Res> {
  __$$RetiradaImplCopyWithImpl(
    _$RetiradaImpl _value,
    $Res Function(_$RetiradaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Retirada
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? data = null,
    Object? destinoId = null,
    Object? valor = null,
    Object? descricao = null,
  }) {
    return _then(
      _$RetiradaImpl(
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
        destinoId: null == destinoId
            ? _value.destinoId
            : destinoId // ignore: cast_nullable_to_non_nullable
                  as String,
        valor: null == valor
            ? _value.valor
            : valor // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        descricao: null == descricao
            ? _value.descricao
            : descricao // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RetiradaImpl implements _Retirada {
  const _$RetiradaImpl({
    required this.id,
    @JsonKey(name: 'empresa_id') required this.empresaId,
    required this.data,
    @JsonKey(name: 'destino_id') required this.destinoId,
    @DecimalConverter() required this.valor,
    this.descricao = '',
  });

  factory _$RetiradaImpl.fromJson(Map<String, dynamic> json) =>
      _$$RetiradaImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @override
  final DateTime data;
  @override
  @JsonKey(name: 'destino_id')
  final String destinoId;
  @override
  @DecimalConverter()
  final Decimal valor;
  @override
  @JsonKey()
  final String descricao;

  @override
  String toString() {
    return 'Retirada(id: $id, empresaId: $empresaId, data: $data, destinoId: $destinoId, valor: $valor, descricao: $descricao)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RetiradaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.empresaId, empresaId) ||
                other.empresaId == empresaId) &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.destinoId, destinoId) ||
                other.destinoId == destinoId) &&
            (identical(other.valor, valor) || other.valor == valor) &&
            (identical(other.descricao, descricao) ||
                other.descricao == descricao));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    empresaId,
    data,
    destinoId,
    valor,
    descricao,
  );

  /// Create a copy of Retirada
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RetiradaImplCopyWith<_$RetiradaImpl> get copyWith =>
      __$$RetiradaImplCopyWithImpl<_$RetiradaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RetiradaImplToJson(this);
  }
}

abstract class _Retirada implements Retirada {
  const factory _Retirada({
    required final String id,
    @JsonKey(name: 'empresa_id') required final String empresaId,
    required final DateTime data,
    @JsonKey(name: 'destino_id') required final String destinoId,
    @DecimalConverter() required final Decimal valor,
    final String descricao,
  }) = _$RetiradaImpl;

  factory _Retirada.fromJson(Map<String, dynamic> json) =
      _$RetiradaImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'empresa_id')
  String get empresaId;
  @override
  DateTime get data;
  @override
  @JsonKey(name: 'destino_id')
  String get destinoId;
  @override
  @DecimalConverter()
  Decimal get valor;
  @override
  String get descricao;

  /// Create a copy of Retirada
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RetiradaImplCopyWith<_$RetiradaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
