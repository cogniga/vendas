// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compra_insumo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CompraInsumo _$CompraInsumoFromJson(Map<String, dynamic> json) {
  return _CompraInsumo.fromJson(json);
}

/// @nodoc
mixin _$CompraInsumo {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'empresa_id')
  String get empresaId => throw _privateConstructorUsedError;
  DateTime get data => throw _privateConstructorUsedError;
  String get produto => throw _privateConstructorUsedError;
  @JsonKey(name: 'valor_total')
  @DecimalConverter()
  Decimal get valorTotal => throw _privateConstructorUsedError;
  String get tipo => throw _privateConstructorUsedError;
  String get descricao => throw _privateConstructorUsedError;
  int get pacotes => throw _privateConstructorUsedError;
  int get itens => throw _privateConstructorUsedError;
  @JsonKey(name: 'destino_id')
  String? get destinoId => throw _privateConstructorUsedError;

  /// Serializes this CompraInsumo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CompraInsumo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompraInsumoCopyWith<CompraInsumo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompraInsumoCopyWith<$Res> {
  factory $CompraInsumoCopyWith(
    CompraInsumo value,
    $Res Function(CompraInsumo) then,
  ) = _$CompraInsumoCopyWithImpl<$Res, CompraInsumo>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    DateTime data,
    String produto,
    @JsonKey(name: 'valor_total') @DecimalConverter() Decimal valorTotal,
    String tipo,
    String descricao,
    int pacotes,
    int itens,
    @JsonKey(name: 'destino_id') String? destinoId,
  });
}

/// @nodoc
class _$CompraInsumoCopyWithImpl<$Res, $Val extends CompraInsumo>
    implements $CompraInsumoCopyWith<$Res> {
  _$CompraInsumoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompraInsumo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? data = null,
    Object? produto = null,
    Object? valorTotal = null,
    Object? tipo = null,
    Object? descricao = null,
    Object? pacotes = null,
    Object? itens = null,
    Object? destinoId = freezed,
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
            produto: null == produto
                ? _value.produto
                : produto // ignore: cast_nullable_to_non_nullable
                      as String,
            valorTotal: null == valorTotal
                ? _value.valorTotal
                : valorTotal // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            tipo: null == tipo
                ? _value.tipo
                : tipo // ignore: cast_nullable_to_non_nullable
                      as String,
            descricao: null == descricao
                ? _value.descricao
                : descricao // ignore: cast_nullable_to_non_nullable
                      as String,
            pacotes: null == pacotes
                ? _value.pacotes
                : pacotes // ignore: cast_nullable_to_non_nullable
                      as int,
            itens: null == itens
                ? _value.itens
                : itens // ignore: cast_nullable_to_non_nullable
                      as int,
            destinoId: freezed == destinoId
                ? _value.destinoId
                : destinoId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CompraInsumoImplCopyWith<$Res>
    implements $CompraInsumoCopyWith<$Res> {
  factory _$$CompraInsumoImplCopyWith(
    _$CompraInsumoImpl value,
    $Res Function(_$CompraInsumoImpl) then,
  ) = __$$CompraInsumoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    DateTime data,
    String produto,
    @JsonKey(name: 'valor_total') @DecimalConverter() Decimal valorTotal,
    String tipo,
    String descricao,
    int pacotes,
    int itens,
    @JsonKey(name: 'destino_id') String? destinoId,
  });
}

