-- =====================================================================
--  Datos de ejemplo (ILUSTRATIVOS)  -  para poder demostrar el pipeline
--  Repositorio de referencia — TIBI Consulting
--
--  IMPORTANTE: los precios y volúmenes de esta tabla son valores de
--  ejemplo elegidos para que el pipeline sea demostrable. NO corresponden
--  a tarifas, acuerdos comerciales ni datos reales de ningún cliente.
--
--  Los nombres de operadoras (marcas de telecomunicaciones públicas) se
--  usan solo para dar contexto realista al ejemplo.
-- =====================================================================

INSERT INTO billing.maestro_precios
    (fecha, pais, operador, tipo_operador, precio_unitario, moneda, plan_prefijo, regla)
VALUES
  ('2025-01-01', 'CHILE',     'CLARO',      'PLAN_A', 4500.00,   'CLP', 'Claro Chile Plan A',      NULL),
  ('2025-01-01', 'CHILE',     'MOVISTAR',   'PLAN_A', 6100.00,   'CLP', 'Movistar Chile Plan A',   NULL),
  ('2025-01-01', 'CHILE',     'ENTEL',      'PLAN_A', 7500.00,   'CLP', 'Entel Chile Plan A',      NULL),
  ('2025-01-01', 'CHILE',     'CLARO',      'PLAN_B', 460.00,    'CLP', 'Claro Chile Plan B',      NULL),
  ('2025-01-01', 'CHILE',     'MOVISTAR',   'PLAN_B', 490.00,    'CLP', 'Movistar Chile Plan B',   NULL),
  ('2025-01-01', 'CHILE',     'ENTEL',      'PLAN_B', 950.00,    'CLP', 'Entel Chile Plan B',      NULL),
  ('2025-01-01', 'ECUADOR',   'CLARO',      'PLAN_B', 0.70,      'USD', 'Claro Ecuador Plan B',    NULL),
  ('2025-01-01', 'MEXICO',    'MOVISTAR',   'PLAN_B', 400.00,    'MXN', 'Movistar México Plan B',  NULL),
  -- Ejemplo de clasificación por atributo: mismo prefijo de plan, dos
  -- categorías según el volumen de datos contratado.
  ('2025-01-01', 'ARGENTINA', 'CLARO',      'PLAN_B', 220.00,    'ARS', 'Claro Argentina Plan Base', '< 1GB'),
  ('2025-01-01', 'ARGENTINA', 'CLARO',      'PLAN_A', 10000.00,  'ARS', 'Claro Argentina Plan Base', '>= 1GB'),
  ('2025-01-01', 'PERU',      'ENTEL',      'PLAN_C', 4.00,      'PEN', 'Entel Perú Plan C',       NULL),
  ('2025-01-01', 'PERU',      'CLARO',      'PLAN_B', 6.00,      'PEN', 'Claro Perú Plan B',       NULL),
  ('2025-01-01', 'PERU',      'CLARO',      'PLAN_A', 19.00,     'PEN', 'Claro Perú Plan A',       NULL),
  ('2025-01-01', 'CHILE',     'OPERADOR_D', 'PLAN_D', 2450.00,   'CLP', 'Operador D Chile',        NULL),
  -- Operadora recién incorporada: aún sin tarifa acordada, se reporta
  -- solo la cantidad de SIMs (precio y moneda en NULL).
  ('2025-01-01', 'VARIOS',    'OPERADOR_E', 'GLOBAL', NULL,      NULL,  'Operador E Global',       NULL);
