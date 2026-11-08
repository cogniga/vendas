import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sales/core/format/formatos.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/confirm_delete_button.dart';
import 'package:sales/core/widgets/kpi_card.dart';
import 'package:sales/core/widgets/page_header.dart';
import 'package:sales/core/widgets/pill.dart';
import 'package:sales/core/widgets/platform_pill.dart';
import 'package:sales/core/widgets/responsive_list.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/data/repositorios/retirada_repository.dart';
import 'package:sales/data/repositorios/saque_repository.dart';
import 'package:sales/domain/calculos/caixa.dart';
import 'package:sales/domain/calculos/decimais.dart';
import 'package:sales/domain/calculos/pedido.dart';
import 'package:sales/domain/entidades/destino.dart';
import 'package:sales/domain/entidades/enums.dart';
import 'package:sales/domain/entidades/faixa_taxa.dart';
import 'package:sales/domain/entidades/plataforma.dart';
import 'package:sales/features/caixa/application/caixa_providers.dart';
import 'package:sales/features/caixa/presentation/cor_destino.dart';
import 'package:sales/features/caixa/presentation/destinos_panel.dart';
import 'package:sales/features/caixa/presentation/retirada_form.dart';
import 'package:sales/features/caixa/presentation/saque_form.dart';

/// Tipo de um movimento no extrato do caixa.
enum TipoMovimento { saque, investimento, insumo, retirada }

/// Uma linha do extrato (saque/investimento/insumo/retirada).
class Movimento {
  const Movimento({
    required this.data,
    required this.tipo,
    required this.descricao,
    required this.valor,
    this.rateio = const {},
    this.destinoId,
    this.id,
  });

  final DateTime data;
  final TipoMovimento tipo;
  final String descricao;

  /// Valor do movimento: positivo para saque, negativo para saídas.
  final Decimal valor;

  /// Para saque: valor rateado por `destinoId`.
  final Map<String, Decimal> rateio;

  /// Para saídas (investimento/insumo/retirada): destino de onde saiu.
  final String? destinoId;

  /// Id da origem; `null` em movimentos sem ação de exclusão aqui.
  final String? id;

  /// Rótulo do tipo exibido na pill.
  String get rotulo => switch (tipo) {
        TipoMovimento.saque => 'Saque',
        TipoMovimento.investimento => 'Investimento',
        TipoMovimento.insumo => 'Insumo',
        TipoMovimento.retirada => 'Retirada',
      };

  /// Valor atribuído ao destino [d] (rateio para saque, saída para os demais).
  Decimal? valorNoDestino(Destino d) {
    if (tipo == TipoMovimento.saque) return rateio[d.id];
    return destinoId == d.id ? valor : null;
  }
}

/// Tela de Caixa e saques (R10): a mais complexa do financeiro.
class CaixaPage extends ConsumerWidget {
  const CaixaPage({super.key});

  Future<void> _registrarSaque(
    BuildContext context,
    WidgetRef ref,
    List<Destino> destinos,
    List<Plataforma> plataformas,
  ) async {
    final empresa = await ref.read(empresaAtualProvider.future);
    if (empresa == null || !context.mounted) return;
    final salvou = await abrirSaqueForm(
      context,
      empresaId: empresa.id,
      destinos: destinos,
      plataformas: plataformas,
    );
    if (salvou ?? false) {
      ref
        ..invalidate(saquesProvider)
        ..invalidate(dadosCaixaProvider);
    }
  }

