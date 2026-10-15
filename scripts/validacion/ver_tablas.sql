/* =============================================================================
   ver_tablas.sql  —  SELECT * de cada tabla (capturas que pide el enunciado)
   -----------------------------------------------------------------------------
   Ejecutar:  bin/ver_tablas.sh <anio|deporte|deportista>
   Al final de cada SELECT, sqlcmd imprime "(N rows affected)": inclúyelo en la
   captura. En la carga por año hay decenas de miles de filas; la captura muestra
   el final del resultado y esa línea con el total. Si prefieres verlo en
   cuadrícula, abre el mismo SELECT en SSMS, DBeaver o la extensión de VS Code.
   ============================================================================= */
SELECT DB_NAME() AS base_de_datos, SYSDATETIME() AS fecha_hora_servidor;

SELECT * FROM dbo.pais           ORDER BY pais_id;
SELECT * FROM dbo.edicion        ORDER BY edicion_id;
SELECT * FROM dbo.deporte        ORDER BY deporte_id;
SELECT * FROM dbo.evento         ORDER BY evento_id;
SELECT * FROM dbo.deportista     ORDER BY deportista_id;
SELECT * FROM dbo.participacion  ORDER BY participacion_id;
SELECT * FROM dbo.resultado      ORDER BY participacion_id, evento_id;
SELECT * FROM dbo.bitacora_carga ORDER BY carga_id;
GO
