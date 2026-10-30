import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sales/core/format/padrao_escrita.dart';
import 'package:sales/core/router/rotas.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/features/onboarding/application/onboarding_controller.dart';

/// Tela de onboarding: cria a empresa e oferece importar a planilha ou
/// começar vazio (design.md §9/§10).
///
/// Passo 1 pede o nome da empresa (normalizado como título ao enviar). Depois
/// de criada, o passo 2 oferece "Importar dados da planilha" ou "Começar
/// vazio"; ao concluir, o controller invalida `empresaAtualProvider` e a tela
/// navega para o painel.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  Future<void> _criar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final nome = PadraoEscrita.titulo(_nome.text);
    await ref.read(onboardingControllerProvider.notifier).criarEmpresa(nome);
  }

  Future<void> _concluir({required bool importar}) async {
    await ref
        .read(onboardingControllerProvider.notifier)
        .concluir(importar: importar);
    if (!mounted) return;
    final estado = ref.read(onboardingControllerProvider);
    if (!estado.hasError) {
      context.go(Rotas.painel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final estado = ref.watch(onboardingControllerProvider);
    final carregando = estado.isLoading;
    final empresaCriada =
        ref.watch(onboardingControllerProvider.notifier).empresaId != null;

    return Scaffold(
      backgroundColor: cores.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Espacos.g20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(Espacos.g20),
                child: empresaCriada
                    ? _PassoImportar(
                        carregando: carregando,
                        erro: estado.hasError ? '${estado.error}' : null,
                        onImportar: () => _concluir(importar: true),
                        onVazio: () => _concluir(importar: false),
                      )
                    : _PassoNome(
                        formKey: _formKey,
                        controller: _nome,
                        carregando: carregando,
                        erro: estado.hasError ? '${estado.error}' : null,
                        onEnviar: _criar,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Passo 1: nome da empresa.
class _PassoNome extends StatelessWidget {
  const _PassoNome({
    required this.formKey,
    required this.controller,
    required this.carregando,
    required this.erro,
    required this.onEnviar,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool carregando;
  final String? erro;
  final VoidCallback onEnviar;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final cores = context.cores;
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Bem-vindo', style: textos.headlineMedium),
          const SizedBox(height: Espacos.base),
          Text(
            'Dê um nome à sua empresa para começar.',
            style: textos.bodyMedium?.copyWith(color: cores.muted),
          ),
          const SizedBox(height: Espacos.g20),
          TextFormField(
            controller: controller,
            enabled: !carregando,
            decoration: const InputDecoration(labelText: 'Nome da empresa'),
            onFieldSubmitted: (_) => onEnviar(),
            validator: (valor) =>
                (valor == null || valor.trim().isEmpty)
                    ? 'Informe o nome da empresa'
                    : null,
          ),
          if (erro != null) ...[
            const SizedBox(height: Espacos.g12),
            _MensagemErro(texto: erro!),
          ],
          const SizedBox(height: Espacos.g20),
          FilledButton(
            onPressed: carregando ? null : onEnviar,
            child: carregando
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}

/// Passo 2: importar a planilha ou começar vazio.
class _PassoImportar extends StatelessWidget {
  const _PassoImportar({
    required this.carregando,
    required this.erro,
    required this.onImportar,
    required this.onVazio,
  });

  final bool carregando;
  final String? erro;
  final VoidCallback onImportar;
  final VoidCallback onVazio;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final cores = context.cores;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Empresa criada', style: textos.headlineMedium),
        const SizedBox(height: Espacos.base),
        Text(
          'Quer trazer os dados da sua planilha ou começar com o '
          'sistema vazio?',
          style: textos.bodyMedium?.copyWith(color: cores.muted),
        ),
        if (erro != null) ...[
          const SizedBox(height: Espacos.g12),
          _MensagemErro(texto: erro!),
        ],
        const SizedBox(height: Espacos.g20),
        FilledButton.icon(
          onPressed: carregando ? null : onImportar,
          icon: carregando
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(LucideIcons.download),
          label: const Text('Importar dados da planilha'),
        ),
        const SizedBox(height: Espacos.g8),
        OutlinedButton(
          onPressed: carregando ? null : onVazio,
          child: const Text('Começar vazio'),
        ),
      ],
    );
  }
}

/// Mensagem de erro em caixa suave (§10).
class _MensagemErro extends StatelessWidget {
  const _MensagemErro({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Espacos.g12),
      decoration: BoxDecoration(
        color: cores.badSoft,
        borderRadius: BorderRadius.circular(Raios.controle),
      ),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cores.bad,
            ),
      ),
    );
  }
}
