// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pedido_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PedidoItem _$PedidoItemFromJson(Map<String, dynamic> json) {
  return _PedidoItem.fromJson(json);
}

/// @nodoc
mixin _$PedidoItem {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'empresa_id')
  String get empresaId => throw _privateConstructorUsedError;
  @JsonKey(name: 'pedido_id')
  String get pedidoId => throw _privateConstructorUsedError;
  TipoPedidoItem get tipo => throw _privateConstructorUsedError;
  int get quantidade => throw _privateConstructorUsedError;
  @JsonKey(name: 'custo_unitario')
  @DecimalConverter()
  Decimal get custoUnitario => throw _privateConstructorUsedError;
  @JsonKey(name: 'abelinhas_unitarias')
  @DecimalConverter()
  Decimal get abelinhasUnitarias => throw _privateConstructorUsedError;
  @JsonKey(name: 'produto_id')
  String? get produtoId => throw _privateConstructorUsedError;
  @JsonKey(name: 'produto_venda_id')
  String? get produtoVendaId => throw _privateConstructorUsedError;

  /// Serializes this PedidoItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PedidoItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PedidoItemCopyWith<PedidoItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PedidoItemCopyWith<$Res> {
  factory $PedidoItemCopyWith(
    PedidoItem value,
    $Res Function(PedidoItem) then,
  ) = _$PedidoItemCopyWithImpl<$Res, PedidoItem>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    @JsonKey(name: 'pedido_id') String pedidoId,
    TipoPedidoItem tipo,
    int quantidade,
    @JsonKey(name: 'custo_unitario') @DecimalConverter() Decimal custoUnitario,
    @JsonKey(name: 'abelinhas_unitarias')
    @DecimalConverter()
    Decimal abelinhasUnitarias,
    @JsonKey(name: 'produto_id') String? produtoId,
    @JsonKey(name: 'produto_venda_id') String? produtoVendaId,
  });
}

/// @nodoc
class _$PedidoItemCopyWithImpl<$Res, $Val extends PedidoItem>
    implements $PedidoItemCopyWith<$Res> {
  _$PedidoItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PedidoItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? pedidoId = null,
    Object? tipo = null,
    Object? quantidade = null,
    Object? custoUnitario = null,
    Object? abelinhasUnitarias = null,
    Object? produtoId = freezed,
    Object? produtoVendaId = freezed,
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
            pedidoId: null == pedidoId
                ? _value.pedidoId
                : pedidoId // ignore: cast_nullable_to_non_nullable
                      as String,
            tipo: null == tipo
                ? _value.tipo
                : tipo // ignore: cast_nullable_to_non_nullable
                      as TipoPedidoItem,
            quantidade: null == quantidade
                ? _value.quantidade
                : quantidade // ignore: cast_nullable_to_non_nullable
                      as int,
            custoUnitario: null == custoUnitario
                ? _value.custoUnitario
                : custoUnitario // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            abelinhasUnitarias: null == abelinhasUnitarias
                ? _value.abelinhasUnitarias
                : abelinhasUnitarias // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            produtoId: freezed == produtoId
                ? _value.produtoId
                : produtoId // ignore: cast_nullable_to_non_nullable
                      as String?,
            produtoVendaId: freezed == produtoVendaId
                ? _value.produtoVendaId
                : produtoVendaId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PedidoItemImplCopyWith<$Res>
    implements $PedidoItemCopyWith<$Res> {
  factory _$$PedidoItemImplCopyWith(
    _$PedidoItemImpl value,
    $Res Function(_$PedidoItemImpl) then,
  ) = __$$PedidoItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    @JsonKey(name: 'pedido_id') String pedidoId,
    TipoPedidoItem tipo,
    int quantidade,
    @JsonKey(name: 'custo_unitario') @DecimalConverter() Decimal custoUnitario,
    @JsonKey(name: 'abelinhas_unitarias')
    @DecimalConverter()
    Decimal abelinhasUnitarias,
    @JsonKey(name: 'produto_id') String? produtoId,
    @JsonKey(name: 'produto_venda_id') String? produtoVendaId,
  });
}

