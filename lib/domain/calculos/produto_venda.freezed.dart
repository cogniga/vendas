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

/// @nodoc
mixin _$ResultadoKit {
  /// Soma `produto.custo * qtd` dos itens.
  Decimal get compra => throw _privateConstructorUsedError;

  /// `compra + embalagem + impressao + outros`.
  Decimal get investimento => throw _privateConstructorUsedError;

  /// `M` — o que o cliente paga: `preco - desconto - cupom`.
  Decimal get clientePaga => throw _privateConstructorUsedError;

  /// Taxa da plataforma sobre `M`.
  Decimal get taxa => throw _privateConstructorUsedError;

  /// `M - taxa`.
  Decimal get liquido => throw _privateConstructorUsedError;

  /// `liquido - investimento`.
  Decimal get lucro => throw _privateConstructorUsedError;

  /// `lucro / liquido`, em fração.
  Decimal get margem => throw _privateConstructorUsedError;

  /// `lucro / investimento`, em fração.
  Decimal get roi => throw _privateConstructorUsedError;

  /// Faturamento da meta: `preco * metaQtd` (null se lucro <= 0).
  Decimal get metaFaturamento => throw _privateConstructorUsedError;

  /// Progresso: `vendidos / metaQtd`, em fração.
  Decimal get atingido => throw _privateConstructorUsedError;

  /// Custo de anúncio-alvo: `lucro * fatiaRoas`.
  Decimal get custoAnuncio => throw _privateConstructorUsedError;

  /// `Σ abelinhas(produto) * qtd`.
  Decimal get abelinhasKit => throw _privateConstructorUsedError;

  /// Unidades para bater a meta de lucro (null se lucro <= 0).
  int? get metaQtd => throw _privateConstructorUsedError;

  /// ROAS-alvo: `M / (lucro * fatia)` (null se lucro <= 0 ou fatia <= 0).
  Decimal? get roasAlvo => throw _privateConstructorUsedError;

  /// Unidades vendidas na plataforma (iniciais + pedidos válidos).
  int get vendidos => throw _privateConstructorUsedError;

  /// Create a copy of ResultadoKit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResultadoKitCopyWith<ResultadoKit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultadoKitCopyWith<$Res> {
  factory $ResultadoKitCopyWith(
    ResultadoKit value,
    $Res Function(ResultadoKit) then,
  ) = _$ResultadoKitCopyWithImpl<$Res, ResultadoKit>;
  @useResult
  $Res call({
    Decimal compra,
    Decimal investimento,
    Decimal clientePaga,
    Decimal taxa,
    Decimal liquido,
    Decimal lucro,
    Decimal margem,
    Decimal roi,
    Decimal metaFaturamento,
    Decimal atingido,
    Decimal custoAnuncio,
    Decimal abelinhasKit,
    int? metaQtd,
    Decimal? roasAlvo,
    int vendidos,
  });
}

