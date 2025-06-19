import 'package:flutter/material.dart';
import '../data/models/gasto.dart';
import 'gasto_form_view.dart';
import 'package:agrocuy/infrastructure/services/shared_gasto_service.dart';

final SharedGastoService _storage = SharedGastoService();

class GastosListView extends StatefulWidget {
  const GastosListView({super.key});

  @override
  State<GastosListView> createState() => _GastosListViewState();
}

class _GastosListViewState extends State<GastosListView> {
  List<Gasto> gastos = [];

  @override
  void initState() {
    super.initState();
    _loadGastos();
  }

  Future<void> _loadGastos() async {
    final loaded = await _storage.getGastos();
    setState(() {
      gastos = loaded;
    });
  }

  Future<void> _saveGastos() async {
    await _storage.saveGastos(gastos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gastos Realizados")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade300),
                  child: const Text("Filtrar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nuevoGasto = await Navigator.push<Gasto>(
                      context,
                      MaterialPageRoute(builder: (_) => const GastoFormView()),
                    );
                    if (nuevoGasto != null && mounted) {
                      setState(() {
                        gastos.add(nuevoGasto);
                      });
                      _saveGastos();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text("Nuevo Gasto"),
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
              child: ListView.builder(
                itemCount: gastos.length,
                itemBuilder: (context, index) {
                  final gasto = gastos[index];
                  return _gastoCard(context, gasto);
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

  Widget _gastoCard(BuildContext context, Gasto gasto) {
    return Card(
      color: Colors.yellow.shade100,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              gasto.imagen,
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
                    "Gasto - ${gasto.tipo}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  Text("Fecha: ${gasto.fecha}"),
                  Text("Monto Gastado: ${gasto.monto}"),
                  Text("Detalle: ${gasto.detalle}"),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final editado = await Navigator.push<Gasto>(
                      context,
                      MaterialPageRoute(builder: (_) => GastoFormView(gasto: gasto)),
                    );
                    if (editado != null && mounted) {
                      setState(() {
                        final i = gastos.indexOf(gasto);
                        gastos[i] = editado;
                      });
                      _saveGastos();
                    }
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      gastos.remove(gasto);
                    });
                    _saveGastos();
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text("Delete"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
