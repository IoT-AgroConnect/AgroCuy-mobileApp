class JaulaModel {
  final int id;
  final String nombre;
  final String descripcion;
  final int capacidadMaxima;
  final DateTime fechaCreacion;
  final bool activa;

  JaulaModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.capacidadMaxima,
    required this.fechaCreacion,
    this.activa = true,
  });

  factory JaulaModel.fromJson(Map<String, dynamic> json) {
    return JaulaModel(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      capacidadMaxima: json['capacidadMaxima'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      activa: json['activa'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'capacidadMaxima': capacidadMaxima,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'activa': activa,
    };
  }

  JaulaModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    int? capacidadMaxima,
    DateTime? fechaCreacion,
    bool? activa,
  }) {
    return JaulaModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      capacidadMaxima: capacidadMaxima ?? this.capacidadMaxima,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      activa: activa ?? this.activa,
    );
  }
}
