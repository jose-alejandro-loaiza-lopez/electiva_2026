class Universidad {
  final String? id;
  final String nit;
  final String nombre;
  final String direccion;
  final String telefono;
  final String paginaWeb;

  Universidad({
    this.id,
    required this.nit,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.paginaWeb,
  });

  Map<String, dynamic> toMap() => {
    'nit': nit,
    'nombre': nombre,
    'direccion': direccion,
    'telefono': telefono,
    'pagina_web': paginaWeb,
  };

  factory Universidad.fromMap(Map<String, dynamic> map, String id) => Universidad(
    id: id,
    nit: map['nit'] ?? '',
    nombre: map['nombre'] ?? '',
    direccion: map['direccion'] ?? '',
    telefono: map['telefono'] ?? '',
    paginaWeb: map['pagina_web'] ?? '',
  );
}
