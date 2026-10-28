// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preco_plataforma.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PrecoPlataforma _$PrecoPlataformaFromJson(Map<String, dynamic> json) {
  return _PrecoPlataforma.fromJson(json);
}

/// @nodoc
mixin _$PrecoPlataforma {
  @JsonKey(name: 'empresa_id')
  String get empresaId => throw _privateConstructorUsedError;
  @JsonKey(name: 'produto_venda_id')
  String get produtoVendaId => throw _privateConstructorUsedError;
  @JsonKey(name: 'plataforma_id')
  String get plataformaId => throw _privateConstructorUsedError;
  @DecimalNullableConverter()
  Decimal? get preco => throw _privateConstructorUsedError;
  @DecimalNullableConverter()
  Decimal? get desconto => throw _privateConstructorUsedError;
  @DecimalNullableConverter()
  Decimal? get cupom => throw _privateConstructorUsedError;
  @JsonKey(name: 'vendidos_iniciais')
  int get vendidosIniciais => throw _privateConstructorUsedError;

  /// Serializes this PrecoPlataforma to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PrecoPlataforma
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrecoPlataformaCopyWith<PrecoPlataforma> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrecoPlataformaCopyWith<$Res> {
  factory $PrecoPlataformaCopyWith(
    PrecoPlataforma value,
    $Res Function(PrecoPlataforma) then,
  ) = _$PrecoPlataformaCopyWithImpl<$Res, PrecoPlataforma>;
  @useResult
  $Res call({
    @JsonKey(name: 'empresa_id') String empresaId,
    @JsonKey(name: 'produto_venda_id') String produtoVendaId,
    @JsonKey(name: 'plataforma_id') String plataformaId,
    @DecimalNullableConverter() Decimal? preco,
    @DecimalNullableConverter() Decimal? desconto,
    @DecimalNullableConverter() Decimal? cupom,
    @JsonKey(name: 'vendidos_iniciais') int vendidosIniciais,
  });
}

/// @nodoc
class _$PrecoPlataformaCopyWithImpl<$Res, $Val extends PrecoPlataforma>
    implements $PrecoPlataformaCopyWith<$Res> {
  _$PrecoPlataformaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PrecoPlataforma
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? empresaId = null,
    Object? produtoVendaId = null,
    Object? plataformaId = null,
    Object? preco = freezed,
    Object? desconto = freezed,
    Object? cupom = freezed,
    Object? vendidosIniciais = null,
  }) {
    return _then(
      _value.copyWith(
            empresaId: null == empresaId
                ? _value.empresaId
                : empresaId // ignore: cast_nullable_to_non_nullable
                      as String,
            produtoVendaId: null == produtoVendaId
                ? _value.produtoVendaId
                : produtoVendaId // ignore: cast_nullable_to_non_nullable
                      as String,
            plataformaId: null == plataformaId
                ? _value.plataformaId
                : plataformaId // ignore: cast_nullable_to_non_nullable
                      as String,
            preco: freezed == preco
                ? _value.preco
                : preco // ignore: cast_nullable_to_non_nullable
                      as Decimal?,
            desconto: freezed == desconto
                ? _value.desconto
                : desconto // ignore: cast_nullable_to_non_nullable
                      as Decimal?,
            cupom: freezed == cupom
                ? _value.cupom
                : cupom // ignore: cast_nullable_to_non_nullable
                      as Decimal?,
            vendidosIniciais: null == vendidosIniciais
                ? _value.vendidosIniciais
                : vendidosIniciais // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PrecoPlataformaImplCopyWith<$Res>
    implements $PrecoPlataformaCopyWith<$Res> {
  factory _$$PrecoPlataformaImplCopyWith(
    _$PrecoPlataformaImpl value,
    $Res Function(_$PrecoPlataformaImpl) then,
  ) = __$$PrecoPlataformaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'empresa_id') String empresaId,
    @JsonKey(name: 'produto_venda_id') String produtoVendaId,
    @JsonKey(name: 'plataforma_id') String plataformaId,
    @DecimalNullableConverter() Decimal? preco,
    @DecimalNullableConverter() Decimal? desconto,
    @DecimalNullableConverter() Decimal? cupom,
    @JsonKey(name: 'vendidos_iniciais') int vendidosIniciais,
  });
}

