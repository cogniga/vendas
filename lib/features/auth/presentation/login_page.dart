import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/core/config/sessao_local.dart';
import 'package:sales/core/theme/tokens.dart';
import 'package:sales/features/auth/application/auth_controller.dart';

/// Tela de autenticação: entrar / criar conta / esqueci a senha (§10).
///
/// Usa [authControllerProvider]; após autenticar, o `redirect` do go_router
/// leva a `/` ou `/onboarding`. Mostra estado de carregamento no botão e erro
/// em mensagem abaixo do formulário.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _criandoConta = false;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final controller = ref.read(authControllerProvider.notifier);
    if (_criandoConta) {
      await controller.criarConta(_email.text, _senha.text);
    } else {
      await controller.entrar(_email.text, _senha.text);
    }
    if (!mounted) return;
    final estado = ref.read(authControllerProvider);
    if (_criandoConta && !estado.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Conta criada. Verifique o e-mail se for pedida confirmação.',
          ),
        ),
      );
    }
  }

  Future<void> _esqueciSenha() async {
    final emailCtrl = TextEditingController(text: _email.text);
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar senha'),
        content: TextField(
          controller: emailCtrl,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'E-mail'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(emailCtrl.text.trim()),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
    emailCtrl.dispose();
    if (email == null || email.isEmpty || !mounted) return;
    await ref.read(authControllerProvider.notifier).recuperarSenha(email);
    if (!mounted) return;
    final estado = ref.read(authControllerProvider);
    if (!estado.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enviamos um e-mail para redefinir a senha.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final textos = Theme.of(context).textTheme;
    final estado = ref.watch(authControllerProvider);
    final carregando = estado.isLoading;

    return Scaffold(
      backgroundColor: cores.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Espacos.g20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(Espacos.g20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Balcão Revenda', style: textos.headlineMedium),
                      const SizedBox(height: Espacos.base),
                      Text(
                        _criandoConta
                            ? 'Crie sua conta para começar.'
                            : 'Entre para continuar.',
                        style: textos.bodyMedium?.copyWith(
                          color: cores.muted,
                        ),
                      ),
                      if (!_criandoConta) ...[
                        const SizedBox(height: Espacos.g8),
                        Text(
                          'Acesso provisório: adm / adm',
                          style: textos.bodySmall?.copyWith(
                            color: cores.muted,
                          ),
                        ),
                      ],
                      const SizedBox(height: Espacos.g20),
                      TextFormField(
                        controller: _email,
                        enabled: !carregando,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                        ),
                        validator: _validarEmail,
                      ),
                      const SizedBox(height: Espacos.g12),
                      TextFormField(
                        controller: _senha,
                        enabled: !carregando,
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                        ),
                        onFieldSubmitted: (_) => _enviar(),
                        validator: _validarSenha,
                      ),
                      if (estado.hasError) ...[
                        const SizedBox(height: Espacos.g12),
                        _MensagemErro(texto: '${estado.error}'),
                      ],
                      const SizedBox(height: Espacos.g20),
                      FilledButton(
                        onPressed: carregando ? null : _enviar,
                        child: carregando
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _criandoConta ? 'Criar conta' : 'Entrar',
                              ),
                      ),
                      const SizedBox(height: Espacos.g8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: carregando
                                ? null
                                : () => setState(
                                      () => _criandoConta = !_criandoConta,
                                    ),
                            child: Text(
                              _criandoConta
                                  ? 'Já tenho conta'
                                  : 'Criar conta',
                            ),
                          ),
                          if (!_criandoConta)
                            TextButton(
                              onPressed: carregando ? null : _esqueciSenha,
                              child: const Text('Esqueci a senha'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validarEmail(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Informe o e-mail';
    // Atalho de desenvolvimento: aceita o usuário local "adm".
    if (!_criandoConta && SessaoLocal.valida(texto, _senha.text)) {
      return null;
    }
    if (!texto.contains('@') || !texto.contains('.')) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? _validarSenha(String? valor) {
    final texto = valor ?? '';
    if (texto.isEmpty) return 'Informe a senha';
    // Atalho de desenvolvimento: não exige 6 caracteres para o usuário local.
    if (!_criandoConta && SessaoLocal.valida(_email.text, texto)) {
      return null;
    }
    if (_criandoConta && texto.length < 6) {
      return 'A senha precisa de pelo menos 6 caracteres';
    }
    return null;
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
