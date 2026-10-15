# Modelo entidad-relación

GitHub dibuja este diagrama automáticamente. Para el PDF, copien el bloque en https://mermaid.live y exporten la imagen.

```mermaid
erDiagram
    PAIS ||--o{ PARTICIPACION : "representa"
    DEPORTISTA ||--o{ PARTICIPACION : "participa"
    EDICION ||--o{ PARTICIPACION : "en"
    PARTICIPACION ||--|{ RESULTADO : "compite"
    EVENTO ||--o{ RESULTADO : "de"
    DEPORTE ||--|{ EVENTO : "agrupa"

    PAIS {
        int pais_id PK
        char noc UK "GUA, USA, JAM"
        varchar region
        varchar notas
    }
    EDICION {
        int edicion_id PK
        varchar nombre UK "2008 Summer"
        smallint anio
        varchar temporada "Summer o Winter"
        varchar ciudad
    }
    DEPORTE {
        int deporte_id PK
        varchar nombre UK
    }
    EVENTO {
        int evento_id PK
        int deporte_id FK
        varchar nombre UK
    }
    DEPORTISTA {
        int deportista_id PK "ID original del dataset"
        varchar nombre
        char sexo "M o F"
    }
    PARTICIPACION {
        int participacion_id PK
        int deportista_id FK "UK con edicion_id"
        int edicion_id FK
        int pais_id FK
        tinyint edad
        smallint estatura_cm
        decimal peso_kg
    }
    RESULTADO {
        int participacion_id PK, FK
        int evento_id PK, FK
        varchar equipo
        varchar medalla "Oro, Plata, Bronce o NULL"
    }
```

Tabla auxiliar (no forma parte del modelo de negocio): `BITACORA_CARGA (carga_id PK, fecha_hora, tipo, descripcion, filas_fuente, filas_insertadas, duracion_ms)`. Registra cada carga y permite comprobar, después de restaurar, qué cargas contiene la base.

## Justificación de la normalización (3FN)

- **DEPORTISTA**: nombre y sexo dependen solo del deportista, así que no se repiten en cada evento.
- **PARTICIPACION**: edad, estatura, peso y país dependen del deportista *en una edición*, no de cada evento. Por eso van en una tabla con clave única (deportista, edición).
- **RESULTADO**: el equipo y la medalla dependen de la participación *en un evento*. Por ejemplo, en relevos el equipo puede ser "United States-1".
- **EVENTO → DEPORTE**: el deporte depende del evento. Se separa para evitar una dependencia transitiva.
- **EDICION**: año, temporada y ciudad dependen de la edición ("2008 Summer").
