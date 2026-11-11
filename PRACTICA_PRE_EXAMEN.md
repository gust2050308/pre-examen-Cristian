# Práctica guiada pre-examen — Unidad II: Cafetería UTEZ

**Para qué sirve:** prepararte para el examen práctico de la Unidad II. Aplica **los mismos conceptos**, con **el mismo formato** de instrucciones y la misma forma de calificar.

---

## Índice

1. Cómo se parece al examen
2. Cómo usar esta guía: tres vueltas
3. Paso 0 — Prepara tu computadora (con internet)
4. Paso 1 — Crea el proyecto sin internet
5. Paso 2 — Dominio
6. Paso 3 — Datos
7. Paso 4 — ViewModel con ChangeNotifier
8. Paso 5 — main.dart y provider
9. Paso 6 — Vista 1: lista de pedidos
10. Paso 7 — Vista 2: formulario y navegación
11. Paso 8 — Tu única prueba
12. Paso 9 — Verifica como lo hará el docente
13. Paso 10 — Entrega como en el examen
14. Hoja de contratos (para la vuelta 2 y el simulacro)
15. Errores frecuentes
16. Preguntas de repaso
17. Simulacro de 90 minutos
18. Cómo se califica el examen

---

## Cómo se parece al examen

|  | Esta práctica | El examen |
| --- | --- | --- |
| Caso | Cafetería UTEZ (pedidos) | **Otro caso**, con otros nombres, textos y reglas |
| Pantallas | Lista + formulario con `push` / `pop` | Igual |
| Estado | ViewModel con `ChangeNotifier`, entregado con provider | Igual |
| Capas | `dominio/`, `datos/`, `presentacion/` | Igual |
| Pruebas | **Una** prueba unitaria del ViewModel, escrita por ti | Igual |
| Internet | Practica el simulacro **sin** internet | **Sin** internet |
| Tiempo | Libre en las vueltas 1 y 2; 90 min en el simulacro | 90 min |
| Contratos | Nombres, textos y `Key` exactos | Igual: se califica con pruebas automáticas |
| Calificación | `autoevaluar.sh` te da 90 puntos automáticos | Se usa el mismo formato, más 10 de revisión |

> Si puedes hacer esta práctica **desde cero, sin mirar y en menos de 90 minutos**, estás listo para el examen.

### Lo que vas a construir

```
┌──────────────────────────────────┐        ┌──────────────────────────────────┐
│ Cafetería UTEZ                   │        │ ←  Nuevo pedido                  │
├──────────────────────────────────┤  push  ├──────────────────────────────────┤
│ Pedidos: 2 · Piezas: 5           │ ─────► │ Cliente    [Ana               ]  │
│ (1) Café                      ✓  │        │ Producto   [Café            ▼]   │
│     Ana · x2                     │        │ Cantidad   [3                 ]  │
│ (2) Torta                     ✓  │ ◄───── │ La cantidad debe ser de 1 a 5    │
│     Luis · x3                    │  pop   │                                  │
│                  [+ Nuevo pedido]│        │           [ Agregar ]            │
└──────────────────────────────────┘        └──────────────────────────────────┘
```

- **Pedidos:** lista de pedidos pendientes con un encabezado de totales. El botón ✓ marca el pedido como entregado (lo quita).
- **Nuevo pedido:** si los datos son válidos, guarda y regresa; si no, muestra el error y se queda.

### Cómo se conectan las piezas (MVVM + capas)

```
             PRESENTACIÓN                         DOMINIO              DATOS
┌───────────────────────────────────┐     ┌──────────────────┐   ┌─────────────────────────┐
│ PedidosPage    NuevoPedidoPage    │     │ Pedido           │   │ PedidoRepository        │
│ (Vistas: watch para mostrar,      │     │ validarCliente   │   │   (contrato abstracto)  │
│          read para actuar)        │     │ validarCantidad  │   │          ▲              │
│            │                      │     │ (Dart puro)      │   │ MemoriaPedidoRepository │
│            ▼                      │     └──────────────────┘   └─────────────────────────┘
│ PedidosViewModel (ChangeNotifier) │ ──► usa las reglas    ──►  usa SOLO el contrato
└───────────────────────────────────┘
main.dart: crea MemoriaPedidoRepository y cuelga el ViewModel con ChangeNotifierProvider.
```

---

## Cómo usar esta guía: tres vueltas

