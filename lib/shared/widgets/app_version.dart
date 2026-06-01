import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersion extends StatelessWidget {
  const AppVersion({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version;
        return Text(
          version == null ? 'Focus App' : 'Focus App v$version',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        );
      },
    );
  }
}
