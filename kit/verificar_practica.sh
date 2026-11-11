#!/usr/bin/env bash
# Práctica guiada pre-examen Unidad II — Cafetería UTEZ: verificación de capas y cableado
#
#   bash verificar_practica.sh
#
# Se corre desde la raíz de cafe_utez/ (o desde la carpeta que lo contiene).
# Revisa que las capas estén separadas, que MVVM y provider estén cableados
# como se pidió y que exista exactamente UNA prueba tuya. No revisa que la app
# funcione: para eso está la autoevaluación (test/_autoevaluacion/).
#
# Es el mismo tipo de revisión que usará el docente en el examen.
#
# Si el archivo llegó con saltos de línea de Windows (CRLF), se corre una copia limpia. Esta línea debe terminar en "#".
if grep -q $'\r' "$0" 2>/dev/null; then d=$(cd "$(dirname "$0")" && pwd); limpio="${TMPDIR:-/tmp}/verificar_practica_lf.sh"; tr -d '\r' < "$0" > "$limpio"; VERIFICAR_DIR="$d" exec bash "$limpio" "$@"; fi #

aqui="${VERIFICAR_DIR:-$(cd "$(dirname "$0")" && pwd)}"

proyecto=""
for candidato in "$1" "$aqui" "$aqui/cafe_utez" "$PWD" "$PWD/cafe_utez"; do
  [ -n "$candidato" ] || continue
  if [ -f "$candidato/pubspec.yaml" ] && grep -q "^name: cafe_utez" "$candidato/pubspec.yaml"; then
    proyecto="$candidato"
    break
  fi
done

if [ -z "$proyecto" ]; then
  echo "No encuentro el proyecto cafe_utez (falta pubspec.yaml con name: cafe_utez)."
  echo "Copia este script a la raíz de cafe_utez/ y córrelo desde ahí."
  exit 1
fi

cd "$proyecto" || exit 1
echo "Proyecto: $proyecto"

fallas=0

ok()    { echo "  OK     $1"; }
falta() { echo "  FALTA  $1"; fallas=$((fallas + 1)); }

# Solo cuentan las líneas import, no los comentarios que mencionan el paquete.
importa() { grep -rqnE "^[[:space:]]*import[[:space:]]+['\"].*$1" "$2"; }
# Código del archivo sin las líneas que son solo comentario.
codigo() { grep -vE "^[[:space:]]*//" "$1"; }
# true si el código (sin comentarios) contiene el patrón.
usa() { codigo "$2" | grep -qE "$1"; }

dom=lib/dominio/pedido.dart
contrato=lib/datos/pedido_repository.dart
memoria=lib/datos/memoria_pedido_repository.dart
vm=lib/presentacion/pedidos_view_model.dart
lista=lib/presentacion/pedidos_page.dart
form=lib/presentacion/nuevo_pedido_page.dart
main=lib/main.dart

echo
echo "1) Archivos del contrato"
for f in "$dom" "$contrato" "$memoria" "$vm" "$lista" "$form" "$main"; do
  if [ -f "$f" ]; then ok "$f"; else falta "$f no existe"; fi
done
if grep -qE "^[[:space:]]+provider:" pubspec.yaml; then ok "pubspec.yaml tiene provider"; else falta "pubspec.yaml no tiene provider en dependencies"; fi

echo
echo "2) Dominio y datos no conocen Flutter"
for capa in lib/dominio lib/datos; do
  if [ -d "$capa" ] && ! importa "package:flutter" "$capa"; then
    ok "$capa no importa package:flutter"
  else
    falta "$capa no existe o importa package:flutter"
  fi
done
if [ -f "$contrato" ] && usa "abstract[[:space:]]+(interface[[:space:]]+)?class[[:space:]]+PedidoRepository" "$contrato"; then
  ok "PedidoRepository es un contrato abstracto"
else
  falta "PedidoRepository no es abstract class"
fi
if [ -f "$memoria" ] && usa "implements[[:space:]]+PedidoRepository" "$memoria"; then
  ok "MemoriaPedidoRepository implementa el contrato"
else
  falta "MemoriaPedidoRepository no implementa PedidoRepository"
fi

echo
echo "3) ViewModel: avisa, no dibuja, no sabe de dónde salen los datos"
if [ -f "$vm" ]; then
  if importa "material.dart" "$vm"; then falta "$vm importa material.dart (usa foundation.dart)"; else ok "$vm no importa material.dart"; fi
  if importa "provider" "$vm"; then falta "$vm importa provider: el ViewModel no debe saber quién lo entrega"; else ok "$vm no depende de provider"; fi
  if usa "extends[[:space:]]+ChangeNotifier" "$vm"; then ok "PedidosViewModel extiende ChangeNotifier"; else falta "PedidosViewModel no extiende ChangeNotifier"; fi
  if usa "notifyListeners\(\)" "$vm"; then ok "$vm llama a notifyListeners()"; else falta "$vm nunca llama a notifyListeners()"; fi
  if usa "MemoriaPedidoRepository|memoria_pedido" "$vm"; then falta "$vm conoce la implementación en memoria"; else ok "$vm solo conoce el contrato PedidoRepository"; fi
  if usa "validarCliente" "$vm" && usa "validarCantidad" "$vm"; then ok "$vm usa las reglas del dominio"; else falta "$vm no llama a validarCliente y validarCantidad"; fi
  if usa "get[[:space:]]+totalPiezas" "$vm"; then ok "totalPiezas es estado derivado (getter)"; else falta "totalPiezas debe ser un getter calculado"; fi