| Vuelta | Cómo | Tiempo aprox. |
| --- | --- | --- |
| **1. Guiada** | Sigue los pasos 0 a 10. **Escribe** el código (no copies y pegues): así se te queda. Lee cada "Por qué". Haz los experimentos. | 2 h |
| **2. Con apoyo** | Borra tu proyecto. Hazlo de nuevo usando **solo** la hoja de contratos. Si te atoras, vuelve al paso correspondiente. | 1.5 h |
| **3. Simulacro** | Desconecta el internet, pon un cronómetro de 90 min y hazlo desde cero sin mirar nada. Al final corre `autoevaluar.sh`. | 90 min |

Si en el simulacro sacas 90/90 y terminas con tiempo, estás listo. Si no, revisa en qué renglón perdiste puntos y repite ese paso.

---

## Paso 0 — Prepara tu computadora (con internet)

**Hazlo antes del examen, en la computadora que vas a usar.** Sin esto, en el examen no podrás agregar provider.

`flutter pub add provider --offline` solo funciona si provider **y su dependencia** `nested` ya están en la caché de pub de tu máquina. Con internet, corre:

```bash
dart pub cache add provider --version 6.1.5+1
dart pub cache add nested --version 1.0.0
```

Comprueba que existan estas carpetas:

| Sistema | Carpeta | Deben existir |
| --- | --- | --- |
| macOS / Linux | `~/.pub-cache/hosted/pub.dev/` | `provider-6.1.5+1` y `nested-1.0.0` |
| Windows | `%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\` | `provider-6.1.5+1` y `nested-1.0.0` |

**Prueba de humo:** desconecta el Wi-Fi y corre:

```bash
flutter create --empty --offline --org mx.edu.utez humo
cd humo
flutter pub add provider --offline   # debe terminar sin error
flutter run -d chrome                # debe abrir la app vacía
cd .. && rm -rf humo
```

Si usas el emulador de Android, prueba también sin internet: el primer build de un proyecto nuevo descarga cosas de Gradle y puede fallar. **Chrome es lo más seguro** sin red.

En Windows instala **Git Bash** (viene con Git) para correr los scripts `.sh`.

---

## Paso 1 — Crea el proyecto sin internet

El proyecto **tiene que llamarse** `cafe_utez`: las pruebas importan `package:cafe_utez/...`.

```bash
flutter create --empty --offline --org mx.edu.utez cafe_utez
cd cafe_utez
flutter pub add provider --offline

mkdir -p lib/dominio lib/datos lib/presentacion test
cp ../kit/verificar_practica.sh .     # ajusta la ruta a donde tengas kit/

