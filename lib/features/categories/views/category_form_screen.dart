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

/// Formulário usado para criar ou editar categorias com seleção dinâmica de ícones.
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
  late IconData _selectedIcon; 

  bool _isSaving = false;

  /// BANCO DE ÍCONES DISPONÍVEIS PARA O USUÁRIO ESCOLHER
  static const List<IconData> _availableIcons = [
    Icons.folder_rounded,
    Icons.business_center_rounded,
    Icons.school_rounded,
    Icons.favorite_rounded,
    Icons.payments_rounded,
    Icons.home_rounded,
    Icons.sports_esports_rounded,
    Icons.fitness_center_rounded,
    Icons.code_rounded,
    Icons.flight_takeoff_rounded,
    Icons.shopping_cart_rounded,
    Icons.restaurant_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _selectedColor = widget.category?.color ?? CategoryPalette.fallback;
    
    // Converte a String? do modelo de volta para int para montar o IconData
    final int? savedCodePoint = widget.category?.icon != null 
        ? int.tryParse(widget.category!.icon!) 
        : null;

    _selectedIcon = savedCodePoint != null 
        ? IconData(savedCodePoint, fontFamily: 'MaterialIcons')
        : _availableIcons.first;
    
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Persiste a categoria criada ou editada.
  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final categoryVM = context.read<CategoryViewModel>();
    
    final category = Category(
      id: widget.category?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      color: _selectedColor,
      icon: _selectedIcon.codePoint.toString(), // Transforma o int em String?
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
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(categoryVM.errorMessage ?? 'Erro ao salvar.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.category != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    final currentPreviewColor = CategoryPalette.parse(_selectedColor);

    return AppGestureNavigation(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBarWidget(
          leading: IconButton(
            tooltip: 'Voltar',
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
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
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Ajustar Categoria' : 'Nova Categoria',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Agrupe suas tarefas para manter o foco por nicho.",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 28),

                    // LIVE PREVIEW CARD 
                    const Text(
                      "PRÉ-VISUALIZAÇÃO",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 10),
                    _buildLivePreviewCard(_nameController.text, currentPreviewColor, _selectedIcon, theme),
                    const SizedBox(height: 28),

                    // NOME DA CATEGORIA
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.label_outline_rounded, size: 18, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              const Text(
                                "Como se chamará?",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            maxLength: 25,
                            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                            decoration: appInputDecoration(
                              context,
                              label: 'Ex: Trabalho, Estudos, Saúde...',
                              icon: Icons.edit_rounded,
                            ),
                            validator: (value) => value == null || value.trim().isEmpty
                                ? 'Insira um nome para a categoria'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SELEÇÃO DE ÍCONE CUSTOMIZADO
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(_selectedIcon, size: 18, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              const Text(
                                "Símbolo da Categoria",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Wrap(
                              spacing: 14,
                              runSpacing: 14,
                              children: _availableIcons.map((iconData) {
                                final isSelected = _selectedIcon.codePoint == iconData.codePoint;

                                return InkWell(
                                  onTap: () => setState(() => _selectedIcon = iconData),
                                  borderRadius: BorderRadius.circular(14),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? currentPreviewColor.withValues(alpha: 0.15)
                                          : theme.dividerColor.withValues(alpha: 0.03),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected ? currentPreviewColor : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      iconData,
                                      color: isSelected ? currentPreviewColor : theme.colorScheme.onSurfaceVariant,
                                      size: 22,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // PALETA DE CORES VISUAL
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.palette_outlined, size: 18, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              const Text(
                                "Identidade Visual",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Wrap(
                              spacing: 14,
                              runSpacing: 14,
                              children: CategoryPalette.colors.map((color) {
                                final selected = _selectedColor == color;
                                final displayColor = CategoryPalette.parse(color);

                                return Semantics(
                                  button: true,
                                  selected: selected,
                                  label: selected ? 'Cor $color selecionada' : 'Selecionar cor $color',
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedColor = color),
                                    borderRadius: BorderRadius.circular(24),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: displayColor,
                                        shape: BoxShape.circle,
                                        boxShadow: selected
                                            ? [
                                                BoxShadow(
                                                  color: displayColor.withValues(alpha: 0.35),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : null,
                                        border: selected
                                            ? Border.all(
                                                color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                                                width: 3,
                                              )
                                            : null,
                                      ),
                                      child: selected
                                          ? Icon(
                                              Icons.check,
                                              color: theme.brightness == Brightness.dark && displayColor == Colors.white
                                                  ? Colors.black
                                                  : Colors.white,
                                              size: 18,
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
                    const SizedBox(height: 36),

                    // BOTÃO DE CONFIRMAÇÃO 
                    Center(
                      child: Container(
                        width: isWideScreen ? 350 : double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: _isSaving
                                ? [Colors.grey, Colors.grey]
                                : [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withValues(alpha: 0.8),
                                  ],
                          ),
                          boxShadow: !_isSaving
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isSaving
                              ? Semantics(
                                  label: 'Salvando categoria',
                                  liveRegion: true,
                                  child: const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  ),
                                )
                              : Text(
                                  isEditing ? 'SALVAR ALTERAÇÕES' : 'CRIAR CATEGORIA',
                                  style: const TextStyle(
                                    color: AppColors.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
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

  /// LIVE PREVIEW CARD REATIVO COM SUPORTE A ÍCONE DINÂMICO
  Widget _buildLivePreviewCard(String text, Color color, IconData icon, ThemeData theme) {
    final cleanText = text.trim().isEmpty ? 'Nome da Categoria' : text;
    return Container(
      width: 180,
      height: 110,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Icon(Icons.more_vert_rounded, size: 18, color: Colors.grey),
            ],
          ),
          Text(
            cleanText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: text.trim().isEmpty ? Colors.grey : theme.textTheme.bodyLarge?.color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}