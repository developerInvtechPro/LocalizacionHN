# Ejecución y aceptación de la migración HN

**Actualización 1.2.2.0:** se implementó la copia ampliada de **236 referencias** a campos/tablas propios de V2, sin activar la lógica anterior. El procedimiento vigente es [COPIA_REFERENCIAS_HN.md](COPIA_REFERENCIAS_HN.md). Las observaciones de 68 campos que siguen describen la revisión previa, no el alcance de la nueva rutina.


**Revisión prioritaria de compras y ventas:** el mapa ejecutable actual solo cubre 68 campos de clientes/ventas. Se ha comprobado contra las fuentes 1.0.1.69 que compras, proveedores y catálogos tienen datos fuera del mapa. No usar esta copia parcial como aceptación de la migración completa. Leer [PLAN_COMPRAS_VENTAS.md](PLAN_COMPRAS_VENTAS.md) y [COMPARACION_COMPRAS_VENTAS.md](COMPARACION_COMPRAS_VENTAS.md) antes de ejecutar.


Versión 1.2.1.0 · 26 de octubre de 2026

Estado: herramienta preparada y compilada localmente. Ejecución, pruebas AL y comprobación funcional en Business Central pendientes. Ningún resultado de datos reales se presupone.

## Alcance y condición de inicio

Esta etapa copia 68 metadatos de clientes y documentos: número fiscal POS, CAI completo, código de autorización separado, rangos, fecha límite, RTN y atributos POS incluidos en el mapa. No vuelve a contabilizar históricos ni emite documentos. No migra automáticamente toda la funcionalidad ni las tablas de la extensión vieja.

Antes de publicar en un entorno compartido, resolver los conflictos de IDs documentados en MIGRACION_POS.md y comprobar las versiones realmente instaladas de API_BCPOS/Validacion_Facturas. La comprobación local de los paquetes de origen 1.0.1.73/1.0.1.74 acredita compatibilidad de esos 68 campos, no convivencia de todas las apps. No usar ForceSync, Recreate ni eliminación de datos para eludir diferencias.

Trabajar primero en una copia representativa del sandbox. Mantener ambas extensiones y la información antigua. Asignar HN MIGRATION al responsable. Coordinar una ventana sin escrituras en clientes/documentos por usuarios, API, reintentos o tareas; documentar su detención y reanudación. La herramienta no detiene ni adapta por sí sola esos servicios.

## Evidencia inicial

Anotar empresa, entorno, fecha/hora, responsable, versiones y paquetes de las apps. Exportar una muestra controlada de facturas/abonos con número interno, No Factura antiguo, CAI, rango, fecha de documento y vencimiento. Incluir documento abierto, cliente, línea, factura/abono y una factura que se utilizará como origen de nota de débito.

Conservar antes y después balanza y conteos/saldos de movimientos de cliente, proveedor, contabilidad e ISV. La herramienta de metadatos no sustituye esta conciliación contable independiente. Revisar también totales e información no contenida en el mapa.

## Paso 1. Verificación previa

1. Buscar Verificación de migración HN.
2. Abrir Preparar, copiar o validar migración.
3. Elegir Verificar antes de copiar y Tabla (0 = todas) = 0.
4. Revisar el identificador de ejecución, los resúmenes por tabla y RESULTADO DE EJECUCIÓN.
5. Exportar ejecución a CSV. Conservar como evidencia previa.
6. Si hay conflictos, revisar registro/campo y propietarios. No copiar mientras el resultado sea Bloqueado. Los pendientes sin conflicto son destinos vacíos que podrán rellenarse.

## Paso 2. Copia y validación automática

1. Seleccionar Copiar y validar automáticamente, Tabla = 0.
2. Revisar la fase previa: todas las tablas se verifican antes de escribir.
3. Revisar VALIDACIÓN AUTOMÁTICA por tabla: pendientes = 0 y conflictos = 0.
4. Revisar RESULTADO DE EJECUCIÓN: Correcto, total copiado y alcance.
5. Exportar el CSV de esa ejecución. No confundirlo con una verificación previa ni con otra empresa.
6. Si se recibe una excepción, la copia de esa ejecución se revierte. Conservar el error y ejecutar Verificar antes de reintentar; no corregir por SQL ni borrar datos de origen.

