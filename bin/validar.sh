#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# validar.sh — Conteos, huellas, bitácora, fragmentación y DBCC CHECKDB
#
# Uso:  bin/validar.sh <anio|deporte|deportista>
# Úsalo después de cada carga y después de cada restauración (y toma captura
# con el reloj del sistema visible).
# -----------------------------------------------------------------------------
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
TIPO="${1:?Uso: bin/validar.sh <anio|deporte|deportista>}"
"$DIR/sql.sh" validacion/validar.sql "olimpiadas_$TIPO"
