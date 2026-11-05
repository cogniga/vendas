import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sales/core/theme/tema_provider.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/core/widgets/page_header.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/data/repositorios/empresa_selecionada.dart';
import 'package:sales/domain/entidades/empresa.dart';
import 'package:sales/features/configuracoes/application/configuracoes_providers.dart';

/// Tela de Dados e configurações (R14, R12).
///
/// Bloco principal: seletor da empresa padrão do sistema. Ao salvar, toda a
/// aplicação passa a usar a empresa escolhida.
class ConfiguracoesPage extends ConsumerWidget {
  const ConfiguracoesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: 'Dados e configurações',
          subtitle: 'Empresa ativa, aparência e preferências do sistema.',
        ),
        _BlocoEmpresa(),
        SizedBox(height: Espacos.g20),
        _BlocoTema(),
      ],
    );
  }
}

/// Seletor da empresa padrão do sistema.
class _BlocoEmpresa extends ConsumerStatefulWidget {
  const _BlocoEmpresa();

  @override
  ConsumerState<_BlocoEmpresa> createState() => _BlocoEmpresaState();
}

class _BlocoEmpresaState extends ConsumerState<_BlocoEmpresa> {
  String? _escolhida;
  bool _salvando = false;

  @override
  Widget build(BuildContext context) {
    final empresasAsync = ref.watch(todasEmpresasProvider);
    final selecionada = ref.watch(empresaSelecionadaProvider);
    _escolhida ??= selecionada;

    return _Painel(
      titulo: 'Empresa',
      subtitulo: 'Escolha a empresa que o sistema inteiro vai usar.',
      filho: empresasAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(Espacos.g12),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => _Erro(
          onTentar: () => ref.invalidate(todasEmpresasProvider),
        ),
        data: (empresas) {
          if (empresas.isEmpty) {
            return const Text(
              'Nenhuma empresa cadastrada. Crie uma no Supabase ou pelo '
              'cadastro inicial.',
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _valido(_escolhida, empresas)
                    ? _escolhida
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Empresa ativa',
                ),
                items: [
                  for (final e in empresas)
                    DropdownMenuItem(value: e.id, child: Text(e.nome)),
                ],
                onChanged: (v) => setState(() => _escolhida = v),
              ),
              const SizedBox(height: Espacos.g16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _salvando || _escolhida == null
                      ? null
                      : () => _salvar(_escolhida!),
                  child: _salvando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _valido(String? id, List<Empresa> empresas) =>
      id != null && empresas.any((e) => e.id == id);

  Future<void> _salvar(String empresaId) async {
    setState(() => _salvando = true);
    try {
      // Persiste a escolha e invalida a empresa ativa para recarregar todo o
      // sistema com a nova empresa (o provider também vincula o membro).
      await ref.read(empresaSelecionadaProvider.notifier).definir(empresaId);
      ref.invalidate(empresaAtualProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Empresa ativa salva. O sistema agora usa ela.'),
        ),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar. Tente de novo.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }
}

/// Seletor de tema (Claro / Escuro / Automático).
class _BlocoTema extends ConsumerWidget {
  const _BlocoTema();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modo = ref.watch(temaProvider);
    final notifier = ref.read(temaProvider.notifier);

    return _Painel(
      titulo: 'Aparência',
      subtitulo: 'Tema da interface.',
      filho: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.light,
            label: Text('Claro'),
            icon: Icon(LucideIcons.sun, size: 16),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            label: Text('Escuro'),
            icon: Icon(LucideIcons.moon, size: 16),
          ),
          ButtonSegment(
            value: ThemeMode.system,
            label: Text('Automático'),
            icon: Icon(LucideIcons.monitor, size: 16),
          ),
        ],
        selected: {modo},
        onSelectionChanged: (s) => notifier.definir(s.first),
      ),
    );
  }
}

/// Cartão-painel padrão da tela.
class _Painel extends StatelessWidget {
  const _Painel({
    required this.titulo,
    required this.filho,
    this.subtitulo,
  });

  final String titulo;
  final String? subtitulo;
  final Widget filho;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Espacos.g16),
      decoration: BoxDecoration(
        color: cores.surface,
        borderRadius: BorderRadius.circular(Raios.cartao),
        border: Border.all(color: cores.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: textos.titleMedium),
          if (subtitulo != null) ...[
            const SizedBox(height: Espacos.base),
            Text(
              subtitulo!,
              style: textos.bodySmall?.copyWith(color: cores.muted),
            ),
          ],
          const SizedBox(height: Espacos.g16),
          filho,
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
    return Row(
      children: [
        const Expanded(
          child: Text('Não foi possível carregar as empresas.'),
        ),
        OutlinedButton(
          onPressed: onTentar,
          child: const Text('Tentar de novo'),
        ),
      ],
    );
  }
}
