import 'package:flutter/material.dart';
import '../data/models/recurso.dart';

class RecursoFormView extends StatefulWidget {
  final Recurso? recurso;

  const RecursoFormView({super.key, this.recurso});

  @override
  State<RecursoFormView> createState() => _RecursoFormViewState();
}

class _RecursoFormViewState extends State<RecursoFormView> {
  final _formKey = GlobalKey<FormState>();
  String tipoSeleccionado = "Alimento";

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.recurso != null) {
      _nombreController.text = widget.recurso!.nombre;
      _cantidadController.text = widget.recurso!.cantidad;
      _fechaController.text = widget.recurso!.fecha;
      _observacionesController.text = widget.recurso!.observaciones;
      tipoSeleccionado = widget.recurso!.tipo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    _fechaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recurso == null ? "Registrar Recurso" : "Editar Recurso"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              const Text("Tipo de recurso:"),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _botonTipo("Alimento", Colors.amber.shade100),
                  _botonTipo("Medicina", Colors.cyan.shade100),
                  _botonTipo("Producción", Colors.green.shade100),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cantidadController,
                decoration: const InputDecoration(labelText: "Cantidad"),
                validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fechaController,
                decoration: const InputDecoration(labelText: "Fecha"),
                validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacionesController,
                decoration: const InputDecoration(labelText: "Observaciones"),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Descartar"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final recurso = Recurso(
                          nombre: _nombreController.text,
                          tipo: tipoSeleccionado,
                          fecha: _fechaController.text,
                          cantidad: _cantidadController.text,
                          observaciones: _observacionesController.text,
                          imagen: "assets/saco.png",
                        );
                        Navigator.pop(context, recurso);
                      }
                    },
                    child: Text(widget.recurso == null ? "Registrar" : "Guardar"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _botonTipo(String tipo, Color color) {
    return ChoiceChip(
      label: Text(tipo),
      selected: tipoSeleccionado == tipo,
      selectedColor: color,
      onSelected: (_) {
        setState(() {
          tipoSeleccionado = tipo;
        });
      },
    );
  }
}