bash verificar_practica.sh            # casi todo en FALTA: es el punto de partida
```

**Por qué `--offline`:** le dice a Flutter que no intente descargar nada y use lo que ya hay en la caché. Sin esa bandera, sin internet, `flutter create` y `pub add` fallan.

**Checkpoint:** `pubspec.yaml` dice `name: cafe_utez` y tiene `provider:` en `dependencies`.

---

## Paso 2 — Dominio

Archivo `lib/dominio/pedido.dart`. El dominio es **Dart puro**: no importa nada de Flutter. Aquí viven la entidad y las reglas del negocio.

```dart
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
```

**Por qué así:**

- Las reglas devuelven `String?`: el **mensaje** si hay error, `null` si todo está bien. Así la vista puede mostrar el texto tal cual.
- `trim()` antes de medir: `' Al '` tiene 4 caracteres, pero solo 2 letras reales.
- `validarCantidad` recibe `int?` y no `String`: convertir texto a número es trabajo del ViewModel; la regla solo decide si el número es válido.
- `productosCafe` y `cantidadMaxima` **no son estado**: nunca cambian mientras corre la app.

**Checkpoint:** corre `bash verificar_practica.sh`; el punto 2 debe decir `lib/dominio no importa package:flutter`.

---

## Paso 3 — Datos

La capa de datos tiene dos archivos: el **contrato** (qué se puede hacer) y una **implementación** (cómo se hace).

`lib/datos/pedido_repository.dart`

```dart
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
```

`lib/datos/memoria_pedido_repository.dart`

```dart
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
```

**Por qué así:**

- Todo es `Future` aunque la memoria responda al instante: una base de datos o una API **sí** tardarían. Si mañana cambias la memoria por una API, el contrato no cambia.
- `List.unmodifiable`: si devolvieras `_pedidos` directamente, cualquiera podría hacer `.add()` desde fuera y saltarse el repositorio.
- El repositorio es la **fuente de verdad**: el ViewModel solo tiene una copia.

**Checkpoint:** el script debe marcar OK en `PedidoRepository es un contrato abstracto` y `MemoriaPedidoRepository implementa el contrato`.

---

## Paso 4 — ViewModel con ChangeNotifier

Archivo `lib/presentacion/pedidos_view_model.dart`. Es la pieza más importante (vale 25 puntos en el examen).

```dart
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
```

**Por qué así:**

- **`foundation.dart` y no `material.dart`:** `ChangeNotifier` vive en `foundation`. El ViewModel no dibuja, así que no necesita widgets.
- **Recibe `PedidoRepository` (el contrato), no `MemoriaPedidoRepository`:** así en la prueba o en producción le puedes pasar cualquier implementación.
- `int.tryParse` devuelve `null` si el texto no es número (`'dos'`), y `null` es justo lo que `validarCantidad` convierte en `'Escribe la cantidad con número'`.
- **`??` encadena las reglas:** si `validarCliente` devuelve un mensaje, ese gana y ni se evalúa la cantidad. Si devuelve `null`, se usa lo que diga `validarCantidad`.
- **Tres `notifyListeners()` en `registrar`:** uno para el error, uno al empezar (`guardando = true` desactiva el botón) y uno al terminar (la lista se entera y el botón se reactiva). Si olvidas el último, el pedido sí se guarda, pero la pantalla no se entera.
- **Después de guardar se vuelve a leer `todos()`:** el repositorio es la fuente de verdad.
- **`totalPiezas` es getter:** es estado **derivado**. Si fuera un campo que sumas a mano, tarde o temprano no coincidiría con `pedidos`.

### Los cuatro tipos de estado en esta app

| Tipo | Dónde | Ejemplo |
| --- | --- | --- |
| Efímero | `State` de un widget, con `setState` | El producto elegido en el Dropdown, el texto de los campos |
| Compartido | ViewModel, con `notifyListeners` | `pedidos`, `error`, `guardando` |
| Derivado | Getter del ViewModel | `totalPiezas` |
| Persistido | Repositorio | La lista privada `_pedidos` |

**Checkpoint:** el punto 3 del script debe estar todo en OK.

---

## Paso 5 — main.dart y provider

Archivo `lib/main.dart`. Es el único que conoce la implementación concreta del repositorio y el que "arma" la app.

```dart
// Práctica guiada pre-examen Unidad II — Cafetería UTEZ (solución).
// Único archivo que conoce la implementación concreta del repositorio.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'datos/memoria_pedido_repository.dart';
import 'datos/pedido_repository.dart';
import 'presentacion/pedidos_page.dart';
import 'presentacion/pedidos_view_model.dart';

void main() {
  runApp(CafeUtezApp(repositorio: MemoriaPedidoRepository()));
}

class CafeUtezApp extends StatelessWidget {
  const CafeUtezApp({super.key, required this.repositorio});

  final PedidoRepository repositorio;

