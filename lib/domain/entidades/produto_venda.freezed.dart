// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'produto_venda.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProdutoVenda _$ProdutoVendaFromJson(Map<String, dynamic> json) {
  return _ProdutoVenda.fromJson(json);
}

/// @nodoc
mixin _$ProdutoVenda {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'empresa_id')
  String get empresaId => throw _privateConstructorUsedError;
  String get nome => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get embalagem => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get impressao => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get outros => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get preco => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get desconto => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get cupom => throw _privateConstructorUsedError;
  @JsonKey(name: 'meta_lucro')
  @DecimalConverter()
  Decimal get metaLucro => throw _privateConstructorUsedError;
  @JsonKey(name: 'fatia_roas')
  @DecimalConverter()
  Decimal get fatiaRoas => throw _privateConstructorUsedError;
  @JsonKey(name: 'margem_alvo')
  @DecimalConverter()
  Decimal get margemAlvo => throw _privateConstructorUsedError;
  @JsonKey(name: 'compra_insumo_id')
  String? get compraInsumoId => throw _privateConstructorUsedError;
  @JsonKey(name: 'preco_concorrente')
  @DecimalNullableConverter()
  Decimal? get precoConcorrente => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ProdutoVendaItem> get itens => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, PrecoPlataforma> get precosPorPlataforma =>
      throw _privateConstructorUsedError;

  /// Serializes this ProdutoVenda to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProdutoVenda
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProdutoVendaCopyWith<ProdutoVenda> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProdutoVendaCopyWith<$Res> {
  factory $ProdutoVendaCopyWith(
    ProdutoVenda value,
    $Res Function(ProdutoVenda) then,
  ) = _$ProdutoVendaCopyWithImpl<$Res, ProdutoVenda>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    String nome,
    @DecimalConverter() Decimal embalagem,
    @DecimalConverter() Decimal impressao,
    @DecimalConverter() Decimal outros,
    @DecimalConverter() Decimal preco,
    @DecimalConverter() Decimal desconto,
    @DecimalConverter() Decimal cupom,
    @JsonKey(name: 'meta_lucro') @DecimalConverter() Decimal metaLucro,
    @JsonKey(name: 'fatia_roas') @DecimalConverter() Decimal fatiaRoas,
    @JsonKey(name: 'margem_alvo') @DecimalConverter() Decimal margemAlvo,
    @JsonKey(name: 'compra_insumo_id') String? compraInsumoId,
    @JsonKey(name: 'preco_concorrente')
    @DecimalNullableConverter()
    Decimal? precoConcorrente,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<ProdutoVendaItem> itens,
    @JsonKey(includeFromJson: false, includeToJson: false)
    Map<String, PrecoPlataforma> precosPorPlataforma,
  });
}