/// @nodoc
class __$$CompraInsumoImplCopyWithImpl<$Res>
    extends _$CompraInsumoCopyWithImpl<$Res, _$CompraInsumoImpl>
    implements _$$CompraInsumoImplCopyWith<$Res> {
  __$$CompraInsumoImplCopyWithImpl(
    _$CompraInsumoImpl _value,
    $Res Function(_$CompraInsumoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CompraInsumo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? data = null,
    Object? produto = null,
    Object? valorTotal = null,
    Object? tipo = null,
    Object? descricao = null,
    Object? pacotes = null,
    Object? itens = null,
    Object? destinoId = freezed,
  }) {
    return _then(
      _$CompraInsumoImpl(
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
        produto: null == produto
            ? _value.produto
            : produto // ignore: cast_nullable_to_non_nullable
                  as String,
        valorTotal: null == valorTotal
            ? _value.valorTotal
            : valorTotal // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        tipo: null == tipo
            ? _value.tipo
            : tipo // ignore: cast_nullable_to_non_nullable
                  as String,
        descricao: null == descricao
            ? _value.descricao
            : descricao // ignore: cast_nullable_to_non_nullable
                  as String,
        pacotes: null == pacotes
            ? _value.pacotes
            : pacotes // ignore: cast_nullable_to_non_nullable
                  as int,
        itens: null == itens
            ? _value.itens
            : itens // ignore: cast_nullable_to_non_nullable
                  as int,
        destinoId: freezed == destinoId
            ? _value.destinoId
            : destinoId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CompraInsumoImpl implements _CompraInsumo {
  const _$CompraInsumoImpl({
    required this.id,
    @JsonKey(name: 'empresa_id') required this.empresaId,
    required this.data,
    required this.produto,
    @JsonKey(name: 'valor_total') @DecimalConverter() required this.valorTotal,
    this.tipo = 'Embalagem',
    this.descricao = '',
    this.pacotes = 1,
    this.itens = 1,
    @JsonKey(name: 'destino_id') this.destinoId,
  });

  factory _$CompraInsumoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompraInsumoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @override
  final DateTime data;
  @override
  final String produto;
  @override
  @JsonKey(name: 'valor_total')
  @DecimalConverter()
  final Decimal valorTotal;
  @override
  @JsonKey()
  final String tipo;
  @override
  @JsonKey()
  final String descricao;
  @override
  @JsonKey()
  final int pacotes;
  @override
  @JsonKey()
  final int itens;
  @override
  @JsonKey(name: 'destino_id')
  final String? destinoId;

  @override
  String toString() {
    return 'CompraInsumo(id: $id, empresaId: $empresaId, data: $data, produto: $produto, valorTotal: $valorTotal, tipo: $tipo, descricao: $descricao, pacotes: $pacotes, itens: $itens, destinoId: $destinoId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompraInsumoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.empresaId, empresaId) ||
                other.empresaId == empresaId) &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.produto, produto) || other.produto == produto) &&
            (identical(other.valorTotal, valorTotal) ||
                other.valorTotal == valorTotal) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.descricao, descricao) ||
                other.descricao == descricao) &&
            (identical(other.pacotes, pacotes) || other.pacotes == pacotes) &&
            (identical(other.itens, itens) || other.itens == itens) &&
            (identical(other.destinoId, destinoId) ||
                other.destinoId == destinoId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    empresaId,
    data,
    produto,
    valorTotal,
    tipo,
    descricao,
    pacotes,
    itens,
    destinoId,
  );

  /// Create a copy of CompraInsumo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompraInsumoImplCopyWith<_$CompraInsumoImpl> get copyWith =>
      __$$CompraInsumoImplCopyWithImpl<_$CompraInsumoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompraInsumoImplToJson(this);
  }
}

abstract class _CompraInsumo implements CompraInsumo {
  const factory _CompraInsumo({
    required final String id,
    @JsonKey(name: 'empresa_id') required final String empresaId,
    required final DateTime data,
    required final String produto,
    @JsonKey(name: 'valor_total')
    @DecimalConverter()
    required final Decimal valorTotal,
    final String tipo,
    final String descricao,
    final int pacotes,
    final int itens,
    @JsonKey(name: 'destino_id') final String? destinoId,
  }) = _$CompraInsumoImpl;

  factory _CompraInsumo.fromJson(Map<String, dynamic> json) =
      _$CompraInsumoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'empresa_id')
  String get empresaId;
  @override
  DateTime get data;
  @override
  String get produto;
  @override
  @JsonKey(name: 'valor_total')
  @DecimalConverter()
  Decimal get valorTotal;
  @override
  String get tipo;
  @override
  String get descricao;
  @override
  int get pacotes;
  @override
  int get itens;
  @override
  @JsonKey(name: 'destino_id')
  String? get destinoId;

  /// Create a copy of CompraInsumo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompraInsumoImplCopyWith<_$CompraInsumoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
