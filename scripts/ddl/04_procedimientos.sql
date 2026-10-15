/* =============================================================================
   04_procedimientos.sql  —  Procedimientos de carga
   -----------------------------------------------------------------------------
   Se crean dentro de cada base de tipo de carga (lo hace bin/preparar_bd.sh).
   Leen de olimpiadas_staging.dbo.vw_fuente / noc_regions_raw.

   dbo.sp_carga_inicial  -> catálogo de países (carga inicial, antes del FULL backup)
   dbo.sp_cargar         -> una carga filtrada por año, evento y/o deportista.
                            Inserta solo lo que no existe (no duplica si se repite).
   ============================================================================= */
SET NOCOUNT ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_carga_inicial
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF EXISTS (SELECT 1 FROM dbo.bitacora_carga)
    BEGIN
        RAISERROR('La carga inicial ya se ejecuto en esta base. Usa bin/preparar_bd.sh para empezar de nuevo.', 16, 1);
        RETURN;
    END;

    DECLARE @inicio DATETIME2(3) = SYSDATETIME();
    DECLARE @filas  INT;

    BEGIN TRANSACTION;

    INSERT INTO dbo.pais (noc, region, notas)
    SELECT n.noc,
           NULLIF(NULLIF(n.region, ''), 'NA'),
           NULLIF(REPLACE(n.notas, CHAR(13), ''), '')
    FROM olimpiadas_staging.dbo.noc_regions_raw AS n;

    SET @filas = @@ROWCOUNT;

    INSERT INTO dbo.bitacora_carga (tipo, descripcion, filas_fuente, filas_insertadas, duracion_ms)
    VALUES ('inicial', 'Carga inicial: catalogo de paises (NOC)', @filas, @filas,
            DATEDIFF(MILLISECOND, @inicio, SYSDATETIME()));

    COMMIT TRANSACTION;

    SELECT 'pais' AS tabla, @filas AS filas_nuevas;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_cargar
    @tipo          VARCHAR(20),              -- 'anio' | 'deporte' | 'deportista' (para la bitácora)
    @descripcion   VARCHAR(100),
    @anio          SMALLINT,                 -- año de los Juegos
    @temporada     VARCHAR(10)  = 'Summer',  -- 'Summer' | 'Winter'
    @evento        VARCHAR(100) = NULL,      -- ej. 'Athletics Women''s 100 metres'
    @deportista_id INT          = NULL       -- ID del dataset, ej. 13029 = Usain Bolt
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @inicio DATETIME2(3) = SYSDATETIME();
    DECLARE @filas_fuente INT,
            @n_pais INT, @n_edicion INT, @n_deporte INT, @n_evento INT,
            @n_deportista INT, @n_participacion INT, @n_resultado INT;

    /* 1. Filas de staging que corresponden a esta carga */
    SELECT *
    INTO #fuente
    FROM olimpiadas_staging.dbo.vw_fuente
    WHERE anio      = @anio
      AND temporada = @temporada
      AND (@evento        IS NULL OR evento    = @evento)
      AND (@deportista_id IS NULL OR atleta_id = @deportista_id);

    SET @filas_fuente = @@ROWCOUNT;

    IF @filas_fuente = 0
    BEGIN
        RAISERROR('No hay filas en staging con esos filtros. Revisa anio/temporada/evento/deportista.', 16, 1);
        RETURN;
    END;

    BEGIN TRANSACTION;

    /* 2. Países que no vinieron en la carga inicial (ej. SGP no está en noc_regions) */
    INSERT INTO dbo.pais (noc)
    SELECT DISTINCT f.noc
    FROM #fuente AS f
    WHERE NOT EXISTS (SELECT 1 FROM dbo.pais AS p WHERE p.noc = f.noc);
    SET @n_pais = @@ROWCOUNT;

    /* 3. Ediciones */
    INSERT INTO dbo.edicion (nombre, anio, temporada, ciudad)
    SELECT f.juegos, MIN(f.anio), MIN(f.temporada), MIN(f.ciudad)
    FROM #fuente AS f
    WHERE NOT EXISTS (SELECT 1 FROM dbo.edicion AS e WHERE e.nombre = f.juegos)
    GROUP BY f.juegos;
    SET @n_edicion = @@ROWCOUNT;

    /* 4. Deportes */
    INSERT INTO dbo.deporte (nombre)
    SELECT DISTINCT f.deporte
    FROM #fuente AS f
    WHERE NOT EXISTS (SELECT 1 FROM dbo.deporte AS d WHERE d.nombre = f.deporte);
    SET @n_deporte = @@ROWCOUNT;

    /* 5. Eventos */
    INSERT INTO dbo.evento (deporte_id, nombre)
    SELECT MIN(d.deporte_id), f.evento
    FROM #fuente AS f
    JOIN dbo.deporte AS d ON d.nombre = f.deporte
    WHERE NOT EXISTS (SELECT 1 FROM dbo.evento AS e WHERE e.nombre = f.evento)
    GROUP BY f.evento;
    SET @n_evento = @@ROWCOUNT;

    /* 6. Deportistas */
    INSERT INTO dbo.deportista (deportista_id, nombre, sexo)
    SELECT f.atleta_id, MIN(f.nombre), MIN(f.sexo)
    FROM #fuente AS f
    WHERE NOT EXISTS (SELECT 1 FROM dbo.deportista AS a WHERE a.deportista_id = f.atleta_id)
    GROUP BY f.atleta_id;
    SET @n_deportista = @@ROWCOUNT;

    /* 7. Participaciones: deportista + edición (+ país, edad, estatura, peso) */
    INSERT INTO dbo.participacion (deportista_id, edicion_id, pais_id, edad, estatura_cm, peso_kg)
    SELECT f.atleta_id, e.edicion_id, MIN(p.pais_id), MIN(f.edad), MIN(f.estatura_cm), MIN(f.peso_kg)
    FROM #fuente AS f
    JOIN dbo.edicion AS e ON e.nombre = f.juegos
    JOIN dbo.pais    AS p ON p.noc    = f.noc
    WHERE NOT EXISTS (SELECT 1 FROM dbo.participacion AS x
                      WHERE x.deportista_id = f.atleta_id
                        AND x.edicion_id    = e.edicion_id)
    GROUP BY f.atleta_id, e.edicion_id;
    SET @n_participacion = @@ROWCOUNT;

    /* 8. Resultados: participación + evento (+ equipo y medalla) */
    INSERT INTO dbo.resultado (participacion_id, evento_id, equipo, medalla)
    SELECT x.participacion_id, ev.evento_id, MIN(f.equipo), MIN(f.medalla)
    FROM #fuente AS f
    JOIN dbo.edicion       AS e  ON e.nombre = f.juegos
    JOIN dbo.participacion AS x  ON x.deportista_id = f.atleta_id
                                AND x.edicion_id    = e.edicion_id
    JOIN dbo.evento        AS ev ON ev.nombre = f.evento
    WHERE NOT EXISTS (SELECT 1 FROM dbo.resultado AS r
                      WHERE r.participacion_id = x.participacion_id
                        AND r.evento_id        = ev.evento_id)
    GROUP BY x.participacion_id, ev.evento_id;
    SET @n_resultado = @@ROWCOUNT;

    /* 9. Bitácora */
    INSERT INTO dbo.bitacora_carga (tipo, descripcion, filas_fuente, filas_insertadas, duracion_ms)
    VALUES (@tipo, @descripcion, @filas_fuente,
            @n_pais + @n_edicion + @n_deporte + @n_evento + @n_deportista + @n_participacion + @n_resultado,
            DATEDIFF(MILLISECOND, @inicio, SYSDATETIME()));

    COMMIT TRANSACTION;

    /* Resumen de la carga (queda en el log) */
    SELECT @descripcion AS carga, @filas_fuente AS filas_fuente;

    SELECT tabla, filas_nuevas
    FROM (VALUES ('pais', @n_pais), ('edicion', @n_edicion), ('deporte', @n_deporte),
                 ('evento', @n_evento), ('deportista', @n_deportista),
                 ('participacion', @n_participacion), ('resultado', @n_resultado)) AS t (tabla, filas_nuevas);
END;
GO

PRINT 'Procedimientos creados en ' + DB_NAME() + '.';
GO
