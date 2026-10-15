#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# descargar_datos.sh — Descarga el dataset "120 years of Olympic history"
#                      (271,116 filas, Atenas 1896 a Río 2016) a ./datos
#
# Fuente: copia pública en GitHub del proyecto TidyTuesday (2021-07-27) del
# dataset de Kaggle de Randi Griffin. No necesita cuenta de Kaggle.
# -----------------------------------------------------------------------------
set -euo pipefail
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
URL="https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-07-27"

mkdir -p "$RAIZ/datos"
curl -fL -o "$RAIZ/datos/athlete_events.csv" "$URL/olympics.csv"
curl -fL -o "$RAIZ/datos/noc_regions.csv"    "$URL/regions.csv"

echo
echo "Lineas (incluye encabezado):"
wc -l "$RAIZ/datos/athlete_events.csv" "$RAIZ/datos/noc_regions.csv"
echo "Esperado: 271117 y 231"
