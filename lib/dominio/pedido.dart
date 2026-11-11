// DOMINIO — entidad Pedido y sus reglas. Dart puro: no importa Flutter.

// Productos que vende la cafetería. Es una constante, no es estado.
const productosCafe = ['Café', 'Torta', 'Jugo', 'Galletas'];

// Tope de piezas por pedido.
const cantidadMaxima = 5;

// Entidad: un pedido de la cafetería.
class Pedido {
  const Pedido({
    required this.cliente,
    required this.producto,
    required this.cantidad,
  });

  // Nombre de quien pidió.
  final String cliente;
  // Producto pedido; uno de productosCafe.
  final String producto;
  // Piezas, de 1 a cantidadMaxima.
  final int cantidad;
}

// Regla: devuelve el mensaje de error o null si el nombre es válido.
String? validarCliente(String cliente) {
  final limpio = cliente.trim();
  if (limpio.isEmpty) return 'Escribe el nombre del cliente';
  if (limpio.length < 3) return 'El nombre debe tener al menos 3 letras';
  return null;
}

// Regla: devuelve el mensaje de error o null si la cantidad es válida.
// Recibe int? porque el texto puede no ser un número (llega null).
String? validarCantidad(int? cantidad) {
  if (cantidad == null) return 'Escribe la cantidad con número';
  if (cantidad < 1 || cantidad > cantidadMaxima) {
    return 'La cantidad debe ser de 1 a $cantidadMaxima';
  }
  return null;
}