// DATOS — contrato del repositorio.
// El ViewModel solo conoce este archivo, nunca la implementación concreta.

import '../dominio/pedido.dart';

abstract class PedidoRepository {
  // Guarda un pedido nuevo al final de la lista.
  Future<void> guardar(Pedido pedido);

  // Quita el pedido que está en esa posición (ya se entregó).
  Future<void> entregar(int indice);

  // Devuelve los pedidos pendientes, en el orden en que se guardaron.
  Future<List<Pedido>> todos();
}