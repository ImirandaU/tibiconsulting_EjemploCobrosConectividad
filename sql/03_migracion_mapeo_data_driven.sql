-- =====================================================================
--  Migración ilustrativa: evolución del maestro hacia un mapeo data-driven
--  Repositorio de referencia — TIBI Consulting
--
--  Contexto: la primera versión del sistema tenía el mapeo (qué plan del
--  Excel corresponde a qué país/operadora/precio) escrito directamente en
--  el código. Cada país u operadora nueva exigía editar y desplegar el
--  programa. Esta migración documenta el cambio de diseño: mover ese
--  mapeo a la propia tabla de precios, para que agregar una operadora
--  sea un INSERT y no un despliegue.
--
--  Es idempotente: se puede correr más de una vez sin duplicar ni romper.
-- =====================================================================

-- 1) Nuevas columnas de mapeo (si el maestro ya existía sin ellas)
ALTER TABLE billing.maestro_precios ADD COLUMN IF NOT EXISTS plan_prefijo TEXT;
ALTER TABLE billing.maestro_precios ADD COLUMN IF NOT EXISTS regla TEXT;

-- 2) Precio y moneda pasan a ser opcionales (para poder registrar
--    operadoras que ya se están recibiendo en el archivo mensual pero
--    todavía no tienen tarifa acordada -> se reportan solo sus SIMs)
ALTER TABLE billing.maestro_precios ALTER COLUMN precio_unitario DROP NOT NULL;
ALTER TABLE billing.maestro_precios ALTER COLUMN moneda DROP NOT NULL;

-- 3) Ejemplo de "clasificación por atributo": una operadora cuyos planes
--    comparten el mismo nombre pero se separan en dos categorías de precio
--    según el volumen de datos contratado. Se resuelve con una regla en el
--    maestro en vez de listar cada plan a mano en el código.
--
--    UPDATE billing.maestro_precios
--       SET plan_prefijo = 'Operador X Plan Base', regla = '< 1GB'
--     WHERE pais='PAIS_A' AND operador='OPERADOR_X' AND tipo_operador='CATEGORIA_1';
--
--    UPDATE billing.maestro_precios
--       SET plan_prefijo = 'Operador X Plan Base', regla = '>= 1GB'
--     WHERE pais='PAIS_A' AND operador='OPERADOR_X' AND tipo_operador='CATEGORIA_2';