else
  falta "$vm no existe"
fi

echo
echo "4) Vistas: provider (watch para mostrar, read para actuar)"
for v in "$lista" "$form"; do
  [ -f "$v" ] || { falta "$v no existe"; continue; }
  if importa "package:provider" "$v"; then ok "$v importa provider"; else falta "$v no importa package:provider"; fi
  if usa "context\.watch<PedidosViewModel>" "$v"; then ok "$v muestra con context.watch"; else falta "$v no usa context.watch<PedidosViewModel>"; fi
  if usa "context\.read<PedidosViewModel>" "$v"; then ok "$v actúa con context.read"; else falta "$v no usa context.read<PedidosViewModel>"; fi
  if importa "datos/" "$v"; then falta "$v importa algo de lib/datos"; else ok "$v no importa nada de lib/datos"; fi
  if usa "required[[:space:]]+this\.(vm|viewModel)|ListenableBuilder" "$v"; then falta "$v recibe o escucha el ViewModel a mano"; else ok "$v pide el ViewModel al árbol"; fi
done
malos=$(grep -rnE "(on[A-Z][A-Za-z]*)[[:space:]]*:.*\.watch|\(\)[[:space:]]*(async[[:space:]]*)?=>.*\.watch" lib/presentacion 2>/dev/null \
  | grep -vE "^[^:]+:[0-9]+:[[:space:]]*//")
if [ -z "$malos" ]; then
  ok "ningún callback usa watch"
else
  while IFS= read -r m; do falta "watch dentro de un callback: $m"; done <<< "$malos"
fi

echo
echo "5) Navegación"
if [ -f "$lista" ] && usa "Navigator\.(of\(context\)\.)?push" "$lista" && usa "NuevoPedidoPage" "$lista"; then
  ok "$lista abre NuevoPedidoPage con Navigator.push"
else
  falta "$lista no hace Navigator.push a NuevoPedidoPage"
fi
if [ -f "$form" ] && usa "Navigator\.(of\(context\)\.)?pop" "$form"; then
  ok "$form regresa con Navigator.pop"
else
  falta "$form no hace Navigator.pop"
fi
if [ -f "$form" ] && usa "void[[:space:]]+dispose\(\)" "$form"; then ok "$form libera sus controladores en dispose()"; else falta "$form no tiene dispose()"; fi

echo
echo "6) main.dart arma la app"
if [ -f "$main" ] && usa "ChangeNotifierProvider" "$main"; then ok "$main cuelga el ViewModel con ChangeNotifierProvider"; else falta "$main no usa ChangeNotifierProvider"; fi
if [ -f "$main" ] && usa "class[[:space:]]+CafeUtezApp" "$main"; then ok "$main define CafeUtezApp"; else falta "$main no define CafeUtezApp"; fi
intrusos=$(grep -rlE "^[[:space:]]*import[[:space:]]+['\"].*memoria_pedido_repository" lib 2>/dev/null \
  | grep -vE "lib/main\.dart$")
if [ -z "$intrusos" ]; then
  ok "MemoriaPedidoRepository solo se importa en main.dart"
else
  for i in $intrusos; do falta "$i importa la implementación en memoria"; done
fi

echo
echo "7) Exactamente UNA prueba"
pruebas=0
if [ -d test ]; then
  # test/_autoevaluacion es la batería de práctica; no cuenta.
  pruebas=$(grep -rhE "^[[:space:]]*(test|testWidgets)[[:space:]]*\(" test \
    --include="*.dart" --exclude-dir=_autoevaluacion 2>/dev/null | wc -l | tr -d ' ')
fi
if [ "$pruebas" -eq 1 ]; then
  ok "hay exactamente 1 prueba en test/"
else
  falta "se esperaba 1 prueba en test/ y hay $pruebas"
fi
if [ -f test/pedidos_view_model_test.dart ]; then ok "test/pedidos_view_model_test.dart existe"; else falta "test/pedidos_view_model_test.dart no existe"; fi

echo
if [ "$fallas" -eq 0 ]; then
  echo "Resultado: todo OK. Ahora corre: flutter test test/_autoevaluacion"
  exit 0
else
  echo "Resultado: $fallas punto(s) en FALTA."
  exit 1
fi
