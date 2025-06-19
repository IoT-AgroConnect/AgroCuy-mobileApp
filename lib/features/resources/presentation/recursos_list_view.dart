import 'package:flutter/material.dart';
import 'recurso_form_view.dart';
import '../data/models/recurso.dart';
import 'package:agrocuy/infrastructure/services/shared_recurso_service.dart';

class RecursosListView extends StatefulWidget {
  const RecursosListView({super.key});

  @override
  State<RecursosListView> createState() => _RecursosListViewState();
}

class _RecursosListViewState extends State<RecursosListView> {
  List<Recurso> recursos = [];
  final SharedRecursoService _storage = SharedRecursoService();

  @override
  void initState() {
    super.initState();
    _loadRecursos();
  }

  Future<void> _loadRecursos() async {
    final data = await _storage.loadRecursos();
    setState(() {
      recursos = data;
    });
  }

  Future<void> _saveRecursos() async {
    await _storage.saveRecursos(recursos);
  }

  void _addRecurso(Recurso recurso) {
    setState(() {
      recursos.add(recurso);
    });
    _saveRecursos();
  }

  void _updateRecurso(int index, Recurso recurso) {
    setState(() {
      recursos[index] = recurso;
    });
    _saveRecursos();
  }

  void _deleteRecurso(int index) {
    setState(() {
      recursos.removeAt(index);
    });
    _saveRecursos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listado de Recursos"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {}, // Filtro futuro
                  icon: const Icon(Icons.filter_list),
                  label: const Text("Filtrar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade300,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nuevoRecurso = await Navigator.push<Recurso>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecursoFormView(),
                      ),
                    );
                    if (nuevoRecurso != null && mounted) {
                      _addRecurso(nuevoRecurso);
                    }
                  },
                  child: const Text("Registro de nuevo recurso"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filtroCategoria("Alimento", Colors.amber.shade100),
                _filtroCategoria("Salud", Colors.cyan.shade100),
                _filtroCategoria("Mantenimiento", Colors.green.shade100),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: recursos.isEmpty
                  ? const Center(child: Text("No hay recursos registrados."))
                  : ListView.builder(
                itemCount: recursos.length,
                itemBuilder: (context, index) {
                  final recurso = recursos[index];
                  return _recursoCard(context, recurso, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtroCategoria(String nombre, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _recursoCard(BuildContext context, Recurso recurso, int index) {
    return Card(
      color: Colors.yellow.shade100,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              recurso.imagen,
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recurso.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("Tipo: ${recurso.tipo}"),
                  Text("Fecha: ${recurso.fecha}"),
                  Text("Cantidad: ${recurso.cantidad}"),
                  Text("Observaciones: ${recurso.observaciones}"),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final recursoEditado = await Navigator.push<Recurso>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecursoFormView(recurso: recurso),
                      ),
                    );
                    if (recursoEditado != null && mounted) {
                      _updateRecurso(index, recursoEditado);
                    }
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    _deleteRecurso(index);
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text("Delete"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