  @override
  Widget build(BuildContext context) {
    // El provider va ARRIBA de MaterialApp: así la ruta que se abre con
    // Navigator.push también encuentra el ViewModel.
    return ChangeNotifierProvider(
      create: (_) => PedidosViewModel(repositorio)..cargar(),
      child: MaterialApp(
        title: 'Cafetería UTEZ',
        theme: ThemeData(colorSchemeSeed: Colors.brown),
        home: const PedidosPage(),
      ),
    );
  }
}
```

**Por qué así:**

- **`CafeUtezApp` recibe el repositorio por constructor:** las pruebas pueden armar la app con un repositorio falso. En el examen, las pruebas del docente arrancan tu app así.
- `..cargar()` es la cascada: crea el ViewModel, llama a `cargar()` y le entrega a provider **el ViewModel** (no el `Future`).
- **`ChangeNotifierProvider` crea el ViewModel una sola vez** y llama a `dispose()` por ti cuando sale del árbol.
- **El provider va arriba de `MaterialApp`.** Esto es lo más importante del paso. Lo vas a comprobar en el experimento del paso 7.

> Todavía no compila porque falta `PedidosPage`. Es normal: sigue al paso 6.

---

## Paso 6 — Vista 1: lista de pedidos

Archivo `lib/presentacion/pedidos_page.dart`.

```dart
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
```

**Por qué así:**

- **`StatelessWidget`:** no guarda nada propio. Todo lo que muestra viene del ViewModel.
- **`context.watch` en `build`** para **mostrar**: se suscribe y la pantalla se redibuja con cada `notifyListeners()`.
- **`context.read` en los `onPressed`** para **actuar**: solo toma el ViewModel, sin suscribirse. Usar `watch` dentro de un callback lanza un error.
- **`Expanded` alrededor del `ListView`:** un `ListView` dentro de un `Column` sin `Expanded` truena por altura infinita.
- **`Key('entregar_$i')` y `Key('nuevo')`:** las pruebas encuentran los botones por su `Key`. En el examen, las `Key` vienen en el contrato: cópialas exactas.
- **`limpiarError()` antes del `push`:** si el usuario dejó un error y regresó con la flecha, al volver a abrir el formulario no debe ver el error viejo. Se llama aquí, en el callback, y no en `initState` del formulario, porque avisar mientras se construye una pantalla causa el error "setState() or markNeedsBuild() called during build".
- **No importa nada de `datos/`:** la vista solo conoce al ViewModel.

> Todavía falta `NuevoPedidoPage`. Sigue al paso 7.

---

## Paso 7 — Vista 2: formulario y navegación

Archivo `lib/presentacion/nuevo_pedido_page.dart`.

```dart
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
```

**Por qué así:**

- **`StatefulWidget` solo por estado efímero:** los controladores y el producto elegido solo le importan a esta pantalla. El dato **compartido** (los pedidos) vive en el ViewModel.
- **`dispose()` libera los controladores:** si no, quedan ocupando memoria cuando la pantalla se cierra.
- **No recibe el ViewModel ni devuelve datos con `pop(resultado)`:** el pedido viaja por el ViewModel compartido. Por eso la lista ya lo muestra al regresar, sin que tú le pases nada.
- **`if (!ok || !mounted) return;`:** después de un `await`, la pantalla pudo haberse cerrado. `mounted` evita usar un `context` que ya no existe (y quita el aviso `use_build_context_synchronously`).
- **`onPressed: vm.guardando ? null : _agregar`:** `null` desactiva el botón; así no se guarda dos veces si el usuario toca rápido.
- `initialValue` en el Dropdown es el nombre actual del parámetro (versiones viejas usaban `value`).

### Ahora sí: corre la app

```bash
flutter run -d chrome
```

Prueba los tres casos:

1. Abre **Nuevo pedido**, escribe `Al` y toca **Agregar**: aparece `El nombre debe tener al menos 3 letras` y no regresa.
2. Corrige a `Ana`, cantidad `3` y agrega: regresa a la lista con `Pedidos: 1 · Piezas: 3`.
3. Toca ✓: la fila desaparece y el encabezado vuelve a 0.

### Experimento: dónde va el provider

En `main.dart`, cambia **temporalmente** el `build` de `CafeUtezApp` por esto:

```dart
    return MaterialApp(
      title: 'Cafetería UTEZ',
      theme: ThemeData(colorSchemeSeed: Colors.brown),
      home: ChangeNotifierProvider(
        create: (_) => PedidosViewModel(repositorio)..cargar(),
        child: const PedidosPage(),
      ),
    );
```

Haz **Hot restart** y toca **Nuevo pedido**: verás `ProviderNotFoundException`. La lista sí funciona, pero el formulario no.

**Por qué:** `MaterialApp` crea un `Navigator`. Las pantallas que abres con `push` se cuelgan **del** `Navigator`, al lado de `home`, no dentro de él. Si el provider está en `home`, la pantalla nueva no lo tiene arriba y no lo encuentra. Con el provider **arriba** de `MaterialApp`, todas las rutas lo ven.

```
Provider dentro de home (MAL)            Provider arriba de MaterialApp (BIEN)
MaterialApp                              ChangeNotifierProvider
└─ Navigator                             └─ MaterialApp
   ├─ ChangeNotifierProvider                └─ Navigator
   │  └─ PedidosPage        ✓                  ├─ PedidosPage        ✓
   └─ NuevoPedidoPage       ✗ no lo ve         └─ NuevoPedidoPage    ✓
