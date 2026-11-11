// PRESENTACIÓN — Vista 2: formulario para agregar un pedido.
// Es StatefulWidget solo por el estado efímero (controladores y producto elegido).
// No recibe el ViewModel por constructor: lo pide al árbol con provider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dominio/pedido.dart';
import 'pedidos_view_model.dart';

class NuevoPedidoPage extends StatefulWidget {
  const NuevoPedidoPage({super.key});

  @override
  State<NuevoPedidoPage> createState() => _NuevoPedidoPageState();
}

class _NuevoPedidoPageState extends State<NuevoPedidoPage> {
  final _cliente = TextEditingController();
  final _cantidad = TextEditingController();
  String _producto = productosCafe.first;

  @override
  void dispose() {
    _cliente.dispose();
    _cantidad.dispose();
    super.dispose();
  }

  Future<void> _agregar() async {
    final ok = await context.read<PedidosViewModel>().registrar(
      _cliente.text,
      _producto,
      _cantidad.text,
    );
    // Si no se guardó, el error ya lo muestra el ViewModel; no se navega.
    if (!ok || !mounted) return;
    // pop regresa a la lista, que ya se enteró del pedido nuevo.
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PedidosViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo pedido')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('cliente'),
            controller: _cliente,
            decoration: const InputDecoration(labelText: 'Cliente'),
          ),
          DropdownButtonFormField<String>(
            key: const Key('producto'),
            initialValue: _producto,
            decoration: const InputDecoration(labelText: 'Producto'),
            items: [
              for (final p in productosCafe)
                DropdownMenuItem(value: p, child: Text(p)),
            ],
            // Estado efímero: basta setState.
            onChanged: (p) => setState(() => _producto = p!),
          ),
          TextField(
            key: const Key('cantidad'),
            controller: _cantidad,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cantidad'),
          ),
          const SizedBox(height: 16),
          if (vm.error != null)
            Text(
              vm.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: vm.guardando ? null : _agregar,
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}