## Paso 3. Validación posterior independiente

1. Seleccionar Validar después de la migración, Tabla = 0, o usar Validar las siete tablas.
2. Comprobar que Copia de referencia corresponde a la ejecución Correcta del paso 2.
3. Revisar VALIDACIÓN POSTERIOR: cero destinos pendientes y cero diferencias. En esta fase los pendientes incluyen el registro y campo que requieren revisión.
4. Revisar REVISIÓN FISCAL: no debe haber identidades fiscales duplicadas ni incidencias de CAI, rangos o fechas históricas. Si faltan datos en el comprobante original, documentar y resolver el tratamiento; no fabricar un CAI para pasar la validación.
5. Revisar RESULTADO DE EJECUCIÓN: Correcto, cero pendientes y cero conflictos. Exportar a CSV. No sumar resúmenes de distintas fases: cada fase compara el mismo conjunto y el resultado global se presenta aparte.
6. Las tablas Sin correspondencias y los orígenes vacíos no se consideran datos migrados. Revisar esas exclusiones explícitamente; Correcto acredita únicamente el mapa y las comprobaciones realizadas.

## Paso 4. Prueba funcional y conservación

1. En Lista hist. facturas venta, comparar No Factura antiguo con Documento fiscal de origen POS. Para históricos importados es normal que Número fiscal HN quede vacío: ese campo corresponde a emisiones propias de V2 y no debe rellenarse para fingir una emisión nueva.
2. Crear una nota de débito de prueba, seleccionar el cliente y buscar la factura migrada. Factura origen conserva el número interno BC; Número fiscal factura origen debe cargar el fiscal POS y los datos fiscales deben cargar el CAI completo.
3. Confirmar que cambiar cliente o moneda limpia el origen anterior y filtra la nueva búsqueda.
4. Repetir con abono registrado y datos de clientes/líneas. Verificar RTN con ceros iniciales, textos largos y decimales sin truncamiento ni redondeo.
5. Verificar que crear/consultar borradores y ejecutar la migración no cambió los correlativos CAI.
6. Conciliar los informes contables y conteos/saldos anteriores y posteriores. Esta comprobación necesita datos reales en BC; no está sustituida por la compilación.
7. En sandbox, repetir Copiar: debe copiar cero campos si nada cambió. Repetir la validación posterior.
8. Probar una diferencia controlada en una copia desechable: Verificar debe mostrarla y Copiar debe dejar todas las tablas sin cambios. Probar un fallo durante escritura/validación y confirmar reversión completa.
9. Validar recepción API, reenvíos sin duplicación, dos sucursales, pagos, devoluciones y turnos antes de reanudar operación real. La adaptación de las apps consumidoras es una tarea separada.

## Acta de aceptación

| Evidencia | Resultado a completar en BC |
| --- | --- |
| Empresa/entorno/responsable | Pendiente |
| Versiones y paquetes instalados | Pendiente |
| Ejecución previa y CSV | Pendiente |
| Ejecución de copia y CSV | Pendiente |
| Ejecución posterior, copia de referencia y CSV | Pendiente |
| Cero pendientes y conflictos del mapa | Pendiente |
| Revisión fiscal e incidencias resueltas | Pendiente |
| Exclusiones: tabla 115, orígenes vacíos y campos fuera del mapa | Pendiente |
| Selector de factura con fiscal y CAI completos | Pendiente |
| Conciliación contable, conteos y correlativos | Pendiente |
| API y validación/cierre adaptados y probados | Pendiente |
| Catálogos e históricos propios todavía no migrados | Pendiente |
| Aprobación del responsable para el siguiente paso | Pendiente |

## Condición para retirar la extensión anterior

No desinstalar como parte de este procedimiento. Primero completar el inventario y traslado de catálogos/históricos propios, adaptar consumidores y resolver dependencias. Un CSV Correcto de los 68 metadatos no acredita esas tareas. La decisión de retiro y la conservación de datos de la extensión requieren un paso posterior explícito, con respaldo y recuperación comprobados.
