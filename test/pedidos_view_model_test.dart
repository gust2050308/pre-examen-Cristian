// Prueba unitaria del ViewModel: sin pantalla y sin red.
//   flutter test

import 'package:cafe_utez/datos/memoria_pedido_repository.dart';
import 'package:cafe_utez/presentacion/pedidos_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registrar con datos válidos guarda en el repositorio y avisa', () async {
    // Preparar
    final repositorio = MemoriaPedidoRepository();
    final vm = PedidosViewModel(repositorio);
    var avisos = 0;
    vm.addListener(() => avisos++);

    // Actuar
    final ok = await vm.registrar('Ana', 'Café', '2');

    // Comprobar
    expect(ok, isTrue);
    expect(vm.error, isNull);
    expect(vm.pedidos, hasLength(1));
    expect(vm.totalPiezas, 2);
    expect((await repositorio.todos()).single.cliente, 'Ana');
    expect(avisos, greaterThan(0));

    vm.dispose();
  });
}