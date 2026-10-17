# Diccionario de datos

Este diccionario describe el modelo normalizado creado en cada base de carga (`olimpiadas_anio`, `olimpiadas_deporte` y `olimpiadas_deportista`). Las tres bases tienen el mismo esquema; solo cambia el subconjunto de filas que se carga.

## Convenciones

- **PK**: llave primaria.
- **UK**: restricción de unicidad.
- **FK**: llave foránea.
- **NULL**: el dato puede estar ausente en el dataset.
- Los tipos y longitudes corresponden a `scripts/ddl/03_tablas.sql`.

## Tabla `pais`

Catálogo de Comités Olímpicos Nacionales. Se carga inicialmente desde `noc_regions.csv`.

| Columna | Tipo | Nulo | Clave/restricción | Descripción |
|---|---|---:|---|---|
| `pais_id` | `INT IDENTITY` | No | PK | Identificador interno del país. |
| `noc` | `CHAR(3)` | No | UK | Código NOC de tres caracteres, por ejemplo `GUA`, `USA` o `JAM`. |
| `region` | `VARCHAR(60)` | Sí | — | Región o nombre del país según el catálogo fuente. |
| `notas` | `VARCHAR(60)` | Sí | — | Observaciones del catálogo fuente. |

## Tabla `edicion`

Una edición concreta de los Juegos Olímpicos.

| Columna | Tipo | Nulo | Clave/restricción | Descripción |
|---|---|---:|---|---|
| `edicion_id` | `INT IDENTITY` | No | PK | Identificador interno de la edición. |
| `nombre` | `VARCHAR(20)` | No | UK | Nombre compuesto del dataset, por ejemplo `2008 Summer`. |
| `anio` | `SMALLINT` | No | — | Año de celebración. |
| `temporada` | `VARCHAR(10)` | No | CHECK | Solo admite `Summer` o `Winter`. |
| `ciudad` | `VARCHAR(40)` | No | — | Ciudad registrada para la edición. |

## Tabla `deporte`

Catálogo de deportes olímpicos.

| Columna | Tipo | Nulo | Clave/restricción | Descripción |
|---|---|---:|---|---|
| `deporte_id` | `INT IDENTITY` | No | PK | Identificador interno del deporte. |
| `nombre` | `VARCHAR(40)` | No | UK | Nombre del deporte, por ejemplo `Athletics`. |

## Tabla `evento`

Prueba específica dentro de un deporte.

| Columna | Tipo | Nulo | Clave/restricción | Descripción |
|---|---|---:|---|---|
| `evento_id` | `INT IDENTITY` | No | PK | Identificador interno del evento. |
| `deporte_id` | `INT` | No | FK → `deporte.deporte_id` | Deporte al que pertenece el evento. |
| `nombre` | `VARCHAR(100)` | No | UK | Nombre exacto del evento, por ejemplo `Athletics Women's 100 metres`. |

## Tabla `deportista`

Catálogo de atletas. `deportista_id` conserva el identificador original del dataset.

| Columna | Tipo | Nulo | Clave/restricción | Descripción |
|---|---|---:|---|---|
| `deportista_id` | `INT` | No | PK | Identificador del atleta en el CSV de resultados. |
| `nombre` | `VARCHAR(150)` | No | — | Nombre del atleta. |
| `sexo` | `CHAR(1)` | No | CHECK | `M` o `F`. |

## Tabla `participacion`

Representa a un deportista participando en una edición y representando a un país. Los atributos físicos dependen de esa combinación, no de cada evento.

| Columna | Tipo | Nulo | Clave/restricción | Descripción |
|---|---|---:|---|---|
| `participacion_id` | `INT IDENTITY` | No | PK | Identificador interno de la participación. |
| `deportista_id` | `INT` | No | FK → `deportista.deportista_id` | Atleta que participa. |
| `edicion_id` | `INT` | No | FK → `edicion.edicion_id` | Edición de los Juegos. |
| `pais_id` | `INT` | No | FK → `pais.pais_id` | País o NOC que representa. |
| `edad` | `TINYINT` | Sí | — | Edad registrada en el dataset. |
| `estatura_cm` | `SMALLINT` | Sí | — | Estatura en centímetros. |
| `peso_kg` | `DECIMAL(5,1)` | Sí | — | Peso en kilogramos. |

La restricción `UNIQUE (deportista_id, edicion_id)` evita duplicar la participación de un atleta en una misma edición.

## Tabla `resultado`

Resultado de una participación en un evento. Su llave primaria es compuesta porque una participación puede tener varios eventos.

| Columna | Tipo | Nulo | Clave/restricción | Descripción |
|---|---|---:|---|---|
| `participacion_id` | `INT` | No | PK/FK → `participacion.participacion_id` | Participación del atleta. |
| `evento_id` | `INT` | No | PK/FK → `evento.evento_id` | Evento en el que compitió. |
| `equipo` | `VARCHAR(60)` | Sí | — | Equipo o delegación; en relevos puede incluir un sufijo como `United States-1`. |
| `medalla` | `VARCHAR(6)` | Sí | CHECK | `Oro`, `Plata`, `Bronce` o NULL si no obtuvo medalla. |

## Tabla `bitacora_carga`

Tabla auxiliar para auditar las cargas y comprobar qué estado debe aparecer después de cada restauración.

| Columna | Tipo | Nulo | Clave/restricción | Descripción |
|---|---|---:|---|---|
| `carga_id` | `INT IDENTITY` | No | PK | Consecutivo de la carga. |
| `fecha_hora` | `DATETIME2(0)` | No | DEFAULT | Fecha y hora de ejecución. |
| `tipo` | `VARCHAR(20)` | No | — | `inicial`, `anio`, `deporte` o `deportista`. |
| `descripcion` | `VARCHAR(100)` | No | — | Descripción del filtro aplicado. |
| `filas_fuente` | `INT` | No | — | Filas leídas desde staging. |
| `filas_insertadas` | `INT` | No | — | Suma de filas nuevas insertadas en las tablas de negocio. |
| `duracion_ms` | `INT` | No | — | Duración de la carga en milisegundos. |

## Relaciones

- `deporte 1:N evento`.
- `evento 1:N resultado`.
- `pais 1:N participacion`.
- `deportista 1:N participacion`.
- `edicion 1:N participacion`.
- `participacion 1:N resultado`.

La justificación de tercera forma normal y el diagrama se encuentran en [`modelo_er.md`](modelo_er.md) y [`ERD.png`](ERD.png).
