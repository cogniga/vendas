# Como rodar o Balcão Revenda

## 1. Configurar o Supabase

### 1.1 Pegar as credenciais no painel do Supabase
No [app.supabase.com](https://app.supabase.com), abra seu projeto e pegue dois valores:

- **SUPABASE_URL** — em **Project Settings → General** (ou **Data API**), campo
  **Project URL** (ex.: `https://abcdxyz.supabase.co`).
- **SUPABASE_ANON_KEY** — em **Project Settings → API Keys**. Use **uma** destas:
  - a **Publishable key** (`sb_publishable_...`) na aba
    "Publishable and secret API keys"; **ou**
  - a chave **anon / public** (um JWT `eyJ...`) na aba
    "Legacy anon, service_role API keys".

> Nunca use a **service_role** nem as **Secret keys** no app. Elas são privadas.

### 1.2 Aplicar o banco de dados
Rode a migração `supabase/migrations/0001_schema.sql` uma vez:

- **Pelo painel:** abra **SQL Editor**, cole o conteúdo do arquivo e execute; **ou**
- **Pela CLI:** `supabase db push`

Isso cria as tabelas (incluindo `produto_online`), o RLS por empresa e a função
`criar_empresa`.

## 2. Preencher as chaves no projeto

As chaves **não** ficam no código. Preencha o arquivo local (já ignorado pelo git):

`env/supabase.json`

```json
{
  "SUPABASE_URL": "https://SEU-PROJETO.supabase.co",
  "SUPABASE_ANON_KEY": "sua_chave_publishable_ou_anon"
}
```

## 3. Rodar o app

```bash
flutter pub get
flutter run -d macos --dart-define-from-file=env/supabase.json
```

Troque `-d macos` por `-d chrome`, `-d windows` ou `-d <id-do-dispositivo>` conforme
a plataforma. Veja os dispositivos com `flutter devices`.

## Comandos úteis

```bash
flutter test                 # roda os testes
flutter analyze lib test     # análise estática
dart run build_runner build --delete-conflicting-outputs   # regenera código freezed
```