/// @nodoc
class _$ProdutoVendaCopyWithImpl<$Res, $Val extends ProdutoVenda>
    implements $ProdutoVendaCopyWith<$Res> {
  _$ProdutoVendaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProdutoVenda
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? nome = null,
    Object? embalagem = null,
    Object? impressao = null,
    Object? outros = null,
    Object? preco = null,
    Object? desconto = null,
    Object? cupom = null,
    Object? metaLucro = null,
    Object? fatiaRoas = null,
    Object? margemAlvo = null,
    Object? compraInsumoId = freezed,
    Object? precoConcorrente = freezed,
    Object? itens = null,
    Object? precosPorPlataforma = null,
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
            preco: null == preco
                ? _value.preco
                : preco // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            desconto: null == desconto
                ? _value.desconto
                : desconto // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            cupom: null == cupom
                ? _value.cupom
                : cupom // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            metaLucro: null == metaLucro
                ? _value.metaLucro
                : metaLucro // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            fatiaRoas: null == fatiaRoas
                ? _value.fatiaRoas
                : fatiaRoas // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            margemAlvo: null == margemAlvo
                ? _value.margemAlvo
                : margemAlvo // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            compraInsumoId: freezed == compraInsumoId
                ? _value.compraInsumoId
                : compraInsumoId // ignore: cast_nullable_to_non_nullable
                      as String?,
            precoConcorrente: freezed == precoConcorrente
                ? _value.precoConcorrente
                : precoConcorrente // ignore: cast_nullable_to_non_nullable
                      as Decimal?,
            itens: null == itens
                ? _value.itens
                : itens // ignore: cast_nullable_to_non_nullable
                      as List<ProdutoVendaItem>,
            precosPorPlataforma: null == precosPorPlataforma
                ? _value.precosPorPlataforma
                : precosPorPlataforma // ignore: cast_nullable_to_non_nullable
                      as Map<String, PrecoPlataforma>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProdutoVendaImplCopyWith<$Res>
    implements $ProdutoVendaCopyWith<$Res> {
  factory _$$ProdutoVendaImplCopyWith(
    _$ProdutoVendaImpl value,
    $Res Function(_$ProdutoVendaImpl) then,
  ) = __$$ProdutoVendaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    String nome,
    @DecimalConverter() Decimal embalagem,
    @DecimalConverter() Decimal impressao,
    @DecimalConverter() Decimal outros,
    @DecimalConverter() Decimal preco,
    @DecimalConverter() Decimal desconto,
    @DecimalConverter() Decimal cupom,
    @JsonKey(name: 'meta_lucro') @DecimalConverter() Decimal metaLucro,
    @JsonKey(name: 'fatia_roas') @DecimalConverter() Decimal fatiaRoas,
    @JsonKey(name: 'margem_alvo') @DecimalConverter() Decimal margemAlvo,
    @JsonKey(name: 'compra_insumo_id') String? compraInsumoId,
    @JsonKey(name: 'preco_concorrente')
    @DecimalNullableConverter()
    Decimal? precoConcorrente,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<ProdutoVendaItem> itens,
    @JsonKey(includeFromJson: false, includeToJson: false)
    Map<String, PrecoPlataforma> precosPorPlataforma,
  });
}

