import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focus/features/focus/viewmodels/focus_view_model.dart';
import 'package:focus/data/repositories/sensors/contracts/sensor_repository.dart';
import 'package:focus/data/repositories/sensors/mock_sensor_repository.dart';

class FocusModeScreen extends StatelessWidget {
  const FocusModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta os estados do cronômetro e do sensor
    final focusVM = context.watch<FocusViewModel>();
    
    // Captura a instância do repositório para podermos simular o clique no Chrome
    final sensorRepo = context.read<SensorRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Foco'),
        centerTitle: true,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        // O fundo fica suavemente escuro se o "celular estiver virado na mesa"
        color: focusVM.isDeviceFaceDown 
            ? Colors.black87 
            : Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone Indicador de Estado do Sensor
              Icon(
                focusVM.isDeviceFaceDown ? Icons.phone_android : Icons.screen_lock_portrait,
                size: 80,
                color: focusVM.isDeviceFaceDown ? Colors.green : Colors.grey,
              ),
              const SizedBox(height: 16),
              
              // Texto de Orientação ao Usuário
              Text(
                focusVM.isDeviceFaceDown 
                    ? 'Dispositivo virado! Foco Ativo.' 
                    : 'Vire o celular para baixo para iniciar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: focusVM.isDeviceFaceDown ? Colors.green : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 40),

              // O CRONÔMETRO REATIVO (Estilo Pomodoro)
              Text(
                focusVM.formattedTime,
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: focusVM.isDeviceFaceDown ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 20),

              // Indicador de Status do Timer
              Chip(
                label: Text(focusVM.isActive ? 'CONTANDO...' : 'PAUSADO'),
                backgroundColor: focusVM.isActive ? Colors.amber[100] : Colors.grey[300],
              ),
              
              const SizedBox(height: 60),
              const Divider(),
              const SizedBox(height: 10),

              // 🧪 PAINEL EXCLUSIVO DE TESTE (Para simulação no Chrome)
              Text(
                'Ambiente de Testes (Web/Chrome)',
                style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 12),
              
              ElevatedButton.icon(
                icon: const Icon(Icons.touch_app),
                label: Text(focusVM.isDeviceFaceDown 
                    ? 'Simular: Desvirar Celular' 
                    : 'Simular: Virar Celular na Mesa'
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: focusVM.isDeviceFaceDown ? Colors.red[400] : Colors.blue[400],
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Aqui acontece o gatilho lógico no Mock!
                  if (sensorRepo is MockSensorRepository) {
                    sensorRepo.simulateSensorTrigger();
                  }
                },
              ),
              
              // Feedback de geolocalização ao terminar o ciclo
              // Feedback de geolocalização ao terminar o ciclo
              if (focusVM.completionLocation != null) ...[
                const SizedBox(height: 20),
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: double.infinity, // 👈 Agora o width está no lugar certo (SizedBox)
                      child: Text(
                        '📍 Último ciclo salvo em:\nLat: ${focusVM.completionLocation!['latitude']}\nLong: ${focusVM.completionLocation!['longitude']}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}