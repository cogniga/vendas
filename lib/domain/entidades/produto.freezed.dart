// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'produto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Produto _$ProdutoFromJson(Map<String, dynamic> json) {
  return _Produto.fromJson(json);
}

/// @nodoc
mixin _$Produto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'empresa_id')
  String get empresaId => throw _privateConstructorUsedError;
  String get codigo => throw _privateConstructorUsedError;
  String get nome => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get custo => throw _privateConstructorUsedError;
  String get marca => throw _privateConstructorUsedError;
  String get categoria => throw _privateConstructorUsedError;
  String get fornecedor => throw _privateConstructorUsedError;
  String get unidade => throw _privateConstructorUsedError;
  int get estoque => throw _privateConstructorUsedError;
  String get ean => throw _privateConstructorUsedError;
  bool get ativo => throw _privateConstructorUsedError;
  String get obs => throw _privateConstructorUsedError;
  @JsonKey(name: 'abelinhas_manual')
  @DecimalNullableConverter()
  Decimal? get abelinhasManual => throw _privateConstructorUsedError;

  /// Serializes this Produto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Produto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProdutoCopyWith<Produto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProdutoCopyWith<$Res> {
  factory $ProdutoCopyWith(Produto value, $Res Function(Produto) then) =
      _$ProdutoCopyWithImpl<$Res, Produto>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    String codigo,
    String nome,
    @DecimalConverter() Decimal custo,
    String marca,
    String categoria,
    String fornecedor,
    String unidade,
    int estoque,
    String ean,
    bool ativo,
    String obs,
    @JsonKey(name: 'abelinhas_manual')
    @DecimalNullableConverter()
    Decimal? abelinhasManual,
  });
}

/// @nodoc
class _$ProdutoCopyWithImpl<$Res, $Val extends Produto>
    implements $ProdutoCopyWith<$Res> {
  _$ProdutoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Produto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? codigo = null,
    Object? nome = null,
    Object? custo = null,
    Object? marca = null,
    Object? categoria = null,
    Object? fornecedor = null,
    Object? unidade = null,
    Object? estoque = null,
    Object? ean = null,
    Object? ativo = null,
    Object? obs = null,
    Object? abelinhasManual = freezed,
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
            codigo: null == codigo
                ? _value.codigo
                : codigo // ignore: cast_nullable_to_non_nullable
                      as String,
            nome: null == nome
                ? _value.nome
                : nome // ignore: cast_nullable_to_non_nullable
                      as String,
            custo: null == custo
                ? _value.custo
                : custo // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            marca: null == marca
                ? _value.marca
                : marca // ignore: cast_nullable_to_non_nullable
                      as String,
            categoria: null == categoria
                ? _value.categoria
                : categoria // ignore: cast_nullable_to_non_nullable
                      as String,
            fornecedor: null == fornecedor
                ? _value.fornecedor
                : fornecedor // ignore: cast_nullable_to_non_nullable
                      as String,
            unidade: null == unidade
                ? _value.unidade
                : unidade // ignore: cast_nullable_to_non_nullable
                      as String,
            estoque: null == estoque
                ? _value.estoque
                : estoque // ignore: cast_nullable_to_non_nullable
                      as int,
            ean: null == ean
                ? _value.ean
                : ean // ignore: cast_nullable_to_non_nullable
                      as String,
            ativo: null == ativo
                ? _value.ativo
                : ativo // ignore: cast_nullable_to_non_nullable
                      as bool,
            obs: null == obs
                ? _value.obs
                : obs // ignore: cast_nullable_to_non_nullable
                      as String,
            abelinhasManual: freezed == abelinhasManual
                ? _value.abelinhasManual
                : abelinhasManual // ignore: cast_nullable_to_non_nullable
                      as Decimal?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProdutoImplCopyWith<$Res> implements $ProdutoCopyWith<$Res> {
  factory _$$ProdutoImplCopyWith(
    _$ProdutoImpl value,
    $Res Function(_$ProdutoImpl) then,
  ) = __$$ProdutoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    String codigo,
    String nome,
    @DecimalConverter() Decimal custo,
    String marca,
    String categoria,
    String fornecedor,
    String unidade,
    int estoque,
    String ean,
    bool ativo,
    String obs,
    @JsonKey(name: 'abelinhas_manual')
    @DecimalNullableConverter()
    Decimal? abelinhasManual,
  });
}

