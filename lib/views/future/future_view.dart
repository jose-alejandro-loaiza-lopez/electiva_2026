import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../widgets/base_view.dart';

/// Vista que demuestra el uso de Future, async/await.
/// Muestra estados: Cargando… / Éxito / Error y
/// registra en consola el orden de ejecución.
class FutureView extends StatefulWidget {
  const FutureView({super.key});

  @override
  State<FutureView> createState() => _FutureViewState();
}

/// Enum para representar el estado de la carga de datos
enum EstadoCarga { inicial, cargando, exito, error }

class _FutureViewState extends State<FutureView> {
  List<String> _nombres = [];
  EstadoCarga _estado = EstadoCarga.inicial;
  String _mensajeError = '';
  bool _simularError = false; // Switch para simular un error

  @override
  void initState() {
    super.initState();
    obtenerDatos(); // Carga de datos al iniciar la vista
  }

  // ──────────────────────────────────────────────────────────
  //  Servicio simulado: retorna datos tras 3 segundos
  // ──────────────────────────────────────────────────────────
  /// Simula una consulta a un servicio remoto usando [Future.delayed].
  /// Si [simularError] es true, lanza una excepción para demostrar
  /// el manejo de errores con try/catch.
  Future<List<String>> cargarNombres({bool simularError = false}) async {
    // Future.delayed simula la latencia de una API
    await Future.delayed(const Duration(seconds: 3));

    if (simularError) {
      throw Exception('Error de conexión: no se pudo contactar al servidor.');
    }

    return [
      'Juan',
      'Pedro',
      'Luis',
      'Ana',
      'María',
      'José',
      'Carlos',
      'Sofía',
      'Laura',
      'Fernando',
      'Ricardo',
      'Diana',
      'Elena',
      'Miguel',
      'Rosa',
      'Luz',
      'Carmen',
      'Pablo',
      'Jorge',
      'Roberto',
    ];
  }

  // ──────────────────────────────────────────────────────────
  //  Flujo async/await con manejo de estados
  // ──────────────────────────────────────────────────────────
  /// Obtiene los datos del servicio simulado.
  /// Imprime en consola el orden de ejecución (antes, durante, después).
  Future<void> obtenerDatos() async {
    // ── ANTES ──
    if (kDebugMode) {
      print('═══════════════════════════════════════════════');
      print('🔵 [ANTES]  Se va a iniciar la carga de datos.');
      print('   Hilo principal: UI no se bloquea.');
    }

    setState(() {
      _estado = EstadoCarga.cargando;
      _nombres = [];
      _mensajeError = '';
    });

    // ── DURANTE ──
    if (kDebugMode) {
      print('🟡 [DURANTE] Esperando respuesta del Future (3 s)…');
    }

    try {
      final datos = await cargarNombres(simularError: _simularError);

      // Verificar que el widget sigue montado antes de llamar a setState
      if (!mounted) return;

      // ── DESPUÉS (éxito) ──
      if (kDebugMode) {
        print(
          '🟢 [DESPUÉS] Datos recibidos correctamente (${datos.length} elementos).',
        );
        print('═══════════════════════════════════════════════');
      }

      setState(() {
        _estado = EstadoCarga.exito;
        _nombres = datos;
      });
    } catch (e) {
      if (!mounted) return;

      // ── DESPUÉS (error) ──
      if (kDebugMode) {
        print('🔴 [DESPUÉS] Ocurrió un error: $e');
        print('═══════════════════════════════════════════════');
      }

      setState(() {
        _estado = EstadoCarga.error;
        _mensajeError = e.toString();
      });
    }
  }

  // ──────────────────────────────────────────────────────────
  //  UI
  // ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BaseView(
      title: 'Future · async / await',
      body: Column(
        children: [
          // ── Indicador de estado actual ──
          _buildEstadoBanner(colorScheme),

          // ── Switch para simular error ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.bug_report, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Simular error en la próxima carga'),
                ),
                Switch(
                  value: _simularError,
                  onChanged: (v) => setState(() => _simularError = v),
                ),
              ],
            ),
          ),

          // ── Botón de recargar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _estado == EstadoCarga.cargando
                    ? null
                    : obtenerDatos,
                icon: const Icon(Icons.refresh),
                label: Text(
                  _estado == EstadoCarga.error
                      ? 'Reintentar'
                      : 'Recargar datos',
                ),
              ),
            ),
          ),

          const Divider(),

          // ── Cuerpo según el estado ──
          Expanded(child: _buildBody(colorScheme)),
        ],
      ),
    );
  }

  /// Banner superior que muestra el estado actual de la operación.
  Widget _buildEstadoBanner(ColorScheme cs) {
    late final IconData icono;
    late final String texto;
    late final Color color;

    switch (_estado) {
      case EstadoCarga.inicial:
        icono = Icons.info_outline;
        texto = 'Presiona el botón para cargar datos';
        color = Colors.grey;
        break;
      case EstadoCarga.cargando:
        icono = Icons.hourglass_top;
        texto = 'Cargando…';
        color = Colors.orange;
        break;
      case EstadoCarga.exito:
        icono = Icons.check_circle;
        texto = 'Éxito — ${_nombres.length} nombres cargados';
        color = Colors.green;
        break;
      case EstadoCarga.error:
        icono = Icons.error;
        texto = 'Error';
        color = Colors.red;
        break;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          _estado == EstadoCarga.cargando
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: color,
                  ),
                )
              : Icon(icono, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  texto,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                if (_estado == EstadoCarga.error)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _mensajeError,
                      style: TextStyle(fontSize: 12, color: color),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Cuerpo principal: GridView con los nombres o mensaje según el estado.
  Widget _buildBody(ColorScheme cs) {
    switch (_estado) {
      case EstadoCarga.inicial:
        return const Center(
          child: Text(
            'Sin datos todavía.',
            style: TextStyle(color: Colors.grey),
          ),
        );
      case EstadoCarga.cargando:
        return const Center(child: CircularProgressIndicator());
      case EstadoCarga.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 64, color: Colors.red.shade200),
              const SizedBox(height: 12),
              const Text(
                'No se pudieron cargar los datos.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text(
                'Desactiva el switch de error e intenta de nuevo.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        );
      case EstadoCarga.exito:
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: GridView.builder(
            itemCount: _nombres.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2,
            ),
            itemBuilder: (context, index) {
              return Card(
                color: cs.primaryContainer,
                child: Center(
                  child: Text(
                    _nombres[index],
                    style: TextStyle(
                      fontSize: 18,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
              );
            },
          ),
        );
    }
  }
}