  Future<void> _registrarRetirada(
    BuildContext context,
    WidgetRef ref,
    List<Destino> destinos,
  ) async {
    final empresa = await ref.read(empresaAtualProvider.future);
    if (empresa == null || !context.mounted) return;
    final salvou = await abrirRetiradaForm(
      context,
      empresaId: empresa.id,
      destinos: destinos,
    );
    if (salvou ?? false) {
      ref
        ..invalidate(retiradasProvider)
        ..invalidate(dadosCaixaProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dadosCaixaProvider);

    // Mantém a tela com o último dado conhecido durante uma atualização,
    // evitando o "flash" do indicador de carregamento ao abrir a tela.
    final dados = async.valueOrNull;
    if (dados != null) {
      return _Conteudo(
        dados: dados,
        onRegistrarSaque: () => _registrarSaque(
          context,
          ref,
          dados.destinos,
          dados.plataformas.keys.toList(),
        ),
        onRegistrarRetirada: () =>
            _registrarRetirada(context, ref, dados.destinos),
      );
    }

    // Erro na primeira carga (sem dado anterior).
    if (async.hasError) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(title: 'Caixa e saques'),
          _Erro(onTentar: () => ref.invalidate(dadosCaixaProvider)),
        ],
      );
    }

    // Primeira carga, sem dado ainda: cabeçalho + skeleton discreto.
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(title: 'Caixa e saques'),
        Padding(
          padding: EdgeInsets.all(Espacos.g20),
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

class _Conteudo extends ConsumerWidget {
  const _Conteudo({
    required this.dados,
    required this.onRegistrarSaque,
    required this.onRegistrarRetirada,
  });

  final DadosCaixa dados;
  final VoidCallback onRegistrarSaque;
  final VoidCallback onRegistrarRetirada;

  Future<void> _excluirSaque(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) =>
      _excluir(
        context,
        ref,
        () => ref.read(saqueRepositoryProvider).excluir(id),
        // Invalida a FONTE (cache de saques); só o agregado não basta,
        // porque ele relê o saquesProvider ainda com a lista antiga.
        () => ref.invalidate(saquesProvider),
        'Saque excluído.',
      );

  Future<void> _excluirRetirada(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) =>
      _excluir(
        context,
        ref,
        () => ref.read(retiradaRepositoryProvider).excluir(id),
        () => ref.invalidate(retiradasProvider),
        'Retirada excluída.',
      );

  /// Exclui, recarrega a fonte + o agregado e avisa o resultado (inclusive
  /// erro, que antes era engolido em silêncio).
  Future<void> _excluir(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() acao,
    VoidCallback invalidarFonte,
    String mensagemOk,
  ) async {
    final mensageiro = ScaffoldMessenger.of(context);
    try {
      await acao();
      invalidarFonte();
      ref.invalidate(dadosCaixaProvider);
      mensageiro.showSnackBar(SnackBar(content: Text(mensagemOk)));
    } on Object catch (e) {
      final texto = e.toString();
      mensageiro.showSnackBar(
        SnackBar(
          content: Text(
            texto.startsWith('ErroRepositorio: ')
                ? texto.substring('ErroRepositorio: '.length)
                : 'Não foi possível excluir. Tente de novo.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empresaId =
        ref.watch(empresaAtualProvider).valueOrNull?.id ?? '';
    final destinos = dados.destinos;
    final somaPct = destinos.fold(zero, (s, d) => s + d.percentual);
    final fechou = (somaPct - cem).abs() <= (Decimal.one / cem).toDecimal();

    final sacado = dados.saques.fold(zero, (s, x) => s + x.valor);
    final saidas = destinos.fold(
      zero,
      (s, d) => s + saidasDestino(
        d.id,
        investimentos: dados.investimentos,
        comprasInsumo: dados.comprasInsumo,
        retiradas: dados.retiradas,
      ),
    );
    final saldo = saldoTotal(
      destinos,
      saques: dados.saques,
      investimentos: dados.investimentos,
      comprasInsumo: dados.comprasInsumo,
      retiradas: dados.retiradas,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: 'Caixa e saques',
          subtitle: 'Cada saque das plataformas é dividido automaticamente '
              'entre os destinos pelos percentuais configurados. Compras, '
              'investimentos e retiradas saem do destino escolhido.',
          actions: [
            OutlinedButton.icon(
              onPressed: onRegistrarRetirada,
              icon: const Icon(LucideIcons.arrowDownLeft, size: 18),
              label: const Text('Registrar retirada'),
            ),
            FilledButton.icon(
              onPressed: onRegistrarSaque,
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Registrar saque'),
            ),
          ],
        ),
        KpiRow(
          cartoes: [
            KpiCard(
              label: 'Sacado das plataformas',
              value: Formatos.moedaDecimal(sacado),
              sub: '${dados.saques.length} saque(s)',
            ),
            KpiCard(
              label: 'Saídas do caixa',
              value: Formatos.moedaDecimal(saidas),
              sub: 'compras, investimentos e retiradas',
            ),
            KpiCard(
              label: 'Saldo em caixa',
              value: Formatos.moedaDecimal(saldo),
              sub: 'soma de todos os destinos',
            ),
          ],
        ),
        const SizedBox(height: Espacos.g16),
        _SaldoPorDestino(dados: dados, somaPct: somaPct, fechou: fechou),
        const SizedBox(height: Espacos.g16),
        _ParDestinosPlataforma(dados: dados, empresaId: empresaId),
        const SizedBox(height: Espacos.g16),
        _Extrato(
          dados: dados,
          onExcluirSaque: (id) => _excluirSaque(context, ref, id),
          onExcluirRetirada: (id) => _excluirRetirada(context, ref, id),
        ),
      ],
    );
  }
}

/// Painel "Saldo por destino": um cartão por destino com barra proporcional.
class _SaldoPorDestino extends StatelessWidget {
  const _SaldoPorDestino({
    required this.dados,
    required this.somaPct,
    required this.fechou,
  });

  final DadosCaixa dados;
  final Decimal somaPct;
  final bool fechou;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return _Painel(
      header: Row(
        children: [
          Expanded(
            child: Text('Saldo por destino', style: textos.titleMedium),
          ),
          if (fechou)
            const Pill('Rateio fecha 100%', tom: TomPill.bom)
          else
            Pill(
              'Rateio soma ${Formatos.numero(somaPct.toDouble())}%',
              tom: TomPill.ruim,
            ),
        ],
      ),
      corpo: LayoutBuilder(
        builder: (context, constraints) {
          const espaco = Espacos.g12;
          final colunas = constraints.maxWidth < 520 ? 1 : 2;
          final largura =
              (constraints.maxWidth - espaco * (colunas - 1)) / colunas;
          return Wrap(
            spacing: espaco,
            runSpacing: espaco,
            children: [
              for (final d in dados.destinos)
                SizedBox(
                  width: largura < 0 ? 0 : largura,
                  child: _CartaoDestino(destino: d, dados: dados),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CartaoDestino extends StatelessWidget {
  const _CartaoDestino({required this.destino, required this.dados});

  final Destino destino;
  final DadosCaixa dados;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final cor = corDoDestino(context, destino.cor);
    final s = saldoDestino(
      destino.id,
      saques: dados.saques,
      investimentos: dados.investimentos,
      comprasInsumo: dados.comprasInsumo,
      retiradas: dados.retiradas,
    );
    final negativo = s.saldo < zero;
    final fracao = s.entradas > zero
        ? (s.saldo / s.entradas).toDouble().clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(Espacos.g16),
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(shape: BoxShape.circle, color: cor),
              ),
              const SizedBox(width: Espacos.g8),
              Expanded(child: Text(destino.nome)),
              Pill('${Formatos.numero(destino.percentual.toDouble())}%'),
            ],
          ),
          const SizedBox(height: Espacos.g8),
          Text(
            Formatos.moedaDecimal(s.saldo),
            style: textos.titleLarge?.copyWith(
              color: negativo ? cores.bad : null,
            ),
          ),
          const SizedBox(height: Espacos.g8),
          ClipRRect(
            borderRadius: BorderRadius.circular(Raios.pill),
            child: Stack(
              children: [
                Container(height: 6, color: cores.surface2),
                FractionallySizedBox(
                  widthFactor: fracao,
                  child: Container(height: 6, color: cor),
                ),
              ],
            ),
          ),
          const SizedBox(height: Espacos.g8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Entrou ${Formatos.moedaDecimal(s.entradas)}',
                  style: textos.bodySmall?.copyWith(color: cores.muted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Espacos.g8),
              Text(
                'Saiu ${Formatos.moedaDecimal(s.saidas)}',
                style: textos.bodySmall?.copyWith(color: cores.muted),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Par "Destinos e percentuais" + "Por plataforma" lado a lado (mesma altura).
class _ParDestinosPlataforma extends StatelessWidget {
  const _ParDestinosPlataforma({required this.dados, required this.empresaId});

  final DadosCaixa dados;
  final String empresaId;

  @override
  Widget build(BuildContext context) {
    final a = DestinosPanel(dados: dados, empresaId: empresaId);
    final b = _PorPlataforma(dados: dados);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: a),
                const SizedBox(width: Espacos.g16),
                Expanded(child: b),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [a, const SizedBox(height: Espacos.g16), b],
        );
      },
    );
  }
}

/// Painel "Por plataforma": líquido dos pedidos concluídos × sacado.
class _PorPlataforma extends StatelessWidget {
  const _PorPlataforma({required this.dados});

  final DadosCaixa dados;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;

    List<FaixaTaxa> faixasDe(Plataforma p) => dados.plataformas[p] ?? const [];

    Decimal liquidoDe(Plataforma p) {
      var total = zero;
      for (final pedido in dados.pedidos) {
        if (pedido.plataformaId != p.id) continue;
        if (pedido.situacao != SituacaoPedido.concluido) continue;
        total += calcularPedido(pedido, faixasDe(p)).liquido;
      }
      return total;
    }

    Decimal sacadoDe(Plataforma p) {
      var total = zero;
      for (final saque in dados.saques) {
        if (saque.plataformaId == p.id) total += saque.valor;
      }
      return total;
    }

    final plataformas = dados.plataformas.keys.toList();

    return _Painel(
      header: Row(
        children: [
          Expanded(
            child: Text('Por plataforma', style: textos.titleMedium),
          ),
          Text(
            'líquido lançado × sacado',
            style: textos.bodySmall?.copyWith(color: cores.muted),
          ),
        ],
      ),
      corpo: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < plataformas.length; i++) ...[
            if (i > 0) const SizedBox(height: Espacos.g12),
            _LinhaPlataforma(
              plataforma: plataformas[i],
              liquido: liquidoDe(plataformas[i]),
              sacado: sacadoDe(plataformas[i]),
            ),
          ],
          if (plataformas.isEmpty)
            Text(
              'Nenhuma plataforma cadastrada.',
              style: textos.bodyMedium?.copyWith(color: cores.muted),
            ),
        ],
      ),
    );
  }
}

class _LinhaPlataforma extends StatelessWidget {
  const _LinhaPlataforma({
    required this.plataforma,
    required this.liquido,
    required this.sacado,
  });

  final Plataforma plataforma;
  final Decimal liquido;
  final Decimal sacado;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;

    Widget valor(String rotulo, Decimal v) => Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rotulo,
              style: textos.bodySmall?.copyWith(color: cores.muted),
            ),
            const SizedBox(height: Espacos.base),
            Text(
              Formatos.moedaDecimal(v),
              style: textos.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        );

    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: PlatformPill(nome: plataforma.nome, cor: plataforma.cor),
          ),
        ),
        valor('Líquido dos pedidos', liquido),
        const SizedBox(width: Espacos.g16),
        valor('Sacado', sacado),
      ],
    );
  }
}

