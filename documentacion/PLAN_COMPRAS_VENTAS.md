# Revisión y plan prioritario de compras y ventas

**Actualización 1.2.2.0:** se implementó la copia ampliada de **236 referencias** a campos/tablas propios de V2, sin activar la lógica anterior. El procedimiento vigente es [COPIA_REFERENCIAS_HN.md](COPIA_REFERENCIAS_HN.md). Las observaciones de 68 campos que siguen describen la revisión previa, no el alcance de la nueva rutina.


26 de octubre de 2026 · Estado: NO EJECUTAR como migración completa de compras y ventas.

## Referencia correcta de la extensión anterior

Se localizó en Descargas el paquete IT Invtech_Localizacion_HN_1.0.1.69.app. Incluye 160 fuentes AL y símbolos. Se revisaron las definiciones de campos/tablas, claves y código activo de registro; los bloques comentados no se consideraron funcionalidad vigente. No se modificó el paquete ni se reutilizó lógica posterior de retenciones.

Los 68 campos del mapa existente coinciden también con 1.0.1.69 en ID, nombre, tipo y longitud. La coincidencia confirma la parte ya preparada, pero no su cobertura completa. El origen normativo del generador pasa a 1.0.1.69; .73/.74 se contrastan únicamente para compatibilidad de esos campos.

## Resultado de la comparación

La revisión enumera 251 campos añadidos por la localización en las tablas prioritarias: 68 mapeados, 142 campos normales pendientes y 41 calculados que requieren validación funcional, no copia de valores. No se presupone que todos tengan datos ni que todos deban entrar en la primera etapa; la exclusión de datos persistidos debe quedar justificada.

| Área | Origen y estado frente a la copia preparada |
| --- | --- |
| Ventas | 66 campos mapeados entre cabeceras/líneas abiertas, facturas y abonos. Faltan 44 campos normales y la conservación de catálogos/pagos. |
| Clientes | RTN y exoneración mapeados: 2 de 32 campos añadidos. Los otros 30 requieren clasificar su uso; contactos y credenciales no se trasladan por equivalencia automática. |
| Compras y proveedores | Ningún campo del mapa actual. Hay 66 campos normales y 13 calculados entre proveedor, cabecera/línea y factura de compra registrada. |
| Empresa | Dos campos antiguos propios de teléfono/RTN aún sin cruce. No confundirlos con datos estándar ya conservados. |
| Abonos de compra registrados | No se encontraron extensiones de cabecera/línea con esos datos en los símbolos .69. No inventar un CAI histórico por copiar el vigente del proveedor. |
| Catálogos | Gestión CAI de proveedores, CAI Facturación, exoneraciones, grupos de impuestos y configuración fuera del mapa ejecutable. |
| Pagos e históricos auxiliares | salesPaymentMethods, Sales Payment Detail, declaraciones, resúmenes y boletas anteriores fuera del mapa. No volver a registrar sus importes. |

El inventario completo, con campo, ID, tipo y clasificación, está en COMPARACION_COMPRAS_VENTAS.md y migracion/comparacion-compras-ventas.json. La auditoría se reproduce con herramientas/auditar_compras_ventas.py.

## Diferencias críticas confirmadas

1. Código CAI de compras es Code[37] en la extensión vieja; la clave de autorización del proveedor de V2 es Code[20]. No se pueden unir por nombre ni truncar. Primero conservar el valor original y definir un cruce por proveedor, CAI, rango y sucursal.
La factura y el pedido de compra anteriores apuntan a Gestión CAI.No. CAI (el CAI completo); el abono de compra apunta a CAI Facturación.Código (catálogo de ventas). Por eso Código CAI no tiene una única semántica entre documentos. El cruce nuevo debe distinguir estos casos y conservar sus valores originales.

2. RTN del proveedor es Code[50]; no equivale al VAT Registration No. estándar ni debe reducirse para llenar un comprobante. Código de proveedor y condición de extranjero también necesitan destinos propios.
3. Gestión CAI permite varias filas por la clave Proveedor + CAI + Sucursal. V2 usa Proveedor + Código: la importación debe conservar las tres identidades y resolver claves sin perder autorizaciones repetidas por sucursal.
4. CAI Facturación guarda Num Predeterminado en Code[50]; V2 maneja el próximo número fiscal en Code[20]. No truncar ni habilitar automáticamente. Conciliar números ya emitidos, documentos abiertos, anulados y comprobantes externos antes de fijar el próximo disponible.
El campo Tipo CAI del catálogo antiguo contiene estados Pending/Processed/Canceled, no los tipos fiscales de V2. No convertirlo por ordinal a Factura/Retención/Nota de crédito/Nota de débito.

