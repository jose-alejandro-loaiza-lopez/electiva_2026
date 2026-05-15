import 'package:flutter/material.dart';
import '../../services/universidad_service.dart';
import '../../models/universidad.dart';
import '../../widgets/custom_drawer.dart';
import 'universidad_form_screen.dart';

class UniversidadListScreen extends StatelessWidget {
  const UniversidadListScreen({super.key});

  void _confirmDelete(BuildContext context, String id, String nombre) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar'),
        content: Text('¿Eliminar "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              UniversidadService().deleteUniversidad(id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = UniversidadService();

    return Scaffold(
      appBar: AppBar(title: const Text('Universidades')),
      drawer: const CustomDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UniversidadFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Universidad>>(
        stream: service.getUniversidades(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final universidades = snapshot.data!;
          if (universidades.isEmpty) {
            return const Center(
                child: Text('No hay universidades registradas'));
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: universidades.length,
            itemBuilder: (context, index) {
              final u = universidades[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.nombre,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('NIT: ${u.nit}'),
                              Text('Dirección: ${u.direccion}'),
                              Text('Teléfono: ${u.telefono}'),
                              Text('Web: ${u.paginaWeb}'),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    UniversidadFormScreen(universidad: u),
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _confirmDelete(context, u.id!, u.nombre),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
