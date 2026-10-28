// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plataforma.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Plataforma _$PlataformaFromJson(Map<String, dynamic> json) {
  return _Plataforma.fromJson(json);
}

/// @nodoc
mixin _$Plataforma {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'empresa_id')
  String get empresaId => throw _privateConstructorUsedError;
  String get nome => throw _privateConstructorUsedError;
  String get cor => throw _privateConstructorUsedError;
  String get obs => throw _privateConstructorUsedError;
  int get ordem => throw _privateConstructorUsedError;

  /// Serializes this Plataforma to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Plataforma
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlataformaCopyWith<Plataforma> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlataformaCopyWith<$Res> {
  factory $PlataformaCopyWith(
    Plataforma value,
    $Res Function(Plataforma) then,
  ) = _$PlataformaCopyWithImpl<$Res, Plataforma>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    String nome,
    String cor,
    String obs,
    int ordem,
  });
}

/// @nodoc
class _$PlataformaCopyWithImpl<$Res, $Val extends Plataforma>
    implements $PlataformaCopyWith<$Res> {
  _$PlataformaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Plataforma
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? nome = null,
    Object? cor = null,
    Object? obs = null,
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
            obs: null == obs
                ? _value.obs
                : obs // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$PlataformaImplCopyWith<$Res>
    implements $PlataformaCopyWith<$Res> {
  factory _$$PlataformaImplCopyWith(
    _$PlataformaImpl value,
    $Res Function(_$PlataformaImpl) then,
  ) = __$$PlataformaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    String nome,
    String cor,
    String obs,
    int ordem,
  });
}

/// @nodoc
class __$$PlataformaImplCopyWithImpl<$Res>
    extends _$PlataformaCopyWithImpl<$Res, _$PlataformaImpl>
    implements _$$PlataformaImplCopyWith<$Res> {
  __$$PlataformaImplCopyWithImpl(
    _$PlataformaImpl _value,
    $Res Function(_$PlataformaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Plataforma
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? nome = null,
    Object? cor = null,
    Object? obs = null,
    Object? ordem = null,
  }) {
    return _then(
      _$PlataformaImpl(
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
        obs: null == obs
            ? _value.obs
            : obs // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$PlataformaImpl implements _Plataforma {
  const _$PlataformaImpl({
    required this.id,
    @JsonKey(name: 'empresa_id') required this.empresaId,
    required this.nome,
    this.cor = '#9A8FD4',
    this.obs = '',
    this.ordem = 0,
  });

  factory _$PlataformaImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlataformaImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @override
  final String nome;
  @override
  @JsonKey()
  final String cor;
  @override
  @JsonKey()
  final String obs;
  @override
  @JsonKey()
  final int ordem;

  @override
  String toString() {
    return 'Plataforma(id: $id, empresaId: $empresaId, nome: $nome, cor: $cor, obs: $obs, ordem: $ordem)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlataformaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.empresaId, empresaId) ||
                other.empresaId == empresaId) &&
            (identical(other.nome, nome) || other.nome == nome) &&
            (identical(other.cor, cor) || other.cor == cor) &&
            (identical(other.obs, obs) || other.obs == obs) &&
            (identical(other.ordem, ordem) || other.ordem == ordem));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, empresaId, nome, cor, obs, ordem);

  /// Create a copy of Plataforma
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlataformaImplCopyWith<_$PlataformaImpl> get copyWith =>
      __$$PlataformaImplCopyWithImpl<_$PlataformaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlataformaImplToJson(this);
  }
}

abstract class _Plataforma implements Plataforma {
  const factory _Plataforma({
    required final String id,
    @JsonKey(name: 'empresa_id') required final String empresaId,
    required final String nome,
    final String cor,
    final String obs,
    final int ordem,
  }) = _$PlataformaImpl;

  factory _Plataforma.fromJson(Map<String, dynamic> json) =
      _$PlataformaImpl.fromJson;

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
  String get obs;
  @override
  int get ordem;

  /// Create a copy of Plataforma
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlataformaImplCopyWith<_$PlataformaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
