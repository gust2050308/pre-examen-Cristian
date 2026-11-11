// Autoevaluación de la práctica guiada (Cafetería UTEZ).
// Imita el formato de la batería con la que se califica el examen:
// cada group() es un renglón de la rúbrica.
//
// Cópiala a test/_autoevaluacion/ y córrela con:
//   flutter test test/_autoevaluacion -r expanded
//
// NO cuenta como "tu prueba": el script la excluye del conteo.

import 'package:cafe_utez/datos/memoria_pedido_repository.dart';
import 'package:cafe_utez/datos/pedido_repository.dart';
import 'package:cafe_utez/dominio/pedido.dart';
import 'package:cafe_utez/main.dart';
import 'package:cafe_utez/presentacion/nuevo_pedido_page.dart';
import 'package:cafe_utez/presentacion/pedidos_page.dart';
import 'package:cafe_utez/presentacion/pedidos_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Repositorio falso: registra lo que recibe para saber si el ViewModel lo usó.
class RepositorioEspia implements PedidoRepository {
  RepositorioEspia([List<Pedido> iniciales = const []])
    : _datos = [...iniciales];

  final List<Pedido> _datos;
  final List<Pedido> recibidos = [];

  @override
  Future<void> guardar(Pedido pedido) async {
    recibidos.add(pedido);
    _datos.add(pedido);
  }

  @override
  Future<void> entregar(int indice) async => _datos.removeAt(indice);

  @override
  Future<List<Pedido>> todos() async => List.unmodifiable(_datos);
}

Future<void> abrirFormulario(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('nuevo')));
  await tester.pumpAndSettle();
}

Future<void> llenarYAgregar(
  WidgetTester tester, {
  required String cliente,
  required String cantidad,
}) async {
  await tester.enterText(find.byKey(const Key('cliente')), cliente);
  await tester.enterText(find.byKey(const Key('cantidad')), cantidad);
  await tester.tap(find.text('Agregar'));
  await tester.pumpAndSettle();
}

