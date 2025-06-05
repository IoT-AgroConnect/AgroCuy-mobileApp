// 📄 models/gasto.dart

class Gasto {
  final String tipo;
  final String fecha;
  final String monto;
  final String detalle;
  final String imagen;

  Gasto({
    required this.tipo,
    required this.fecha,
    required this.monto,
    required this.detalle,
    required this.imagen,
  });
}
