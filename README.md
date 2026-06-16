# Focus

Aplicativo Flutter para organização de atividades, categorias e ciclos de foco. O projeto usa Firebase para autenticação e persistência principal, Provider para estado, tema claro/escuro persistido localmente e uma arquitetura organizada por features.

## Funcionalidades

- Autenticação com e-mail e senha via Firebase Auth.
- Dashboard com métricas de tarefas, progresso geral e gráficos.
- Cadastro, edição, detalhes, conclusão e lixeira de atividades.
- Filtros de atividades por nome, data de vencimento e agrupamento por categoria.
- Cadastro, edição, detalhes e lixeira de categorias.
- Modo foco com cronômetro controlado por sensor de proximidade.
- Registro de acessos recentes com data e localização quando disponível.
- Perfil com foto local, dados cadastrais e timeline de acessos.
- Tela de configurações com modo escuro persistido.
- Navegação por bottom navigation, drawer lateral e gestos horizontais.

## Stack

- Flutter / Dart
- Provider
- Firebase Core
- Firebase Auth
- Cloud Firestore
- Shared Preferences
- Geolocator
- Permission Handler
- Proximity Sensor
- Image Picker
- Sqflite / Sqflite FFI
- Mocktail para testes

## Estrutura

```text
lib/
  core/
    constants/        # Políticas globais, como retenção da lixeira
    services/         # Contratos e implementações globais de permissão
    theme/            # Cores, tema e paleta de categorias

  data/
    database_helper.dart
    repositories/     # Contratos e implementações Firebase/SQLite/mock

  features/
    auth/             # Login, cadastro, sessão e auditoria de login
    categories/       # Categorias, forms, detalhes e widgets próprios
    focus/            # Modo foco e cronômetro por sensor
    profile/          # Perfil, foto e histórico de acessos
    settings/         # Preferências locais, como modo escuro
    tasks/            # Dashboard, tarefas, filtros, forms e widgets próprios
    trash/            # Lixeira de tarefas e categorias

  shared/
    models/           # Modelos compartilhados
    utils/            # Helpers de navegação/logout
    widgets/          # Componentes globais reutilizáveis
```

## Padrão de Organização

O projeto separa componentes globais e componentes específicos de cada módulo:

- `shared/widgets`: widgets reutilizados por várias features, como `AppBarWidget`, `AppCard`, `AppDrawer`, bottom navigation e gesture navigation.
- `features/<modulo>/widgets`: widgets usados somente dentro daquela feature, como cards, filtros, gráficos e estados vazios.
- `features/<modulo>/views`: telas completas, normalmente com `Scaffold`, navegação e composição geral.
- `features/<modulo>/viewmodels`: estado e regras de apresentação.
- `features/<modulo>/models`: modelos de domínio daquela feature.

## Principais Features

### Auth

Responsável por login, cadastro, restauração de sessão e logout.

Arquivos principais:

- `features/auth/views/login.dart`
- `features/auth/views/register.dart`
- `features/auth/views/auth_gate.dart`
- `features/auth/viewmodels/auth_view_model.dart`
- `features/auth/services/login_access_recorder.dart`

### Tasks

Responsável por atividades, filtros, dashboard e modo de edição.

Recursos:

- Listagem responsiva.
- Busca por nome.
- Filtro por vencimento.
- Exibição agrupada por categoria.
- Card com ações de detalhes, edição e conclusão.
- Lixeira com restauração.

Widgets específicos:

- `features/tasks/widgets/task_card.dart`
- `features/tasks/widgets/task_filter_bar.dart`
- `features/tasks/widgets/category_task_section.dart`
- `features/tasks/widgets/task_empty_state.dart`
- `features/tasks/widgets/dashboard_summary_card.dart`
- `features/tasks/widgets/dashboard_charts.dart`

### Categories

Responsável por categorias e suas cores.

Widgets específicos:

