-- =====================================================================
--  Capa de Reportería  -  schema "billing"
--  Repositorio de referencia — TIBI Consulting
--
--  Tres tablas:
--    1) maestro_precios   -> el mantenedor. Define país, operadora, tipo,
--                            precio, moneda Y el mapeo hacia los planes del
--                            archivo mensual (plan_prefijo + regla opcional).
--                            HISTORIZADA (append-only): cada cambio de
--                            precio es una fila nueva con su fecha de
--                            vigencia. Nunca se hace UPDATE de precio.
--    2) resultado_cobros  -> el cruce cantidad (SIMs) x precio, por periodo.
--                            Idempotente (DELETE + INSERT al recalcular).
--    3) log_ejecucion     -> bitácora, una fila por cada corrida.
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS billing;

-- ---------------------------------------------------------------------
-- 1) MAESTRO DE PRECIOS  (mantenedor de precios Y de mapeo)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS billing.maestro_precios (
    id              BIGSERIAL     PRIMARY KEY,
    fecha           DATE          NOT NULL,           -- fecha de vigencia del precio
    pais            VARCHAR(60)   NOT NULL,
    operador        VARCHAR(60)   NOT NULL,
    tipo_operador   VARCHAR(60)   NOT NULL,
    precio_unitario NUMERIC(18,6),                    -- NULL = fila "solo SIMs" (sin cobro)
    moneda          VARCHAR(10),                       -- NULL = fila "solo SIMs"
    -- mapeo hacia el archivo mensual (esto es lo que hace el sistema data-driven)
    plan_prefijo    TEXT,                              -- texto con que matchea el plan (startswith)
    regla           TEXT,                              -- opcional: '< 1GB' / '>= 1GB' / etc.
    fecha_carga     TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_maestro_precios_llave
    ON billing.maestro_precios (pais, operador, tipo_operador, fecha);

-- ---------------------------------------------------------------------
-- 2) RESULTADO DE COBROS  (p*q por periodo)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS billing.resultado_cobros (
    id              BIGSERIAL     PRIMARY KEY,
    fecha_ejecucion TIMESTAMPTZ   NOT NULL,
    periodo         CHAR(6)       NOT NULL,
    pais            VARCHAR(60),
    operador        VARCHAR(60),
    tipo_operador   VARCHAR(60),
    plan_prefijo    VARCHAR(80),
    sims_total      INTEGER       NOT NULL,
    precio_unitario NUMERIC(18,6),                    -- NULL si la llave no tiene precio
    moneda          VARCHAR(10),
    monto           NUMERIC(20,4),                     -- p*q ; NULL si no hay precio
    comentario      VARCHAR(200)
);

CREATE INDEX IF NOT EXISTS ix_resultado_cobros_periodo
    ON billing.resultado_cobros (periodo);

-- ---------------------------------------------------------------------
-- 3) LOG DE EJECUCIÓN  (bitácora)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS billing.log_ejecucion (
    id              BIGSERIAL     PRIMARY KEY,
    fecha_ejecucion TIMESTAMPTZ   NOT NULL DEFAULT now(),
    periodo         CHAR(6)       NOT NULL,
    archivo_origen  VARCHAR(300),
    filas_generadas INTEGER,
    sims_totales    BIGINT,
    modo            VARCHAR(20)                         -- 'raw' | 'reporte'
);