/// @nodoc
class _$ResultadoKitCopyWithImpl<$Res, $Val extends ResultadoKit>
    implements $ResultadoKitCopyWith<$Res> {
  _$ResultadoKitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResultadoKit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? compra = null,
    Object? investimento = null,
    Object? clientePaga = null,
    Object? taxa = null,
    Object? liquido = null,
    Object? lucro = null,
    Object? margem = null,
    Object? roi = null,
    Object? metaFaturamento = null,
    Object? atingido = null,
    Object? custoAnuncio = null,
    Object? abelinhasKit = null,
    Object? metaQtd = freezed,
    Object? roasAlvo = freezed,
    Object? vendidos = null,
  }) {
    return _then(
      _value.copyWith(
            compra: null == compra
                ? _value.compra
                : compra // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            investimento: null == investimento
                ? _value.investimento
                : investimento // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            clientePaga: null == clientePaga
                ? _value.clientePaga
                : clientePaga // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            taxa: null == taxa
                ? _value.taxa
                : taxa // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            liquido: null == liquido
                ? _value.liquido
                : liquido // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            lucro: null == lucro
                ? _value.lucro
                : lucro // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            margem: null == margem
                ? _value.margem
                : margem // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            roi: null == roi
                ? _value.roi
                : roi // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            metaFaturamento: null == metaFaturamento
                ? _value.metaFaturamento
                : metaFaturamento // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            atingido: null == atingido
                ? _value.atingido
                : atingido // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            custoAnuncio: null == custoAnuncio
                ? _value.custoAnuncio
                : custoAnuncio // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            abelinhasKit: null == abelinhasKit
                ? _value.abelinhasKit
                : abelinhasKit // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            metaQtd: freezed == metaQtd
                ? _value.metaQtd
                : metaQtd // ignore: cast_nullable_to_non_nullable
                      as int?,
            roasAlvo: freezed == roasAlvo
                ? _value.roasAlvo
                : roasAlvo // ignore: cast_nullable_to_non_nullable
                      as Decimal?,
            vendidos: null == vendidos
                ? _value.vendidos
                : vendidos // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ResultadoKitImplCopyWith<$Res>
    implements $ResultadoKitCopyWith<$Res> {
  factory _$$ResultadoKitImplCopyWith(
    _$ResultadoKitImpl value,
    $Res Function(_$ResultadoKitImpl) then,
  ) = __$$ResultadoKitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Decimal compra,
    Decimal investimento,
    Decimal clientePaga,
    Decimal taxa,
    Decimal liquido,
    Decimal lucro,
    Decimal margem,
    Decimal roi,
    Decimal metaFaturamento,
    Decimal atingido,
    Decimal custoAnuncio,
    Decimal abelinhasKit,
    int? metaQtd,
    Decimal? roasAlvo,
    int vendidos,
  });
}

/// @nodoc
class __$$ResultadoKitImplCopyWithImpl<$Res>
    extends _$ResultadoKitCopyWithImpl<$Res, _$ResultadoKitImpl>
    implements _$$ResultadoKitImplCopyWith<$Res> {
  __$$ResultadoKitImplCopyWithImpl(
    _$ResultadoKitImpl _value,
    $Res Function(_$ResultadoKitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResultadoKit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? compra = null,
    Object? investimento = null,
    Object? clientePaga = null,
    Object? taxa = null,
    Object? liquido = null,
    Object? lucro = null,
    Object? margem = null,
    Object? roi = null,
    Object? metaFaturamento = null,
    Object? atingido = null,
    Object? custoAnuncio = null,
    Object? abelinhasKit = null,
    Object? metaQtd = freezed,
    Object? roasAlvo = freezed,
    Object? vendidos = null,
  }) {
    return _then(
      _$ResultadoKitImpl(
        compra: null == compra
            ? _value.compra
            : compra // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        investimento: null == investimento
            ? _value.investimento
            : investimento // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        clientePaga: null == clientePaga
            ? _value.clientePaga
            : clientePaga // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        taxa: null == taxa
            ? _value.taxa
            : taxa // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        liquido: null == liquido
            ? _value.liquido
            : liquido // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        lucro: null == lucro
            ? _value.lucro
            : lucro // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        margem: null == margem
            ? _value.margem
            : margem // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        roi: null == roi
            ? _value.roi
            : roi // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        metaFaturamento: null == metaFaturamento
            ? _value.metaFaturamento
            : metaFaturamento // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        atingido: null == atingido
            ? _value.atingido
            : atingido // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        custoAnuncio: null == custoAnuncio
            ? _value.custoAnuncio
            : custoAnuncio // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        abelinhasKit: null == abelinhasKit
            ? _value.abelinhasKit
            : abelinhasKit // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        metaQtd: freezed == metaQtd
            ? _value.metaQtd
            : metaQtd // ignore: cast_nullable_to_non_nullable
                  as int?,
        roasAlvo: freezed == roasAlvo
            ? _value.roasAlvo
            : roasAlvo // ignore: cast_nullable_to_non_nullable
                  as Decimal?,
        vendidos: null == vendidos
            ? _value.vendidos
            : vendidos // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ResultadoKitImpl implements _ResultadoKit {
  const _$ResultadoKitImpl({
    required this.compra,
    required this.investimento,
    required this.clientePaga,
    required this.taxa,
    required this.liquido,
    required this.lucro,
    required this.margem,
    required this.roi,
    required this.metaFaturamento,
    required this.atingido,
    required this.custoAnuncio,
    required this.abelinhasKit,
    this.metaQtd,
    this.roasAlvo,
    this.vendidos = 0,
  });

  /// Soma `produto.custo * qtd` dos itens.
  @override
  final Decimal compra;

  /// `compra + embalagem + impressao + outros`.
  @override
  final Decimal investimento;

  /// `M` — o que o cliente paga: `preco - desconto - cupom`.
  @override
  final Decimal clientePaga;

  /// Taxa da plataforma sobre `M`.
  @override
  final Decimal taxa;

  /// `M - taxa`.
  @override
  final Decimal liquido;

  /// `liquido - investimento`.
  @override
  final Decimal lucro;

  /// `lucro / liquido`, em fração.
  @override
  final Decimal margem;

  /// `lucro / investimento`, em fração.
  @override
  final Decimal roi;

  /// Faturamento da meta: `preco * metaQtd` (null se lucro <= 0).
  @override
  final Decimal metaFaturamento;

  /// Progresso: `vendidos / metaQtd`, em fração.
  @override
  final Decimal atingido;

  /// Custo de anúncio-alvo: `lucro * fatiaRoas`.
  @override
  final Decimal custoAnuncio;

  /// `Σ abelinhas(produto) * qtd`.
  @override
  final Decimal abelinhasKit;

  /// Unidades para bater a meta de lucro (null se lucro <= 0).
  @override
  final int? metaQtd;

  /// ROAS-alvo: `M / (lucro * fatia)` (null se lucro <= 0 ou fatia <= 0).
  @override
  final Decimal? roasAlvo;

  /// Unidades vendidas na plataforma (iniciais + pedidos válidos).
  @override
  @JsonKey()
  final int vendidos;

  @override
  String toString() {
    return 'ResultadoKit(compra: $compra, investimento: $investimento, clientePaga: $clientePaga, taxa: $taxa, liquido: $liquido, lucro: $lucro, margem: $margem, roi: $roi, metaFaturamento: $metaFaturamento, atingido: $atingido, custoAnuncio: $custoAnuncio, abelinhasKit: $abelinhasKit, metaQtd: $metaQtd, roasAlvo: $roasAlvo, vendidos: $vendidos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResultadoKitImpl &&
            (identical(other.compra, compra) || other.compra == compra) &&
            (identical(other.investimento, investimento) ||
                other.investimento == investimento) &&
            (identical(other.clientePaga, clientePaga) ||
                other.clientePaga == clientePaga) &&
            (identical(other.taxa, taxa) || other.taxa == taxa) &&
            (identical(other.liquido, liquido) || other.liquido == liquido) &&
            (identical(other.lucro, lucro) || other.lucro == lucro) &&
            (identical(other.margem, margem) || other.margem == margem) &&
            (identical(other.roi, roi) || other.roi == roi) &&
            (identical(other.metaFaturamento, metaFaturamento) ||
                other.metaFaturamento == metaFaturamento) &&
            (identical(other.atingido, atingido) ||
                other.atingido == atingido) &&
            (identical(other.custoAnuncio, custoAnuncio) ||
                other.custoAnuncio == custoAnuncio) &&
            (identical(other.abelinhasKit, abelinhasKit) ||
                other.abelinhasKit == abelinhasKit) &&
            (identical(other.metaQtd, metaQtd) || other.metaQtd == metaQtd) &&
            (identical(other.roasAlvo, roasAlvo) ||
                other.roasAlvo == roasAlvo) &&
            (identical(other.vendidos, vendidos) ||
                other.vendidos == vendidos));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    compra,
    investimento,
    clientePaga,
    taxa,
    liquido,
    lucro,
    margem,
    roi,
    metaFaturamento,
    atingido,
    custoAnuncio,
    abelinhasKit,
    metaQtd,
    roasAlvo,
    vendidos,
  );

  /// Create a copy of ResultadoKit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResultadoKitImplCopyWith<_$ResultadoKitImpl> get copyWith =>
      __$$ResultadoKitImplCopyWithImpl<_$ResultadoKitImpl>(this, _$identity);
}

abstract class _ResultadoKit implements ResultadoKit {
  const factory _ResultadoKit({
    required final Decimal compra,
    required final Decimal investimento,
    required final Decimal clientePaga,
    required final Decimal taxa,
    required final Decimal liquido,
    required final Decimal lucro,
    required final Decimal margem,
    required final Decimal roi,
    required final Decimal metaFaturamento,
    required final Decimal atingido,
    required final Decimal custoAnuncio,
    required final Decimal abelinhasKit,
    final int? metaQtd,
    final Decimal? roasAlvo,
    final int vendidos,
  }) = _$ResultadoKitImpl;

  /// Soma `produto.custo * qtd` dos itens.
  @override
  Decimal get compra;

  /// `compra + embalagem + impressao + outros`.
  @override
  Decimal get investimento;

  /// `M` — o que o cliente paga: `preco - desconto - cupom`.
  @override
  Decimal get clientePaga;

  /// Taxa da plataforma sobre `M`.
  @override
  Decimal get taxa;

  /// `M - taxa`.
  @override
  Decimal get liquido;

  /// `liquido - investimento`.
  @override
  Decimal get lucro;

  /// `lucro / liquido`, em fração.
  @override
  Decimal get margem;

  /// `lucro / investimento`, em fração.
  @override
  Decimal get roi;

  /// Faturamento da meta: `preco * metaQtd` (null se lucro <= 0).
  @override
  Decimal get metaFaturamento;

  /// Progresso: `vendidos / metaQtd`, em fração.
  @override
  Decimal get atingido;

  /// Custo de anúncio-alvo: `lucro * fatiaRoas`.
  @override
  Decimal get custoAnuncio;

  /// `Σ abelinhas(produto) * qtd`.
  @override
  Decimal get abelinhasKit;

  /// Unidades para bater a meta de lucro (null se lucro <= 0).
  @override
  int? get metaQtd;

  /// ROAS-alvo: `M / (lucro * fatia)` (null se lucro <= 0 ou fatia <= 0).
  @override
  Decimal? get roasAlvo;

  /// Unidades vendidas na plataforma (iniciais + pedidos válidos).
  @override
  int get vendidos;

  /// Create a copy of ResultadoKit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResultadoKitImplCopyWith<_$ResultadoKitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
