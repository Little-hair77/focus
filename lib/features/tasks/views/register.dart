import 'package:flutter/material.dart';

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

  bool loading = false;
  bool obscurePassword = true;

  Future<void> cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conta criada com sucesso 🚀')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro")),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add,
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

                    // NOME
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite seu nome';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // EMAIL
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
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

                    // SENHA
                    TextFormField(
                      controller: _passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite sua senha';
                        }

                        if (value.length < 6) {
                          return 'Senha muito curta';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: loading ? null : cadastrar,
                        child: loading
                            ? const CircularProgressIndicator()
                            : const Text('Cadastrar'),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Já tenho conta'),
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
