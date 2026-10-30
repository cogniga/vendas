import 'package:flutter/material.dart';

/// Placeholder TEMPORÁRIO de Login/criar conta.
///
/// FEAT-003 substitui esta tela pela autenticação real (Supabase Auth). Existe
/// aqui apenas para o roteador compilar na PARTE B.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Login — em construção (FEAT-003)'),
      ),
    );
  }
}
