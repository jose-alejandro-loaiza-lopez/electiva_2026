import 'package:flutter/material.dart';
import '../../services/universidad_service.dart';
import '../../models/universidad.dart';
import '../../widgets/base_view.dart';
import 'universidad_form_screen.dart';

class UniversidadListScreen extends StatelessWidget {
  const UniversidadListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = UniversidadService();

    return BaseView(
      title: 'Universidades',
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Universidad>>(
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
                  itemCount: universidades.length,
                  itemBuilder: (context, index) {
                    final u = universidades[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(u.nombre,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NIT: ${u.nit}'),
                            Text('Dirección: ${u.direccion}'),
                            Text('Teléfono: ${u.telefono}'),
                            Text('Web: ${u.paginaWeb}'),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const UniversidadFormScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Nueva Universidad'),
            ),
          ),
        ],
      ),
    );
  }
}
