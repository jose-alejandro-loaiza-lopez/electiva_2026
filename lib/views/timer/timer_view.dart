import 'dart:async';
import 'package:flutter/material.dart';

import '../../widgets/base_view.dart';

/// Vista que demuestra el uso de [Timer] para implementar un cronómetro.
///
/// Funcionalidades:
/// - Iniciar / Pausar / Reanudar / Reiniciar.
/// - Actualización cada 100 ms (centésimas de segundo).
/// - Cancelación del timer al pausar o salir de la vista (limpieza de recursos).
class TimerView extends StatefulWidget {
  const TimerView({super.key});

  @override
  State<TimerView> createState() => _TimerViewState();
}

/// Enum para representar el estado del cronómetro
enum EstadoCronometro { detenido, corriendo, pausado }

class _TimerViewState extends State<TimerView> {
  // ── Estado del cronómetro ──
  Timer? _timer; // Referencia al Timer periódico
  EstadoCronometro _estado = EstadoCronometro.detenido;

  // Tiempo acumulado en milisegundos (permite pausar y reanudar)
  int _milisegundosAcumulados = 0;

  // Momento en que se inició/reanudó el cronómetro
  DateTime? _inicioTramo;

  // ── Historial de vueltas (laps) ──
  final List<int> _vueltas = []; // almacena milisegundos de cada vuelta

