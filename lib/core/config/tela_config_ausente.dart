import 'package:flutter/material.dart';
import 'package:sales/core/theme/tokens.dart';

/// Mostrada quando `SUPABASE_URL`/`SUPABASE_ANON_KEY` não foram informados.
///
/// Orienta o usuário a rodar o app com os `--dart-define` necessários.
class TelaConfigAusente extends StatelessWidget {
  const TelaConfigAusente({super.key});

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(Espacos.g20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuração do Supabase ausente',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: Espacos.g12),
                Text(
                  'Informe as variáveis SUPABASE_URL e SUPABASE_ANON_KEY ao '
                  'iniciar o aplicativo.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: Espacos.g16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Espacos.g16),
                  decoration: BoxDecoration(
                    color: cores.surface2,
                    borderRadius: BorderRadius.circular(Raios.cartao),
                    border: Border.all(color: cores.line),
                  ),
                  child: SelectableText(
                    'flutter run -d macos \\\n'
                    '  --dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co \\\n'
                    '  --dart-define=SUPABASE_ANON_KEY=SUA_CHAVE',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: cores.ink,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
