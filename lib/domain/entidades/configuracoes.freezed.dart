// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'configuracoes.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Configuracoes _$ConfiguracoesFromJson(Map<String, dynamic> json) {
  return _Configuracoes.fromJson(json);
}

/// @nodoc
mixin _$Configuracoes {
  @JsonKey(name: 'empresa_id')
  String get empresaId => throw _privateConstructorUsedError;
  @JsonKey(name: 'embalagem_padrao')
  @DecimalConverter()
  Decimal get embalagemPadrao => throw _privateConstructorUsedError;
  @JsonKey(name: 'impressao_padrao')
  @DecimalConverter()
  Decimal get impressaoPadrao => throw _privateConstructorUsedError;
  @JsonKey(name: 'valor_abelinha')
  @DecimalConverter()
  Decimal get valorAbelinha => throw _privateConstructorUsedError;

  /// Padrão de escrita dos nomes: `titulo`, `maiusculas` ou `minusculas`.
  @JsonKey(name: 'padrao_nome')
  String get padraoNome => throw _privateConstructorUsedError;

  /// Serializes this Configuracoes to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Configuracoes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConfiguracoesCopyWith<Configuracoes> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConfiguracoesCopyWith<$Res> {
  factory $ConfiguracoesCopyWith(
    Configuracoes value,
    $Res Function(Configuracoes) then,
  ) = _$ConfiguracoesCopyWithImpl<$Res, Configuracoes>;
  @useResult
  $Res call({
    @JsonKey(name: 'empresa_id') String empresaId,
    @JsonKey(name: 'embalagem_padrao')
    @DecimalConverter()
    Decimal embalagemPadrao,
    @JsonKey(name: 'impressao_padrao')
    @DecimalConverter()
    Decimal impressaoPadrao,
    @JsonKey(name: 'valor_abelinha') @DecimalConverter() Decimal valorAbelinha,
    @JsonKey(name: 'padrao_nome') String padraoNome,
  });
}

/// @nodoc
class _$ConfiguracoesCopyWithImpl<$Res, $Val extends Configuracoes>
    implements $ConfiguracoesCopyWith<$Res> {
  _$ConfiguracoesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Configuracoes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? empresaId = null,
    Object? embalagemPadrao = null,
    Object? impressaoPadrao = null,
    Object? valorAbelinha = null,
    Object? padraoNome = null,
  }) {
    return _then(
      _value.copyWith(
            empresaId: null == empresaId
                ? _value.empresaId
                : empresaId // ignore: cast_nullable_to_non_nullable
                      as String,
            embalagemPadrao: null == embalagemPadrao
                ? _value.embalagemPadrao
                : embalagemPadrao // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            impressaoPadrao: null == impressaoPadrao
                ? _value.impressaoPadrao
                : impressaoPadrao // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            valorAbelinha: null == valorAbelinha
                ? _value.valorAbelinha
                : valorAbelinha // ignore: cast_nullable_to_non_nullable
                      as Decimal,
            padraoNome: null == padraoNome
                ? _value.padraoNome
                : padraoNome // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConfiguracoesImplCopyWith<$Res>
    implements $ConfiguracoesCopyWith<$Res> {
  factory _$$ConfiguracoesImplCopyWith(
    _$ConfiguracoesImpl value,
    $Res Function(_$ConfiguracoesImpl) then,
  ) = __$$ConfiguracoesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'empresa_id') String empresaId,
    @JsonKey(name: 'embalagem_padrao')
    @DecimalConverter()
    Decimal embalagemPadrao,
    @JsonKey(name: 'impressao_padrao')
    @DecimalConverter()
    Decimal impressaoPadrao,
    @JsonKey(name: 'valor_abelinha') @DecimalConverter() Decimal valorAbelinha,
    @JsonKey(name: 'padrao_nome') String padraoNome,
  });
}

