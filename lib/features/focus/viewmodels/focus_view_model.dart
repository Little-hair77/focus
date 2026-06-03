import 'dart:async';
import 'package:flutter/material.dart';
import 'package:focus/core/services/permission_service.dart';
import 'package:focus/data/repositories/location/contracts/location_repository.dart';
import 'package:focus/data/repositories/sensors/contracts/sensor_repository.dart';
import 'package:focus/features/tasks/models/task_model.dart';

class FocusViewModel extends ChangeNotifier {
  final PermissionService _permissionService;
  final LocationRepository _locationRepository;
  final SensorRepository _sensorRepository;

  // Estados do Cronômetro
  Timer? _timer;
  int _defaultSessionMinutes = 25; 
  int _secondsRemaining = 25 * 60; 
  bool _isActive = false;
  Task? _currentTask;

  Task? get currentTask => _currentTask;

  // Estado do Sensor e GPS
  bool _isDeviceFaceDown = false;
  Map<String, double>? _completionLocation;
  StreamSubscription<bool>? _sensorSubscription;

  // Define qual tarefa será vinculada ao cronometro
  void setTask(Task task){
    _currentTask = task;
    notifyListeners();
  }

  // Limpa a tarefa se o usuário sair do modo foco
  void clearTask(){
    _currentTask = null;
    notifyListeners();
  }

  /// Aumenta o tempo em 5 minutos (Apenas se o timer estiver pausado)
  void incrementTime() {
    if (_isActive) return;
    if (_defaultSessionMinutes >= 120) return; // Limite máximo de 2 horas de foco
    
    _defaultSessionMinutes += 5;
    _secondsRemaining = _defaultSessionMinutes * 60;
    notifyListeners();
  }

  /// Diminui o tempo em 5 minutos (Apenas se o timer estiver pausado)
  void decrementTime() {
    if (_isActive) return;
    if (_defaultSessionMinutes <= 5) return; // Limite mínimo de 5 minutos de foco
    
    _defaultSessionMinutes -= 5;
    _secondsRemaining = _defaultSessionMinutes * 60;
    notifyListeners();
  }

  FocusViewModel({
    required PermissionService permissionService,
    required LocationRepository locationRepository,
    required SensorRepository sensorRepository,
  })  : _permissionService = permissionService,
        _locationRepository = locationRepository,
        _sensorRepository = sensorRepository {
    _initSensorListener();
  }

  // Getters para a View consumir de forma segura
  int get secondsRemaining => _secondsRemaining;
  bool get isActive => _isActive;
  bool get isDeviceFaceDown => _isDeviceFaceDown;
  Map<String, double>? get completionLocation => _completionLocation;

  String get formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Inicializa a escuta reativa do sensor de proximidade
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

  void _pauseTimer() {
    _isActive = false;
    _timer?.cancel();
    notifyListeners();
  }

  /// Sessão finalizada com sucesso! Captura o GPS
  void _completeFocusSession() async {
    _pauseTimer();
    
    // ALTERADO: Em vez de voltar fixo para 25, volta para o tempo customizado escolhido
    _secondsRemaining = _defaultSessionMinutes * 60; 

    // Trata a permissão antes de buscar o hardware do GPS
    final hasPermission = await _permissionService.hasLocationPermission();
    if (hasPermission) {
      final locationService = await _locationRepository.isLocationServiceEnabled();
      if (locationService) {
        _completionLocation = await _locationRepository.getCurrentLocation();
      }
    }
    
    if (_currentTask != null) {
      debugPrint("🚀 Ciclo concluído com sucesso para a tarefa: ${_currentTask!.title}");
      
      if (_completionLocation != null) {
        debugPrint("📍 Localização do foco: Lat ${_completionLocation!['latitude']}, Long ${_completionLocation!['longitude']}");
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