import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:focus/data/repositories/access_log_repository.dart';
import 'package:focus/features/profile/models/access_log.dart';

/// Controla foto de perfil e histórico de acessos do usuário.
class ProfileViewModel extends ChangeNotifier {
  /// Repositório usado para carregar os registros de acesso.
  final AccessLogRepository _accessLogRepository;

  /// Picker usado para câmera e galeria.
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  bool _isLoading = false;
  bool _isLoadingAccessLogs = false;
  String? _accessLogsError;
  String? _userId;
  int _accessLogVersion = 0;
  List<AccessLog> _accessLogs = [];

  ProfileViewModel({required AccessLogRepository accessLogRepository})
    : _accessLogRepository = accessLogRepository;

  /// Arquivo local da foto escolhida.
  File? get imageFile => _imageFile;

  /// Indica se uma imagem está sendo processada.
  bool get isLoading => _isLoading;

  /// Indica se o histórico de acessos está carregando.
  bool get isLoadingAccessLogs => _isLoadingAccessLogs;

  /// Mensagem de erro ao carregar acessos.
  String? get accessLogsError => _accessLogsError;

  /// Histórico de acessos recente do usuário.
  List<AccessLog> get accessLogs => List.unmodifiable(_accessLogs);

  /// Sincroniza o viewmodel com usuário e versão da auditoria.
  void syncUser(String? userId, {int accessLogVersion = 0}) {
    final userChanged = _userId != userId;
    final accessLogChanged = _accessLogVersion != accessLogVersion;
    if (!userChanged && !accessLogChanged) return;

    _userId = userId;
    _accessLogVersion = accessLogVersion;
    if (userChanged) {
      _accessLogs = [];
    }
    _accessLogsError = null;
    _isLoadingAccessLogs = false;
    notifyListeners();

    if (userId != null) {
      Future.microtask(fetchAccessLogs);
    }
  }

  /// Carrega os acessos recentes do usuário ativo.
  Future<void> fetchAccessLogs() async {
    final userId = _userId;
    if (userId == null) return;

    _isLoadingAccessLogs = true;
    _accessLogsError = null;
    notifyListeners();

    try {
      final accessLogs = await _accessLogRepository.getRecentAccessLogs(userId);
      if (_userId != userId) return;
      _accessLogs = accessLogs;
    } catch (error) {
      if (_userId != userId) return;
      _accessLogsError = 'Não foi possível carregar o histórico de acessos.';
      debugPrint('Erro ao carregar auditoria de acessos: $error');
    } finally {
      if (_userId == userId) {
        _isLoadingAccessLogs = false;
        notifyListeners();
      }
    }
  }

  /// Abre a câmera e armazena a foto escolhida.
  Future<void> pickImageFromCamera() async {
    _setLoading(true);
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
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

  /// Abre a galeria e armazena a foto escolhida.
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

  /// Atualiza o estado de carregamento da foto.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