5. Los campos Fecha Inicio/Fecha Fin de los catálogos están marcados obsoletos en el origen. No inventar una fecha inicial de vigencia cuando no esté informada; conservar el dato y documentar la revisión.
6. Ventas contiene Fuente, Proyecto, Ubicación, orden de compra general, textos de entrega, descripción extendida e imágenes, además de acumulados fiscales almacenados fuera del mapa. Separar los campos normales de los FlowFields. No recalcular ni reemplazar sin conciliación los importes históricos impresos.
7. La compra abierta guarda TransactionNumber y un External Document No. propio; el estándar Vendor Invoice No. tiene otro significado. Preservar los valores distintos, detectar desacuerdos y no sobrescribir la factura del proveedor ni el número interno BC.
8. Los indicadores de retención ya existían en .69, pero no se deben convertir en documentos activos ni provocar nuevos asientos al migrar. Conservarlos como datos de origen y conciliar los históricos sin heredar algoritmos ni duplicar retenciones.

## Lógica que debe corregirse al sustituir el motor

El código activo .69 de compras sale si el proveedor está marcado extranjero; la validación actual de compras de V2 no tiene una excepción equivalente basada en ese campo. Se debe conservar el indicador y definir su tratamiento antes del corte, para evitar bloquear compras legítimas o crear una excepción indiscriminada.

El código anterior de compras solo valida cuando No. CAI está vacío, toma la primera autorización encontrada y compara vencimiento con Posting Date usando <=. Eso omite controles al capturar CAI manual y rechaza el día límite. V2 debe conservar sus controles al registrar: validar siempre el documento aplicable, usar fecha de emisión, admitir el último día y resolver de forma inequívoca múltiples autorizaciones. No se hereda ese código defectuoso.

En AssignSaleCaiOnBeforePost .69, la emisión para pedidos/facturas está comentada; la de abonos de venta sí está activa y avanza el catálogo NC. Mantener ambos motores activos puede producir consumo en el catálogo anterior y en V2. Antes del corte hay que desactivar de manera controlada el comportamiento anterior sin retirar sus datos ni introducir la lógica de retenciones posterior a .69.

La rutina de compras que se llama antes de insertar la factura histórica contiene su copia comentada; la conservación real de cada campo también depende de TransferFields y otros eventos. No asumir que todo dato del pedido existe en su factura registrada ni reconstruirlo con el CAI actual.

## Orden corregido antes de ejecutar

1. Medir en una copia de sandbox los datos no vacíos por campo y los registros de cada catálogo. Registrar versiones instaladas y conservar una muestra fiscal/contable de compras y ventas.
2. Completar primero los destinos y cruces de proveedores y compras: RTN Code[50], extranjero, código proveedor, CAI Code[37], rangos, vencimiento y metadatos de documentos. Mantener tipos/longitudes y el número interno estándar.
3. Preparar la conservación/importación de Gestión CAI y CAI Facturación. Resolver sucursales y claves. Importar sin consumo de correlativos y sin habilitación automática de registros ambiguos o sin vigencia conciliada.
4. Completar los datos normales de ventas que sean necesarios para operar y conservar el resto con una exclusión o archivo explícito. Conciliar detalle de pagos y sus vínculos por tipo/documento/línea.
5. Extender el mapa ejecutable, permisos, verificación de esquema y auditoría a compras y proveedores. La rutina actual sigue limitada a 68 campos y no aplica este plan ampliado todavía.
6. Adaptar la API y validación/cierre, resolver los conflictos de IDs y coordinar una transición sin dos motores de numeración. No renumerar campos publicados, usar ForceSync ni sustituir datos por valores truncados.
7. Ejecutar prevalidación y copia sin registros contables ni CAI consumidos. Validar origen/destino para documentos abiertos y registrados, incluidas retenciones históricas y exoneraciones que se conserven como datos.
8. Probar pedido/factura de venta, abono, pedido/factura de compra, compra extranjera, múltiples CAI por proveedor, último día de vigencia, números fuera de rango y discrepancias de pagos. Repetir copia para comprobar idempotencia y simular un fallo para comprobar reversión.
9. Emitir acta de aceptación separada para compras y ventas. Un resultado Correcto del mapa actual de 68 campos no cierra estas áreas ni autoriza desinstalar la extensión vieja.

## Qué se cambia ahora y qué no

Esta revisión deja la evidencia y el plan corregidos; no amplía a ciegas la copia de datos ni activa una migración de catálogos. Se identifica claramente en la pantalla de ejecución que el alcance actual es clientes/ventas. No se ejecutaron cambios en BC ni se alteró la extensión anterior.
