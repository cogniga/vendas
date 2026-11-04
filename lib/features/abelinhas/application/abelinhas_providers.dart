import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/domain/calculos/abelinhas.dart';
import 'package:sales/domain/entidades/faixa_abelinha.dart';
import 'package:sales/domain/entidades/produto.dart';
import 'package:sales/features/produtos/application/produtos_providers.dart';

/// Dados agregados da tela de Regra de abelinhas (produtos + faixas + valor).
///
/// Reaproveita [produtosProvider], [faixasAbelinhaProvider] e
/// [configuracoesProvider] da feature de produtos para não duplicar leitura.
class DadosAbelinhas {
  const DadosAbelinhas({
    required this.produtos,
    required this.faixas,
    required this.valorAbelinha,
  });

  final List<Produto> produtos;
  final List<FaixaAbelinha> faixas;
  final Decimal valorAbelinha;
}

/// Carrega os dados necessários para a tela de abelinhas.
final dadosAbelinhasProvider =
    FutureProvider.autoDispose<DadosAbelinhas>((ref) async {
  final produtos = await ref.watch(produtosProvider.future);
  final faixas = await ref.watch(faixasAbelinhaProvider.future);
  final config = await ref.watch(configuracoesProvider.future);
  return DadosAbelinhas(
    produtos: produtos,
    faixas: faixas,
    valorAbelinha: config?.valorAbelinha ?? Decimal.zero,
  );
});

/// Expõe a análise geral derivada a partir de um [DadosAbelinhas] e do valor
/// `v` atualmente digitado (sem persistir). Função utilitária pura usada pela
/// tela ao recalcular ao vivo.
AnaliseGeralAbelinhas analiseGeralDe(DadosAbelinhas dados, Decimal v) =>
    analiseGeral(dados.produtos, dados.faixas, v);
