// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pedido.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Pedido _$PedidoFromJson(Map<String, dynamic> json) {
  return _Pedido.fromJson(json);
}

/// @nodoc
mixin _$Pedido {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'empresa_id')
  String get empresaId => throw _privateConstructorUsedError;
  DateTime get data => throw _privateConstructorUsedError;
  String get cliente => throw _privateConstructorUsedError;
  @JsonKey(name: 'plataforma_id')
  String get plataformaId => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get embalagem => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get impressao => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get outros => throw _privateConstructorUsedError;
  @JsonKey(name: 'preco_venda')
  @DecimalConverter()
  Decimal get precoVenda => throw _privateConstructorUsedError;
  @JsonKey(name: 'itens_taxa_fixa')
  int get itensTaxaFixa => throw _privateConstructorUsedError;
  @JsonKey(name: 'liquido_informado')
  @DecimalNullableConverter()
  Decimal? get liquidoInformado => throw _privateConstructorUsedError;
  SituacaoPedido get situacao => throw _privateConstructorUsedError;
  String get obs => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<PedidoItem> get itens => throw _privateConstructorUsedError;

  /// Serializes this Pedido to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Pedido
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PedidoCopyWith<Pedido> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PedidoCopyWith<$Res> {
  factory $PedidoCopyWith(Pedido value, $Res Function(Pedido) then) =
      _$PedidoCopyWithImpl<$Res, Pedido>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    DateTime data,
    String cliente,
    @JsonKey(name: 'plataforma_id') String plataformaId,
    @DecimalConverter() Decimal embalagem,
    @DecimalConverter() Decimal impressao,
    @DecimalConverter() Decimal outros,
    @JsonKey(name: 'preco_venda') @DecimalConverter() Decimal precoVenda,
    @JsonKey(name: 'itens_taxa_fixa') int itensTaxaFixa,
    @JsonKey(name: 'liquido_informado')
    @DecimalNullableConverter()
    Decimal? liquidoInformado,
    SituacaoPedido situacao,
    String obs,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<PedidoItem> itens,
  });
}

/// @nodoc
class _$PedidoCopyWithImpl<$Res, $Val extends Pedido>
    implements $PedidoCopyWith<$Res> {
  _$PedidoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Pedido
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? data = null,
    Object? cliente = null,
    Object? plataformaId = null,
    Object? embalagem = null,
    Object? impressao = null,
    Object? outros = null,
    Object? precoVenda = null,
    Object? itensTaxaFixa = null,
    Object? liquidoInformado = freezed,
    Object? situacao = null,
    Object? obs = null,
    Object? itens = null,
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
            cliente: null == cliente
                ? _value.cliente
                : cliente // ignore: cast_nullable_to_non_nullable
                      as String,
            plataformaId: null == plataformaId
                ? _value.plataformaId
                : plataformaId // ignore: cast_nullable_to_non_nullable
                      as String,
            embalagem: null == embalagem
                ? _value.embalagem
                : embalagem // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            impressao: null == impressao
                ? _value.impressao
                : impressao // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            outros: null == outros
                ? _value.outros
                : outros // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            precoVenda: null == precoVenda
                ? _value.precoVenda
                : precoVenda // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            itensTaxaFixa: null == itensTaxaFixa
                ? _value.itensTaxaFixa
                : itensTaxaFixa // ignore: cast_nullable_to_non_nullable
                      as int,
            liquidoInformado: freezed == liquidoInformado
                ? _value.liquidoInformado
                : liquidoInformado // ignore: cast_nullable_to_non_nullable
                      as Decimal?,
            situacao: null == situacao
                ? _value.situacao
                : situacao // ignore: cast_nullable_to_non_nullable
                      as SituacaoPedido,
            obs: null == obs
                ? _value.obs
                : obs // ignore: cast_nullable_to_non_nullable
                      as String,
            itens: null == itens
                ? _value.itens
                : itens // ignore: cast_nullable_to_non_nullable
                      as List<PedidoItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PedidoImplCopyWith<$Res> implements $PedidoCopyWith<$Res> {
  factory _$$PedidoImplCopyWith(
    _$PedidoImpl value,
    $Res Function(_$PedidoImpl) then,
  ) = __$$PedidoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    DateTime data,
    String cliente,
    @JsonKey(name: 'plataforma_id') String plataformaId,
    @DecimalConverter() Decimal embalagem,
    @DecimalConverter() Decimal impressao,
    @DecimalConverter() Decimal outros,
    @JsonKey(name: 'preco_venda') @DecimalConverter() Decimal precoVenda,
    @JsonKey(name: 'itens_taxa_fixa') int itensTaxaFixa,
    @JsonKey(name: 'liquido_informado')
    @DecimalNullableConverter()
    Decimal? liquidoInformado,
    SituacaoPedido situacao,
    String obs,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<PedidoItem> itens,
  });
}

