#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# ver_tablas.sh — SELECT * de todas las tablas de un tipo de carga
#
# Uso:  bin/ver_tablas.sh <anio|deporte|deportista>
# -----------------------------------------------------------------------------
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
TIPO="${1:?Uso: bin/ver_tablas.sh <anio|deporte|deportista>}"
"$DIR/sql.sh" validacion/ver_tablas.sql "olimpiadas_$TIPO"
