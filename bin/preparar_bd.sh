#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# preparar_bd.sh — Crea DESDE CERO la base de un tipo de carga:
#                  base vacía + tablas + procedimientos de carga.
#
# Uso:  bin/preparar_bd.sh <anio|deporte|deportista>
# Crea: olimpiadas_anio | olimpiadas_deporte | olimpiadas_deportista
# -----------------------------------------------------------------------------
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

TIPO="${1:?Uso: bin/preparar_bd.sh <anio|deporte|deportista>}"
case "$TIPO" in
  anio|deporte|deportista) ;;
  *) echo "Tipo invalido: $TIPO (usa anio, deporte o deportista)" >&2; exit 1 ;;
esac
BD="olimpiadas_$TIPO"

read -r -p "Esto BORRA y vuelve a crear la base $BD si ya existe. ¿Continuar? (s/n) " R
[[ "$R" == "s" || "$R" == "S" ]] || { echo "Cancelado."; exit 0; }

"$DIR/sql.sh" ddl/02_crear_bd.sql master "BD=$BD"
"$DIR/sql.sh" ddl/03_tablas.sql "$BD"
"$DIR/sql.sh" ddl/04_procedimientos.sql "$BD"

echo
echo "Listo: $BD creada y vacia. Siguiente paso:  bin/cargar.sh $TIPO 0"
