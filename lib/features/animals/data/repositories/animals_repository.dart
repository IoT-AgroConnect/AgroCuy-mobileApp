import '../models/jaula_model.dart';
import '../models/cuy_model.dart';

class AnimalsRepository {
  // Datos de ejemplo para jaulas
  static final List<JaulaModel> _jaulas = [
    JaulaModel(
      id: 1,
      nombre: 'Jaula A1',
      descripcion: 'Jaula para cuyes reproductores',
      capacidadMaxima: 10,
      fechaCreacion: DateTime.now().subtract(const Duration(days: 30)),
    ),
    JaulaModel(
      id: 2,
      nombre: 'Jaula B1',
      descripcion: 'Jaula para cuyes jovenes',
      capacidadMaxima: 15,
      fechaCreacion: DateTime.now().subtract(const Duration(days: 20)),
    ),
    JaulaModel(
      id: 3,
      nombre: 'Jaula C1',
      descripcion: 'Jaula de crecimiento',
      capacidadMaxima: 12,
      fechaCreacion: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  // Datos de ejemplo para cuyes
  static final List<CuyModel> _cuyes = [
    CuyModel(
      id: 1,
      nombre: 'Pepe',
      sexo: 'macho',
      fechaNacimiento: DateTime.now().subtract(const Duration(days: 120)),
      peso: 0.8,
      color: 'marron',
      estado: 'sano',
      jaulaId: 1,
      fechaIngreso: DateTime.now().subtract(const Duration(days: 100)),
      observaciones: 'Cuy reproductor principal',
    ),
    CuyModel(
      id: 2,
      nombre: 'Luna',
      sexo: 'hembra',
      fechaNacimiento: DateTime.now().subtract(const Duration(days: 90)),
      peso: 0.7,
      color: 'blanco',
      estado: 'reproduccion',
      jaulaId: 1,
      fechaIngreso: DateTime.now().subtract(const Duration(days: 80)),
      observaciones: 'Hembra reproductora',
    ),
    CuyModel(
      id: 3,
      nombre: 'Rocky',
      sexo: 'macho',
      fechaNacimiento: DateTime.now().subtract(const Duration(days: 45)),
      peso: 0.4,
      color: 'negro',
      estado: 'sano',
      jaulaId: 2,
      fechaIngreso: DateTime.now().subtract(const Duration(days: 30)),
    ),
    CuyModel(
      id: 4,
      nombre: 'Bella',
      sexo: 'hembra',
      fechaNacimiento: DateTime.now().subtract(const Duration(days: 60)),
      peso: 0.5,
      color: 'tricolor',
      estado: 'sano',
      jaulaId: 2,
      fechaIngreso: DateTime.now().subtract(const Duration(days: 45)),
    ),
  ];

  // CRUD para Jaulas
  Future<List<JaulaModel>> getAllJaulas() async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simular delay de red
    return List.from(_jaulas);
  }

  Future<JaulaModel> getJaulaById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _jaulas.firstWhere((jaula) => jaula.id == id);
  }

  Future<void> createJaula(JaulaModel jaula) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newJaula = jaula.copyWith(id: _getNextJaulaId());
    _jaulas.add(newJaula);
  }

  Future<void> updateJaula(JaulaModel jaula) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _jaulas.indexWhere((j) => j.id == jaula.id);
    if (index != -1) {
      _jaulas[index] = jaula;
    }
  }

  Future<void> deleteJaula(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _jaulas.removeWhere((jaula) => jaula.id == id);
    // También eliminar cuyes de esa jaula
    _cuyes.removeWhere((cuy) => cuy.jaulaId == id);
  }

  // CRUD para Cuyes
  Future<List<CuyModel>> getCuyesByJaulaId(int jaulaId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _cuyes.where((cuy) => cuy.jaulaId == jaulaId).toList();
  }

  Future<CuyModel> getCuyById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _cuyes.firstWhere((cuy) => cuy.id == id);
  }

  Future<void> createCuy(CuyModel cuy) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newCuy = cuy.copyWith(id: _getNextCuyId());
    _cuyes.add(newCuy);
  }

  Future<void> updateCuy(CuyModel cuy) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _cuyes.indexWhere((c) => c.id == cuy.id);
    if (index != -1) {
      _cuyes[index] = cuy;
    }
  }

  Future<void> deleteCuy(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _cuyes.removeWhere((cuy) => cuy.id == id);
  }

  // Métodos auxiliares
  int _getNextJaulaId() {
    return _jaulas.isEmpty
        ? 1
        : _jaulas.map((j) => j.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  int _getNextCuyId() {
    return _cuyes.isEmpty
        ? 1
        : _cuyes.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  // Estadísticas
  Future<int> getCantidadCuyesPorJaula(int jaulaId) async {
    final cuyes = await getCuyesByJaulaId(jaulaId);
    return cuyes.length;
  }
}
