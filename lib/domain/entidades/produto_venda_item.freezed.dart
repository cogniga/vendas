// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'produto_venda_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProdutoVendaItem _$ProdutoVendaItemFromJson(Map<String, dynamic> json) {
  return _ProdutoVendaItem.fromJson(json);
}

/// @nodoc
mixin _$ProdutoVendaItem {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'empresa_id')
  String get empresaId => throw _privateConstructorUsedError;
  @JsonKey(name: 'produto_venda_id')
  String get produtoVendaId => throw _privateConstructorUsedError;
  @JsonKey(name: 'produto_id')
  String get produtoId => throw _privateConstructorUsedError;
  int get quantidade => throw _privateConstructorUsedError;

  /// Serializes this ProdutoVendaItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProdutoVendaItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProdutoVendaItemCopyWith<ProdutoVendaItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProdutoVendaItemCopyWith<$Res> {
  factory $ProdutoVendaItemCopyWith(
    ProdutoVendaItem value,
    $Res Function(ProdutoVendaItem) then,
  ) = _$ProdutoVendaItemCopyWithImpl<$Res, ProdutoVendaItem>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    @JsonKey(name: 'produto_venda_id') String produtoVendaId,
    @JsonKey(name: 'produto_id') String produtoId,
    int quantidade,
  });
}

/// @nodoc
class _$ProdutoVendaItemCopyWithImpl<$Res, $Val extends ProdutoVendaItem>
    implements $ProdutoVendaItemCopyWith<$Res> {
  _$ProdutoVendaItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProdutoVendaItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? produtoVendaId = null,
    Object? produtoId = null,
    Object? quantidade = null,
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
            produtoVendaId: null == produtoVendaId
                ? _value.produtoVendaId
                : produtoVendaId // ignore: cast_nullable_to_non_nullable
                      as String,
            produtoId: null == produtoId
                ? _value.produtoId
                : produtoId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantidade: null == quantidade
                ? _value.quantidade
                : quantidade // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProdutoVendaItemImplCopyWith<$Res>
    implements $ProdutoVendaItemCopyWith<$Res> {
  factory _$$ProdutoVendaItemImplCopyWith(
    _$ProdutoVendaItemImpl value,
    $Res Function(_$ProdutoVendaItemImpl) then,
  ) = __$$ProdutoVendaItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    @JsonKey(name: 'produto_venda_id') String produtoVendaId,
    @JsonKey(name: 'produto_id') String produtoId,
    int quantidade,
  });
}

/// @nodoc
class __$$ProdutoVendaItemImplCopyWithImpl<$Res>
    extends _$ProdutoVendaItemCopyWithImpl<$Res, _$ProdutoVendaItemImpl>
    implements _$$ProdutoVendaItemImplCopyWith<$Res> {
  __$$ProdutoVendaItemImplCopyWithImpl(
    _$ProdutoVendaItemImpl _value,
    $Res Function(_$ProdutoVendaItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProdutoVendaItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? produtoVendaId = null,
    Object? produtoId = null,
    Object? quantidade = null,
  }) {
    return _then(
      _$ProdutoVendaItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        empresaId: null == empresaId
            ? _value.empresaId
            : empresaId // ignore: cast_nullable_to_non_nullable
                  as String,
        produtoVendaId: null == produtoVendaId
            ? _value.produtoVendaId
            : produtoVendaId // ignore: cast_nullable_to_non_nullable
                  as String,
        produtoId: null == produtoId
            ? _value.produtoId
            : produtoId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantidade: null == quantidade
            ? _value.quantidade
            : quantidade // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProdutoVendaItemImpl implements _ProdutoVendaItem {
  const _$ProdutoVendaItemImpl({
    required this.id,
    @JsonKey(name: 'empresa_id') required this.empresaId,
    @JsonKey(name: 'produto_venda_id') required this.produtoVendaId,
    @JsonKey(name: 'produto_id') required this.produtoId,
    required this.quantidade,
  });

  factory _$ProdutoVendaItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProdutoVendaItemImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @override
  @JsonKey(name: 'produto_venda_id')
  final String produtoVendaId;
  @override
  @JsonKey(name: 'produto_id')
  final String produtoId;
  @override
  final int quantidade;

  @override
  String toString() {
    return 'ProdutoVendaItem(id: $id, empresaId: $empresaId, produtoVendaId: $produtoVendaId, produtoId: $produtoId, quantidade: $quantidade)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProdutoVendaItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.empresaId, empresaId) ||
                other.empresaId == empresaId) &&
            (identical(other.produtoVendaId, produtoVendaId) ||
                other.produtoVendaId == produtoVendaId) &&
            (identical(other.produtoId, produtoId) ||
                other.produtoId == produtoId) &&
            (identical(other.quantidade, quantidade) ||
                other.quantidade == quantidade));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    empresaId,
    produtoVendaId,
    produtoId,
    quantidade,
  );

  /// Create a copy of ProdutoVendaItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProdutoVendaItemImplCopyWith<_$ProdutoVendaItemImpl> get copyWith =>
      __$$ProdutoVendaItemImplCopyWithImpl<_$ProdutoVendaItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProdutoVendaItemImplToJson(this);
  }
}

abstract class _ProdutoVendaItem implements ProdutoVendaItem {
  const factory _ProdutoVendaItem({
    required final String id,
    @JsonKey(name: 'empresa_id') required final String empresaId,
    @JsonKey(name: 'produto_venda_id') required final String produtoVendaId,
    @JsonKey(name: 'produto_id') required final String produtoId,
    required final int quantidade,
  }) = _$ProdutoVendaItemImpl;

  factory _ProdutoVendaItem.fromJson(Map<String, dynamic> json) =
      _$ProdutoVendaItemImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'empresa_id')
  String get empresaId;
  @override
  @JsonKey(name: 'produto_venda_id')
  String get produtoVendaId;
  @override
  @JsonKey(name: 'produto_id')
  String get produtoId;
  @override
  int get quantidade;

  /// Create a copy of ProdutoVendaItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProdutoVendaItemImplCopyWith<_$ProdutoVendaItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