```

**Regresa el código a como estaba** antes de seguir.

---

## Paso 8 — Tu única prueba

En el examen se pide **exactamente una** prueba, del ViewModel, escrita por ti. Practícala aquí con el mismo formato.

Archivo `test/pedidos_view_model_test.dart`:

```dart
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
```

```bash
flutter test
```

**Por qué así:**

- **Preparar / Actuar / Comprobar:** es la estructura que se espera y que el docente revisa (vale puntos en la revisión manual).
- **No necesita pantalla ni red:** gracias a las capas, la lógica vive en el ViewModel y se prueba sola. Es la recompensa de separar capas.
- **`addListener` cuenta avisos:** así compruebas que el ViewModel sí llamó a `notifyListeners()`.
- **La línea más valiosa es la del repositorio:** `vm.pedidos` es solo la copia del ViewModel; consultar `repositorio.todos()` demuestra que de verdad se delegó en la capa de datos.
- `vm.dispose()` al final: quien crea un `ChangeNotifier`, lo libera.

### Experimento: ¿tu prueba detecta errores?

1. En el ViewModel, comenta la línea `await _repositorio.guardar(...)` (las tres líneas).
2. Corre `flutter test`: debe fallar en `expect(vm.pedidos, hasLength(1))`.
3. Regresa el código.

Una prueba que no falla cuando rompes el código no sirve. En el examen, una prueba que no comprueba nada real (como `expect(true, isTrue)`) vale 0.

---

## Paso 9 — Verifica como lo hará el docente

### 9.1 Script de capas

```bash
bash verificar_practica.sh
```

Debe terminar en `Resultado: todo OK`. Revisa capas, `ChangeNotifier`, provider (`watch` y `read`), navegación, `dispose()` y que haya **exactamente una** prueba tuya.

### 9.2 Autoevaluación (como la batería del docente)

```bash
mkdir -p test/_autoevaluacion
cp ../kit/autoevaluacion_test.dart test/_autoevaluacion/
flutter test test/_autoevaluacion -r expanded
```

Son 19 pruebas agrupadas como la rúbrica (R1 a R4). **No cuentan como "tu prueba":** el script excluye la carpeta `_autoevaluacion`. Si una falla, el mensaje te dice qué texto o `Key` esperaba.

### 9.3 Puntaje como en el examen

Desde la carpeta `PRE EXAMEN/`:

```bash
bash kit/autoevaluar.sh ruta/a/tu/cafe_utez
```

Trabaja sobre una **copia** de tu proyecto y te imprime algo así:

```
================ Resumen automático ================
  R1 Dominio ............................  15 / 15
  R2 Datos ..............................  10 / 10
  R3 ViewModel ..........................  25 / 25
  R4 Vistas, provider y navegación ......  25 / 25
  R5 Tu prueba pasa .....................  10 / 10
  Script de capas en OK .................   5 /  5
  ------------------------------------------------
  Automático ............................  90 / 90
  + R6 revisión del docente (10): calidad de tu prueba, app que corre, código limpio
