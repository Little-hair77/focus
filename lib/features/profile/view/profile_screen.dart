import 'package:flutter/material.dart';
import 'package:focus/features/profile/models/access_log.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:focus/features/profile/viewmodels/profile_view_model.dart';
import 'package:focus/features/auth/viewmodels/auth_view_model.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/shared/widgets/gesture_navigation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Abre o menu de opções inferior (BottomSheet) com estilo mobile nativo
  void _showImagePickerOptions(
    BuildContext context,
    ProfileViewModel profileVM,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Wrap(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Escolher da Galeria'),
                  onTap: () {
                    Navigator.of(context).pop();
                    profileVM.pickImageFromGallery();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Tirar Nova Foto'),
                  onTap: () {
                    Navigator.of(context).pop();
                    profileVM.pickImageFromCamera();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileVM = context.watch<ProfileViewModel>();
    final authVM = context.watch<AuthViewModel>();

    // Obtém dados cadastrais direto do seu AuthViewModel/UserModel existente
    final userName = authVM.userName ?? 'Usuário';
    final userEmail = authVM.userEmail ?? '';
    final initial = userName.trim().isEmpty ? 'U' : userName[0].toUpperCase();

    // Captura e formata a data de criação do usuário (DD/MM/AAAA)
    String formattedCreationDate = 'Não informada';
    if (authVM.currentUser?.createdAt != null) {
      final date = authVM.currentUser!.createdAt;
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      formattedCreationDate = '$day/$month/$year';
    }

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

                // SEÇÃO AVATAR (FOTO DE PERFIL REATIVA)
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Semantics(
                      image: true,
                      label: profileVM.imageFile == null
                          ? 'Avatar de $userName com inicial $initial'
                          : 'Foto de perfil de $userName',
                      child: ExcludeSemantics(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.2,
                              ),
                              width: 4,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 65,
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.08),
                            backgroundImage: profileVM.imageFile != null
                                ? FileImage(profileVM.imageFile!)
                                : null,
                            child: profileVM.imageFile == null
                                ? Text(
                                    initial,
                                    style: TextStyle(
                                      fontSize: 44,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),

                    // Botão Flutuante Estilizado para Trocar/Adicionar Foto
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.primary,
                      child: IconButton(
                        tooltip: 'Alterar foto de perfil',
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: () =>
                            _showImagePickerOptions(context, profileVM),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Indicador de Progresso sutil enquanto o arquivo de foto é processado
                if (profileVM.isLoading) ...[
                  Semantics(
                    label: 'Processando foto de perfil',
                    liveRegion: true,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Nome em destaque abaixo da foto
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                // Painel de Informações do Usuário (CARD CLEAN)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Informações Pessoais',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.person_outline,
                          color: theme.iconTheme.color?.withValues(alpha: 0.7),
                        ),
                        title: const Text(
                          'Nome de exibição',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        subtitle: Text(
                          userName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(
                          height: 1,
                          color: theme.dividerColor.withValues(alpha: 0.1),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.email_outlined,
                          color: theme.iconTheme.color?.withValues(alpha: 0.7),
                        ),
                        title: const Text(
                          'Endereço de E-mail',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        subtitle: Text(
                          userEmail,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(
                          height: 1,
                          color: theme.dividerColor.withValues(alpha: 0.1),
                        ),
                      ),
                      // 🚀 NOVO: Item de lista exibindo a data de criação da conta
                      ListTile(
                        leading: Icon(
                          Icons.calendar_today_outlined,
                          color: theme.iconTheme.color?.withValues(alpha: 0.7),
                        ),
                        title: const Text(
                          'Membro desde',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        subtitle: Text(
                          formattedCreationDate,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Últimos acessos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _AccessTimeline(profileVM: profileVM),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccessTimeline extends StatelessWidget {
  final ProfileViewModel profileVM;

  const _AccessTimeline({required this.profileVM});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (profileVM.isLoadingAccessLogs) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      );
    }

    if (profileVM.accessLogsError != null) {
      return _AccessMessageCard(
        icon: Icons.error_outline,
        message: profileVM.accessLogsError!,
        action: TextButton(
          onPressed: profileVM.fetchAccessLogs,
          child: const Text('Tentar novamente'),
        ),
      );
    }

    if (profileVM.accessLogs.isEmpty) {
      return const _AccessMessageCard(
        icon: Icons.history,
        message: 'Nenhum acesso registrado.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          for (var index = 0; index < profileVM.accessLogs.length; index++)
            _AccessTimelineItem(
              accessLog: profileVM.accessLogs[index],
              isLast: index == profileVM.accessLogs.length - 1,
            ),
        ],
      ),
    );
  }
}

class _AccessTimelineItem extends StatelessWidget {
  final AccessLog accessLog;
  final bool isLast;

  const _AccessTimelineItem({required this.accessLog, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accessedAt = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(accessLog.accessedAt.toLocal());
    final coordinates = accessLog.hasLocation
        ? 'Lat. ${accessLog.latitude!.toStringAsFixed(6)}  •  '
              'Long. ${accessLog.longitude!.toStringAsFixed(6)}'
        : 'Localização indisponível';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 52,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                    border: Border.all(color: theme.cardColor, width: 3),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accessedAt,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        accessLog.hasLocation
                            ? Icons.location_on_outlined
                            : Icons.location_off_outlined,
                        size: 17,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          coordinates,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessMessageCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final Widget? action;

  const _AccessMessageCard({
    required this.icon,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          ?action,
        ],
      ),
    );
  }
}
