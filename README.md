# Pipeline de Cobros por Conectividad IoT

Pipeline de datos que reemplaza un proceso de facturación manual —repartido entre
dos áreas sin una fuente de verdad común— por un flujo automatizado, auditable
y **operable sin tocar código**: agregar un país o una operadora nueva es un
`INSERT` en base de datos, no un despliegue.

> **Repositorio de referencia con fines de portafolio.** Los nombres de esquema,
> las rutas de configuración y los datos de ejemplo (`sql/04_seed_ejemplo.sql`)
> son ilustrativos. No corresponden a ningún cliente, tarifa ni acuerdo comercial
> real. La arquitectura y los patrones de procesamiento sí son fieles al sistema
> real en producción.

Caso completo, con contexto de negocio y aprendizajes, en
[tibiconsulting.cl](https://tibiconsulting.cl).

---

## Qué resuelve

Una empresa que factura conectividad celular por volumen (SIMs activas, en este
caso) necesita consolidar, mes a mes, cantidades repartidas en múltiples países
y operadoras, cada una con su propio precio y moneda. Antes de este pipeline,
ese cálculo se armaba a mano, en Excel, por dos personas de áreas distintas.

## Arquitectura

```
archivo mensual (Excel)
        │
        ▼
  capa RAW tipada          (schema "raw")
        │
        ▼
  cruce con el maestro      (schema "billing")
  de precios (data-driven)
        │
        ▼
  resultado de cobros  +  reporte Excel ejecutivo
```

- **Capa RAW (`raw.cuentas_raw`):** landing tipada del archivo mensual. Guarda
  todo sin filtrar, con trazabilidad de periodo y archivo de origen. Es la base
  también para análisis exploratorio.
- **Maestro de precios (`billing.maestro_precios`):** el corazón data-driven.
  Cada fila define país, operadora, tipo, precio, moneda, **y el mapeo** hacia
  los planes del archivo mensual (`plan_prefijo` + una `regla` opcional de
  clasificación). Historizado: los cambios de precio se agregan, nunca se
  sobrescriben.
- **Resultado (`billing.resultado_cobros`):** el cruce cantidad × precio por
  periodo. Idempotente: reprocesar un mes lo reemplaza, no lo duplica.
- **Bitácora (`billing.log_ejecucion`):** una fila por cada corrida (carga RAW
  o cálculo de reporte), para auditoría.

## Por qué el mapeo vive en la base de datos

La primera versión tenía el mapeo (qué plan del Excel corresponde a qué país/
operadora/precio) escrito en el código. Cada país u operadora nueva exigía
editar y desplegar el programa. Se movió ese mapeo a la tabla `maestro_precios`
(ver `sql/03_migracion_mapeo_data_driven.sql` para el detalle de esa evolución).
El resultado: agregar una operadora es una fila nueva en la tabla, sin tocar
`pipeline_cobros.py`.

```sql
INSERT INTO billing.maestro_precios
  (fecha, pais, operador, tipo_operador, precio_unitario, moneda, plan_prefijo, regla)
VALUES ('2025-01-01', 'PAÍS', 'OPERADORA', 'TIPO', 0.00, 'MONEDA', 'Prefijo del plan', NULL);
```

Y al correr el proceso, esa fila ya aparece en el resultado.

### Clasificación por atributo (`regla`)

Algunas operadoras ofrecen planes que comparten el mismo nombre pero deben
separarse en dos categorías de precio según un atributo del plan (en el caso
real, el volumen de datos contratado). En vez de listar cada plan a mano, el
maestro admite una regla evaluable:

```sql
-- < 1GB paga tarifa A, >= 1GB paga tarifa B, mismo prefijo de plan
regla = '< 1GB'   -- ó '>= 1GB', '< 500MB', etc.
```

## Otros problemas reales que resuelve

- **Hojas de Excel vacías puestas antes de la hoja de datos real** — la lectura
  ingenua de la primera hoja devolvía cero filas ciertos meses. Se blindó para
  ubicar siempre la hoja de datos correcta.
- **Archivos de bloqueo de Office (`~$...`)** cuando alguien deja el Excel
  abierto — se filtran antes de listar los archivos a procesar.
- **Periodo derivado del nombre del archivo**, no de un prefijo numérico escrito
  a mano (poco confiable): se usa el mes en texto.
- **Procesamiento histórico resiliente** — si un mes falla al reprocesar varios
  a la vez, se registra el error y el proceso continúa con el resto.
- **Validación defensiva de moneda/precio** — una fila sin precio o moneda
  válidos en el maestro reporta solo la cantidad de SIMs, en vez de fallar o
  inventar un monto.

## Cómo correrlo

```bash
pip install -r requirements.txt
cp .env.example .env        # completar credenciales y rutas
psql -f sql/01_schema_landing.sql
psql -f sql/02_schema_billing.sql
psql -f sql/04_seed_ejemplo.sql   # datos de ejemplo, opcional

python pipeline_cobros.py
```

El menú permite cargar la capa RAW, generar el reporte, o ambos —por periodo
específico (año/mes) o en modo histórico (todos los archivos disponibles en
`INPUT_DIR`).

## Estructura del repositorio

```
├── pipeline_cobros.py                       # motor: ingesta RAW, cruce, reportería, menú
├── requirements.txt
├── .env.example
└── sql/
    ├── 01_schema_landing.sql                # capa RAW
    ├── 02_schema_billing.sql                # maestro, resultado, bitácora
    ├── 03_migracion_mapeo_data_driven.sql   # evolución hacia el mapeo en BD
    └── 04_seed_ejemplo.sql                  # datos ilustrativos para demo
```

## Stack técnico

Python · PostgreSQL · pandas · SQLAlchemy · openpyxl · python-dotenv

---

<sub>Desarrollado por **TIBI Consulting**. ¿Tu facturación todavía vive en un
Excel armado a mano? [Conversemos](https://tibiconsulting.cl).</sub>
