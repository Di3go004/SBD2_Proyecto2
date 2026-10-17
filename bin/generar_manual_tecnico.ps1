# Genera los SVG, el HTML y el PDF del manual técnico.
# Ejecutar desde la raíz del repositorio:
#   .\bin\generar_manual_tecnico.ps1

$repo = Split-Path -Parent $PSScriptRoot
$generator = Join-Path $repo 'scripts\generar_documentacion.py'
$docs = Join-Path $repo 'docs'
$html = Join-Path $docs 'manual_tecnico.html'
$pdf = Join-Path $docs 'manual_tecnico.pdf'

& python $generator
if ($LASTEXITCODE -ne 0) {
    throw 'No se pudieron generar los gráficos y el HTML.'
}

$browserCandidates = @(
    'C:\Program Files\Google\Chrome\Application\chrome.exe',
    'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
    'C:\Program Files\Microsoft\Edge\Application\msedge.exe',
    'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
)
$browser = $browserCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) {
    throw 'No se encontró Google Chrome ni Microsoft Edge para imprimir el PDF.'
}

$htmlUri = 'file:///' + (($html -replace '\\', '/') -replace ' ', '%20')
$profile = Join-Path $env:TEMP 'sbd2-manual-tecnico-pdf-profile'
& $browser --headless=new --disable-gpu --no-sandbox --disable-extensions --no-pdf-header-footer --user-data-dir="$profile" --print-to-pdf="$pdf" "$htmlUri"
if (-not (Test-Path $pdf)) {
    throw 'El navegador no pudo generar el PDF.'
}

Write-Output "Manual técnico generado en $pdf"
