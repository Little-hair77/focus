# focus

## 🎨 Design Tokens (Sprint 3)

O projeto **Focus** adota um sistema de Design Tokens para garantir a consistência de componentes, espaçamentos e acessibilidade visual entre os modos claro e escuro.

### 1. Cores (Color Tokens)
| Token | Referência no Código (`ThemeData`) | Aplicação Visual |
| :--- | :--- | :--- |
| `color-primary` | `theme.colorScheme.primary` | Identidade visual roxa, botões de ação e ícones de destaque. |
| `color-surface-card`| `theme.brightness == Brightness.dark` | Cards brancos no modo claro / `#1E1E1E` no modo escuro. |
| `color-background`  | `theme.scaffoldBackgroundColor` | Fundo das páginas (`#F8F9FE` no Light / `#121212` no Dark). |

### 2. Espaçamentos (Spacing Tokens)
- `spacing-xs` (`8px`): Margens internas de inputs e pequenos paddings.
- `spacing-md` (`16px`): Distância padrão entre os cartões de tarefas na Home.
- `spacing-lg` (`24px`): Padding lateral das telas e formulários.

### 3. Tipografia (Typography Tokens)
- `font-brand`: Extra Bold (`FontWeight.w900`), Tamanho `24px` (Logo Focus na AppBar).
- `font-title`: Bold (`FontWeight.bold`), Tamanho `18px` a `22px` (Títulos de seções e formulários).
- `font-body`: Normal (`FontWeight.normal`), Tamanho `13px` a `14px` (Notas e descrições).
A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