/// Painel "Extrato": movimentos ordenados por data desc, coluna por destino.
class _Extrato extends StatelessWidget {
  const _Extrato({
    required this.dados,
    required this.onExcluirSaque,
    required this.onExcluirRetirada,
  });

  final DadosCaixa dados;
  final ValueChanged<String> onExcluirSaque;
  final ValueChanged<String> onExcluirRetirada;

  List<Movimento> _movimentos() {
    final lista = <Movimento>[
      for (final s in dados.saques)
        Movimento(
          data: s.data,
          tipo: TipoMovimento.saque,
          descricao: 'Saque ${_nomePlataforma(s.plataformaId)}'.trim(),
          valor: s.valor,
          rateio: {for (final r in s.rateio) r.destinoId: r.valor},
          id: s.id,
        ),
      for (final i in dados.investimentos)
        if (i.destinoId != null)
          Movimento(
            data: i.data,
            tipo: TipoMovimento.investimento,
            descricao: i.distribuidor,
            valor: -i.valor,
            destinoId: i.destinoId,
          ),
      for (final c in dados.comprasInsumo)
        if (c.destinoId != null)
          Movimento(
            data: c.data,
            tipo: TipoMovimento.insumo,
            descricao: c.produto,
            valor: -c.valorTotal,
            destinoId: c.destinoId,
          ),
      for (final r in dados.retiradas)
        Movimento(
          data: r.data,
          tipo: TipoMovimento.retirada,
          descricao: r.descricao.isEmpty ? 'Retirada' : r.descricao,
          valor: -r.valor,
          destinoId: r.destinoId,
          id: r.id,
        ),
    ]..sort((a, b) => b.data.compareTo(a.data));
    return lista;
  }

