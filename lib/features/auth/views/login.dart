import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/shared/widgets/app_input_decoration.dart';
import 'package:focus/shared/widgets/gesture_navigation.dart';
import 'package:provider/provider.dart';
import 'package:focus/features/auth/viewmodels/auth_view_model.dart';

/// Tela de login por e-mail e senha.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// Estado do formulário de login.
class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  /// Valida o formulário e tenta autenticar o usuário.
  Future<void> _efetuarLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();

    final sucesso = await authVM.login(
      _emailController.text,
      _senhaController.text,
    );

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login realizado com sucesso 🚀')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(authVM.errorMessage ?? 'Erro ao entrar.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authVM = context.watch<AuthViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return AppGestureNavigation(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Row(
            children: [
              // COLUNA DA ESQUERDA: Só aparece em telas grandes (Desktop)
              if (isDesktop)
                Expanded(
                  flex: 1,
                  child: Container(
                    color: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Semantics(
                          image: true,
                          label: 'Logo do Focus',
                          child: Image.asset(
                            'assets/images/focusLogo2.png',
                            width: 500,
                            height: 500,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Centralize seus objetivos, maximize seus resultados.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.onPrimary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // COLUNA DA DIREITA: Formulário de Login (Mobile e Desktop)
              Expanded(
                flex: 1,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 24.0,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (!isDesktop) ...[
                              Semantics(
                                image: true,
                                label: 'Logo do Focus',
                                child: Image.asset(
                                  'assets/images/focusLogo.png',
                                  width: 500,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(0, -10),
                                child: Text(
                                  'Organize suas tarefas com clareza',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textMediumEmphasis,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            if (isDesktop) ...[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Boas-vindas de volta!',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],

                            // Input de Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: appInputDecoration(
                                context,
                                label: 'Email',
                                icon: Icons.email_outlined,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Digite seu email';
                                }
                                if (!value.contains('@')) {
                                  return 'Email inválido';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Input de Senha
                            TextFormField(
                              controller: _senhaController,
                              obscureText: obscurePassword,
                              decoration:
                                  appInputDecoration(
                                    context,
                                    label: 'Senha',
                                    icon: Icons.lock_outline_rounded,
                                  ).copyWith(
                                    suffixIcon: Semantics(
                                      label: obscurePassword
                                          ? 'Mostrar senha'
                                          : 'Ocultar senha',
                                      hint:
                                          'Toque duas vezes para alternar a visibilidade da senha',
                                      button: true,
                                      child: IconButton(
                                        tooltip: obscurePassword
                                            ? 'Mostrar senha'
                                            : 'Ocultar senha',
                                        icon: Icon(
                                          obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                        onPressed: () => setState(
                                          () => obscurePassword =
                                              !obscurePassword,
                                        ),
                                      ),
                                    ),
                                  ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Digite sua senha';
                                }
                                if (value.length < 6) {
                                  return 'A senha deve ter no mínimo 6 caracteres';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),

                            // Botão de Entrar
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: Semantics(
                                label: 'Entrar no aplicativo',
                                hint:
                                    'Verifica as credenciais inseridas e inicia sua sessão',
                                button: true,
                                child: ElevatedButton(
                                  onPressed: authVM.isLoading
                                      ? null
                                      : _efetuarLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: authVM.isLoading
                                      ? Semantics(
                                          label: 'Autenticando acesso',
                                          liveRegion: true,
                                          child:
                                              const CircularProgressIndicator(
                                                color: AppColors.onPrimary,
                                              ),
                                        )
                                      : const Text(
                                          'ENTRAR',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Divisor visual
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    'ou continue com',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textMediumEmphasis,
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Botão Google
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: Semantics(
                                label: 'Entrar com Google',
                                hint:
                                    'Abre a autenticação com sua conta Google',
                                button: true,
                                child: OutlinedButton.icon(
                                  onPressed: authVM.isLoading
                                      ? null
                                      : () async {
                                          final sucesso = await authVM
                                              .signInWithGoogle();
                                          if (!context.mounted) return;
                                          if (sucesso) {
                                            Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              '/home',
                                              (route) => false,
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  authVM.errorMessage ??
                                                      'Erro ao entrar com Google.',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: theme.colorScheme.outline,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: Image.asset(
                                    'assets/images/logoGoogle.png',
                                    width: 22,
                                    height: 22,
                                  ),
                                  label: const Text(
                                    'Entrar com Google',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Link de Cadastro
                            Semantics(
                              label: 'Ir para tela de criação de conta',
                              hint:
                                  'Abre o formulário para se cadastrar como novo usuário no Focus',
                              button: true,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: Text(
                                  'Não tem uma conta? Criar conta',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