```

### 9.4 Analizador

```bash
flutter analyze lib
```

Debe decir `No issues found!`. En el examen, los avisos del analizador cuentan en "código limpio".

---

## Paso 10 — Entrega como en el examen

```bash
flutter clean
cd ..
zip -r MATRICULA_APELLIDO_cafe_utez.zip cafe_utez          # macOS / Linux
```

En Windows (PowerShell):

```powershell
Compress-Archive -Path cafe_utez -DestinationPath MATRICULA_APELLIDO_cafe_utez.zip
```

`flutter clean` borra `build/` y `.dart_tool/`, que pesan mucho y se regeneran solos.

---

## Hoja de contratos

Úsala en la **vuelta 2** y en el **simulacro**. En el examen vas a recibir una hoja así, con otros nombres. Todo lo que no está aquí lo decides tú.

### Estructura

```
lib/dominio/pedido.dart
lib/datos/pedido_repository.dart
lib/datos/memoria_pedido_repository.dart
lib/presentacion/pedidos_view_model.dart
lib/presentacion/pedidos_page.dart
lib/presentacion/nuevo_pedido_page.dart
lib/main.dart
test/pedidos_view_model_test.dart        ← tu única prueba
```

### Dominio (`pedido.dart`, sin Flutter)

| Elemento | Contrato |
| --- | --- |
| Constantes | `productosCafe = ['Café', 'Torta', 'Jugo', 'Galletas']`, `cantidadMaxima = 5` |
| Entidad | `Pedido({required String cliente, required String producto, required int cantidad})`, `const`, campos `final` |
| `String? validarCliente(String)` | vacío o espacios → `'Escribe el nombre del cliente'` · menos de 3 letras sin contar espacios de los extremos → `'El nombre debe tener al menos 3 letras'` · si no, `null` |
| `String? validarCantidad(int?)` | `null` → `'Escribe la cantidad con número'` · menor que 1 o mayor que 5 → `'La cantidad debe ser de 1 a 5'` · si no, `null` |

### Datos (sin Flutter)

| Elemento | Contrato |
| --- | --- |
| `abstract class PedidoRepository` | `Future<void> guardar(Pedido)`, `Future<void> entregar(int indice)`, `Future<List<Pedido>> todos()` |
| `MemoriaPedidoRepository implements PedidoRepository` | lista privada; `todos()` devuelve `List.unmodifiable` |

### ViewModel (`PedidosViewModel extends ChangeNotifier`)

| Miembro | Contrato |
| --- | --- |
| Constructor | `PedidosViewModel(PedidoRepository repositorio)` |
| Estado | `List<Pedido> pedidos = []`, `String? error`, `bool guardando = false` |
| Derivado | `int get totalPiezas` (suma de `cantidad`) |
| `Future<void> cargar()` | lee `todos()` y avisa |
| `Future<bool> registrar(String cliente, String producto, String cantidadTexto)` | `int.tryParse` del texto sin espacios · valida cliente y luego cantidad · si falla: `error`, avisa, `false`, sin tocar el repo · si pasa: `guardando = true`, `error = null`, avisa, guarda con cliente sin espacios, relee, `guardando = false`, avisa, `true` |
| `Future<void> entregar(int indice)` | entrega en el repo, relee y avisa |
| `void limpiarError()` | `error = null` y avisa |

### `main.dart`

`main()` arranca `CafeUtezApp(repositorio: MemoriaPedidoRepository())`. `CafeUtezApp` es `StatelessWidget` con `required this.repositorio` (tipo `PedidoRepository`), usa `ChangeNotifierProvider` y su `home` es `const PedidosPage()`.

### Vistas

| Pantalla | Elemento | Contrato |
| --- | --- | --- |
| `PedidosPage` (`StatelessWidget`, `const`, sin vm por constructor) | AppBar | `'Cafetería UTEZ'` |
|  | Encabezado | `'Pedidos: N · Piezas: P'` |
|  | Lista vacía | `'Sin pedidos'` |
|  | Fila | `title`: producto · `subtitle`: `'cliente · xN'` (ej. `Ana · x3`) |
|  | Botón entregar | `IconButton` con `Key('entregar_$i')` → `entregar(i)` |
|  | FAB | `Key('nuevo')` → `limpiarError()` y `Navigator.push` a `NuevoPedidoPage` |
| `NuevoPedidoPage` (`StatefulWidget`, `const`, sin vm por constructor) | AppBar | `'Nuevo pedido'` |
|  | Campos | `TextField` `Key('cliente')`, `DropdownButtonFormField<String>` `Key('producto')` (arranca en el primero), `TextField` `Key('cantidad')` |
|  | Error | `Text` con el mensaje exacto de `error` si no es `null` |
|  | Botón | `FilledButton` `'Agregar'`, desactivado si `guardando` |
|  | Al agregar | si `registrar` devuelve `true` → `Navigator.pop`; si no, se queda |

### Tu prueba

Un solo `test('registrar con datos válidos guarda en el repositorio y avisa', ...)` con Preparar/Actuar/Comprobar: `true`, sin error, 1 pedido, `totalPiezas == 2`, el repositorio lo tiene y hubo avisos.

---

## Errores frecuentes

| Lo que ves | Causa | Cómo se arregla |
| --- | --- | --- |
| `ProviderNotFoundException` al abrir el formulario | El provider está dentro de `home` | Súbelo arriba de `MaterialApp` (experimento del paso 7) |
| La lista no se actualiza al regresar | Falta el último `notifyListeners()` de `registrar`, o usaste `read` en `build` | `watch` en `build`; avisa al terminar de guardar |
| El botón se queda desactivado | `guardando` nunca vuelve a `false` | Ponlo en `false` y avisa al final |
| `Tried to listen to a value exposed with provider, from outside of the widget tree` | `context.watch` dentro de un `onPressed` | En callbacks usa `context.read` |
| `Vertical viewport was given unbounded height` | `ListView` dentro de `Column` sin `Expanded` | Envuélvelo en `Expanded` |
| El error viejo aparece al reabrir el formulario | No llamas a `limpiarError()` antes del `push` | Llámalo en el `onPressed` del FAB |
| `setState() or markNeedsBuild() called during build` | Llamaste a `limpiarError()` en `initState` del formulario | Llámalo en el callback, antes del `push` |
| `Target of URI doesn't exist: 'package:cafe_utez/...'` en las pruebas | El `name:` de `pubspec.yaml` no es `cafe_utez` | Crea el proyecto con el nombre exacto |
| Aviso `use_build_context_synchronously` | Usas `context` después de un `await` sin revisar | `if (!mounted) return;` antes de `Navigator.pop` |
| `' Al '` pasa la validación | No hiciste `trim()` antes de medir | `trim()` primero |
| La autoevaluación dice que la lista se puede modificar | `todos()` devuelve la lista privada | `List.unmodifiable(_pedidos)` |
| El script dice "se esperaba 1 prueba y hay 2" | Dejaste el `widget_test.dart` de ejemplo u otra prueba | Deja solo tu prueba |
| `flutter pub add provider --offline` falla | provider o nested no están en la caché | Paso 0, con internet |