void main() {
  // ---------------------------------------------------------------- DOMINIO
  group('R1 Dominio', () {
    test('productosCafe y cantidadMaxima', () {
      expect(productosCafe, ['Café', 'Torta', 'Jugo', 'Galletas']);
      expect(cantidadMaxima, 5);
    });

    test('validarCliente', () {
      expect(validarCliente(''), 'Escribe el nombre del cliente');
      expect(validarCliente('   '), 'Escribe el nombre del cliente');
      expect(validarCliente('Al'), 'El nombre debe tener al menos 3 letras');
      expect(validarCliente(' Al '), 'El nombre debe tener al menos 3 letras');
      expect(validarCliente('Ana'), isNull);
    });

    test('validarCantidad', () {
      expect(validarCantidad(null), 'Escribe la cantidad con número');
      expect(validarCantidad(0), 'La cantidad debe ser de 1 a 5');
      expect(validarCantidad(6), 'La cantidad debe ser de 1 a 5');
      expect(validarCantidad(1), isNull);
      expect(validarCantidad(5), isNull);
    });
  });

  // ------------------------------------------------------------------ DATOS
  group('R2 Datos', () {
    test('guardar, todos y entregar en memoria', () async {
      final repo = MemoriaPedidoRepository();
      expect(repo, isA<PedidoRepository>());
      expect(await repo.todos(), isEmpty);

      await repo.guardar(
        const Pedido(cliente: 'Ana', producto: 'Café', cantidad: 2),
      );
      await repo.guardar(
        const Pedido(cliente: 'Luis', producto: 'Torta', cantidad: 1),
      );
      expect((await repo.todos()).map((p) => p.producto), ['Café', 'Torta']);

      await repo.entregar(0);
      expect((await repo.todos()).single.producto, 'Torta');
    });

    test('todos() no deja modificar la lista por fuera', () async {
      final repo = MemoriaPedidoRepository();
      final lista = await repo.todos();
      expect(
        () => lista.add(
          const Pedido(cliente: 'Ana', producto: 'Café', cantidad: 1),
        ),
        throwsUnsupportedError,
      );
    });
  });

  // ------------------------------------------------------------- VIEWMODEL
  group('R3 ViewModel (ChangeNotifier)', () {
    late RepositorioEspia espia;
    late PedidosViewModel vm;
    late int avisos;

    setUp(() {
      espia = RepositorioEspia();
      vm = PedidosViewModel(espia);
      avisos = 0;
      vm.addListener(() => avisos++);
    });

    tearDown(() => vm.dispose());

    test('es ChangeNotifier y arranca vacío', () {
      expect(vm, isA<ChangeNotifier>());
      expect(vm.pedidos, isEmpty);
      expect(vm.error, isNull);
      expect(vm.guardando, isFalse);
      expect(vm.totalPiezas, 0);
    });

    test('cargar() trae lo del repositorio y avisa', () async {
      final otro = PedidosViewModel(
        RepositorioEspia([
          const Pedido(cliente: 'Eva', producto: 'Jugo', cantidad: 3),
        ]),
      );
      var n = 0;
      otro.addListener(() => n++);
      await otro.cargar();
      expect(otro.pedidos.single.producto, 'Jugo');
      expect(n, greaterThan(0));
      otro.dispose();
    });

    test('registrar válido guarda, limpia el error y avisa', () async {
      expect(await vm.registrar('  Ana  ', 'Torta', ' 3 '), isTrue);
      expect(espia.recibidos.single.cliente, 'Ana');
      expect(espia.recibidos.single.producto, 'Torta');
      expect(espia.recibidos.single.cantidad, 3);
      expect(vm.pedidos, hasLength(1));
      expect(vm.error, isNull);
      expect(vm.guardando, isFalse);
      expect(avisos, greaterThan(0));
    });

    test('registrar avisa "guardando" y luego "listo"', () async {
      final valores = <bool>[];
      vm.addListener(() => valores.add(vm.guardando));
      await vm.registrar('Ana', 'Café', '1');
      expect(valores.first, isTrue);
      expect(valores.last, isFalse);
    });

    test('registrar inválido pone el error del dominio y no guarda', () async {
      expect(await vm.registrar('Al', 'Café', '2'), isFalse);
      expect(vm.error, 'El nombre debe tener al menos 3 letras');

      expect(await vm.registrar('Ana', 'Café', 'dos'), isFalse);
      expect(vm.error, 'Escribe la cantidad con número');

      expect(await vm.registrar('Ana', 'Café', '9'), isFalse);
      expect(vm.error, 'La cantidad debe ser de 1 a 5');

      expect(espia.recibidos, isEmpty);
      expect(avisos, greaterThanOrEqualTo(3));
    });

    test('totalPiezas es derivado de pedidos', () async {
      await vm.registrar('Ana', 'Café', '2');
      await vm.registrar('Luis', 'Torta', '3');
      expect(vm.totalPiezas, 5);
      await vm.entregar(0);
      expect(vm.totalPiezas, 3);
      expect(vm.pedidos.single.producto, 'Torta');
    });

    test('limpiarError quita el error y avisa', () async {
      await vm.registrar('', 'Café', '2');
      expect(vm.error, isNotNull);
      final antes = avisos;
      vm.limpiarError();
      expect(vm.error, isNull);
      expect(avisos, antes + 1);
    });
  });

  // ------------------------------------------- VISTAS + PROVIDER + NAVEGACIÓN
  group('R4 Vistas, provider y navegación', () {
    testWidgets('arranca en la lista vacía', (tester) async {
      await tester.pumpWidget(CafeUtezApp(repositorio: RepositorioEspia()));
      await tester.pumpAndSettle();

      expect(find.byType(PedidosPage), findsOneWidget);
      expect(find.text('Cafetería UTEZ'), findsOneWidget);
      expect(find.text('Pedidos: 0 · Piezas: 0'), findsOneWidget);
      expect(find.text('Sin pedidos'), findsOneWidget);
    });

    testWidgets('el FAB navega al formulario (push)', (tester) async {
      await tester.pumpWidget(CafeUtezApp(repositorio: RepositorioEspia()));
      await tester.pumpAndSettle();
      await abrirFormulario(tester);

      expect(find.byType(NuevoPedidoPage), findsOneWidget);
      expect(find.text('Nuevo pedido'), findsWidgets);
      expect(find.byKey(const Key('cliente')), findsOneWidget);
      expect(find.byKey(const Key('producto')), findsOneWidget);
      expect(find.byKey(const Key('cantidad')), findsOneWidget);
    });

    testWidgets('dato inválido: muestra el error y NO regresa', (tester) async {
      final espia = RepositorioEspia();
      await tester.pumpWidget(CafeUtezApp(repositorio: espia));
      await tester.pumpAndSettle();
      await abrirFormulario(tester);

      await llenarYAgregar(tester, cliente: 'Ana', cantidad: '8');

      expect(find.text('La cantidad debe ser de 1 a 5'), findsOneWidget);
      expect(find.byType(NuevoPedidoPage), findsOneWidget);
      expect(espia.recibidos, isEmpty);
    });

    testWidgets('dato válido: guarda, hace pop y la lista se entera', (
      tester,
    ) async {
      final espia = RepositorioEspia();
      await tester.pumpWidget(CafeUtezApp(repositorio: espia));
      await tester.pumpAndSettle();
      await abrirFormulario(tester);

      await llenarYAgregar(tester, cliente: 'Ana', cantidad: '3');

      expect(find.byType(NuevoPedidoPage), findsNothing);
      expect(find.byType(PedidosPage), findsOneWidget);
      expect(find.text('Pedidos: 1 · Piezas: 3'), findsOneWidget);
      expect(find.text('Café'), findsOneWidget);
      expect(find.text('Ana · x3'), findsOneWidget);
      expect(espia.recibidos.single.cantidad, 3);
    });

    testWidgets('el Dropdown cambia el producto que se guarda', (tester) async {
      final espia = RepositorioEspia();
      await tester.pumpWidget(CafeUtezApp(repositorio: espia));
      await tester.pumpAndSettle();
      await abrirFormulario(tester);

      await tester.tap(find.byKey(const Key('producto')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jugo').last);
      await tester.pumpAndSettle();
      await llenarYAgregar(tester, cliente: 'Ana', cantidad: '1');

      expect(espia.recibidos.single.producto, 'Jugo');
      expect(find.text('Jugo'), findsOneWidget);
    });

    testWidgets('entregar quita la fila y actualiza el encabezado', (
      tester,
    ) async {
      await tester.pumpWidget(
        CafeUtezApp(
          repositorio: RepositorioEspia([
            const Pedido(cliente: 'Ana', producto: 'Café', cantidad: 2),
            const Pedido(cliente: 'Luis', producto: 'Torta', cantidad: 4),
          ]),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pedidos: 2 · Piezas: 6'), findsOneWidget);

      await tester.tap(find.byKey(const Key('entregar_0')));
      await tester.pumpAndSettle();

      expect(find.text('Pedidos: 1 · Piezas: 4'), findsOneWidget);
      expect(find.text('Café'), findsNothing);
      expect(find.text('Torta'), findsOneWidget);
    });

    testWidgets('al reabrir el formulario no aparece el error viejo', (
      tester,
    ) async {
      await tester.pumpWidget(CafeUtezApp(repositorio: RepositorioEspia()));
      await tester.pumpAndSettle();
      await abrirFormulario(tester);
      await llenarYAgregar(tester, cliente: 'Al', cantidad: '2');
      expect(find.text('El nombre debe tener al menos 3 letras'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await abrirFormulario(tester);

      expect(find.text('El nombre debe tener al menos 3 letras'), findsNothing);
    });
  });
}
