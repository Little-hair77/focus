import 'dart:async';
import 'package:flutter/material.dart';
import 'package:focus/core/services/permission_service.dart';
import 'package:focus/data/repositories/location/contracts/location_repository.dart';
import 'package:focus/data/repositories/sensors/contracts/sensor_repository.dart';
import 'package:focus/features/tasks/models/task_model.dart';

/// Controla o cronômetro de foco, sensor de proximidade e localização final.
class FocusViewModel extends ChangeNotifier {
  /// Serviço usado para validar permissões antes de capturar localização.
  final PermissionService _permissionService;

  /// Repositório usado para obter coordenadas ao concluir foco.
  final LocationRepository _locationRepository;

  /// Repositório usado para escutar o sensor de proximidade.
  final SensorRepository _sensorRepository;

  /// Timer ativo do ciclo de foco.
  Timer? _timer;

  /// Duração configurada para novas sessões.
  int _defaultSessionMinutes = 25;

  /// Segundos restantes no ciclo atual.
  int _secondsRemaining = 25 * 60;

  /// Indica se o cronômetro está rodando.
  bool _isActive = false;

  /// Tarefa vinculada ao ciclo atual.
  Task? _currentTask;

  /// Tarefa atualmente vinculada ao modo foco.
  Task? get currentTask => _currentTask;

  /// Indica se o dispositivo está com proximidade detectada.
  bool _isDeviceFaceDown = false;

  /// Local capturado ao concluir o ciclo de foco.
  Map<String, double>? _completionLocation;

  /// Assinatura da escuta do sensor de proximidade.
  StreamSubscription<bool>? _sensorSubscription;

  /// Define qual tarefa será vinculada ao cronômetro.
  void setTask(Task task) {
    _currentTask = task;
    notifyListeners();
  }

  /// Limpa a tarefa vinculada ao cronômetro.
  void clearTask() {
    _currentTask = null;
    notifyListeners();
  }

  /// Aumenta o tempo em 5 minutos quando o timer está pausado.
  void incrementTime() {
    if (_isActive) return;
    if (_defaultSessionMinutes >= 120) {
      return; // Limite máximo de 2 horas de foco
    }

    _defaultSessionMinutes += 5;
    _secondsRemaining = _defaultSessionMinutes * 60;
    notifyListeners();
  }

  /// Diminui o tempo em 5 minutos quando o timer está pausado.
  void decrementTime() {
    if (_isActive) return;
    if (_defaultSessionMinutes <= 5) {
      return; // Limite mínimo de 5 minutos de foco
    }

    _defaultSessionMinutes -= 5;
    _secondsRemaining = _defaultSessionMinutes * 60;
    notifyListeners();
  }

  FocusViewModel({
    required PermissionService permissionService,
    required LocationRepository locationRepository,
    required SensorRepository sensorRepository,
  }) : _permissionService = permissionService,
       _locationRepository = locationRepository,
       _sensorRepository = sensorRepository {
    _initSensorListener();
  }

  /// Segundos restantes no ciclo atual.
  int get secondsRemaining => _secondsRemaining;

  /// Indica se o cronômetro está ativo.
  bool get isActive => _isActive;

  /// Indica se o sensor detectou proximidade.
  bool get isDeviceFaceDown => _isDeviceFaceDown;

  /// Local capturado ao finalizar o ciclo.
  Map<String, double>? get completionLocation => _completionLocation;

  /// Tempo formatado para exibição no cronômetro.
  String get formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Inicializa a escuta reativa do sensor de proximidade.
  void _initSensorListener() async {
    final hasSensor = await _sensorRepository.hasProximitySensor();
    if (!hasSensor) return;

    // Escuta o fluxo de dados do sensor
    _sensorSubscription = _sensorRepository.onProximityChanged.listen((isNear) {
      _isDeviceFaceDown = isNear;

      if (_isDeviceFaceDown) {
        _startTimer();
      } else {
        _pauseTimer();
      }
      notifyListeners();
    });
  }

  /// Inicia a contagem regressiva do ciclo atual.
  void _startTimer() {
    if (_isActive) return;
    _isActive = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _completeFocusSession();
      }
    });
  }

  /// Pausa a contagem regressiva do ciclo atual.
  void _pauseTimer() {
    _isActive = false;
    _timer?.cancel();
    notifyListeners();
  }

  /// Conclui o ciclo de foco e tenta capturar a localização.
  void _completeFocusSession() async {
    _pauseTimer();

    // ALTERADO: Em vez de voltar fixo para 25, volta para o tempo customizado escolhido
    _secondsRemaining = _defaultSessionMinutes * 60;

    // Trata a permissão antes de buscar o hardware do GPS
    final hasPermission = await _permissionService.hasLocationPermission();
    if (hasPermission) {
      final locationService = await _locationRepository
          .isLocationServiceEnabled();
      if (locationService) {
        _completionLocation = await _locationRepository.getCurrentLocation();
      }
    }

    if (_currentTask != null) {
      debugPrint(
        "🚀 Ciclo concluído com sucesso para a tarefa: ${_currentTask!.title}",
      );

      if (_completionLocation != null) {
        debugPrint(
          "📍 Localização do foco: Lat ${_completionLocation!['latitude']}, Long ${_completionLocation!['longitude']}",
        );
      }

      // TODO: No futuro, poderá chamar o TaskRepository aqui para persistir no Firebase!
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sensorSubscription?.cancel();
    super.dispose();
  }
}
