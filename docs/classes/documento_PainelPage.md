# documento_PainelPage

- **Arquivo:** `lib/features/painel/presentation/painel_page.dart`
- **Responsabilidade:** Tela do Painel (`ConsumerWidget`): cabeçalho com seletor de período e "Novo pedido", 5 KPIs e a grade de 4 painéis. Usa `dadosPainelProvider` (valor anterior mantido durante recarga, sem spinner); spinner só na primeira carga; erro com "Tentar de novo". Painéis em `painel_paineis.dart` (`PainelVendasPlataforma`, `PainelAtencao`, `PainelCaixa`, `PainelTopItens`).