- `features/categories/widgets/category_card.dart`
- `features/categories/widgets/category_empty_state.dart`

### Profile

Responsável por exibir dados do usuário, foto local e histórico de acessos.

Widgets específicos:

- `features/profile/widgets/profile_avatar.dart`
- `features/profile/widgets/profile_info_panel.dart`
- `features/profile/widgets/access_timeline.dart`

### Settings

Responsável por preferências locais do app.

Configuração atual:

- Modo escuro persistido com `SharedPreferences`.

Arquivos principais:

- `features/settings/views/settings_screen.dart`
- `features/settings/viewmodels/theme_view_model.dart`
- `features/settings/services/settings_service.dart`

### Focus Mode

Responsável pelo ciclo de foco.

Recursos:

- Cronômetro.
- Sensor de proximidade.
- Captura de localização ao concluir sessão, quando permitido.
- Vínculo opcional com tarefa selecionada.

## Tema e Design Tokens

O app usa `AppTheme` e `AppColors` para manter consistência visual entre modo claro e escuro.

### Cores

| Token / Classe | Uso |
| --- | --- |
| `AppColors.primary` | Cor principal da marca |
| `AppColors.secondary` | Destaques e gradientes |
| `AppColors.lightBackground` | Fundo do tema claro |
| `AppColors.darkBackground` | Fundo do tema escuro |
| `AppColors.lightSurface` | Cards no tema claro |
| `AppColors.darkSurface` | Cards no tema escuro |
| `AppColors.textMuted` | Textos auxiliares e estados vazios |

### Categorias

As cores de categoria são centralizadas em:

```text
lib/core/theme/category_palette.dart
```

### Layout

Telas principais seguem o padrão:

```text
Scaffold
  body
    Padding(horizontal: 24, vertical: 24)
      Center
        ConstrainedBox(maxWidth: 1200)
```

Esse padrão mantém dashboard, tarefas, categorias, lixeira e configurações alinhadas em telas maiores.

## Persistência

### Firebase

Usado para:

- Autenticação.
- Tarefas.
- Categorias.
- Histórico de acessos.

Implementações principais:

- `FirebaseTaskRepository`
- `FirebaseCategoryRepository`
- `FirebaseAccessLogRepository`

### Local

Usado para:

- Tema escuro com `SharedPreferences`.
- Banco SQLite local disponível como implementação alternativa.

Arquivos:

- `features/settings/services/settings_service.dart`
- `data/database_helper.dart`
- `SQLiteTaskRepository`
- `SQLiteCategoryRepository`

## Lixeira

Itens removidos não são excluídos imediatamente. Eles recebem `deletedAt` e ficam disponíveis para restauração.

A política de retenção fica em:

```text
lib/core/constants/trash_policy.dart
```

Valor atual:

```dart
static const retentionDays = 15;
```

## Comentários de Código

O projeto usa comentários de documentação no estilo `///` para explicar responsabilidades de:

- classes;
- contratos;
- services;
- repositórios;
- viewmodels;
- widgets;
- métodos/helpers relevantes.

A ideia é documentar comportamento e responsabilidade, sem comentar cada linha óbvia de UI.

## Como Rodar

Instale as dependências:

```sh
flutter pub get
```

Rode no dispositivo disponível:

```sh
flutter run
```

Rode no web-server local:

```sh
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=8080
```

## Qualidade

Análise estática:

```sh
flutter analyze
```

Testes:

```sh
flutter test
```

## Testes

Há testes cobrindo:

- autenticação e auditoria de login;
- categorias;
- perfil e histórico de acessos;
- tarefas;
- persistência do modo escuro;
- widgets principais de navegação/lixeira.

Estrutura:

```text
test/
  features/
    auth/
    categories/
    profile/
    settings/
    tasks/
  widget_test.dart
```

## Assets

Logos do app:

```text
assets/images/focusLogo.png
assets/images/focusLogo2.png
```

Declarados em `pubspec.yaml`.