  // ──────────────────────────────────────────────────────────
  //  Ciclo de vida: cancelar el timer al salir de la vista
  // ──────────────────────────────────────────────────────────
  @override
  void dispose() {
    _timer?.cancel(); // Limpieza de recursos
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────
  //  Cálculo del tiempo total transcurrido
  // ──────────────────────────────────────────────────────────
  /// Retorna los milisegundos totales: los acumulados + el tramo actual.
  int get _milisegundosTotales {
    if (_inicioTramo == null) return _milisegundosAcumulados;
    return _milisegundosAcumulados +
        DateTime.now().difference(_inicioTramo!).inMilliseconds;
  }

  // ──────────────────────────────────────────────────────────
  //  Acciones: Iniciar / Pausar / Reanudar / Reiniciar
  // ──────────────────────────────────────────────────────────

  /// Inicia el cronómetro desde cero o reanuda si estaba pausado.
  void _iniciar() {
    _inicioTramo = DateTime.now();
    // Timer.periodic actualiza la UI cada 100 ms (centésimas)
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {
        // Se llama setState para redibujar el widget con el nuevo tiempo
      });
    });
    setState(() => _estado = EstadoCronometro.corriendo);
  }

  /// Pausa el cronómetro: cancela el timer y guarda el tiempo acumulado.
  void _pausar() {
    _timer?.cancel(); // Cancela el timer al pausar (limpieza de recursos)
    _timer = null;
    _milisegundosAcumulados = _milisegundosTotales;
    _inicioTramo = null;
    setState(() => _estado = EstadoCronometro.pausado);
  }

  /// Reanuda el cronómetro desde donde se pausó.
  void _reanudar() {
    _iniciar(); // Reutiliza _iniciar, el acumulado ya está guardado
  }

  /// Reinicia el cronómetro: cancela el timer y pone todo en cero.
  void _reiniciar() {
    _timer?.cancel(); // Cancela el timer al reiniciar (limpieza de recursos)
    _timer = null;
    setState(() {
      _milisegundosAcumulados = 0;
      _inicioTramo = null;
      _estado = EstadoCronometro.detenido;
      _vueltas.clear();
    });
  }

  /// Registra una vuelta (lap) con el tiempo actual.
  void _registrarVuelta() {
    setState(() {
      _vueltas.add(_milisegundosTotales);
    });
  }

  // ──────────────────────────────────────────────────────────
  //  Formato de tiempo
  // ──────────────────────────────────────────────────────────
  /// Convierte milisegundos a formato MM:SS.cc (centésimas)
  String _formatearTiempo(int ms) {
    final totalCentesimas = ms ~/ 10;
    final centesimas = totalCentesimas % 100;
    final totalSegundos = totalCentesimas ~/ 100;
    final segundos = totalSegundos % 60;
    final minutos = totalSegundos ~/ 60;

    return '${minutos.toString().padLeft(2, '0')}:'
        '${segundos.toString().padLeft(2, '0')}.'
        '${centesimas.toString().padLeft(2, '0')}';
  }

  // ──────────────────────────────────────────────────────────
  //  UI
  // ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ms = _milisegundosTotales;

    return BaseView(
      title: 'Cronómetro · Timer',
      body: Column(
        children: [
          const SizedBox(height: 24),

          // ── Marcador principal ──
          _buildMarcador(ms, colorScheme),

          const SizedBox(height: 8),

          // ── Indicador de estado ──
          _buildChipEstado(),

          const SizedBox(height: 20),

          // ── Botones de control ──
          _buildBotones(colorScheme),

          const SizedBox(height: 16),
          const Divider(),

          // ── Encabezado de vueltas ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.flag, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Vueltas (${_vueltas.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          // ── Lista de vueltas ──
          Expanded(child: _buildListaVueltas(colorScheme)),
        ],
      ),
    );
  }

  /// Widget del marcador grande estilo digital.
  Widget _buildMarcador(int ms, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          _formatearTiempo(ms),
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w300,
            fontFamily: 'monospace', // fuente monoespaciada para el marcador
            letterSpacing: 4,
            color: cs.onSurface,
          ),
        ),
      ),
    );
  }

  /// Chip que muestra el estado actual del cronómetro.
  Widget _buildChipEstado() {
    late final String texto;
    late final Color color;
    late final IconData icono;

    switch (_estado) {
      case EstadoCronometro.detenido:
        texto = 'Detenido';
        color = Colors.grey;
        icono = Icons.stop_circle_outlined;
        break;
      case EstadoCronometro.corriendo:
        texto = 'En marcha';
        color = Colors.green;
        icono = Icons.play_circle_outline;
        break;
      case EstadoCronometro.pausado:
        texto = 'Pausado';
        color = Colors.orange;
        icono = Icons.pause_circle_outline;
        break;
    }

    return Chip(
      avatar: Icon(icono, color: color, size: 18),
      label: Text(texto, style: TextStyle(color: color)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }

  /// Fila de botones: Iniciar/Pausar/Reanudar, Vuelta, Reiniciar.
  Widget _buildBotones(ColorScheme cs) {
    final corriendo = _estado == EstadoCronometro.corriendo;
    final pausado = _estado == EstadoCronometro.pausado;
    final detenido = _estado == EstadoCronometro.detenido;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: () {
              if (detenido) {
                _iniciar();
              } else if (corriendo) {
                _pausar();
              } else if (pausado) {
                _reanudar();
              }
            },
            icon: Icon(
              detenido
                  ? Icons.play_arrow
                  : corriendo
                      ? Icons.pause
                      : Icons.play_arrow,
            ),
            label: Text(
              detenido
                  ? 'Iniciar'
                  : corriendo
                      ? 'Pausar'
                      : 'Reanudar',
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: corriendo ? Colors.orange : cs.primary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: detenido ? null : _reiniciar,
                  icon: const Icon(Icons.replay),
                  label: const Text('Reiniciar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: corriendo ? _registrarVuelta : null,
                  icon: const Icon(Icons.flag),
                  label: const Text('Vuelta'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Lista de vueltas registradas.
  Widget _buildListaVueltas(ColorScheme cs) {
    if (_vueltas.isEmpty) {
      return const Center(
        child: Text(
          'Sin vueltas registradas.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: _vueltas.length,
      itemBuilder: (context, index) {
        // Mostramos la más reciente primero
        final i = _vueltas.length - 1 - index;
        final tiempoVuelta = _vueltas[i];
        final tiempoParcial = i == 0 ? tiempoVuelta : tiempoVuelta - _vueltas[i - 1];

        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: cs.primaryContainer,
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: cs.onPrimaryContainer,
                ),
              ),
            ),
            title: Text(
              _formatearTiempo(tiempoVuelta),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Parcial: ${_formatearTiempo(tiempoParcial)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