---

## Preguntas de repaso

Contéstalas tú primero; luego abre la respuesta. En el examen el docente puede hacerte algunas de estas, señalando **tu propio código**.

<details>
<summary>1. ¿Quién es la fuente de verdad de los pedidos?</summary>

El repositorio. El ViewModel tiene una copia (`pedidos`) que vuelve a leer con `todos()` después de guardar o entregar.
</details>

<details>
<summary>2. ¿Por qué <code>totalPiezas</code> es getter y no un campo?</summary>

Es estado derivado: se calcula de `pedidos`. Si fuera un campo, habría dos verdades que se pueden desfasar (por ejemplo, si olvidas restarlo al entregar).
</details>

<details>
<summary>3. ¿Qué estado es efímero y cuál es compartido en esta app?</summary>

Efímero: los controladores y el producto elegido en `NuevoPedidoPage` (se maneja con `setState`). Compartido: `pedidos`, `error` y `guardando` en el ViewModel (se avisa con `notifyListeners`).
</details>

<details>
<summary>4. ¿Cuál es la diferencia entre <code>ChangeNotifier</code> y provider?</summary>

`ChangeNotifier` es el que **avisa** que algo cambió (el ViewModel lo extiende). provider solo **entrega** ese ViewModel a las pantallas a través del árbol de widgets y llama a `dispose()` por ti. Sin provider tendrías que pasar el ViewModel por constructor a cada pantalla y escucharlo con `ListenableBuilder`.
</details>

<details>
<summary>5. ¿Cuándo se usa <code>context.watch</code> y cuándo <code>context.read</code>?</summary>

`watch` en `build`, para **mostrar** datos: se suscribe y redibuja. `read` en callbacks (`onPressed`), para **actuar**: toma el ViewModel sin suscribirse.
</details>

<details>
<summary>6. ¿Por qué <code>ChangeNotifierProvider</code> va arriba de <code>MaterialApp</code>?</summary>

Porque las rutas que se abren con `Navigator.push` se cuelgan del `Navigator` que crea `MaterialApp`, no de `home`. Si el provider está en `home`, la segunda pantalla no lo encuentra (`ProviderNotFoundException`).
</details>

<details>
<summary>7. ¿Por qué el ViewModel importa <code>foundation.dart</code> y no <code>material.dart</code>?</summary>

Porque no dibuja nada. `ChangeNotifier` está en `foundation`. Importar `material` sería señal de que mezclaste vista con ViewModel.
</details>

<details>
<summary>8. ¿Por qué el ViewModel recibe <code>PedidoRepository</code> y no <code>MemoriaPedidoRepository</code>?</summary>

Para depender del contrato y no de un detalle. Así puedes darle un repositorio falso en las pruebas o uno de API en producción sin tocar el ViewModel.
</details>

<details>
<summary>9. Si mañana los pedidos vienen de una API, ¿qué archivos cambias?</summary>

Creas uno nuevo en `datos/` que implemente `PedidoRepository` y cambias la línea de `main.dart` que lo elige. El ViewModel, las vistas y el dominio no cambian.
</details>

<details>
<summary>10. ¿Por qué tu prueba no necesita pantalla ni red?</summary>

Porque la lógica vive en el ViewModel y el dominio, separados de la vista, y el repositorio en memoria no usa red. Es la recompensa de las capas.
</details>

<details>
<summary>11. ¿Qué pasa si olvidas el último <code>notifyListeners()</code> de <code>registrar</code>?</summary>

