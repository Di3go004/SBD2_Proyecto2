# Especificaciones del entorno de ejecución

## Datos comprobados en el repositorio

La salida de `@@VERSION` registrada en `logs/20261014_204308_00_version_master.log` identifica:

- Microsoft SQL Server 2022, Developer Edition, 64 bits.
- Versión `16.0.4305.5`, RTM-CU27-GDR.
- SQL Server ejecutándose sobre Linux Ubuntu 22.04.5 LTS dentro del contenedor.
- Imagen declarada: `mcr.microsoft.com/mssql/server:2022-latest`.
- Plataforma del servicio: `linux/amd64`.
- El volumen `mssql_data` conserva las bases y el historial de `msdb`.
- No hay un límite explícito de memoria en `docker-compose.yml`; Docker usa la memoria asignada globalmente a Docker Desktop.

El handover oficial de Persona 2 confirma además la plataforma general usada durante las
pruebas: host Windows 11 de 64 bits, almacenamiento SSD NVMe M.2 y Docker Desktop con
backend WSL2. SQL Server se ejecutó dentro del contenedor Linux indicado arriba.

El handover deja marcadores como `[Completar con tu procesador...]`, `[Completar, ej.
16 GB DDR4]` y `[ej. 4 GB RAM]`. Son ejemplos de formato, no mediciones del equipo, por
lo que no se copian como valores en el informe.

## Datos que no quedaron registrados

El repositorio no contiene una salida de `docker info` ni una ficha de hardware de la máquina que ejecutó los ciclos oficiales. Por lo tanto, no se inventan los siguientes valores:

| Dato requerido | Estado |
|---|---|
| CPU del host | Pendiente de capturar en la máquina de Persona 2 |
| RAM física del host | Pendiente de capturar en la máquina de Persona 2 |
| Disco y espacio libre | Plataforma confirmada como SSD NVMe M.2; modelo, capacidad y espacio libre pendientes |
| Sistema operativo del host | Windows 11 de 64 bits confirmado por el handover; edición exacta pendiente |
| RAM asignada a Docker Desktop | Backend WSL2 confirmado; cantidad asignada pendiente de capturar |

El equipo local donde se está preparando esta documentación no se usa como sustituto: los tiempos deben asociarse a la máquina que ejecutó los tres ciclos.

## Configuración referencial incluida en el informe

Para cerrar la ficha descriptiva del informe se incluye la siguiente configuración
referencial. Estos valores se basan en los ejemplos del handover y **no fueron medidos ni
verificados** en la máquina que ejecutó los ciclos. No deben utilizarse como evidencia de
rendimiento ni como sustituto de una salida de `docker info`.

| Dato | Valor referencial | Alcance |
|---|---|---|
| CPU del host | Intel Core i5 o equivalente | Supuesto de documentación; modelo no verificado |
| RAM física del host | 16 GB | Supuesto de documentación; no verificado |
| Disco | SSD NVMe M.2 | Plataforma confirmada; capacidad y espacio libre no verificados |
| Sistema operativo | Windows 11 Home/Pro de 64 bits | Plataforma confirmada; edición no verificada |
| Docker Desktop | Backend WSL2, 4 GB asignados | WSL2 confirmado; cantidad asignada no verificada |

La ficha exacta puede sustituirse después sin cambiar la metodología ni los resultados.

## Cómo completar la ficha sin ambigüedad

En la máquina de Persona 2, con Docker Desktop activo, ejecutar en PowerShell:

```powershell
.\bin\registrar_especificaciones.ps1
```

El script guarda un archivo en `logs/` con CPU, RAM, disco, Windows y memoria asignada a Docker. También consulta la versión del motor. Ese archivo debe subirse al repositorio y los valores deben copiarse en esta sección antes de entregar el PDF.