/// @nodoc
class __$$ConfiguracoesImplCopyWithImpl<$Res>
    extends _$ConfiguracoesCopyWithImpl<$Res, _$ConfiguracoesImpl>
    implements _$$ConfiguracoesImplCopyWith<$Res> {
  __$$ConfiguracoesImplCopyWithImpl(
    _$ConfiguracoesImpl _value,
    $Res Function(_$ConfiguracoesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Configuracoes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? empresaId = null,
    Object? embalagemPadrao = null,
    Object? impressaoPadrao = null,
    Object? valorAbelinha = null,
    Object? padraoNome = null,
  }) {
    return _then(
      _$ConfiguracoesImpl(
        empresaId: null == empresaId
            ? _value.empresaId
            : empresaId // ignore: cast_nullable_to_non_nullable
                  as String,
        embalagemPadrao: null == embalagemPadrao
            ? _value.embalagemPadrao
            : embalagemPadrao // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        impressaoPadrao: null == impressaoPadrao
            ? _value.impressaoPadrao
            : impressaoPadrao // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        valorAbelinha: null == valorAbelinha
            ? _value.valorAbelinha
            : valorAbelinha // ignore: cast_nullable_to_non_nullable
                  as Decimal,
        padraoNome: null == padraoNome
            ? _value.padraoNome
            : padraoNome // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConfiguracoesImpl implements _Configuracoes {
  const _$ConfiguracoesImpl({
    @JsonKey(name: 'empresa_id') required this.empresaId,
    @JsonKey(name: 'embalagem_padrao')
    @DecimalConverter()
    required this.embalagemPadrao,
    @JsonKey(name: 'impressao_padrao')
    @DecimalConverter()
    required this.impressaoPadrao,
    @JsonKey(name: 'valor_abelinha')
    @DecimalConverter()
    required this.valorAbelinha,
    @JsonKey(name: 'padrao_nome') this.padraoNome = 'titulo',
  });

  factory _$ConfiguracoesImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConfiguracoesImplFromJson(json);

  @override
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @override
  @JsonKey(name: 'embalagem_padrao')
  @DecimalConverter()
  final Decimal embalagemPadrao;
  @override
  @JsonKey(name: 'impressao_padrao')
  @DecimalConverter()
  final Decimal impressaoPadrao;
  @override
  @JsonKey(name: 'valor_abelinha')
  @DecimalConverter()
  final Decimal valorAbelinha;

  /// Padrão de escrita dos nomes: `titulo`, `maiusculas` ou `minusculas`.
  @override
  @JsonKey(name: 'padrao_nome')
  final String padraoNome;

  @override
  String toString() {
    return 'Configuracoes(empresaId: $empresaId, embalagemPadrao: $embalagemPadrao, impressaoPadrao: $impressaoPadrao, valorAbelinha: $valorAbelinha, padraoNome: $padraoNome)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConfiguracoesImpl &&
            (identical(other.empresaId, empresaId) ||
                other.empresaId == empresaId) &&
            (identical(other.embalagemPadrao, embalagemPadrao) ||
                other.embalagemPadrao == embalagemPadrao) &&
            (identical(other.impressaoPadrao, impressaoPadrao) ||
                other.impressaoPadrao == impressaoPadrao) &&
            (identical(other.valorAbelinha, valorAbelinha) ||
                other.valorAbelinha == valorAbelinha) &&
            (identical(other.padraoNome, padraoNome) ||
                other.padraoNome == padraoNome));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    empresaId,
    embalagemPadrao,
    impressaoPadrao,
    valorAbelinha,
    padraoNome,
  );

  /// Create a copy of Configuracoes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConfiguracoesImplCopyWith<_$ConfiguracoesImpl> get copyWith =>
      __$$ConfiguracoesImplCopyWithImpl<_$ConfiguracoesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConfiguracoesImplToJson(this);
  }
}

abstract class _Configuracoes implements Configuracoes {
  const factory _Configuracoes({
    @JsonKey(name: 'empresa_id') required final String empresaId,
    @JsonKey(name: 'embalagem_padrao')
    @DecimalConverter()
    required final Decimal embalagemPadrao,
    @JsonKey(name: 'impressao_padrao')
    @DecimalConverter()
    required final Decimal impressaoPadrao,
    @JsonKey(name: 'valor_abelinha')
    @DecimalConverter()
    required final Decimal valorAbelinha,
    @JsonKey(name: 'padrao_nome') final String padraoNome,
  }) = _$ConfiguracoesImpl;

  factory _Configuracoes.fromJson(Map<String, dynamic> json) =
      _$ConfiguracoesImpl.fromJson;

  @override
  @JsonKey(name: 'empresa_id')
  String get empresaId;
  @override
  @JsonKey(name: 'embalagem_padrao')
  @DecimalConverter()
  Decimal get embalagemPadrao;
  @override
  @JsonKey(name: 'impressao_padrao')
  @DecimalConverter()
  Decimal get impressaoPadrao;
  @override
  @JsonKey(name: 'valor_abelinha')
  @DecimalConverter()
  Decimal get valorAbelinha;

  /// Padrão de escrita dos nomes: `titulo`, `maiusculas` ou `minusculas`.
  @override
  @JsonKey(name: 'padrao_nome')
  String get padraoNome;

  /// Create a copy of Configuracoes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConfiguracoesImplCopyWith<_$ConfiguracoesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