/// @nodoc
class __$$ProdutoVendaImplCopyWithImpl<$Res>
    extends _$ProdutoVendaCopyWithImpl<$Res, _$ProdutoVendaImpl>
    implements _$$ProdutoVendaImplCopyWith<$Res> {
  __$$ProdutoVendaImplCopyWithImpl(
    _$ProdutoVendaImpl _value,
    $Res Function(_$ProdutoVendaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProdutoVenda
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? nome = null,
    Object? embalagem = null,
    Object? impressao = null,
    Object? outros = null,
    Object? preco = null,
    Object? desconto = null,
    Object? cupom = null,
    Object? metaLucro = null,
    Object? fatiaRoas = null,
    Object? margemAlvo = null,
    Object? compraInsumoId = freezed,
    Object? precoConcorrente = freezed,
    Object? itens = null,
    Object? precosPorPlataforma = null,
  }) {
    return _then(
      _$ProdutoVendaImpl(
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
        preco: null == preco
            ? _value.preco
            : preco // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        desconto: null == desconto
            ? _value.desconto
            : desconto // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        cupom: null == cupom
            ? _value.cupom
            : cupom // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        metaLucro: null == metaLucro
            ? _value.metaLucro
            : metaLucro // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        fatiaRoas: null == fatiaRoas
            ? _value.fatiaRoas
            : fatiaRoas // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        margemAlvo: null == margemAlvo
            ? _value.margemAlvo
            : margemAlvo // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        compraInsumoId: freezed == compraInsumoId
            ? _value.compraInsumoId
            : compraInsumoId // ignore: cast_nullable_to_non_nullable
                  as String?,
        precoConcorrente: freezed == precoConcorrente
            ? _value.precoConcorrente
            : precoConcorrente // ignore: cast_nullable_to_non_nullable
                  as Decimal?,
        itens: null == itens
            ? _value._itens
            : itens // ignore: cast_nullable_to_non_nullable
                  as List<ProdutoVendaItem>,
        precosPorPlataforma: null == precosPorPlataforma
            ? _value._precosPorPlataforma
            : precosPorPlataforma // ignore: cast_nullable_to_non_nullable
                  as Map<String, PrecoPlataforma>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProdutoVendaImpl implements _ProdutoVenda {
  const _$ProdutoVendaImpl({
    required this.id,
    @JsonKey(name: 'empresa_id') required this.empresaId,
    required this.nome,
    @DecimalConverter() required this.embalagem,
    @DecimalConverter() required this.impressao,
    @DecimalConverter() required this.outros,
    @DecimalConverter() required this.preco,
    @DecimalConverter() required this.desconto,
    @DecimalConverter() required this.cupom,
    @JsonKey(name: 'meta_lucro') @DecimalConverter() required this.metaLucro,
    @JsonKey(name: 'fatia_roas') @DecimalConverter() required this.fatiaRoas,
    @JsonKey(name: 'margem_alvo') @DecimalConverter() required this.margemAlvo,
    @JsonKey(name: 'compra_insumo_id') this.compraInsumoId,
    @JsonKey(name: 'preco_concorrente')
    @DecimalNullableConverter()
    this.precoConcorrente,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final List<ProdutoVendaItem> itens = const <ProdutoVendaItem>[],
    @JsonKey(includeFromJson: false, includeToJson: false)
    final Map<String, PrecoPlataforma> precosPorPlataforma =
        const <String, PrecoPlataforma>{},
  }) : _itens = itens,
       _precosPorPlataforma = precosPorPlataforma;

  factory _$ProdutoVendaImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProdutoVendaImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @override
  final String nome;
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
  @DecimalConverter()
  final Decimal preco;
  @override
  @DecimalConverter()
  final Decimal desconto;
  @override
  @DecimalConverter()
  final Decimal cupom;
  @override
  @JsonKey(name: 'meta_lucro')
  @DecimalConverter()
  final Decimal metaLucro;
  @override
  @JsonKey(name: 'fatia_roas')
  @DecimalConverter()
  final Decimal fatiaRoas;
  @override
  @JsonKey(name: 'margem_alvo')
  @DecimalConverter()
  final Decimal margemAlvo;
  @override
  @JsonKey(name: 'compra_insumo_id')
  final String? compraInsumoId;
  @override
  @JsonKey(name: 'preco_concorrente')
  @DecimalNullableConverter()
  final Decimal? precoConcorrente;
  final List<ProdutoVendaItem> _itens;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ProdutoVendaItem> get itens {
    if (_itens is EqualUnmodifiableListView) return _itens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_itens);
  }

  final Map<String, PrecoPlataforma> _precosPorPlataforma;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, PrecoPlataforma> get precosPorPlataforma {
    if (_precosPorPlataforma is EqualUnmodifiableMapView)
      return _precosPorPlataforma;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_precosPorPlataforma);
  }

  @override
  String toString() {
    return 'ProdutoVenda(id: $id, empresaId: $empresaId, nome: $nome, embalagem: $embalagem, impressao: $impressao, outros: $outros, preco: $preco, desconto: $desconto, cupom: $cupom, metaLucro: $metaLucro, fatiaRoas: $fatiaRoas, margemAlvo: $margemAlvo, compraInsumoId: $compraInsumoId, precoConcorrente: $precoConcorrente, itens: $itens, precosPorPlataforma: $precosPorPlataforma)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProdutoVendaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.empresaId, empresaId) ||
                other.empresaId == empresaId) &&
            (identical(other.nome, nome) || other.nome == nome) &&
            (identical(other.embalagem, embalagem) ||
                other.embalagem == embalagem) &&
            (identical(other.impressao, impressao) ||
                other.impressao == impressao) &&
            (identical(other.outros, outros) || other.outros == outros) &&
            (identical(other.preco, preco) || other.preco == preco) &&
            (identical(other.desconto, desconto) ||
                other.desconto == desconto) &&
            (identical(other.cupom, cupom) || other.cupom == cupom) &&
            (identical(other.metaLucro, metaLucro) ||
                other.metaLucro == metaLucro) &&
            (identical(other.fatiaRoas, fatiaRoas) ||
                other.fatiaRoas == fatiaRoas) &&
            (identical(other.margemAlvo, margemAlvo) ||
                other.margemAlvo == margemAlvo) &&
            (identical(other.compraInsumoId, compraInsumoId) ||
                other.compraInsumoId == compraInsumoId) &&
            (identical(other.precoConcorrente, precoConcorrente) ||
                other.precoConcorrente == precoConcorrente) &&
            const DeepCollectionEquality().equals(other._itens, _itens) &&
            const DeepCollectionEquality().equals(
              other._precosPorPlataforma,
              _precosPorPlataforma,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    empresaId,
    nome,
    embalagem,
    impressao,
    outros,
    preco,
    desconto,
    cupom,
    metaLucro,
    fatiaRoas,
    margemAlvo,
    compraInsumoId,
    precoConcorrente,
    const DeepCollectionEquality().hash(_itens),
    const DeepCollectionEquality().hash(_precosPorPlataforma),
  );

  /// Create a copy of ProdutoVenda
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProdutoVendaImplCopyWith<_$ProdutoVendaImpl> get copyWith =>
      __$$ProdutoVendaImplCopyWithImpl<_$ProdutoVendaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProdutoVendaImplToJson(this);
  }
}

abstract class _ProdutoVenda implements ProdutoVenda {
  const factory _ProdutoVenda({
    required final String id,
    @JsonKey(name: 'empresa_id') required final String empresaId,
    required final String nome,
    @DecimalConverter() required final Decimal embalagem,
    @DecimalConverter() required final Decimal impressao,
    @DecimalConverter() required final Decimal outros,
    @DecimalConverter() required final Decimal preco,
    @DecimalConverter() required final Decimal desconto,
    @DecimalConverter() required final Decimal cupom,
    @JsonKey(name: 'meta_lucro')
    @DecimalConverter()
    required final Decimal metaLucro,
    @JsonKey(name: 'fatia_roas')
    @DecimalConverter()
    required final Decimal fatiaRoas,
    @JsonKey(name: 'margem_alvo')
    @DecimalConverter()
    required final Decimal margemAlvo,
    @JsonKey(name: 'compra_insumo_id') final String? compraInsumoId,
    @JsonKey(name: 'preco_concorrente')
    @DecimalNullableConverter()
    final Decimal? precoConcorrente,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final List<ProdutoVendaItem> itens,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final Map<String, PrecoPlataforma> precosPorPlataforma,
  }) = _$ProdutoVendaImpl;

  factory _ProdutoVenda.fromJson(Map<String, dynamic> json) =
      _$ProdutoVendaImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'empresa_id')
  String get empresaId;
  @override
  String get nome;
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
  @DecimalConverter()
  Decimal get preco;
  @override
  @DecimalConverter()
  Decimal get desconto;
  @override
  @DecimalConverter()
  Decimal get cupom;
  @override
  @JsonKey(name: 'meta_lucro')
  @DecimalConverter()
  Decimal get metaLucro;
  @override
  @JsonKey(name: 'fatia_roas')
  @DecimalConverter()
  Decimal get fatiaRoas;
  @override
  @JsonKey(name: 'margem_alvo')
  @DecimalConverter()
  Decimal get margemAlvo;
  @override
  @JsonKey(name: 'compra_insumo_id')
  String? get compraInsumoId;
  @override
  @JsonKey(name: 'preco_concorrente')
  @DecimalNullableConverter()
  Decimal? get precoConcorrente;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ProdutoVendaItem> get itens;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, PrecoPlataforma> get precosPorPlataforma;

  /// Create a copy of ProdutoVenda
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProdutoVendaImplCopyWith<_$ProdutoVendaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
