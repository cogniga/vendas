import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/data/repositorios/empresa_atual_provider.dart';
import 'package:sales/data/repositorios/empresa_repository.dart';
import 'package:sales/features/onboarding/application/importador_seed.dart';

/// Controla o fluxo de onboarding (criar empresa + importar o seed).
///
/// Expõe o estado como `AsyncValue<void>` (`loading`/`error`/`data`) e guarda
/// o `id` da empresa recém-criada para a importação do seed. Após criar a
/// empresa e, opcionalmente, importar os dados, invalida
/// [empresaAtualProvider] para que o go_router libere o painel.
class OnboardingController extends StateNotifier<AsyncValue<void>> {
  /// Cria o controller com o [Ref] e o [EmpresaRepository] injetados.
  OnboardingController(this._ref, this._empresaRepo)
      : super(const AsyncValue.data(null));

  final Ref _ref;
  final EmpresaRepository _empresaRepo;

  String? _empresaId;

  /// `id` da empresa criada nesta sessão de onboarding (null antes de criar).
  String? get empresaId => _empresaId;

  /// Cria a empresa [nome] via `criarEmpresa` e guarda o `id` gerado.
  ///
  /// Não invalida [empresaAtualProvider] ainda — isso só acontece em
  /// [concluir], depois da escolha de importar ou começar vazio, para não
  /// disparar o redirect antes da hora.
  Future<void> criarEmpresa(String nome) async {
    state = const AsyncValue.loading();
    try {
      _empresaId = await _empresaRepo.criarEmpresa(nome.trim());
      state = const AsyncValue.data(null);
    } on Object catch (e, s) {
      state = AsyncValue.error(_mensagem(e), s);
    }
  }

  /// Conclui o onboarding; se [importar] é true, importa o seed na empresa
  /// criada. Ao final, invalida [empresaAtualProvider].
  Future<void> concluir({required bool importar}) async {
    final id = _empresaId;
    if (id == null) {
      state = AsyncValue.error(
        'Crie a empresa antes de concluir.',
        StackTrace.current,
      );
      return;
    }
    state = const AsyncValue.loading();
    try {
      if (importar) {
        await _ref.read(importadorSeedProvider).importar(id);
      }
      _ref.invalidate(empresaAtualProvider);
      state = const AsyncValue.data(null);
    } on Object catch (e, s) {
      state = AsyncValue.error(_mensagem(e), s);
    }
  }

  String _mensagem(Object erro) {
    final texto = erro.toString();
    return texto.startsWith('ErroRepositorio: ')
        ? texto.substring('ErroRepositorio: '.length)
        : 'Não foi possível concluir. Tente de novo.';
  }
}

/// Provider do [OnboardingController].
final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, AsyncValue<void>>((ref) {
  return OnboardingController(ref, ref.watch(empresaRepositoryProvider));
});
