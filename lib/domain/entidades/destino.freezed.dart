// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'destino.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Destino _$DestinoFromJson(Map<String, dynamic> json) {
  return _Destino.fromJson(json);
}

/// @nodoc
mixin _$Destino {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'empresa_id')
  String get empresaId => throw _privateConstructorUsedError;
  String get nome => throw _privateConstructorUsedError;
  String get cor => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get percentual => throw _privateConstructorUsedError;
  int get ordem => throw _privateConstructorUsedError;

  /// Serializes this Destino to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Destino
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DestinoCopyWith<Destino> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DestinoCopyWith<$Res> {
  factory $DestinoCopyWith(Destino value, $Res Function(Destino) then) =
      _$DestinoCopyWithImpl<$Res, Destino>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    String nome,
    String cor,
    @DecimalConverter() Decimal percentual,
    int ordem,
  });
}

/// @nodoc
class _$DestinoCopyWithImpl<$Res, $Val extends Destino>
    implements $DestinoCopyWith<$Res> {
  _$DestinoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Destino
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? nome = null,
    Object? cor = null,
    Object? percentual = null,
    Object? ordem = null,
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
            nome: null == nome
                ? _value.nome
                : nome // ignore: cast_nullable_to_non_nullable
                      as String,
            cor: null == cor
                ? _value.cor
                : cor // ignore: cast_nullable_to_non_nullable
                      as String,
            percentual: null == percentual
                ? _value.percentual
                : percentual // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            ordem: null == ordem
                ? _value.ordem
                : ordem // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DestinoImplCopyWith<$Res> implements $DestinoCopyWith<$Res> {
  factory _$$DestinoImplCopyWith(
    _$DestinoImpl value,
    $Res Function(_$DestinoImpl) then,
  ) = __$$DestinoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    String nome,
    String cor,
    @DecimalConverter() Decimal percentual,
    int ordem,
  });
}

/// @nodoc
class __$$DestinoImplCopyWithImpl<$Res>
    extends _$DestinoCopyWithImpl<$Res, _$DestinoImpl>
    implements _$$DestinoImplCopyWith<$Res> {
  __$$DestinoImplCopyWithImpl(
    _$DestinoImpl _value,
    $Res Function(_$DestinoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Destino
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? nome = null,
    Object? cor = null,
    Object? percentual = null,
    Object? ordem = null,
  }) {
    return _then(
      _$DestinoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        empresaId: null == empresaId
            ? _value.empresaId
            : empresaId // ignore: cast_nullable_to_non_nullable
                  as String,
        nome: null == nome
            ? _value.nome
            : nome // ignore: cast_nullable_to_non_nullable
                  as String,
        cor: null == cor
            ? _value.cor
            : cor // ignore: cast_nullable_to_non_nullable
                  as String,
        percentual: null == percentual
            ? _value.percentual
            : percentual // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        ordem: null == ordem
            ? _value.ordem
            : ordem // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DestinoImpl implements _Destino {
  const _$DestinoImpl({
    required this.id,
    @JsonKey(name: 'empresa_id') required this.empresaId,
    required this.nome,
    required this.cor,
    @DecimalConverter() required this.percentual,
    this.ordem = 0,
  });

  factory _$DestinoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DestinoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @override
  final String nome;
  @override
  final String cor;
  @override
  @DecimalConverter()
  final Decimal percentual;
  @override
  @JsonKey()
  final int ordem;

  @override
  String toString() {
    return 'Destino(id: $id, empresaId: $empresaId, nome: $nome, cor: $cor, percentual: $percentual, ordem: $ordem)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DestinoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.empresaId, empresaId) ||
                other.empresaId == empresaId) &&
            (identical(other.nome, nome) || other.nome == nome) &&
            (identical(other.cor, cor) || other.cor == cor) &&
            (identical(other.percentual, percentual) ||
                other.percentual == percentual) &&
            (identical(other.ordem, ordem) || other.ordem == ordem));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, empresaId, nome, cor, percentual, ordem);

  /// Create a copy of Destino
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DestinoImplCopyWith<_$DestinoImpl> get copyWith =>
      __$$DestinoImplCopyWithImpl<_$DestinoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DestinoImplToJson(this);
  }
}

abstract class _Destino implements Destino {
  const factory _Destino({
    required final String id,
    @JsonKey(name: 'empresa_id') required final String empresaId,
    required final String nome,
    required final String cor,
    @DecimalConverter() required final Decimal percentual,
    final int ordem,
  }) = _$DestinoImpl;

  factory _Destino.fromJson(Map<String, dynamic> json) = _$DestinoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'empresa_id')
  String get empresaId;
  @override
  String get nome;
  @override
  String get cor;
  @override
  @DecimalConverter()
  Decimal get percentual;
  @override
  int get ordem;

  /// Create a copy of Destino
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DestinoImplCopyWith<_$DestinoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