/// @nodoc
class __$$ProdutoImplCopyWithImpl<$Res>
    extends _$ProdutoCopyWithImpl<$Res, _$ProdutoImpl>
    implements _$$ProdutoImplCopyWith<$Res> {
  __$$ProdutoImplCopyWithImpl(
    _$ProdutoImpl _value,
    $Res Function(_$ProdutoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Produto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? codigo = null,
    Object? nome = null,
    Object? custo = null,
    Object? marca = null,
    Object? categoria = null,
    Object? fornecedor = null,
    Object? unidade = null,
    Object? estoque = null,
    Object? ean = null,
    Object? ativo = null,
    Object? obs = null,
    Object? abelinhasManual = freezed,
  }) {
    return _then(
      _$ProdutoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        empresaId: null == empresaId
            ? _value.empresaId
            : empresaId // ignore: cast_nullable_to_non_nullable
                  as String,
        codigo: null == codigo
            ? _value.codigo
            : codigo // ignore: cast_nullable_to_non_nullable
                  as String,
        nome: null == nome
            ? _value.nome
            : nome // ignore: cast_nullable_to_non_nullable
                  as String,
        custo: null == custo
            ? _value.custo
            : custo // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        marca: null == marca
            ? _value.marca
            : marca // ignore: cast_nullable_to_non_nullable
                  as String,
        categoria: null == categoria
            ? _value.categoria
            : categoria // ignore: cast_nullable_to_non_nullable
                  as String,
        fornecedor: null == fornecedor
            ? _value.fornecedor
            : fornecedor // ignore: cast_nullable_to_non_nullable
                  as String,
        unidade: null == unidade
            ? _value.unidade
            : unidade // ignore: cast_nullable_to_non_nullable
                  as String,
        estoque: null == estoque
            ? _value.estoque
            : estoque // ignore: cast_nullable_to_non_nullable
                  as int,
        ean: null == ean
            ? _value.ean
            : ean // ignore: cast_nullable_to_non_nullable
                  as String,
        ativo: null == ativo
            ? _value.ativo
            : ativo // ignore: cast_nullable_to_non_nullable
                  as bool,
        obs: null == obs
            ? _value.obs
            : obs // ignore: cast_nullable_to_non_nullable
                  as String,
        abelinhasManual: freezed == abelinhasManual
            ? _value.abelinhasManual
            : abelinhasManual // ignore: cast_nullable_to_non_nullable
                  as Decimal?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProdutoImpl implements _Produto {
  const _$ProdutoImpl({
    required this.id,
    @JsonKey(name: 'empresa_id') required this.empresaId,
    required this.codigo,
    required this.nome,
    @DecimalConverter() required this.custo,
    this.marca = '',
    this.categoria = 'Cosméticos',
    this.fornecedor = '',
    this.unidade = 'un',
    this.estoque = 0,
    this.ean = '',
    this.ativo = true,
    this.obs = '',
    @JsonKey(name: 'abelinhas_manual')
    @DecimalNullableConverter()
    this.abelinhasManual,
  });

  factory _$ProdutoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProdutoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @override
  final String codigo;
  @override
  final String nome;
  @override
  @DecimalConverter()
  final Decimal custo;
  @override
  @JsonKey()
  final String marca;
  @override
  @JsonKey()
  final String categoria;
  @override
  @JsonKey()
  final String fornecedor;
  @override
  @JsonKey()
  final String unidade;
  @override
  @JsonKey()
  final int estoque;
  @override
  @JsonKey()
  final String ean;
  @override
  @JsonKey()
  final bool ativo;
  @override
  @JsonKey()
  final String obs;
  @override
  @JsonKey(name: 'abelinhas_manual')
  @DecimalNullableConverter()
  final Decimal? abelinhasManual;

  @override
  String toString() {
    return 'Produto(id: $id, empresaId: $empresaId, codigo: $codigo, nome: $nome, custo: $custo, marca: $marca, categoria: $categoria, fornecedor: $fornecedor, unidade: $unidade, estoque: $estoque, ean: $ean, ativo: $ativo, obs: $obs, abelinhasManual: $abelinhasManual)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProdutoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.empresaId, empresaId) ||
                other.empresaId == empresaId) &&
            (identical(other.codigo, codigo) || other.codigo == codigo) &&
            (identical(other.nome, nome) || other.nome == nome) &&
            (identical(other.custo, custo) || other.custo == custo) &&
            (identical(other.marca, marca) || other.marca == marca) &&
            (identical(other.categoria, categoria) ||
                other.categoria == categoria) &&
            (identical(other.fornecedor, fornecedor) ||
                other.fornecedor == fornecedor) &&
            (identical(other.unidade, unidade) || other.unidade == unidade) &&
            (identical(other.estoque, estoque) || other.estoque == estoque) &&
            (identical(other.ean, ean) || other.ean == ean) &&
            (identical(other.ativo, ativo) || other.ativo == ativo) &&
            (identical(other.obs, obs) || other.obs == obs) &&
            (identical(other.abelinhasManual, abelinhasManual) ||
                other.abelinhasManual == abelinhasManual));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    empresaId,
    codigo,
    nome,
    custo,
    marca,
    categoria,
    fornecedor,
    unidade,
    estoque,
    ean,
    ativo,
    obs,
    abelinhasManual,
  );

  /// Create a copy of Produto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProdutoImplCopyWith<_$ProdutoImpl> get copyWith =>
      __$$ProdutoImplCopyWithImpl<_$ProdutoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProdutoImplToJson(this);
  }
}

abstract class _Produto implements Produto {
  const factory _Produto({
    required final String id,
    @JsonKey(name: 'empresa_id') required final String empresaId,
    required final String codigo,
    required final String nome,
    @DecimalConverter() required final Decimal custo,
    final String marca,
    final String categoria,
    final String fornecedor,
    final String unidade,
    final int estoque,
    final String ean,
    final bool ativo,
    final String obs,
    @JsonKey(name: 'abelinhas_manual')
    @DecimalNullableConverter()
    final Decimal? abelinhasManual,
  }) = _$ProdutoImpl;

  factory _Produto.fromJson(Map<String, dynamic> json) = _$ProdutoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'empresa_id')
  String get empresaId;
  @override
  String get codigo;
  @override
  String get nome;
  @override
  @DecimalConverter()
  Decimal get custo;
  @override
  String get marca;
  @override
  String get categoria;
  @override
  String get fornecedor;
  @override
  String get unidade;
  @override
  int get estoque;
  @override
  String get ean;
  @override
  bool get ativo;
  @override
  String get obs;
  @override
  @JsonKey(name: 'abelinhas_manual')
  @DecimalNullableConverter()
  Decimal? get abelinhasManual;

  /// Create a copy of Produto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProdutoImplCopyWith<_$ProdutoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