/// @nodoc
class __$$PrecoPlataformaImplCopyWithImpl<$Res>
    extends _$PrecoPlataformaCopyWithImpl<$Res, _$PrecoPlataformaImpl>
    implements _$$PrecoPlataformaImplCopyWith<$Res> {
  __$$PrecoPlataformaImplCopyWithImpl(
    _$PrecoPlataformaImpl _value,
    $Res Function(_$PrecoPlataformaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PrecoPlataforma
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? empresaId = null,
    Object? produtoVendaId = null,
    Object? plataformaId = null,
    Object? preco = freezed,
    Object? desconto = freezed,
    Object? cupom = freezed,
    Object? vendidosIniciais = null,
  }) {
    return _then(
      _$PrecoPlataformaImpl(
        empresaId: null == empresaId
            ? _value.empresaId
            : empresaId // ignore: cast_nullable_to_non_nullable
                  as String,
        produtoVendaId: null == produtoVendaId
            ? _value.produtoVendaId
            : produtoVendaId // ignore: cast_nullable_to_non_nullable
                  as String,
        plataformaId: null == plataformaId
            ? _value.plataformaId
            : plataformaId // ignore: cast_nullable_to_non_nullable
                  as String,
        preco: freezed == preco
            ? _value.preco
            : preco // ignore: cast_nullable_to_non_nullable
                  as Decimal?,
        desconto: freezed == desconto
            ? _value.desconto
            : desconto // ignore: cast_nullable_to_non_nullable
                  as Decimal?,
        cupom: freezed == cupom
            ? _value.cupom
            : cupom // ignore: cast_nullable_to_non_nullable
                  as Decimal?,
        vendidosIniciais: null == vendidosIniciais
            ? _value.vendidosIniciais
            : vendidosIniciais // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PrecoPlataformaImpl implements _PrecoPlataforma {
  const _$PrecoPlataformaImpl({
    @JsonKey(name: 'empresa_id') required this.empresaId,
    @JsonKey(name: 'produto_venda_id') required this.produtoVendaId,
    @JsonKey(name: 'plataforma_id') required this.plataformaId,
    @DecimalNullableConverter() this.preco,
    @DecimalNullableConverter() this.desconto,
    @DecimalNullableConverter() this.cupom,
    @JsonKey(name: 'vendidos_iniciais') this.vendidosIniciais = 0,
  });

  factory _$PrecoPlataformaImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrecoPlataformaImplFromJson(json);

  @override
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @override
  @JsonKey(name: 'produto_venda_id')
  final String produtoVendaId;
  @override
  @JsonKey(name: 'plataforma_id')
  final String plataformaId;
  @override
  @DecimalNullableConverter()
  final Decimal? preco;
  @override
  @DecimalNullableConverter()
  final Decimal? desconto;
  @override
  @DecimalNullableConverter()
  final Decimal? cupom;
  @override
  @JsonKey(name: 'vendidos_iniciais')
  final int vendidosIniciais;

  @override
  String toString() {
    return 'PrecoPlataforma(empresaId: $empresaId, produtoVendaId: $produtoVendaId, plataformaId: $plataformaId, preco: $preco, desconto: $desconto, cupom: $cupom, vendidosIniciais: $vendidosIniciais)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrecoPlataformaImpl &&
            (identical(other.empresaId, empresaId) ||
                other.empresaId == empresaId) &&
            (identical(other.produtoVendaId, produtoVendaId) ||
                other.produtoVendaId == produtoVendaId) &&
            (identical(other.plataformaId, plataformaId) ||
                other.plataformaId == plataformaId) &&
            (identical(other.preco, preco) || other.preco == preco) &&
            (identical(other.desconto, desconto) ||
                other.desconto == desconto) &&
            (identical(other.cupom, cupom) || other.cupom == cupom) &&
            (identical(other.vendidosIniciais, vendidosIniciais) ||
                other.vendidosIniciais == vendidosIniciais));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    empresaId,
    produtoVendaId,
    plataformaId,
    preco,
    desconto,
    cupom,
    vendidosIniciais,
  );

  /// Create a copy of PrecoPlataforma
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrecoPlataformaImplCopyWith<_$PrecoPlataformaImpl> get copyWith =>
      __$$PrecoPlataformaImplCopyWithImpl<_$PrecoPlataformaImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PrecoPlataformaImplToJson(this);
  }
}

abstract class _PrecoPlataforma implements PrecoPlataforma {
  const factory _PrecoPlataforma({
    @JsonKey(name: 'empresa_id') required final String empresaId,
    @JsonKey(name: 'produto_venda_id') required final String produtoVendaId,
    @JsonKey(name: 'plataforma_id') required final String plataformaId,
    @DecimalNullableConverter() final Decimal? preco,
    @DecimalNullableConverter() final Decimal? desconto,
    @DecimalNullableConverter() final Decimal? cupom,
    @JsonKey(name: 'vendidos_iniciais') final int vendidosIniciais,
  }) = _$PrecoPlataformaImpl;

  factory _PrecoPlataforma.fromJson(Map<String, dynamic> json) =
      _$PrecoPlataformaImpl.fromJson;

  @override
  @JsonKey(name: 'empresa_id')
  String get empresaId;
  @override
  @JsonKey(name: 'produto_venda_id')
  String get produtoVendaId;
  @override
  @JsonKey(name: 'plataforma_id')
  String get plataformaId;
  @override
  @DecimalNullableConverter()
  Decimal? get preco;
  @override
  @DecimalNullableConverter()
  Decimal? get desconto;
  @override
  @DecimalNullableConverter()
  Decimal? get cupom;
  @override
  @JsonKey(name: 'vendidos_iniciais')
  int get vendidosIniciais;

  /// Create a copy of PrecoPlataforma
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrecoPlataformaImplCopyWith<_$PrecoPlataformaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
