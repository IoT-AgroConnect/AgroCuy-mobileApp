import 'package:flutter/material.dart';
import '../data/models/gasto.dart';

class GastoFormView extends StatefulWidget {
  final Gasto? gasto;

  const GastoFormView({super.key, this.gasto});

  @override
  State<GastoFormView> createState() => _GastoFormViewState();
}

class _GastoFormViewState extends State<GastoFormView> {
  final _formKey = GlobalKey<FormState>();
  String tipoSeleccionado = "Alimento";

  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _detalleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.gasto != null) {
      tipoSeleccionado = widget.gasto!.tipo;
      _fechaController.text = widget.gasto!.fecha;
      _montoController.text = widget.gasto!.monto;
      _detalleController.text = widget.gasto!.detalle;
    }
  }

  @override
  void dispose() {
    _montoController.dispose();
    _fechaController.dispose();
    _detalleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gasto == null ? "Nuevo Gasto" : "Editar Gasto"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Tipo de Gasto:"),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _botonTipo("Alimento", Colors.amber.shade100),
                  _botonTipo("Salud", Colors.cyan.shade100),
                  _botonTipo("Mantenimiento", Colors.green.shade100),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montoController,
                decoration: const InputDecoration(labelText: "Monto gastado (S/.)"),
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fechaController,
                decoration: const InputDecoration(labelText: "Fecha"),
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _detalleController,
                decoration: const InputDecoration(labelText: "Detalle del gasto"),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final gasto = Gasto(
                          tipo: tipoSeleccionado,
                          fecha: _fechaController.text,
                          monto: _montoController.text,
                          detalle: _detalleController.text,
                          imagen: "lib/assets/images/chanchito.png",
                        );
                        Navigator.pop(context, gasto);
                      }
                    },
                    child: Text(widget.gasto == null ? "Registrar" : "Guardar"),
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
