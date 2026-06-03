import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:focus/core/services/permission_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final PermissionService _permissionService;
  final ImagePicker _picker = ImagePicker();
  
  File? _imageFile;
  bool _isLoading = false;

  ProfileViewModel({required PermissionService permissionService})
      : _permissionService = permissionService;

  // Getters para a View monitorar o estado
  File? get imageFile => _imageFile;
  bool get isLoading => _isLoading;

  /// Captura uma foto utilizando a câmera do dispositivo
  Future<void> pickImageFromCamera() async {
    _setLoading(true);
    try {
      // Opcional: Validar permissão de câmera via _permissionService se necessário
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // Otimiza o tamanho do arquivo
      );

      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Erro ao acessar a câmera: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Seleciona uma imagem existente na galeria de fotos
  Future<void> pickImageFromGallery() async {
    _setLoading(true);
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Erro ao acessar a galeria: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}