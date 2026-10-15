#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# sql.sh — Ejecuta un archivo .sql dentro del contenedor de SQL Server (sqlcmd)
#
# Uso:  bin/sql.sh <archivo.sql> [base_de_datos] [VARIABLE=valor ...]
# Ej.:  bin/sql.sh ddl/01_staging.sql
#       bin/sql.sh validacion/validar.sql olimpiadas_anio
#       bin/sql.sh carga/por_anio.sql olimpiadas_anio N=1
#
#  - <archivo.sql> es relativo a la carpeta scripts/ (el contenedor la ve en /scripts)
#  - Imprime la fecha y hora del sistema operativo al inicio y al final
#  - Guarda toda la salida en logs/AAAAMMDD_HHMMSS_<archivo>_<base>.log
#  - Si el script SQL falla, este comando también falla (sqlcmd -b)
# -----------------------------------------------------------------------------
set -euo pipefail
export MSYS_NO_PATHCONV=1   # Git Bash (Windows): no convertir las rutas /scripts/...

RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
if [[ ! -f "$RAIZ/.env" ]]; then
  echo "Falta el archivo .env  ->  cp .env.example .env" >&2
  exit 1
fi
# shellcheck disable=SC1091
source "$RAIZ/.env"
SA_PASSWORD="${SA_PASSWORD%$'\r'}"   # por si .env se guardó con fin de línea de Windows

CONTENEDOR="${CONTENEDOR:-olimpiadas-sql}"
SQLCMD="/opt/mssql-tools18/bin/sqlcmd"

ARCHIVO="${1:?Uso: bin/sql.sh <archivo.sql> [base_de_datos] [VARIABLE=valor ...]}"
BD="${2:-master}"
shift $(( $# >= 2 ? 2 : 1 ))

VARS=()
for par in "$@"; do VARS+=(-v "$par"); done

mkdir -p "$RAIZ/logs"
LOG="$RAIZ/logs/$(date +%Y%m%d_%H%M%S)_$(basename "$ARCHIVO" .sql)_${BD}.log"

{
  echo "=== INICIO $(date '+%Y-%m-%d %H:%M:%S') | $ARCHIVO | BD=$BD ${*:-} ==="
  docker exec -i "$CONTENEDOR" "$SQLCMD" -S localhost -U sa -P "$SA_PASSWORD" -C -b \
    -d "$BD" -W -s "|" ${VARS[@]+"${VARS[@]}"} -i "/scripts/$ARCHIVO"
  echo "=== FIN    $(date '+%Y-%m-%d %H:%M:%S') ==="
} 2>&1 | tee "$LOG"

echo "(log guardado en ${LOG#"$RAIZ"/})"
