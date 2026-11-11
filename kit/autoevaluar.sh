#!/usr/bin/env bash
# Práctica guiada pre-examen Unidad II — autoevaluación con puntos.
#
#   bash autoevaluar.sh <carpeta_de_tu_proyecto_cafe_utez>
#
# Funciona igual que la calificación del examen: trabaja sobre una COPIA
# temporal (tu proyecto no se modifica), corre el script de capas, tu prueba,
# la batería de autoevaluación por renglón y flutter analyze, y suma puntos.
# La revisión manual del docente (R6, 10 pts) no se puede automatizar.

set -u

kit="$(cd "$(dirname "$0")" && pwd)"
origen="${1:-}"

if [ -z "$origen" ] || [ ! -f "$origen/pubspec.yaml" ]; then
  echo "Uso: bash autoevaluar.sh <carpeta_con_pubspec.yaml>"
  exit 1
fi
if ! grep -q "^name: cafe_utez" "$origen/pubspec.yaml"; then
  echo "AVISO: el pubspec.yaml no dice name: cafe_utez. Las pruebas no van a compilar."
fi

tmp="$(mktemp -d)"
copia="$tmp/cafe_utez"
mkdir -p "$copia"
# Se copia sin build/ ni .dart_tool/ para que sea rápido.
(cd "$origen" && tar --exclude=build --exclude=.dart_tool -cf - .) | (cd "$copia" && tar -xf -)
echo "Copia de trabajo: $copia"

cd "$copia" || exit 1
flutter pub get --offline > /dev/null 2>&1 || echo "AVISO: flutter pub get --offline falló."

echo
echo "================ Script de capas (copia limpia) ================"
bash "$kit/verificar_practica.sh" "$copia"
faltas_script=$?

echo
echo "================ Tu prueba ================"
alumno_ok=0
if flutter test test/pedidos_view_model_test.dart > "$tmp/alumno.txt" 2>&1; then
  alumno_ok=1
  echo "  PASA"
else
  echo "  NO PASA (o no existe). Últimas líneas:"
  tail -n 15 "$tmp/alumno.txt"
fi

rm -rf test/_autoevaluacion
mkdir -p test/_autoevaluacion
cp "$kit/autoevaluacion_test.dart" test/_autoevaluacion/

# Corre un group() de la batería. Si todas sus pruebas pasan da los puntos
# completos; si no, puntos proporcionales a las que pasan (redondeo hacia abajo).
# Deja el resultado en la variable $puntos.
renglon() {
  local nombre="$1" valor="$2" archivo
  archivo="$tmp/$(echo "$nombre" | tr -c 'A-Za-z0-9\n' '_').txt"
  flutter test test/_autoevaluacion/autoevaluacion_test.dart \
    --plain-name "$nombre" -r expanded > "$archivo" 2>&1
  local pasan fallan
  pasan=$(grep -oE "\+[0-9]+" "$archivo" | tail -1 | tr -d '+')
  fallan=$(grep -oE "\-[0-9]+:" "$archivo" | tail -1 | tr -d ':-')
  pasan=${pasan:-0}
  fallan=${fallan:-0}
  local total=$((pasan + fallan))
  if [ "$total" -eq 0 ]; then
    puntos=0
    echo "  NO COMPILA  $nombre  (0/$valor) — ver $archivo"
    grep -m 5 -E "Error:" "$archivo" | sed 's/^/             /'
  elif [ "$fallan" -eq 0 ]; then
    puntos=$valor
    echo "  OK          $nombre  ($valor/$valor, $pasan pruebas)"
  else
    puntos=$((valor * pasan / total))
    echo "  PARCIAL     $nombre  ($puntos/$valor, pasan $pasan de $total) — ver $archivo"
    grep -E "\[E\]$" "$archivo" | sed -E 's/^.*-[0-9]+: //; s/ \[E\]$//; s/^/             falla: /'
    grep -m 1 -oE "The following [A-Za-z]+ was thrown" "$archivo" | sed 's/^/             /'
  fi
}

echo
echo "================ Autoevaluación ================"
renglon "R1 Dominio" 15; r1=$puntos
renglon "R2 Datos" 10; r2=$puntos
renglon "R3 ViewModel (ChangeNotifier)" 25; r3=$puntos
renglon "R4 Vistas, provider y navegación" 25; r4=$puntos

r5=0
[ "$alumno_ok" -eq 1 ] && r5=10
rs=0
[ "$faltas_script" -eq 0 ] && rs=5

echo
echo "================ flutter analyze lib ================"
flutter analyze lib 2>&1 | tail -n 5

total=$((r1 + r2 + r3 + r4 + r5 + rs))
echo
echo "================ Resumen automático ================"
printf "  R1 Dominio ............................ %3s / 15\n" "$r1"
printf "  R2 Datos .............................. %3s / 10\n" "$r2"
printf "  R3 ViewModel .......................... %3s / 25\n" "$r3"
printf "  R4 Vistas, provider y navegación ...... %3s / 25\n" "$r4"
printf "  R5 Tu prueba pasa ..................... %3s / 10\n" "$r5"
printf "  Script de capas en OK ................. %3s /  5\n" "$rs"
printf "  ------------------------------------------------\n"
printf "  Automático ............................ %3s / 90\n" "$total"
echo "  + R6 revisión del docente (10): calidad de tu prueba, app que corre, código limpio"
echo
echo "Copia temporal (bórrala cuando termines): $tmp"
