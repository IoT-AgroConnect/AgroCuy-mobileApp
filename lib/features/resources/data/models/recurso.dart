class Recurso {
  final String nombre;
  final String tipo;
  final String fecha;
  final String cantidad;
  final String observaciones;
  final String imagen;

  Recurso({
    required this.nombre,
    required this.tipo,
    required this.fecha,
    required this.cantidad,
    required this.observaciones,
    required this.imagen,
  });

  // Método para convertir Recurso a JSON (para guardar en SharedPreferences)
  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'tipo': tipo,
    'fecha': fecha,
    'cantidad': cantidad,
    'observaciones': observaciones,
    'imagen': imagen,
  };

  // Método para convertir JSON a un objeto Recurso (al cargar desde SharedPreferences)
  factory Recurso.fromJson(Map<String, dynamic> json) => Recurso(
    nombre: json['nombre'],
    tipo: json['tipo'],
    fecha: json['fecha'],
    cantidad: json['cantidad'],
    observaciones: json['observaciones'],
    imagen: json['imagen'],
  );
}
