# Documentação de classes — Camada features

> Regra do projeto: cada classe tem documentação única, atualizada a cada
> alteração. Este arquivo agrupa as classes de `lib/features` entregues na
> PARTE C (autenticação, onboarding e importador do seed). As telas usam os
> tokens `context.cores`/`Raios`/`Espacos` e os componentes de `core/widgets`;
> nenhuma chamada ao Supabase vive em widget — apenas em controllers e
> repositórios.

## documento_AuthController
- **Arquivo:** `lib/features/auth/application/auth_controller.dart`
- **Responsabilidade:** autentica via Supabase Auth (design.md §10).
  `StateNotifier<AsyncValue<void>>` que expõe `loading`/`error`/`data` da
  última operação. Métodos: `entrar(email, senha)` (`signInWithPassword`),
  `criarConta(email, senha)` (`signUp`), `recuperarSenha(email)`
  (`resetPasswordForEmail`) e `sair()` (`signOut`). Traduz `AuthException`
  para mensagens amigáveis em pt_BR (§10). A navegação em si é decidida pelo
  `redirect` do go_router (reage à sessão), não pelo controller.
- **Provider:** `authControllerProvider`
  (`StateNotifierProvider<AuthController, AsyncValue<void>>`).

## documento_LoginPage
- **Arquivo:** `lib/features/auth/presentation/login_page.dart`
- **Responsabilidade:** tela `/login` (substitui o placeholder da FEAT-002).
  Formulário e-mail/senha com validação; alterna entre "Entrar" e "Criar
  conta"; ação "Esqueci a senha" abre diálogo pedindo o e-mail e chama
  `recuperarSenha`. Mostra carregamento no botão (progress) e erro em caixa
  suave (`badSoft`) via `authControllerProvider`. Após autenticar, o redirect
  leva a `/` ou `/onboarding`.

## documento_OnboardingController
- **Arquivo:** `lib/features/onboarding/application/onboarding_controller.dart`
- **Responsabilidade:** fluxo de onboarding em duas etapas.
  `criarEmpresa(nome)` chama `EmpresaRepository.criarEmpresa` e guarda o `id`
  gerado (sem invalidar nada ainda, para o redirect não disparar cedo);
  `concluir({required bool importar})` importa o seed (via
  `ImportadorSeed.importar`) quando pedido e, ao final, invalida
  `empresaAtualProvider`. Estado `AsyncValue<void>` (`loading`/`error`); expõe
  `empresaId` da empresa criada na sessão.
- **Provider:** `onboardingControllerProvider`
  (`StateNotifierProvider<OnboardingController, AsyncValue<void>>`).

## documento_OnboardingPage
- **Arquivo:** `lib/features/onboarding/presentation/onboarding_page.dart`
- **Responsabilidade:** tela `/onboarding` (substitui o placeholder da
  FEAT-002). Passo 1: nome da empresa (normalizado como título com
  `PadraoEscrita.titulo`) → cria a empresa. Passo 2 (após criar): escolha
  "Importar dados da planilha" (`concluir(importar: true)`) ou "Começar vazio"
  (`concluir(importar: false)`); ao concluir sem erro, navega para `/`.
  Estados carregando/erro (§10). Usa `onboardingControllerProvider`.

## documento_ImportadorSeed
- **Arquivo:** `lib/features/onboarding/application/importador_seed.dart`
- **Responsabilidade:** importa `assets/seed/dados-iniciais.json` para a
  empresa (design.md §9). Recebe os repositórios da FEAT-001 por construtor.
  `importar(empresaId)` lê o asset com `rootBundle.loadString` + `json.decode`
  e delega para `importarDados(empresaId, dados)` (separado para teste sem
  `rootBundle`). Ordem: configurações → plataformas/faixas → destinos → regra
  de abelinhas → produtos (`produto_online`) → produtos de venda → compras →
  investimentos → pedidos → saques. Plataformas, destinos e faixas de abelinha
  (já criados pela RPC `criar_empresa`) são **atualizados casando pelo nome**
  sem duplicar; faixas de taxa são substituídas pelas do arquivo. Resolve as
  referências textuais do arquivo (código do produto, nome da plataforma/
  destino, nome do kit) para UUIDs via mapas construídos durante a importação.
- **Snapshots e rateio:** nos itens de pedido, para `tipo` "produto"
  `custo_unitario = produto.custo` e `abelinhas_unitarias =
  abelinhasProduto(...)`; para "produto_venda" usa `calcularKit` (investimento
  e abelinhas do kit) — cálculos de `lib/domain/calculos`, não reimplementados.
  O rateio do saque usa os percentuais do arquivo (`valor * percentual / 100`).
- **Provider:** `importadorSeedProvider` (monta o importador a partir dos
  providers de repositório). `kCaminhoSeed` expõe o caminho do asset.
