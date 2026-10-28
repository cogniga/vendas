// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'faixa_taxa.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FaixaTaxa _$FaixaTaxaFromJson(Map<String, dynamic> json) {
  return _FaixaTaxa.fromJson(json);
}

/// @nodoc
mixin _$FaixaTaxa {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'empresa_id')
  String get empresaId => throw _privateConstructorUsedError;
  @JsonKey(name: 'plataforma_id')
  String get plataformaId => throw _privateConstructorUsedError;
  @JsonKey(name: 'taxa_fixa')
  @DecimalConverter()
  Decimal get taxaFixa => throw _privateConstructorUsedError;
  @JsonKey(name: 'taxa_percentual')
  @DecimalConverter()
  Decimal get taxaPercentual => throw _privateConstructorUsedError;
  @JsonKey(name: 'preco_ate')
  @DecimalNullableConverter()
  Decimal? get precoAte => throw _privateConstructorUsedError;

  /// Serializes this FaixaTaxa to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FaixaTaxa
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FaixaTaxaCopyWith<FaixaTaxa> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FaixaTaxaCopyWith<$Res> {
  factory $FaixaTaxaCopyWith(FaixaTaxa value, $Res Function(FaixaTaxa) then) =
      _$FaixaTaxaCopyWithImpl<$Res, FaixaTaxa>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    @JsonKey(name: 'plataforma_id') String plataformaId,
    @JsonKey(name: 'taxa_fixa') @DecimalConverter() Decimal taxaFixa,
    @JsonKey(name: 'taxa_percentual')
    @DecimalConverter()
    Decimal taxaPercentual,
    @JsonKey(name: 'preco_ate') @DecimalNullableConverter() Decimal? precoAte,
  });
}

/// @nodoc
class _$FaixaTaxaCopyWithImpl<$Res, $Val extends FaixaTaxa>
    implements $FaixaTaxaCopyWith<$Res> {
  _$FaixaTaxaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FaixaTaxa
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? plataformaId = null,
    Object? taxaFixa = null,
    Object? taxaPercentual = null,
    Object? precoAte = freezed,
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
            plataformaId: null == plataformaId
                ? _value.plataformaId
                : plataformaId // ignore: cast_nullable_to_non_nullable
                      as String,
            taxaFixa: null == taxaFixa
                ? _value.taxaFixa
                : taxaFixa // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            taxaPercentual: null == taxaPercentual
                ? _value.taxaPercentual
                : taxaPercentual // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            precoAte: freezed == precoAte
                ? _value.precoAte
                : precoAte // ignore: cast_nullable_to_non_nullable
                      as Decimal?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FaixaTaxaImplCopyWith<$Res>
    implements $FaixaTaxaCopyWith<$Res> {
  factory _$$FaixaTaxaImplCopyWith(
    _$FaixaTaxaImpl value,
    $Res Function(_$FaixaTaxaImpl) then,
  ) = __$$FaixaTaxaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'empresa_id') String empresaId,
    @JsonKey(name: 'plataforma_id') String plataformaId,
    @JsonKey(name: 'taxa_fixa') @DecimalConverter() Decimal taxaFixa,
    @JsonKey(name: 'taxa_percentual')
    @DecimalConverter()
    Decimal taxaPercentual,
    @JsonKey(name: 'preco_ate') @DecimalNullableConverter() Decimal? precoAte,
  });
}

