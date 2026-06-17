import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/features/categories/viewmodels/category_view_model.dart';
import 'package:focus/features/categories/views/category_form_screen.dart';
import 'package:focus/features/categories/widgets/category_empty_state.dart';
import 'package:focus/shared/widgets/app_bar.dart';
import 'package:focus/shared/widgets/app_drawer.dart';
import 'package:focus/shared/widgets/bottom_navigation_bar.dart';
import 'package:focus/shared/widgets/gesture_navigation.dart';
import 'package:focus/shared/models/trash_drag_data.dart';
import 'package:provider/provider.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  /// MAPEAMENTO DINÂMICO DE ÍCONES E CORES BASEADO NO NOME DA CATEGORIA
  Map<String, dynamic> _getCategoryStyle(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('trabalho') || lowerName.contains('job') || lowerName.contains('trampo')) {
      return {'icon': Icons.business_center_rounded, 'color': Colors.blue};
    } else if (lowerName.contains('estudo') || lowerName.contains('faculdade') || lowerName.contains('escola') || lowerName.contains('aee')) {
      return {'icon': Icons.school_rounded, 'color': Colors.purple};
    } else if (lowerName.contains('saude') || lowerName.contains('academia') || lowerName.contains('treino') || lowerName.contains('medico')) {
      return {'icon': Icons.favorite_rounded, 'color': Colors.redAccent};
    } else if (lowerName.contains('finança') || lowerName.contains('dinheiro') || lowerName.contains('pagamento') || lowerName.contains('conta')) {
      return {'icon': Icons.payments_rounded, 'color': Colors.green};
    } else if (lowerName.contains('pessoal') || lowerName.contains('casa') || lowerName.contains('rotina')) {
      return {'icon': Icons.home_rounded, 'color': Colors.orange};
    } else if (lowerName.contains('lazer') || lowerName.contains('viagem') || lowerName.contains('hobby')) {
      return {'icon': Icons.sports_esports_rounded, 'color': Colors.teal};
    }
    // Fallback padrão elegante caso não dê match em nenhuma palavra-chave
    return {'icon': Icons.folder_special_rounded, 'color': Colors.blueGrey};
  }

  @override
  Widget build(BuildContext context) {
    final categoryVM = context.watch<CategoryViewModel>();
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Define o número de colunas da grade baseado na largura da tela (Responsivo)
    int crossAxisCount = 2;
    if (screenWidth > 600) crossAxisCount = 3;
    if (screenWidth > 900) crossAxisCount = 4;

    return AppGestureNavigation(
      tabIndex: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        drawer: const AppDrawer(),
        appBar: const AppBarWidget(),
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: 2,
          onTrashDrop: (data) => _moveToTrash(context, data, categoryVM),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TÍTULO FLUIDO COM CONTAGEM SUBSIDIÁRIA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categorias',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                        ),
                        if (!categoryVM.isLoading && categoryVM.categories.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${categoryVM.categories.length} total',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ÁREA PRINCIPAL DA GRADE DE CONTEÚDO
                    Expanded(
                      child: categoryVM.isLoading
                          ? Semantics(
                              label: 'Carregando categorias',
                              liveRegion: true,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            )
                          : categoryVM.categories.isEmpty
                              ? const CategoryEmptyState()
                              : GridView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.3, 
                                  ),
                                  itemCount: categoryVM.categories.length,
                                  itemBuilder: (context, index) {
                                    final category = categoryVM.categories[index];
                                    final style = _getCategoryStyle(category.name);
                                    final Color catColor = style['color'];
                                    final IconData catIcon = style['icon'];

                                    // Draggable para a lixeira integrada do seu BottomBar
                                    return Draggable<TrashDragData>(
                                      data: TrashDragData(id: category.id, type: TrashItemType.category),
                                      feedback: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          width: 160,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: catColor.withValues(alpha: 0.9),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(catIcon, color: Colors.white, size: 28),
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.3,
                                        child: _buildCategoryCard(category.name, catColor, catIcon, theme),
                                      ),
                                      child: _buildCategoryCard(category.name, catColor, catIcon, theme),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          tooltip: 'Adicionar nova categoria',
          backgroundColor: theme.colorScheme.primary,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CategoryFormScreen()),
          ),
          icon: const Icon(Icons.add, color: AppColors.onPrimary),
          label: const Text(
            'Nova Categoria',
            style: TextStyle(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  /// CONSTRUTOR DE CARTÃO  
  Widget _buildCategoryCard(String name, Color color, IconData icon, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // MICRO-CONTAINER PARA O ÍCONE (Com fundo tonificado)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          
          // NOME DA CATEGORIA EM DESTAQUE
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  /// Move uma categoria arrastada para a lixeira.
  Future<void> _moveToTrash(
    BuildContext context,
    TrashDragData data,
    CategoryViewModel categoryVM,
  ) async {
    if (data.type != TrashItemType.category) return;
    final success = await categoryVM.removeCategory(data.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          success
              ? 'Categoria movida para a lixeira.'
              : categoryVM.errorMessage ?? 'Erro ao mover categoria.',
        ),
      ),
    );
  }
}