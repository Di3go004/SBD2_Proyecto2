#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# cargar.sh — Ejecuta una carga de datos
#
# Uso:  bin/cargar.sh <anio|deporte|deportista> <N>
#   N = 0      carga inicial (catálogo de países)  -> luego RESPALDO COMPLETO
#   N = 1..3   cargas del tipo                     -> luego RESPALDO DIFERENCIAL
# -----------------------------------------------------------------------------
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

TIPO="${1:?Uso: bin/cargar.sh <anio|deporte|deportista> <0|1|2|3>}"
N="${2:?Uso: bin/cargar.sh <anio|deporte|deportista> <0|1|2|3>}"
case "$TIPO" in
  anio|deporte|deportista) ;;
  *) echo "Tipo invalido: $TIPO (usa anio, deporte o deportista)" >&2; exit 1 ;;
esac
BD="olimpiadas_$TIPO"

case "$N" in
  0)     "$DIR/sql.sh" carga/00_carga_inicial.sql "$BD" ;;
  1|2|3) "$DIR/sql.sh" "carga/por_$TIPO.sql" "$BD" "N=$N" ;;
  *)     echo "N debe ser 0, 1, 2 o 3" >&2; exit 1 ;;
esac

echo
echo "Carga $N de '$TIPO' terminada. Ahora:  bin/validar.sh $TIPO  y  bin/ver_tablas.sh $TIPO  (capturas)"
