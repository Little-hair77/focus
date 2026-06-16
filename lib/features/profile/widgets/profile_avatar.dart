import 'package:flutter/material.dart';
import 'package:focus/features/profile/viewmodels/profile_view_model.dart';

/// Avatar do perfil com ação para trocar a foto.
class ProfileAvatar extends StatelessWidget {
  final ProfileViewModel profileVM;
  final String userName;
  final String initial;

  const ProfileAvatar({
    super.key,
    required this.profileVM,
    required this.userName,
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  width: 4,
                ),
              ),
              child: CircleAvatar(
                radius: 65,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.08,
                ),
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
        CircleAvatar(
          radius: 20,
          backgroundColor: theme.colorScheme.primary,
          child: IconButton(
            tooltip: 'Alterar foto de perfil',
            icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
            onPressed: () => _showImagePickerOptions(context, profileVM),
          ),
        ),
      ],
    );
  }

  /// Abre as opções de câmera e galeria.
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
}