  String _nomePlataforma(String id) {
    for (final p in dados.plataformas.keys) {
      if (p.id == id) return p.nome;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final cores = context.cores;
    final movimentos = _movimentos();

    return _Painel(
      header: Text('Extrato', style: textos.titleMedium),
      corpo: movimentos.isEmpty
          ? Text(
              'Nenhum movimento.',
              style: textos.bodyMedium?.copyWith(color: cores.muted),
            )
          : ResponsiveList<Movimento>(
              itens: movimentos,
              limiarCartao: 980,
              acoes: (m) {
                if (m.tipo == TipoMovimento.saque && m.id != null) {
                  return ConfirmDeleteButton(
                    tooltip: 'Excluir saque',
                    onConfirm: () => onExcluirSaque(m.id!),
                  );
                }
                if (m.tipo == TipoMovimento.retirada && m.id != null) {
                  return ConfirmDeleteButton(
                    tooltip: 'Excluir retirada',
                    onConfirm: () => onExcluirRetirada(m.id!),
                  );
                }
                return const SizedBox.shrink();
              },
              colunas: [
                ColunaLista<Movimento>(
                  label: 'Movimento',
                  principal: true,
                  builder: (m) => _CelulaMovimento(movimento: m),
                ),
                ColunaLista<Movimento>(
                  label: 'Valor',
                  alinhamento: Alignment.centerRight,
                  builder: (m) => _CelulaValor(movimento: m),
                ),
                for (final d in dados.destinos)
                  ColunaLista<Movimento>(
                    label: d.nome,
                    alinhamento: Alignment.centerRight,
                    builder: (m) =>
                        _CelulaDestino(movimento: m, destino: d),
                  ),
              ],
            ),
    );
  }
}

class _CelulaMovimento extends StatelessWidget {
  const _CelulaMovimento({required this.movimento});

