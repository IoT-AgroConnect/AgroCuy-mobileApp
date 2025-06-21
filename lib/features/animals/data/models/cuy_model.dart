class CuyModel {
  final int id;
  final String nombre;
  final String sexo; // 'macho' o 'hembra'
  final DateTime fechaNacimiento;
  final double peso;
  final String color;
  final String estado; // 'sano', 'enfermo', 'reproduccion'
  final int jaulaId;
  final DateTime fechaIngreso;
  final String? observaciones;

  CuyModel({
    required this.id,
    required this.nombre,
    required this.sexo,
    required this.fechaNacimiento,
    required this.peso,
    required this.color,
    required this.estado,
    required this.jaulaId,
    required this.fechaIngreso,
    this.observaciones,
  });

  int get edadEnDias {
    return DateTime.now().difference(fechaNacimiento).inDays;
  }

  String get edadFormateada {
    final dias = edadEnDias;
    if (dias < 30) {
      return '$dias dias';
    } else if (dias < 365) {
      final meses = (dias / 30).floor();
      return '$meses meses';
    } else {
      final anios = (dias / 365).floor();
      final mesesRestantes = ((dias % 365) / 30).floor();
      return '$anios años, $mesesRestantes meses';
    }
  }

  factory CuyModel.fromJson(Map<String, dynamic> json) {
    return CuyModel(
      id: json['id'],
      nombre: json['nombre'],
      sexo: json['sexo'],
      fechaNacimiento: DateTime.parse(json['fechaNacimiento']),
      peso: json['peso'].toDouble(),
      color: json['color'],
      estado: json['estado'],
      jaulaId: json['jaulaId'],
      fechaIngreso: DateTime.parse(json['fechaIngreso']),
      observaciones: json['observaciones'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'sexo': sexo,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'peso': peso,
      'color': color,
      'estado': estado,
      'jaulaId': jaulaId,
      'fechaIngreso': fechaIngreso.toIso8601String(),
      'observaciones': observaciones,
    };
  }

  CuyModel copyWith({
    int? id,
    String? nombre,
    String? sexo,
    DateTime? fechaNacimiento,
    double? peso,
    String? color,
    String? estado,
    int? jaulaId,
    DateTime? fechaIngreso,
    String? observaciones,
  }) {
    return CuyModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      sexo: sexo ?? this.sexo,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      peso: peso ?? this.peso,
      color: color ?? this.color,
      estado: estado ?? this.estado,
      jaulaId: jaulaId ?? this.jaulaId,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      observaciones: observaciones ?? this.observaciones,
    );
  }
}
