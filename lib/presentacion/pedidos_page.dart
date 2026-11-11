// PRESENTACIÓN — Vista 1: lista de pedidos pendientes.
// Muestra con context.watch y actúa con context.read. No conoce datos/.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'nuevo_pedido_page.dart';
import 'pedidos_view_model.dart';

class PedidosPage extends StatelessWidget {
  const PedidosPage({super.key});

  @override
  Widget build(BuildContext context) {
    // watch: se suscribe; la lista se redibuja con cada notifyListeners().
    final vm = context.watch<PedidosViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cafetería UTEZ')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Pedidos: ${vm.pedidos.length} · Piezas: ${vm.totalPiezas}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: vm.pedidos.isEmpty
                ? const Center(child: Text('Sin pedidos'))
                : ListView.builder(
              itemCount: vm.pedidos.length,
              itemBuilder: (context, i) {
                final p = vm.pedidos[i];
                return ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(p.producto),
                  subtitle: Text('${p.cliente} · x${p.cantidad}'),
                  trailing: IconButton(
                    key: Key('entregar_$i'),
                    tooltip: 'Entregar',
                    icon: const Icon(Icons.check_circle_outline),
                    // read: dentro de un callback nunca se usa watch.
                    onPressed: () =>
                        context.read<PedidosViewModel>().entregar(i),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('nuevo'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo pedido'),
        onPressed: () {
          context.read<PedidosViewModel>().limpiarError();
          // push apila el formulario; esta vista queda debajo, intacta.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NuevoPedidoPage()),
          );
        },
      ),
    );
  }
}