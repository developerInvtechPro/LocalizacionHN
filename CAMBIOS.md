# Cambios

## 1.1.0.0 — 24 de octubre de 2026

- Proyecto organizado por módulos y herramientas, documentación, pruebas y metadatos en carpetas propias.
- Interfaz, comentarios, informes y documentación en español, conservando identidades de esquema y contrato JSON.
- Configuración de facturación por empresa y emisión de facturas desde pedidos o facturas directas, con controles de CAI, rango, tipo y fecha.
- Notas de crédito fiscales con autorización 06, factura de origen, cliente/moneda coincidentes y motivo.
- Catálogo propio con varias autorizaciones por proveedor, nombre visible, rango, vigencia y conservación después del uso. Validación al facturar compras y abonos, incluidos pedidos.
- Registro fiscal de los nuevos recorridos y trazabilidad de retenciones/notas de débito emitidas desde esta versión.
- 18 RDLC para comprobantes, borradores, catálogos, movimientos contables, clientes, proveedores, aplicaciones/desliquidaciones e ISV; centro de informes.
- Nombres técnicos de informes abreviados a 30 caracteres como máximo, incluidos generadores y referencias, para corregir AL0305.
- Manual completo en Markdown/PDF y guía visual de 22 páginas; configuración y aceptación detalladas.
- 31 pruebas AL preparadas. Compilación y verificaciones locales; sin ejecución en BC ni renderizado real de RDLC.
- Git inicializado localmente; configuración privada, paquetes, símbolos e inventario local excluidos. La subida remota requiere un repositorio de destino accesible.

No se han migrado datos, adaptado el receptor externo ni publicado en Business Central. Los conflictos previos con API_BCPOS siguen documentados como bloqueo de despliegue conjunto.

## 1.0.2.0 — preparación del 23 de octubre de 2026

- Retenciones con varias facturas del mismo proveedor/moneda, reserva contra duplicados y validación del saldo por factura.
- Acción de agregar/quitar facturas; detalle con referencia, fecha y CAI de cada origen.
- Anulación con motivo, fecha, usuario, desliquidación estándar y movimientos compensatorios en una transacción; conserva fiscal y líneas. Crear sustituto genera otro borrador vinculado.
- Marca manual de declaración/entero al SAR y referencia de tratamiento fiscal previa a anular un comprobante marcado. No cambia declaraciones ni recupera impuestos.
- Comprobante impreso con ANULADA y detalle de las facturas. Histórico incluye anulaciones.
- Actualización aditiva de comprobantes V2 anteriores; conserva IDs, nombres y tipos. Los documentos previos sin vínculo fiable al movimiento deben conciliarse antes de su anulación.
- Campos POS propios, copia explícita al registrar ventas/abonos y mapa de 68 campos históricos. Herramienta de verificación/copia con permisos separados y sin dependencia de la localización origen.
- Inventario de API_BCPOS 1.0.0.41 y Validacion_Facturas 1.0.0.153: 14 conflictos preexistentes de instalación. Despliegue conjunto bloqueado hasta resolverlos mediante un procedimiento de conservación de datos.
- Proyecto de pruebas trasladado a codeunit 71250 para evitar el rango de Validacion_Facturas; 23 pruebas AL preparadas.

Validación: compilación local de V2 y pruebas con símbolos Microsoft; verificación de manifiesto, esquema anterior, mapa de tipos/longitudes y datasets RDLC. No ejecutado en Business Central; sin cambios en datos, API, servicio o proyectos de Descargas. No se afirma lista la migración ni el despliegue productivo.
