import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/features/auth/viewmodels/auth_view_model.dart';
import 'package:focus/features/profile/viewmodels/profile_view_model.dart';
import 'package:focus/features/profile/widgets/access_timeline.dart';
import 'package:focus/features/profile/widgets/profile_avatar.dart';
import 'package:focus/features/profile/widgets/profile_info_panel.dart';
import 'package:focus/shared/widgets/gesture_navigation.dart';
import 'package:provider/provider.dart';

/// Tela de perfil do usuário e histórico de acessos.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileVM = context.watch<ProfileViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final userName = authVM.userName ?? 'Usuário';
    final userEmail = authVM.userEmail ?? '';
    final initial = userName.trim().isEmpty ? 'U' : userName[0].toUpperCase();
    final formattedCreationDate = _formatCreationDate(authVM);

    return AppGestureNavigation(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'Meu Perfil',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.onPrimary,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: AppColors.onPrimary,
          iconTheme: const IconThemeData(color: AppColors.onPrimary),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 16),
                ProfileAvatar(
                  profileVM: profileVM,
                  userName: userName,
                  initial: initial,
                ),
                const SizedBox(height: 24),
                if (profileVM.isLoading) ...[
                  Semantics(
                    label: 'Processando foto de perfil',
                    liveRegion: true,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                _ProfileSectionTitle('Informações Pessoais'),
                const SizedBox(height: 12),
                ProfileInfoPanel(
                  userName: userName,
                  userEmail: userEmail,
                  formattedCreationDate: formattedCreationDate,
                ),
                const SizedBox(height: 32),
                _ProfileSectionTitle('Últimos acessos'),
                const SizedBox(height: 12),
                AccessTimeline(profileVM: profileVM),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Formata a data de criação da conta para exibição.
  String _formatCreationDate(AuthViewModel authVM) {
    final date = authVM.currentUser?.createdAt;
    if (date == null) return 'Não informada';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

/// Título padrão das seções do perfil.
class _ProfileSectionTitle extends StatelessWidget {
  final String title;

  const _ProfileSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