/// @nodoc
class __$$PedidoImplCopyWithImpl<$Res>
    extends _$PedidoCopyWithImpl<$Res, _$PedidoImpl>
    implements _$$PedidoImplCopyWith<$Res> {
  __$$PedidoImplCopyWithImpl(
    _$PedidoImpl _value,
    $Res Function(_$PedidoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Pedido
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? data = null,
    Object? cliente = null,
    Object? plataformaId = null,
    Object? embalagem = null,
    Object? impressao = null,
    Object? outros = null,
    Object? precoVenda = null,
    Object? itensTaxaFixa = null,
    Object? liquidoInformado = freezed,
    Object? situacao = null,
    Object? obs = null,
    Object? itens = null,
  }) {
    return _then(
      _$PedidoImpl(
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
        cliente: null == cliente
            ? _value.cliente
            : cliente // ignore: cast_nullable_to_non_nullable
                  as String,
        plataformaId: null == plataformaId
            ? _value.plataformaId
            : plataformaId // ignore: cast_nullable_to_non_nullable
                  as String,
        embalagem: null == embalagem
            ? _value.embalagem
            : embalagem // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        impressao: null == impressao
            ? _value.impressao
            : impressao // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        outros: null == outros
            ? _value.outros
            : outros // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        precoVenda: null == precoVenda
            ? _value.precoVenda
            : precoVenda // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        itensTaxaFixa: null == itensTaxaFixa
            ? _value.itensTaxaFixa
            : itensTaxaFixa // ignore: cast_nullable_to_non_nullable
                  as int,
        liquidoInformado: freezed == liquidoInformado
            ? _value.liquidoInformado
            : liquidoInformado // ignore: cast_nullable_to_non_nullable
                  as Decimal?,
        situacao: null == situacao
            ? _value.situacao
            : situacao // ignore: cast_nullable_to_non_nullable
                  as SituacaoPedido,
        obs: null == obs
            ? _value.obs
            : obs // ignore: cast_nullable_to_non_nullable
                  as String,
        itens: null == itens
            ? _value._itens
            : itens // ignore: cast_nullable_to_non_nullable
                  as List<PedidoItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PedidoImpl implements _Pedido {
  const _$PedidoImpl({
    required this.id,
    @JsonKey(name: 'empresa_id') required this.empresaId,
    required this.data,
    required this.cliente,
    @JsonKey(name: 'plataforma_id') required this.plataformaId,
    @DecimalConverter() required this.embalagem,
    @DecimalConverter() required this.impressao,
    @DecimalConverter() required this.outros,
    @JsonKey(name: 'preco_venda') @DecimalConverter() required this.precoVenda,
    @JsonKey(name: 'itens_taxa_fixa') this.itensTaxaFixa = 1,
    @JsonKey(name: 'liquido_informado')
    @DecimalNullableConverter()
    this.liquidoInformado,
    this.situacao = SituacaoPedido.concluido,
    this.obs = '',
    @JsonKey(includeFromJson: false, includeToJson: false)
    final List<PedidoItem> itens = const <PedidoItem>[],
  }) : _itens = itens;

  factory _$PedidoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PedidoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @override
  final DateTime data;
  @override
  final String cliente;
  @override
  @JsonKey(name: 'plataforma_id')
  final String plataformaId;
  @override
  @DecimalConverter()
  final Decimal embalagem;
  @override
  @DecimalConverter()
  final Decimal impressao;
  @override
  @DecimalConverter()
  final Decimal outros;
  @override
  @JsonKey(name: 'preco_venda')
  @DecimalConverter()
  final Decimal precoVenda;
  @override
  @JsonKey(name: 'itens_taxa_fixa')
  final int itensTaxaFixa;
  @override
  @JsonKey(name: 'liquido_informado')
  @DecimalNullableConverter()
  final Decimal? liquidoInformado;
  @override
  @JsonKey()
  final SituacaoPedido situacao;
  @override
  @JsonKey()
  final String obs;
  final List<PedidoItem> _itens;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<PedidoItem> get itens {
    if (_itens is EqualUnmodifiableListView) return _itens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_itens);
  }

  @override
  String toString() {
    return 'Pedido(id: $id, empresaId: $empresaId, data: $data, cliente: $cliente, plataformaId: $plataformaId, embalagem: $embalagem, impressao: $impressao, outros: $outros, precoVenda: $precoVenda, itensTaxaFixa: $itensTaxaFixa, liquidoInformado: $liquidoInformado, situacao: $situacao, obs: $obs, itens: $itens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PedidoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.empresaId, empresaId) ||
                other.empresaId == empresaId) &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.cliente, cliente) || other.cliente == cliente) &&
            (identical(other.plataformaId, plataformaId) ||
                other.plataformaId == plataformaId) &&
            (identical(other.embalagem, embalagem) ||
                other.embalagem == embalagem) &&
            (identical(other.impressao, impressao) ||
                other.impressao == impressao) &&
            (identical(other.outros, outros) || other.outros == outros) &&
            (identical(other.precoVenda, precoVenda) ||
                other.precoVenda == precoVenda) &&
            (identical(other.itensTaxaFixa, itensTaxaFixa) ||
                other.itensTaxaFixa == itensTaxaFixa) &&
            (identical(other.liquidoInformado, liquidoInformado) ||
                other.liquidoInformado == liquidoInformado) &&
            (identical(other.situacao, situacao) ||
                other.situacao == situacao) &&
            (identical(other.obs, obs) || other.obs == obs) &&
            const DeepCollectionEquality().equals(other._itens, _itens));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    empresaId,
    data,
    cliente,
    plataformaId,
    embalagem,
    impressao,
    outros,
    precoVenda,
    itensTaxaFixa,
    liquidoInformado,
    situacao,
    obs,
    const DeepCollectionEquality().hash(_itens),
  );

  /// Create a copy of Pedido
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PedidoImplCopyWith<_$PedidoImpl> get copyWith =>
      __$$PedidoImplCopyWithImpl<_$PedidoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PedidoImplToJson(this);
  }
}

