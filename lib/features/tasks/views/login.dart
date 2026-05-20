import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool loading = false;
  bool obscurePassword = true;

  // Estilo dos campos seguindo os Design Tokens roxos do projeto Focus
  InputDecoration _inputStyle(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: theme.colorScheme.primary.withOpacity(0.7)),
      filled: true,
      fillColor: theme.colorScheme.primary.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      floatingLabelStyle: TextStyle(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Future<void> fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login realizado com sucesso 🚀')),
    );

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Se a largura for maior que 800px, dividimos a teça é dividida
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Row(
          children: [
            // COLUNA DA ESQUERDA: Só aparece em telas grandes (Computador/Tablet largo)
            if (isDesktop)
              Expanded(
                flex: 1,
                child: Container(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 120,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Focus',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Centralize seus objetivos, maximize seus resultados.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // COLUNA DA DIREITA: O formulário de Login (Aparece em todos os dispositivos)
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
                          // Se for celular, a logo e os textos aparecem em cima do form
                          if (!isDesktop) ...[
                            Icon(
                              Icons.task_alt,
                              size: 80,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Focus',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Organize suas tarefas com clareza',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 40),
                          ],

                          if (isDesktop) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Boas-vindas de volta!',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],

                          // Input de Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputStyle(
                              context,
                              'Email',
                              Icons.email_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Digite seu email';
                              if (!value.contains('@')) return 'Email inválido';
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Input de Senha
                          TextFormField(
                            controller: _senhaController,
                            obscureText: obscurePassword,
                            decoration:
                                _inputStyle(
                                  context,
                                  'Senha',
                                  Icons.lock_outline_rounded,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () => setState(
                                      () => obscurePassword = !obscurePassword,
                                    ),
                                  ),
                                ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Digite sua senha';
                              if (value.length < 6)
                                return 'A senha deve ter no mínimo 6 caracteres';
                              return null;
                            },
                          ),

                          const SizedBox(height: 32),

                          // Botão de Entrada
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withOpacity(0.8),
                                ],
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: loading ? null : fazerLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'ENTRAR',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          TextButton(
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
    );
  }
}
