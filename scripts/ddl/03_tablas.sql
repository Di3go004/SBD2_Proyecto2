/* =============================================================================
   03_tablas.sql  —  Modelo relacional normalizado (3FN) de los Juegos Olímpicos
   -----------------------------------------------------------------------------
   Se ejecuta dentro de la base del tipo de carga (lo hace bin/preparar_bd.sh).

   Modelo:
     pais ─┐
           ├─< participacion >─┬─< resultado >── evento >── deporte
   deportista ┘                │
   edicion ────────────────────┘

   - participacion: un deportista en UNA edición de los Juegos representando a un país
                    (edad, estatura y peso dependen de esa edición).
   - resultado:     la participación en UN evento concreto, con su equipo y medalla.
   - bitacora_carga: registro de cada carga ejecutada (sirve para validar qué
                    cargas quedaron después de restaurar un respaldo).
   El dataset es texto ASCII, por eso se usa VARCHAR.
   ============================================================================= */
SET NOCOUNT ON;
GO

CREATE TABLE dbo.pais (
    pais_id  INT IDENTITY(1, 1) NOT NULL,
    noc      CHAR(3)            NOT NULL,   -- código del Comité Olímpico Nacional (GUA, USA, JAM...)
    region   VARCHAR(60)        NULL,
    notas    VARCHAR(60)        NULL,
    CONSTRAINT pk_pais     PRIMARY KEY (pais_id),
    CONSTRAINT uq_pais_noc UNIQUE (noc)
);

CREATE TABLE dbo.edicion (
    edicion_id INT IDENTITY(1, 1) NOT NULL,
    nombre     VARCHAR(20)        NOT NULL,  -- '2008 Summer'
    anio       SMALLINT           NOT NULL,
    temporada  VARCHAR(10)        NOT NULL,
    ciudad     VARCHAR(40)        NOT NULL,  -- 1956 Summer tuvo 2 sedes; se guarda una
    CONSTRAINT pk_edicion           PRIMARY KEY (edicion_id),
    CONSTRAINT uq_edicion_nombre    UNIQUE (nombre),
    CONSTRAINT ck_edicion_temporada CHECK (temporada IN ('Summer', 'Winter'))
);

CREATE TABLE dbo.deporte (
    deporte_id INT IDENTITY(1, 1) NOT NULL,
    nombre     VARCHAR(40)        NOT NULL,
    CONSTRAINT pk_deporte        PRIMARY KEY (deporte_id),
    CONSTRAINT uq_deporte_nombre UNIQUE (nombre)
);

CREATE TABLE dbo.evento (
    evento_id  INT IDENTITY(1, 1) NOT NULL,
    deporte_id INT                NOT NULL,
    nombre     VARCHAR(100)       NOT NULL,  -- "Athletics Women's 100 metres"
    CONSTRAINT pk_evento         PRIMARY KEY (evento_id),
    CONSTRAINT uq_evento_nombre  UNIQUE (nombre),
    CONSTRAINT fk_evento_deporte FOREIGN KEY (deporte_id) REFERENCES dbo.deporte (deporte_id)
);

CREATE TABLE dbo.deportista (
    deportista_id INT          NOT NULL,     -- se conserva el ID original del dataset
    nombre        VARCHAR(150) NOT NULL,
    sexo          CHAR(1)      NOT NULL,
    CONSTRAINT pk_deportista      PRIMARY KEY (deportista_id),
    CONSTRAINT ck_deportista_sexo CHECK (sexo IN ('M', 'F'))
);

CREATE TABLE dbo.participacion (
    participacion_id INT IDENTITY(1, 1) NOT NULL,
    deportista_id    INT                NOT NULL,
    edicion_id       INT                NOT NULL,
    pais_id          INT                NOT NULL,
    edad             TINYINT            NULL,
    estatura_cm      SMALLINT           NULL,
    peso_kg          DECIMAL(5, 1)      NULL,
    CONSTRAINT pk_participacion            PRIMARY KEY (participacion_id),
    CONSTRAINT uq_participacion            UNIQUE (deportista_id, edicion_id),
    CONSTRAINT fk_participacion_deportista FOREIGN KEY (deportista_id) REFERENCES dbo.deportista (deportista_id),
    CONSTRAINT fk_participacion_edicion    FOREIGN KEY (edicion_id)    REFERENCES dbo.edicion (edicion_id),
    CONSTRAINT fk_participacion_pais       FOREIGN KEY (pais_id)       REFERENCES dbo.pais (pais_id)
);

CREATE TABLE dbo.resultado (
    participacion_id INT         NOT NULL,
    evento_id        INT         NOT NULL,
    equipo           VARCHAR(60) NULL,       -- ej. 'Jamaica' o 'United States-1' en relevos
    medalla          VARCHAR(6)  NULL,       -- 'Oro' | 'Plata' | 'Bronce' | NULL
    CONSTRAINT pk_resultado               PRIMARY KEY (participacion_id, evento_id),
    CONSTRAINT fk_resultado_participacion FOREIGN KEY (participacion_id) REFERENCES dbo.participacion (participacion_id),
    CONSTRAINT fk_resultado_evento        FOREIGN KEY (evento_id)        REFERENCES dbo.evento (evento_id),
    CONSTRAINT ck_resultado_medalla       CHECK (medalla IN ('Oro', 'Plata', 'Bronce'))
);

CREATE TABLE dbo.bitacora_carga (
    carga_id         INT IDENTITY(1, 1) NOT NULL,
    fecha_hora       DATETIME2(0)       NOT NULL CONSTRAINT df_bitacora_fecha DEFAULT (SYSDATETIME()),
    tipo             VARCHAR(20)        NOT NULL,   -- inicial | anio | deporte | deportista
    descripcion      VARCHAR(100)       NOT NULL,
    filas_fuente     INT                NOT NULL,   -- filas leídas de staging
    filas_insertadas INT                NOT NULL,   -- filas nuevas en todas las tablas
    duracion_ms      INT                NOT NULL,
    CONSTRAINT pk_bitacora_carga PRIMARY KEY (carga_id)
);
GO

PRINT 'Tablas creadas en ' + DB_NAME() + '.';
GO
