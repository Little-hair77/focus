import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:focus/features/auth/viewmodels/auth_view_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;

  InputDecoration _inputStyle(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: theme.colorScheme.primary.withValues(alpha: 0.7),
      ),
      filled: true,
      fillColor: theme.colorScheme.primary.withValues(alpha: 0.05),
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

  Future<void> _efetuarCadastro() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();

    final sucesso = await authVM.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );

    if (sucesso && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso 🚀')),
      );
      // Redireciona direto para a Home, limpando a pilha de telas
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add_rounded,
                      size: 90,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Criar Conta',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),

                    TextFormField(
                      controller: _nameController,
                      decoration: _inputStyle(
                        context,
                        'Nome',
                        Icons.person_outline,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Digite seu nome'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputStyle(
                        context,
                        'Email',
                        Icons.email_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite seu email';
                        }
                        if (!value.contains('@')) return 'Email inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _passwordController,
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
                      validator: (value) =>
                          value == null || value.isEmpty || value.length < 6
                          ? 'A senha deve ter no mínimo 6 caracteres'
                          : null,
                    ),
                    const SizedBox(height: 32),

                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: authVM.isLoading ? null : _efetuarCadastro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.transparent,
                          shadowColor: AppColors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: authVM.isLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.onPrimary,
                              )
                            : const Text(
                                'CADASTRAR',
                                style: TextStyle(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.bold,
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
    );
  }
}
