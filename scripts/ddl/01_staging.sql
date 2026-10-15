/* =============================================================================
   01_staging.sql  —  Base de datos de STAGING (se ejecuta UNA sola vez)
   -----------------------------------------------------------------------------
   Carga los CSV crudos del dataset "120 years of Olympic history" a una base
   aparte llamada olimpiadas_staging. Esta base NO se respalda: es solo la
   fuente desde la que las cargas por año / deporte / deportista toman sus filas.

   Ejecutar:  bin/sql.sh ddl/01_staging.sql
   Esperado:  athlete_events_raw = 271116 filas, noc_regions_raw = 230 filas
   ============================================================================= */
SET NOCOUNT ON;

IF DB_ID(N'olimpiadas_staging') IS NULL
    CREATE DATABASE olimpiadas_staging;
GO

USE olimpiadas_staging;
GO

DROP VIEW  IF EXISTS dbo.vw_fuente;
DROP TABLE IF EXISTS dbo.athlete_events_raw;
DROP TABLE IF EXISTS dbo.noc_regions_raw;
GO

/* Tablas crudas: todo como texto, tal cual viene en el CSV.
   Las columnas siguen el mismo orden del archivo (BULK INSERT mapea por posición). */
CREATE TABLE dbo.athlete_events_raw (
    id        VARCHAR(10),
    nombre    VARCHAR(150),
    sexo      VARCHAR(5),
    edad      VARCHAR(10),
    estatura  VARCHAR(10),
    peso      VARCHAR(20),
    equipo    VARCHAR(60),
    noc       VARCHAR(10),
    juegos    VARCHAR(20),
    anio      VARCHAR(10),
    temporada VARCHAR(10),
    ciudad    VARCHAR(40),
    deporte   VARCHAR(40),
    evento    VARCHAR(100),
    medalla   VARCHAR(10)
);

CREATE TABLE dbo.noc_regions_raw (
    noc    VARCHAR(10),
    region VARCHAR(60),
    notas  VARCHAR(60)
);
GO

/* Carga masiva desde los CSV montados en /datos (carpeta ./datos del proyecto).
   FORMAT = 'CSV' respeta los campos entre comillas, por ejemplo:
   "Speed Skating Women's 1,000 metres"  o  "Cornelia ""Cor"" Aalten"            */
BULK INSERT dbo.athlete_events_raw
FROM '/datos/athlete_events.csv'
WITH (
    FORMAT          = 'CSV',
    FIELDQUOTE      = '"',
    FIRSTROW        = 2,        -- salta la fila de encabezados
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',   -- fin de línea LF
    CODEPAGE        = 'RAW',    -- en SQL Server para Linux es la única opción admitida
    TABLOCK
);

BULK INSERT dbo.noc_regions_raw
FROM '/datos/noc_regions.csv'
WITH (
    FORMAT          = 'CSV',
    FIELDQUOTE      = '"',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    CODEPAGE        = 'RAW',
    TABLOCK
);
GO

/* Vista "limpia" con tipos correctos. Las cargas leen de aquí.
   - 'NA' en el CSV significa dato faltante -> NULL
   - Medallas traducidas al español; 'NA' (sin medalla) -> NULL
   - REPLACE de CHAR(13) por si el archivo llegara con fin de línea Windows (CRLF) */
CREATE VIEW dbo.vw_fuente
AS
SELECT
    CAST(id AS INT)                                              AS atleta_id,
    nombre,
    sexo,
    TRY_CAST(NULLIF(edad, 'NA') AS TINYINT)                      AS edad,
    TRY_CAST(NULLIF(estatura, 'NA') AS SMALLINT)                 AS estatura_cm,
    CAST(ROUND(TRY_CAST(NULLIF(peso, 'NA') AS FLOAT), 1) AS DECIMAL(5, 1)) AS peso_kg,
    equipo,
    noc,
    juegos,
    CAST(anio AS SMALLINT)                                       AS anio,
    temporada,
    ciudad,
    deporte,
    evento,
    CASE REPLACE(medalla, CHAR(13), '')
        WHEN 'Gold'   THEN 'Oro'
        WHEN 'Silver' THEN 'Plata'
        WHEN 'Bronze' THEN 'Bronce'
    END                                                          AS medalla
FROM dbo.athlete_events_raw;
GO

/* Verificación de la carga a staging */
SELECT 'athlete_events_raw' AS tabla, COUNT(*) AS filas, 271116 AS esperado FROM dbo.athlete_events_raw
UNION ALL
SELECT 'noc_regions_raw',            COUNT(*),          230             FROM dbo.noc_regions_raw;
GO
