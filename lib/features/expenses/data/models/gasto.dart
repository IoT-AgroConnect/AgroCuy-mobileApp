class Gasto {
  final String concepto;
  final String monto;
  final String fecha;
  final String tipo;
  final String detalle; // ✅ CAMBIA observaciones por detalle
  final String imagen;

  Gasto({
    required this.concepto,
    required this.monto,
    required this.fecha,
    required this.tipo,
    required this.detalle, // ✅ aquí también
    required this.imagen,
  });

  Map<String, dynamic> toJson() => {
    'concepto': concepto,
    'monto': monto,
    'fecha': fecha,
    'tipo': tipo,
    'detalle': detalle, // ✅ aquí también
    'imagen': imagen,
  };

  factory Gasto.fromJson(Map<String, dynamic> json) => Gasto(
    concepto: json['concepto'],
    monto: json['monto'],
    fecha: json['fecha'],
    tipo: json['tipo'],
    detalle: json['detalle'], // ✅ aquí también
    imagen: json['imagen'],
  );
}
