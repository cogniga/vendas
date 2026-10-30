import 'package:flutter/material.dart';

/// Placeholder TEMPORÁRIO de Onboarding (nome da empresa + importar planilha).
///
/// FEAT-003 substitui esta tela pelo fluxo real. Existe aqui apenas para o
/// roteador compilar na PARTE B.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Onboarding — em construção (FEAT-003)'),
      ),
    );
  }
}
