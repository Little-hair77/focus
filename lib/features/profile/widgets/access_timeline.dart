import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/features/profile/models/access_log.dart';
import 'package:focus/features/profile/viewmodels/profile_view_model.dart';
import 'package:intl/intl.dart';

/// Timeline dos acessos recentes do usuário.
class AccessTimeline extends StatelessWidget {
  final ProfileViewModel profileVM;

  const AccessTimeline({super.key, required this.profileVM});

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

/// Item individual da timeline de acesso.
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

/// Card de mensagem usado para erro ou estado vazio da timeline.
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
