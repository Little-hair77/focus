import 'package:flutter/material.dart';

/// Painel com informações cadastrais do usuário.
class ProfileInfoPanel extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String formattedCreationDate;

  const ProfileInfoPanel({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.formattedCreationDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
          _ProfileInfoTile(
            icon: Icons.person_outline,
            title: 'Nome de exibição',
            value: userName,
          ),
          _ProfileInfoDivider(theme: theme),
          _ProfileInfoTile(
            icon: Icons.email_outlined,
            title: 'Endereço de E-mail',
            value: userEmail,
          ),
          _ProfileInfoDivider(theme: theme),
          _ProfileInfoTile(
            icon: Icons.calendar_today_outlined,
            title: 'Membro desde',
            value: formattedCreationDate,
          ),
        ],
      ),
    );
  }
}

/// Linha individual de informação do perfil.
class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.iconTheme.color?.withValues(alpha: 0.7)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
    );
  }
}

/// Divisor usado entre linhas do painel de perfil.
class _ProfileInfoDivider extends StatelessWidget {
  final ThemeData theme;

  const _ProfileInfoDivider({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(
        height: 1,
        color: theme.dividerColor.withValues(alpha: 0.1),
      ),
    );
  }
}