/// @nodoc
class __$$FaixaTaxaImplCopyWithImpl<$Res>
    extends _$FaixaTaxaCopyWithImpl<$Res, _$FaixaTaxaImpl>
    implements _$$FaixaTaxaImplCopyWith<$Res> {
  __$$FaixaTaxaImplCopyWithImpl(
    _$FaixaTaxaImpl _value,
    $Res Function(_$FaixaTaxaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FaixaTaxa
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? empresaId = null,
    Object? plataformaId = null,
    Object? taxaFixa = null,
    Object? taxaPercentual = null,
    Object? precoAte = freezed,
  }) {
    return _then(
      _$FaixaTaxaImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        empresaId: null == empresaId
            ? _value.empresaId
            : empresaId // ignore: cast_nullable_to_non_nullable
                  as String,
        plataformaId: null == plataformaId
            ? _value.plataformaId
            : plataformaId // ignore: cast_nullable_to_non_nullable
                  as String,
        taxaFixa: null == taxaFixa
            ? _value.taxaFixa
            : taxaFixa // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        taxaPercentual: null == taxaPercentual
            ? _value.taxaPercentual
            : taxaPercentual // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        precoAte: freezed == precoAte
            ? _value.precoAte
            : precoAte // ignore: cast_nullable_to_non_nullable
                  as Decimal?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FaixaTaxaImpl implements _FaixaTaxa {
  const _$FaixaTaxaImpl({
    required this.id,
    @JsonKey(name: 'empresa_id') required this.empresaId,
    @JsonKey(name: 'plataforma_id') required this.plataformaId,
    @JsonKey(name: 'taxa_fixa') @DecimalConverter() required this.taxaFixa,
    @JsonKey(name: 'taxa_percentual')
    @DecimalConverter()
    required this.taxaPercentual,
    @JsonKey(name: 'preco_ate') @DecimalNullableConverter() this.precoAte,
  });

  factory _$FaixaTaxaImpl.fromJson(Map<String, dynamic> json) =>
      _$$FaixaTaxaImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @override
  @JsonKey(name: 'plataforma_id')
  final String plataformaId;
  @override
  @JsonKey(name: 'taxa_fixa')
  @DecimalConverter()
  final Decimal taxaFixa;
  @override
  @JsonKey(name: 'taxa_percentual')
  @DecimalConverter()
  final Decimal taxaPercentual;
  @override
  @JsonKey(name: 'preco_ate')
  @DecimalNullableConverter()
  final Decimal? precoAte;

  @override
  String toString() {
    return 'FaixaTaxa(id: $id, empresaId: $empresaId, plataformaId: $plataformaId, taxaFixa: $taxaFixa, taxaPercentual: $taxaPercentual, precoAte: $precoAte)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FaixaTaxaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.empresaId, empresaId) ||
                other.empresaId == empresaId) &&
            (identical(other.plataformaId, plataformaId) ||
                other.plataformaId == plataformaId) &&
            (identical(other.taxaFixa, taxaFixa) ||
                other.taxaFixa == taxaFixa) &&
            (identical(other.taxaPercentual, taxaPercentual) ||
                other.taxaPercentual == taxaPercentual) &&
            (identical(other.precoAte, precoAte) ||
                other.precoAte == precoAte));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    empresaId,
    plataformaId,
    taxaFixa,
    taxaPercentual,
    precoAte,
  );

  /// Create a copy of FaixaTaxa
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FaixaTaxaImplCopyWith<_$FaixaTaxaImpl> get copyWith =>
      __$$FaixaTaxaImplCopyWithImpl<_$FaixaTaxaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FaixaTaxaImplToJson(this);
  }
}

abstract class _FaixaTaxa implements FaixaTaxa {
  const factory _FaixaTaxa({
    required final String id,
    @JsonKey(name: 'empresa_id') required final String empresaId,
    @JsonKey(name: 'plataforma_id') required final String plataformaId,
    @JsonKey(name: 'taxa_fixa')
    @DecimalConverter()
    required final Decimal taxaFixa,
    @JsonKey(name: 'taxa_percentual')
    @DecimalConverter()
    required final Decimal taxaPercentual,
    @JsonKey(name: 'preco_ate')
    @DecimalNullableConverter()
    final Decimal? precoAte,
  }) = _$FaixaTaxaImpl;

  factory _FaixaTaxa.fromJson(Map<String, dynamic> json) =
      _$FaixaTaxaImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'empresa_id')
  String get empresaId;
  @override
  @JsonKey(name: 'plataforma_id')
  String get plataformaId;
  @override
  @JsonKey(name: 'taxa_fixa')
  @DecimalConverter()
  Decimal get taxaFixa;
  @override
  @JsonKey(name: 'taxa_percentual')
  @DecimalConverter()
  Decimal get taxaPercentual;
  @override
  @JsonKey(name: 'preco_ate')
  @DecimalNullableConverter()
  Decimal? get precoAte;

  /// Create a copy of FaixaTaxa
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FaixaTaxaImplCopyWith<_$FaixaTaxaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
