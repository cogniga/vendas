import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/theme/tokens.dart';

/// Renderiza os estados de uma lista a partir de um [AsyncValue] (design §10).
///
/// - Carregando: esqueleto de cartões (skeleton).
/// - Vazio: mensagem + ação opcional ([acaoVazio]).
/// - Erro: caixa suave com "Tentar de novo" ([aoTentarDeNovo]).
/// - Com dados: delega para [comDados]; se a lista vier vazia, mostra o estado
///   vazio.
class EstadoLista<T> extends StatelessWidget {
  const EstadoLista({
    required this.estado,
    required this.comDados,
    required this.mensagemVazia,
    this.aoTentarDeNovo,
    this.acaoVazio,
    super.key,
  });

  /// Estado assíncrono da lista.
  final AsyncValue<List<T>> estado;

  /// Builder para o caso com dados (lista não vazia).
  final Widget Function(List<T> itens) comDados;

  /// Mensagem exibida quando não há itens.
  final String mensagemVazia;

  /// Callback do botão "Tentar de novo" no estado de erro.
  final VoidCallback? aoTentarDeNovo;

  /// Ação opcional no estado vazio (ex.: botão "Novo produto").
  final Widget? acaoVazio;

  @override
  Widget build(BuildContext context) {
    return estado.when(
      loading: () => const _EsqueletoLista(),
      error: (erro, _) => _CaixaErro(
        mensagem: _texto(erro),
        aoTentarDeNovo: aoTentarDeNovo,
      ),
      data: (itens) => itens.isEmpty
          ? _ListaVazia(mensagem: mensagemVazia, acao: acaoVazio)
          : comDados(itens),
    );
  }

  String _texto(Object erro) {
    final texto = erro.toString();
    return texto.startsWith('ErroRepositorio: ')
        ? texto.substring('ErroRepositorio: '.length)
        : 'Não foi possível carregar. Tente de novo.';
  }
}

/// Esqueleto (skeleton) de carregamento com algumas linhas em cinza.
class _EsqueletoLista extends StatelessWidget {
  const _EsqueletoLista();

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return Column(
      children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(height: Espacos.g12),
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: cores.surface2,
              borderRadius: BorderRadius.circular(Raios.cartao),
              border: Border.all(color: cores.line),
            ),
          ),
        ],
      ],
    );
  }
}

/// Estado vazio: mensagem centralizada e ação opcional.
class _ListaVazia extends StatelessWidget {
  const _ListaVazia({required this.mensagem, this.acao});

  final String mensagem;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Espacos.g20),
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      child: Column(
        children: [
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: textos.bodyMedium?.copyWith(color: cores.muted),
          ),
          if (acao != null) ...[
            const SizedBox(height: Espacos.g16),
            acao!,
          ],
        ],
      ),
    );
  }
}

/// Estado de erro: caixa suave com mensagem e botão "Tentar de novo".
class _CaixaErro extends StatelessWidget {
  const _CaixaErro({required this.mensagem, this.aoTentarDeNovo});

  final String mensagem;
  final VoidCallback? aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
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
            mensagem,
            textAlign: TextAlign.center,
            style: textos.bodyMedium?.copyWith(color: cores.bad),
          ),
          if (aoTentarDeNovo != null) ...[
            const SizedBox(height: Espacos.g16),
            OutlinedButton(
              onPressed: aoTentarDeNovo,
              child: const Text('Tentar de novo'),
            ),
          ],
        ],
      ),
    );
  }
}
