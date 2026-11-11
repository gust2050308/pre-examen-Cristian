// DATOS — implementación en memoria del contrato.
// Solo main.dart importa esta clase: es el único que elige la fuente de datos.

import '../dominio/pedido.dart';
import 'pedido_repository.dart';

class MemoriaPedidoRepository implements PedidoRepository {
  // Fuente de verdad: los datos viven aquí y se pierden al cerrar la app.
  final List<Pedido> _pedidos = [];

  @override
  Future<void> guardar(Pedido pedido) async => _pedidos.add(pedido);

  @override
  Future<void> entregar(int indice) async => _pedidos.removeAt(indice);

  // Copia no modificable: nadie puede alterar la lista por fuera.
  @override
  Future<List<Pedido>> todos() async => List.unmodifiable(_pedidos);
}