  final Movimento movimento;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final positivo = movimento.valor > zero;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          movimento.descricao,
          style: textos.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: Espacos.base),
        Wrap(
          spacing: Espacos.g8,
          runSpacing: Espacos.base,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              Formatos.data(movimento.data),
              style: textos.bodySmall?.copyWith(color: cores.muted),
            ),
            Pill(
              movimento.rotulo,
              tom: positivo ? TomPill.bom : TomPill.neutro,
            ),
          ],
        ),
      ],
    );
  }
}

class _CelulaValor extends StatelessWidget {
  const _CelulaValor({required this.movimento});

  final Movimento movimento;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final negativo = movimento.valor < zero;
    return Text(
      Formatos.moedaDecimal(movimento.valor),
      style: textos.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: negativo ? cores.bad : cores.good,
      ),
    );
  }
}

class _CelulaDestino extends StatelessWidget {
  const _CelulaDestino({required this.movimento, required this.destino});

  final Movimento movimento;
  final Destino destino;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final v = movimento.valorNoDestino(destino);
    if (v == null || v == zero) {
      return Text('—', style: TextStyle(color: cores.muted));
    }
    final negativo = v < zero;
    return Text(
      Formatos.moedaDecimal(v),
      style: textos.bodyMedium?.copyWith(
        color: negativo ? cores.bad : null,
      ),
    );
  }
}

/// Casca de painel: cabeçalho + corpo em cartão de superfície.
class _Painel extends StatelessWidget {
  const _Painel({required this.header, required this.corpo});

  final Widget header;
  final Widget corpo;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return Container(
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Espacos.g16,
              Espacos.g16,
              Espacos.g16,
              Espacos.g12,
            ),
            child: header,
          ),
          Divider(height: 1, color: cores.line),
          Padding(
            padding: const EdgeInsets.all(Espacos.g16),
            child: corpo,
          ),
        ],
      ),
    );
  }
}

class _Erro extends StatelessWidget {
  const _Erro({required this.onTentar});

  final VoidCallback onTentar;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Espacos.g20),
      decoration: BoxDecoration(
        color: cores.badSoft,
        borderRadius: BorderRadius.circular(Raios.cartao),
      ),
      child: Column(
        children: [
          Text(
            'Não foi possível carregar o caixa.',
            style: TextStyle(color: cores.bad),
          ),
          const SizedBox(height: Espacos.g16),
          OutlinedButton(
            onPressed: onTentar,
            child: const Text('Tentar de novo'),
          ),
        ],
      ),
    );
  }
}
