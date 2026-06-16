import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focus/features/focus/viewmodels/focus_view_model.dart';
import 'package:focus/shared/widgets/gesture_navigation.dart';

class FocusModeScreen extends StatelessWidget {
  const FocusModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta em tempo real os estados reativos do cronômetro, sensor e tarefa
    final focusVM = context.watch<FocusViewModel>();
    final theme = Theme.of(context);

    return AppGestureNavigation(
      child: Scaffold(
        appBar: AppBar(title: const Text('Modo Foco'), centerTitle: true),
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          // O fundo fica suavemente escuro se o sensor detectar o celular virado na mesa
          color: focusVM.isDeviceFaceDown
              ? Colors.black87
              : theme.scaffoldBackgroundColor,
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (focusVM.currentTask != null) ...[
                  Text(
                    'Focando em:',
                    style: TextStyle(
                      fontSize: 14,
                      color: focusVM.isDeviceFaceDown
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    focusVM.currentTask!.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: focusVM.isDeviceFaceDown
                          ? Colors.white
                          : theme.textTheme.titleLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                ],

                // Ícone Indicador de Estado do Sensor Físico
                Semantics(
                  image: true,
                  label: focusVM.isDeviceFaceDown
                      ? 'Celular virado para baixo. Foco ativo.'
                      : 'Celular em uso. Foco pausado.',
                  liveRegion: true,
                  child: ExcludeSemantics(
                    child: Icon(
                      focusVM.isDeviceFaceDown
                          ? Icons.phone_android
                          : Icons.screen_lock_portrait,
                      size: 80,
                      color: focusVM.isDeviceFaceDown
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Texto de Orientação ao Usuário Mobile
                Text(
                  focusVM.isDeviceFaceDown
                      ? 'Dispositivo virado! Foco Ativo.'
                      : 'Vire o celular para baixo na mesa para iniciar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: focusVM.isDeviceFaceDown
                        ? Colors.green
                        : Colors.grey[750],
                  ),
                ),
                const SizedBox(height: 40),

                // O CRONÔMETRO REATIVO (Estilo Pomodoro)
                Semantics(
                  label: 'Tempo de foco ${focusVM.formattedTime}',
                  liveRegion: true,
                  child: Text(
                    focusVM.formattedTime,
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: focusVM.isDeviceFaceDown
                          ? Colors.white
                          : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Indicador de Status do Timer
                Chip(
                  label: Text(focusVM.isActive ? 'CONTANDO...' : 'PAUSADO'),
                  backgroundColor: focusVM.isActive
                      ? Colors.amber[100]
                      : Colors.grey[300],
                ),

                // Feedback de geolocalização real ao terminar o ciclo
                if (focusVM.completionLocation != null) ...[
                  const SizedBox(height: 40),
                  Card(
                    color: Colors.green[50],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.green, width: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          '📍 Ciclo concluído com sucesso em:\nLat: ${focusVM.completionLocation!['latitude']}\nLong: ${focusVM.completionLocation!['longitude']}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
