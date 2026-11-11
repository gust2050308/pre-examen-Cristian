// PRESENTACIÓN — ViewModel con ChangeNotifier.
// No importa material.dart (no dibuja) ni provider (no sabe quién lo entrega).

import 'package:flutter/foundation.dart';

import '../datos/pedido_repository.dart';
import '../dominio/pedido.dart';

class PedidosViewModel extends ChangeNotifier {
  // El repositorio llega desde fuera (inyección de dependencias).
  PedidosViewModel(this._repositorio);

  final PedidoRepository _repositorio;

  // Estado compartido por las dos pantallas.
  List<Pedido> pedidos = [];
  String? error;
  bool guardando = false;

  // Estado derivado: se calcula, no se guarda en un campo.
  int get totalPiezas => pedidos.fold(0, (suma, p) => suma + p.cantidad);

  // Trae lo que ya tenga el repositorio (al arrancar la app).
  Future<void> cargar() async {
    pedidos = await _repositorio.todos();
    notifyListeners();
  }

  // Acción del botón "Agregar". Devuelve true si se guardó.
  Future<bool> registrar(
      String cliente,
      String producto,
      String cantidadTexto,
      ) async {
    final cantidad = int.tryParse(cantidadTexto.trim());
    // Las reglas viven en el dominio; aquí solo se aplican en orden.
    final motivo = validarCliente(cliente) ?? validarCantidad(cantidad);
    if (motivo != null) {
      error = motivo;
      notifyListeners();
      return false;
    }

    guardando = true;
    error = null;
    notifyListeners();

    await _repositorio.guardar(
      Pedido(cliente: cliente.trim(), producto: producto, cantidad: cantidad!),
    );
    // Se vuelve a leer de la fuente de verdad.
    pedidos = await _repositorio.todos();

    guardando = false;
    notifyListeners();
    return true;
  }

  // Se llama antes de abrir el formulario para que no aparezca un error viejo.
  void limpiarError() {
    error = null;
    notifyListeners();
  }

  // Acción del botón "entregar" de cada fila.
  Future<void> entregar(int indice) async {
    await _repositorio.entregar(indice);
    pedidos = await _repositorio.todos();
    notifyListeners();
  }
}