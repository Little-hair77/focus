import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/core/theme/category_palette.dart';
import 'package:focus/features/categories/models/category_model.dart';
import 'package:focus/features/categories/viewmodels/category_view_model.dart';
import 'package:focus/shared/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:focus/shared/widgets/app_input_decoration.dart';
import 'package:focus/shared/widgets/gesture_navigation.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;

  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedColor;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _selectedColor = widget.category?.color ?? CategoryPalette.fallback;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final categoryVM = context.read<CategoryViewModel>();
    final category = Category(
      id: widget.category?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      color: _selectedColor,
      icon: widget.category?.icon,
      createdAt: widget.category?.createdAt ?? DateTime.now(),
    );

    final success = widget.category == null
        ? await categoryVM.addCategory(category)
        : await categoryVM.editCategory(category);

    if (!mounted) return;

    setState(() => _isSaving = false);
    if (success) {
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(categoryVM.errorMessage ?? 'Erro ao salvar.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.category != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return AppGestureNavigation(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBarWidget(
          leading: IconButton(
            tooltip: 'Voltar',
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.onPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWideScreen ? 520 : double.infinity,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Títulos principais alinhados com o padrão do app
                    Text(
                      isEditing ? 'Ajustar Categoria' : 'Nova Categoria',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: theme.textTheme.titleLarge?.color,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "Agrupe suas tarefas para manter o foco por nicho.",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    // Identificação (CONTAINER CLEAN)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.label_outline_rounded,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Como se chamará?",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            maxLength: 25,
                            buildCounter:
                                (
                                  context, {
                                  required currentLength,
                                  required isFocused,
                                  maxLength,
                                }) => null,
                            decoration: appInputDecoration(
                              context,
                              label: 'Ex: Trabalho, Estudos, Saúde...',
                              icon: Icons.category_rounded,
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Insira um nome para a categoria'
                                : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Paleta de Cores Visual
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.palette_outlined,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Identidade Visual",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              // Indicador reativo da cor escolhida
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: CategoryPalette.parse(_selectedColor),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Wrap(
                              spacing: 14,
                              runSpacing: 14,
                              children: CategoryPalette.colors.map((color) {
                                final selected = _selectedColor == color;
                                final displayColor = CategoryPalette.parse(
                                  color,
                                );

                                return Semantics(
                                  button: true,
                                  selected: selected,
                                  label: selected
                                      ? 'Cor $color selecionada'
                                      : 'Selecionar cor $color',
                                  child: InkWell(
                                    onTap: () =>
                                        setState(() => _selectedColor = color),
                                    borderRadius: BorderRadius.circular(24),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: displayColor,
                                        shape: BoxShape.circle,
                                        boxShadow: selected
                                            ? [
                                                BoxShadow(
                                                  color: displayColor
                                                      .withValues(alpha: 0.4),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                        border: selected
                                            ? Border.all(
                                                color:
                                                    theme.brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : theme.colorScheme.primary,
                                                width: 3,
                                              )
                                            : null,
                                      ),
                                      child: selected
                                          ? Icon(
                                              Icons.check,
                                              color:
                                                  theme.brightness ==
                                                          Brightness.dark &&
                                                      displayColor ==
                                                          Colors.white
                                                  ? Colors.black
                                                  : Colors.white,
                                              size: 20,
                                            )
                                          : null,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Botão de Confirmação com Gradiente e Feedback de Saving
                    Center(
                      child: Container(
                        width: isWideScreen ? 350 : double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: _isSaving
                                ? [Colors.grey, Colors.grey[400]!]
                                : [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary.withValues(
                                      alpha: 0.85,
                                    ),
                                  ],
                          ),
                          boxShadow: !_isSaving
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveCategory,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isSaving
                              ? Semantics(
                                  label: 'Salvando categoria',
                                  liveRegion: true,
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                )
                              : Text(
                                  isEditing
                                      ? 'SALVAR ALTERAÇÕES'
                                      : 'CRIAR CATEGORIA',
                                  style: const TextStyle(
                                    color: AppColors.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                  ),
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