El pedido sí se guarda en el repositorio y en `pedidos`, pero nadie se entera: la lista no se redibuja y el botón sigue desactivado porque la vista no vio que `guardando` volvió a `false`.
</details>

<details>
<summary>12. ¿Por qué se revisa <code>mounted</code> antes de <code>Navigator.pop</code>?</summary>

Porque entre el `await` y el `pop` la pantalla pudo cerrarse (por ejemplo, con la flecha atrás). Usar el `context` de una pantalla que ya no existe causa errores.
</details>

<details>
<summary>13. ¿Dónde vive la regla "mínimo 3 letras"? ¿Puede estar también en la vista?</summary>

Solo en `validarCliente`, en el dominio. Si la repites en la vista o en el ViewModel, tienes dos lugares que cambiar y se pueden contradecir.
</details>

---

## Simulacro de 90 minutos

Cuando ya hiciste las vueltas 1 y 2:

1. Borra tu `cafe_utez` (o crea otro con otro nombre de carpeta, pero `name: cafe_utez` en `pubspec.yaml`).
2. **Desconecta el internet.**
3. Ten a la mano **solo** la hoja de contratos.
4. Pon un cronómetro de **90 minutos** y sigue el mismo cronograma del examen:

| Etapa | Qué | Min | Acumulado |
| --- | --- | --- | --- |
| 0 | Arranque del proyecto | 5 | 5 |
| 1 | Dominio | 10 | 15 |
| 2 | Datos | 8 | 23 |
| 3 | ViewModel | 17 | 40 |
| 4 | `main.dart` y vista de lista | 15 | 55 |
| 5 | Formulario y navegación | 15 | 70 |
| 6 | Tu prueba | 10 | 80 |
| 7 | Verificar y entregar | 10 | 90 |

5. Al terminar, corre `bash kit/autoevaluar.sh ruta/a/tu/cafe_utez`.

**Estrategia para el examen real:**

- **Lee todo el contrato primero** (3 minutos). Subraya textos y `Key`.
- **Copia los textos exactos del contrato**, incluidos acentos y el punto medio `·`. Un acento faltante hace fallar una prueba.
- **Si te atoras en una etapa, sigue con la siguiente.** Cada renglón se califica por separado. Un ViewModel a medias pero que compila vale más que uno perfecto que no compila.
- **Compila seguido** (`flutter analyze lib`). Un proyecto que no compila vale máximo 40.
- **Corre el script de verificación** del examen antes de entregar.
- **Escribe tu prueba aunque no hayas terminado las vistas:** solo necesita el ViewModel y el repositorio.

### Checklist antes de entregar

- [ ] `pubspec.yaml` con el nombre exacto y `provider` en `dependencies`
- [ ] `dominio/` y `datos/` sin imports de Flutter
- [ ] El ViewModel extiende `ChangeNotifier`, importa `foundation.dart` y recibe el **contrato**
- [ ] Las reglas solo viven en el dominio
- [ ] El estado derivado es un getter
- [ ] `ChangeNotifierProvider` **arriba** de `MaterialApp`
- [ ] `watch` en `build`, `read` en callbacks
- [ ] `Navigator.push` para abrir, `Navigator.pop` solo si se guardó
- [ ] `dispose()` en el formulario
- [ ] Textos y `Key` idénticos al contrato
- [ ] **Una** prueba, con Preparar/Actuar/Comprobar, que consulta el repositorio
- [ ] Script en OK, `flutter analyze lib` limpio, `flutter test` en verde
- [ ] `flutter clean` y zip con el nombre pedido

---

## Cómo se califica el examen

Mismo esquema que `autoevaluar.sh`:

| Renglón | Puntos | Cómo |
| --- | --- | --- |
| R1 Dominio | 15 | Pruebas automáticas del docente |
| R2 Datos | 10 | Pruebas automáticas del docente |
| R3 ViewModel | 25 | Pruebas automáticas del docente |
| R4 Vistas, provider y navegación | 25 | Pruebas automáticas del docente |
| R5 Tu prueba | 10 | Existe, pasa y comprueba algo real |
| Script de capas | 5 | El script del examen en OK |
| R6 Revisión del docente | 10 | Calidad de tu prueba, app que corre, código limpio |
| **Total** | **100** |  |

En R1 a R4 los puntos son proporcionales a las pruebas que pasan dentro de cada renglón. Si el proyecto no compila, las pruebas automáticas dan 0 y el máximo es 40. Usar otro gestor en lugar de provider deja R4 en 0.

¡Éxito en el examen!
