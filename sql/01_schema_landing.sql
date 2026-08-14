-- =====================================================================
--  Capa RAW (landing)  -  schema configurable vía env var RAW_SCHEMA
--  Repositorio de referencia — TIBI Consulting
--
--  Landing tipada del archivo mensual. Se guarda TODO sin filtrar; el
--  filtro de cuentas internas/administrativas se aplica recién en el
--  cruce hacia resultado_cobros, para que esta capa quede íntegra y sirva
--  también como base para análisis exploratorio.
--
--  Idempotente por periodo: al recargar un mes se borra y se reinserta.
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS raw;

CREATE TABLE IF NOT EXISTS raw.cuentas_raw (
    id                        BIGSERIAL     PRIMARY KEY,
    -- columnas del archivo de origen (normalizadas a snake_case)
    ciclo_facturacion         TEXT,
    cuenta_padre              TEXT,
    company_id                BIGINT,
    empresa                   TEXT,
    tipo_sim                  TEXT,
    plan                      TEXT,
    codigo_plan               TEXT,
    total_sims                INTEGER,
    precio_plan               NUMERIC(18,4),
    pool_disponible           NUMERIC(20,4),
    total_consumo_mb          NUMERIC(20,4),
    total_sobreconsumo        NUMERIC(20,4),
    total_cobro_plan          NUMERIC(20,4),
    total_cobro_sobreconsumo  NUMERIC(20,4),
    total_cobro_sms           NUMERIC(20,4),
    total_cobro_voz           NUMERIC(20,4),
    total_cobro               NUMERIC(20,4),
    moneda                    TEXT,
    comentarios               TEXT,
    -- trazabilidad
    periodo                   CHAR(6)       NOT NULL,
    archivo_origen            TEXT,
    fecha_carga               TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_cuentas_raw_periodo
    ON raw.cuentas_raw (periodo);

CREATE INDEX IF NOT EXISTS ix_cuentas_raw_periodo_plan
    ON raw.cuentas_raw (periodo, plan);
