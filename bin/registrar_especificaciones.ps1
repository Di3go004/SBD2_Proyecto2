# registrar_especificaciones.ps1
# Captura las especificaciones del host que ejecuta los ciclos y la memoria de Docker.
# Ejecutar desde la raíz del repositorio con Docker Desktop activo.

$repo = Split-Path -Parent $PSScriptRoot
$logs = Join-Path $repo 'logs'
New-Item -ItemType Directory -Force -Path $logs | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$out = Join-Path $logs ("{0}_especificaciones_servidor.txt" -f $stamp)

$computer = Get-CimInstance Win32_ComputerSystem
$processor = Get-CimInstance Win32_Processor | Select-Object -First 1
$os = Get-CimInstance Win32_OperatingSystem
$systemDrive = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$env:SystemDrive'"

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("fecha_captura=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss K')")
$lines.Add("hostname=$env:COMPUTERNAME")
$lines.Add("fabricante=$($computer.Manufacturer)")
$lines.Add("modelo=$($computer.Model)")
$lines.Add("cpu=$($processor.Name)")
$lines.Add("nucleos=$($processor.NumberOfCores)")
$lines.Add("procesadores_logicos=$($computer.NumberOfLogicalProcessors)")
$lines.Add(("ram_fisica_gb={0:N2}" -f ($computer.TotalPhysicalMemory / 1GB)))
$lines.Add("sistema_operativo=$($os.Caption)")
$lines.Add("version_windows=$($os.Version)")
$lines.Add("compilacion_windows=$($os.BuildNumber)")
$lines.Add("arquitectura=$($os.OSArchitecture)")
$lines.Add(("disco_{0}_tamano_gb={1:N2}" -f $env:SystemDrive, ($systemDrive.Size / 1GB)))
$lines.Add(("disco_{0}_libre_gb={1:N2}" -f $env:SystemDrive, ($systemDrive.FreeSpace / 1GB)))

$dockerInfo = & docker info --format '{{.ServerVersion}}|{{.NCPU}}|{{.MemTotal}}' 2>&1
if ($LASTEXITCODE -eq 0) {
    $parts = "$dockerInfo".Trim().Split('|')
    $lines.Add("docker_version=$($parts[0])")
    $lines.Add("docker_cpus=$($parts[1])")
    $lines.Add(("docker_memoria_gb={0:N2}" -f ([double]$parts[2] / 1GB)))
} else {
    $lines.Add('docker_estado=NO DISPONIBLE; ejecutar de nuevo con Docker Desktop activo')
    $lines.Add("docker_error=$dockerInfo")
}

$lines | Set-Content -Encoding utf8 -Path $out
Write-Output "Especificaciones guardadas en $out"
Write-Output "Ejecutar también: bin/sql.sh validacion/00_version.sql"