/// @nodoc
class __$$PedidoItemImplCopyWithImpl<$Res>
    extends _$PedidoItemCopyWithImpl<$Res, _$PedidoItemImpl>
    implements _$$PedidoItemImplCopyWith<$Res> {
  __$$PedidoItemImplCopyWithImpl(
    _$PedidoItemImpl _value,
    $Res Function(_$PedidoItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PedidoItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? pedidoId = null,
    Object? tipo = null,
    Object? quantidade = null,
    Object? custoUnitario = null,
    Object? abelinhasUnitarias = null,
    Object? produtoId = freezed,
    Object? produtoVendaId = freezed,
  }) {
    return _then(
      _$PedidoItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        empresaId: null == empresaId
            ? _value.empresaId
            : empresaId // ignore: cast_nullable_to_non_nullable
                  as String,
        pedidoId: null == pedidoId
            ? _value.pedidoId
            : pedidoId // ignore: cast_nullable_to_non_nullable
                  as String,
        tipo: null == tipo
            ? _value.tipo
            : tipo // ignore: cast_nullable_to_non_nullable
                  as TipoPedidoItem,
        quantidade: null == quantidade
            ? _value.quantidade
            : quantidade // ignore: cast_nullable_to_non_nullable
                  as int,
        custoUnitario: null == custoUnitario
            ? _value.custoUnitario
            : custoUnitario // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        abelinhasUnitarias: null == abelinhasUnitarias
            ? _value.abelinhasUnitarias
            : abelinhasUnitarias // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        produtoId: freezed == produtoId
            ? _value.produtoId
            : produtoId // ignore: cast_nullable_to_non_nullable
                  as String?,
        produtoVendaId: freezed == produtoVendaId
            ? _value.produtoVendaId
            : produtoVendaId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PedidoItemImpl implements _PedidoItem {
  const _$PedidoItemImpl({
    required this.id,
    @JsonKey(name: 'empresa_id') required this.empresaId,
    @JsonKey(name: 'pedido_id') required this.pedidoId,
    required this.tipo,
    required this.quantidade,
    @JsonKey(name: 'custo_unitario')
    @DecimalConverter()
    required this.custoUnitario,
    @JsonKey(name: 'abelinhas_unitarias')
    @DecimalConverter()
    required this.abelinhasUnitarias,
    @JsonKey(name: 'produto_id') this.produtoId,
    @JsonKey(name: 'produto_venda_id') this.produtoVendaId,
  });

  factory _$PedidoItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PedidoItemImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @override
  @JsonKey(name: 'pedido_id')
  final String pedidoId;
  @override
  final TipoPedidoItem tipo;
  @override
  final int quantidade;
  @override
  @JsonKey(name: 'custo_unitario')
  @DecimalConverter()
  final Decimal custoUnitario;
  @override
  @JsonKey(name: 'abelinhas_unitarias')
  @DecimalConverter()
  final Decimal abelinhasUnitarias;
  @override
  @JsonKey(name: 'produto_id')
  final String? produtoId;
  @override
  @JsonKey(name: 'produto_venda_id')
  final String? produtoVendaId;

  @override
  String toString() {
    return 'PedidoItem(id: $id, empresaId: $empresaId, pedidoId: $pedidoId, tipo: $tipo, quantidade: $quantidade, custoUnitario: $custoUnitario, abelinhasUnitarias: $abelinhasUnitarias, produtoId: $produtoId, produtoVendaId: $produtoVendaId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PedidoItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.empresaId, empresaId) ||
                other.empresaId == empresaId) &&
            (identical(other.pedidoId, pedidoId) ||
                other.pedidoId == pedidoId) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.quantidade, quantidade) ||
                other.quantidade == quantidade) &&
            (identical(other.custoUnitario, custoUnitario) ||
                other.custoUnitario == custoUnitario) &&
            (identical(other.abelinhasUnitarias, abelinhasUnitarias) ||
                other.abelinhasUnitarias == abelinhasUnitarias) &&
            (identical(other.produtoId, produtoId) ||
                other.produtoId == produtoId) &&
            (identical(other.produtoVendaId, produtoVendaId) ||
                other.produtoVendaId == produtoVendaId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    empresaId,
    pedidoId,
    tipo,
    quantidade,
    custoUnitario,
    abelinhasUnitarias,
    produtoId,
    produtoVendaId,
  );

  /// Create a copy of PedidoItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PedidoItemImplCopyWith<_$PedidoItemImpl> get copyWith =>
      __$$PedidoItemImplCopyWithImpl<_$PedidoItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PedidoItemImplToJson(this);
  }
}

abstract class _PedidoItem implements PedidoItem {
  const factory _PedidoItem({
    required final String id,
    @JsonKey(name: 'empresa_id') required final String empresaId,
    @JsonKey(name: 'pedido_id') required final String pedidoId,
    required final TipoPedidoItem tipo,
    required final int quantidade,
    @JsonKey(name: 'custo_unitario')
    @DecimalConverter()
    required final Decimal custoUnitario,
    @JsonKey(name: 'abelinhas_unitarias')
    @DecimalConverter()
    required final Decimal abelinhasUnitarias,
    @JsonKey(name: 'produto_id') final String? produtoId,
    @JsonKey(name: 'produto_venda_id') final String? produtoVendaId,
  }) = _$PedidoItemImpl;

  factory _PedidoItem.fromJson(Map<String, dynamic> json) =
      _$PedidoItemImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'empresa_id')
  String get empresaId;
  @override
  @JsonKey(name: 'pedido_id')
  String get pedidoId;
  @override
  TipoPedidoItem get tipo;
  @override
  int get quantidade;
  @override
  @JsonKey(name: 'custo_unitario')
  @DecimalConverter()
  Decimal get custoUnitario;
  @override
  @JsonKey(name: 'abelinhas_unitarias')
  @DecimalConverter()
  Decimal get abelinhasUnitarias;
  @override
  @JsonKey(name: 'produto_id')
  String? get produtoId;
  @override
  @JsonKey(name: 'produto_venda_id')
  String? get produtoVendaId;

  /// Create a copy of PedidoItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PedidoItemImplCopyWith<_$PedidoItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