abstract class _Pedido implements Pedido {
  const factory _Pedido({
    required final String id,
    @JsonKey(name: 'empresa_id') required final String empresaId,
    required final DateTime data,
    required final String cliente,
    @JsonKey(name: 'plataforma_id') required final String plataformaId,
    @DecimalConverter() required final Decimal embalagem,
    @DecimalConverter() required final Decimal impressao,
    @DecimalConverter() required final Decimal outros,
    @JsonKey(name: 'preco_venda')
    @DecimalConverter()
    required final Decimal precoVenda,
    @JsonKey(name: 'itens_taxa_fixa') final int itensTaxaFixa,
    @JsonKey(name: 'liquido_informado')
    @DecimalNullableConverter()
    final Decimal? liquidoInformado,
    final SituacaoPedido situacao,
    final String obs,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final List<PedidoItem> itens,
  }) = _$PedidoImpl;

  factory _Pedido.fromJson(Map<String, dynamic> json) = _$PedidoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'empresa_id')
  String get empresaId;
  @override
  DateTime get data;
  @override
  String get cliente;
  @override
  @JsonKey(name: 'plataforma_id')
  String get plataformaId;
  @override
  @DecimalConverter()
  Decimal get embalagem;
  @override
  @DecimalConverter()
  Decimal get impressao;
  @override
  @DecimalConverter()
  Decimal get outros;
  @override
  @JsonKey(name: 'preco_venda')
  @DecimalConverter()
  Decimal get precoVenda;
  @override
  @JsonKey(name: 'itens_taxa_fixa')
  int get itensTaxaFixa;
  @override
  @JsonKey(name: 'liquido_informado')
  @DecimalNullableConverter()
  Decimal? get liquidoInformado;
  @override
  SituacaoPedido get situacao;
  @override
  String get obs;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<PedidoItem> get itens;

  /// Create a copy of Pedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PedidoImplCopyWith<_$PedidoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
