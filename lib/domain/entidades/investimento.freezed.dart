// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'investimento.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Investimento _$InvestimentoFromJson(Map<String, dynamic> json) {
  return _Investimento.fromJson(json);
}

/// @nodoc
mixin _$Investimento {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'empresa_id')
  String get empresaId => throw _privateConstructorUsedError;
  DateTime get data => throw _privateConstructorUsedError;
  String get distribuidor => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get valor => throw _privateConstructorUsedError;
  String get nota => throw _privateConstructorUsedError;
  @JsonKey(name: 'destino_id')
  String? get destinoId => throw _privateConstructorUsedError;
  String get obs => throw _privateConstructorUsedError;

  /// Serializes this Investimento to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Investimento
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvestimentoCopyWith<Investimento> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvestimentoCopyWith<$Res> {
  factory $InvestimentoCopyWith(
    Investimento value,
    $Res Function(Investimento) then,
  ) = _$InvestimentoCopyWithImpl<$Res, Investimento>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    DateTime data,
    String distribuidor,
    @DecimalConverter() Decimal valor,
    String nota,
    @JsonKey(name: 'destino_id') String? destinoId,
    String obs,
  });
}

/// @nodoc
class _$InvestimentoCopyWithImpl<$Res, $Val extends Investimento>
    implements $InvestimentoCopyWith<$Res> {
  _$InvestimentoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Investimento
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? data = null,
    Object? distribuidor = null,
    Object? valor = null,
    Object? nota = null,
    Object? destinoId = freezed,
    Object? obs = null,
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
            distribuidor: null == distribuidor
                ? _value.distribuidor
                : distribuidor // ignore: cast_nullable_to_non_nullable
                      as String,
            valor: null == valor
                ? _value.valor
                : valor // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            nota: null == nota
                ? _value.nota
                : nota // ignore: cast_nullable_to_non_nullable
                      as String,
            destinoId: freezed == destinoId
                ? _value.destinoId
                : destinoId // ignore: cast_nullable_to_non_nullable
                      as String?,
            obs: null == obs
                ? _value.obs
                : obs // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InvestimentoImplCopyWith<$Res>
    implements $InvestimentoCopyWith<$Res> {
  factory _$$InvestimentoImplCopyWith(
    _$InvestimentoImpl value,
    $Res Function(_$InvestimentoImpl) then,
  ) = __$$InvestimentoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    DateTime data,
    String distribuidor,
    @DecimalConverter() Decimal valor,
    String nota,
    @JsonKey(name: 'destino_id') String? destinoId,
    String obs,
  });
}

/// @nodoc
class __$$InvestimentoImplCopyWithImpl<$Res>
    extends _$InvestimentoCopyWithImpl<$Res, _$InvestimentoImpl>
    implements _$$InvestimentoImplCopyWith<$Res> {
  __$$InvestimentoImplCopyWithImpl(
    _$InvestimentoImpl _value,
    $Res Function(_$InvestimentoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Investimento
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? data = null,
    Object? distribuidor = null,
    Object? valor = null,
    Object? nota = null,
    Object? destinoId = freezed,
    Object? obs = null,
  }) {
    return _then(
      _$InvestimentoImpl(
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
        distribuidor: null == distribuidor
            ? _value.distribuidor
            : distribuidor // ignore: cast_nullable_to_non_nullable
                  as String,
        valor: null == valor
            ? _value.valor
            : valor // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        nota: null == nota
            ? _value.nota
            : nota // ignore: cast_nullable_to_non_nullable
                  as String,
        destinoId: freezed == destinoId
            ? _value.destinoId
            : destinoId // ignore: cast_nullable_to_non_nullable
                  as String?,
        obs: null == obs
            ? _value.obs
            : obs // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InvestimentoImpl implements _Investimento {
  const _$InvestimentoImpl({
    required this.id,
    @JsonKey(name: 'empresa_id') required this.empresaId,
    required this.data,
    required this.distribuidor,
    @DecimalConverter() required this.valor,
    this.nota = '',
    @JsonKey(name: 'destino_id') this.destinoId,
    this.obs = '',
  });

  factory _$InvestimentoImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvestimentoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @override
  final DateTime data;
  @override
  final String distribuidor;
  @override
  @DecimalConverter()
  final Decimal valor;
  @override
  @JsonKey()
  final String nota;
  @override
  @JsonKey(name: 'destino_id')
  final String? destinoId;
  @override
  @JsonKey()
  final String obs;

  @override
  String toString() {
    return 'Investimento(id: $id, empresaId: $empresaId, data: $data, distribuidor: $distribuidor, valor: $valor, nota: $nota, destinoId: $destinoId, obs: $obs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvestimentoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.empresaId, empresaId) ||
                other.empresaId == empresaId) &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.distribuidor, distribuidor) ||
                other.distribuidor == distribuidor) &&
            (identical(other.valor, valor) || other.valor == valor) &&
            (identical(other.nota, nota) || other.nota == nota) &&
            (identical(other.destinoId, destinoId) ||
                other.destinoId == destinoId) &&
            (identical(other.obs, obs) || other.obs == obs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    empresaId,
    data,
    distribuidor,
    valor,
    nota,
    destinoId,
    obs,
  );

  /// Create a copy of Investimento
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvestimentoImplCopyWith<_$InvestimentoImpl> get copyWith =>
      __$$InvestimentoImplCopyWithImpl<_$InvestimentoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvestimentoImplToJson(this);
  }
}

abstract class _Investimento implements Investimento {
  const factory _Investimento({
    required final String id,
    @JsonKey(name: 'empresa_id') required final String empresaId,
    required final DateTime data,
    required final String distribuidor,
    @DecimalConverter() required final Decimal valor,
    final String nota,
    @JsonKey(name: 'destino_id') final String? destinoId,
    final String obs,
  }) = _$InvestimentoImpl;

  factory _Investimento.fromJson(Map<String, dynamic> json) =
      _$InvestimentoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'empresa_id')
  String get empresaId;
  @override
  DateTime get data;
  @override
  String get distribuidor;
  @override
  @DecimalConverter()
  Decimal get valor;
  @override
  String get nota;
  @override
  @JsonKey(name: 'destino_id')
  String? get destinoId;
  @override
  String get obs;

  /// Create a copy of Investimento
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvestimentoImplCopyWith<_$InvestimentoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
