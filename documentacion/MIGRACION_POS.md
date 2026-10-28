> Actualización 28/10/2026: para primera instalación de V2 en producción se preparó una variante 1.3.0.0 con IDs 501xx trasladados a 730xx y auditoría local sin colisiones. El proyecto base mantiene sus bloqueos y sus datos de sandbox. Ver [PRIMERA_INSTALACION_PRODUCCION.md](PRIMERA_INSTALACION_PRODUCCION.md). Esta variante no adapta ni sustituye la API ni autoriza una actualización destructiva del sandbox.

# Preparación de migración POS — 23 de octubre de 2026

**Actualización 1.2.2.0:** se implementó la copia ampliada de **236 referencias** a campos/tablas propios de V2, sin activar la lógica anterior. El procedimiento vigente es [COPIA_REFERENCIAS_HN.md](COPIA_REFERENCIAS_HN.md). Las observaciones de 68 campos que siguen describen la revisión previa, no el alcance de la nueva rutina.


**Revisión prioritaria de compras y ventas:** el mapa ejecutable actual solo cubre 68 campos de clientes/ventas. Se ha comprobado contra las fuentes 1.0.1.69 que compras, proveedores y catálogos tienen datos fuera del mapa. No usar esta copia parcial como aceptación de la migración completa. Leer [PLAN_COMPRAS_VENTAS.md](PLAN_COMPRAS_VENTAS.md) y [COMPARACION_COMPRAS_VENTAS.md](COMPARACION_COMPRAS_VENTAS.md) antes de ejecutar.


Estado: código V2 y herramientas locales preparados. Sin cambios en Business Central, en el servicio POS ni en los proyectos de Descargas. No se ha demostrado aún la continuidad operativa con la nueva extensión.

## Bloqueo de despliegue confirmado

El inventario de símbolos detecta **14 colisiones preexistentes** entre V2 y API_BCPOS 1.0.0.41: tablas 50100–50104, página 50100, tableextension 50102, permissionset 50100 y seis campos de cabeceras de venta. Por ejemplo, Sales Header 50112 significa `HN Fiscal No.` en V2 y `POS Gas Station Code` en API_BCPOS. Eliminar la dependencia anterior no resuelve estos conflictos.

**No publicar V2 junto con esa API en un entorno operativo.** La versión 1.2.1.0 conserva las identidades del esquema V2 1.0.1.1 para proteger los datos que ya existen en sandbox. Los nuevos objetos/campos usan 71100–71199, sin colisiones con la API inventariada. Las pruebas usan 71250–71299, evitando el rango de Validacion_Facturas.

Antes de instalar en el entorno compartido hay que decidir el propietario definitivo y el procedimiento de traslado del esquema existente. Si V2 todavía no existe en producción, se puede preparar una aplicación con identidad/rango definitivos y una herramienta explícita de traslado de los datos V2 del sandbox. Si hay aplicaciones instaladas con datos en los IDs enfrentados, se necesita una transición compatible de propiedad o una exportación/importación auditada en una copia. No renumerar directamente campos/tablas publicados ni usar ForceSync, Recreate o desinstalación con eliminación de datos. Ninguna de estas operaciones se ha realizado.

## Fuentes inspeccionadas

- Documento de traspaso proporcionado por el usuario; se utiliza como contexto, no como orden de desinstalación o corte productivo.
- Descargas/API_BCPOS_INVTECH_1-2: manifiesto y paquete 1.0.0.41, receptor, staging, campos propios, copia de documentos y páginas.
- Descargas/Validacion_Facturas_Default Publisher_1-2: versión 1.0.0.153, dependencias y referencias dinámicas de validación/revisión/cierre. Sus archivos no fueron modificados.
- Símbolos Localizacion_HN 1.0.1.73: solo inventario de nombres, tipos, longitudes y propietario. No se incorporó su lógica de retenciones ni una dependencia de compilación.

Inventario reproducible: `python3 herramientas/inventariar_migracion.py`. Resultado: [inventario.json](../migracion/inventario.json), con 53 referencias localizadas para revisar. Esta búsqueda no prueba por sí sola que no existan otras dependencias o extensiones instaladas.

## Esquema preparado

[mapa-campos.json](../migracion/mapa-campos.json) contiene **68 correspondencias confirmadas** de origen a destino. Las diferencias de ID entre documentos abiertos e históricos se resuelven explícitamente. Se crean campos propios en Customer, Sales Header, Sales Line, Sales Invoice Header/Line y Sales Cr.Memo Header/Line.

- Se mantienen tipos y longitudes del origen: RTN Code[50], placa/chofer/kilometraje Text[60], operador de cabecera Text[60], operador de línea Code[50]. No se convierte kilometraje a número ni RTN a VAT Registration No.
- Código CAI, CAI completo y CAI adicional son destinos distintos. Los metadatos POS tampoco se confunden con las autorizaciones de emisión de notas de débito.
- Los totales recibidos son datos de comparación; no sustituyen importes, impuestos o cantidades estándar.
- La copia de metadatos al registrar es explícita para facturas y abonos, incluidas sus líneas. No depende de TransferFields entre los IDs de la localización anterior.
- No se duplican POS Close ID, POS Shift Date, detalle de pagos, cantidades/precios originales ni otras identidades que ya pertenecen a API_BCPOS. Deben mantenerse sus propietarios durante la transición.
- Los campos históricos de V2 son de solo lectura en interfaz; los nuevos campos tienen DataClassification y tipos explícitos. Se preservan todas las identidades/tipos anteriores de V2, comprobados contra esquema-v2-base.json.
- No se definieron enums para enteros POS cuyo significado todavía no se ha confirmado.

Los símbolos revisados no contienen los mismos metadatos POS en líneas históricas de abonos. Los campos destino permiten conservar los nuevos documentos, pero la migración no inventa datos que no estén en el origen.

## Herramienta de copia y validación histórica — 1.2.1.0

La rutina opera únicamente sobre las 68 correspondencias confirmadas. Los paquetes locales 1.0.1.73 y 1.0.1.74 coinciden en ID, nombre, tipo y longitud para esos campos: `python3 herramientas/verificar_mapa_migracion.py`. Esto no demuestra qué versión está instalada en el entorno; al ejecutar se verifican otra vez el propietario y el paquete reales.

Asignar el permiso separado **HN MIGRATION** en una copia de sandbox compatible. Abrir **Verificación de migración HN → Preparar, copiar o validar migración**.

1. Elegir **Operación = Verificar antes de copiar**, **Tabla = 0**. El cero selecciona clientes, cabeceras/líneas abiertas, facturas y abonos registrados (18, 36, 37, 112, 113, 114 y 115). Se puede indicar una sola tabla.
2. Revisar fases, filas verificadas, campos comparados, coincidentes, origen vacío, pendientes y conflictos. El detalle identifica registro/campo, sin exportar sus valores. Exportar la ejecución a CSV como evidencia inicial.
3. **Bloqueado** exige resolver diferencias, campos ausentes o propietarios/esquemas distintos. No se sobreescriben destinos para forzar coincidencias. **Pendiente** con cero conflictos indica que existen destinos vacíos por copiar.
4. Tras revisar, elegir **Copiar y validar automáticamente**, Tabla = 0. Se bloquean y verifican todas las tablas antes de copiar la primera. Un conflicto conocido deja registro Bloqueado y no copia ninguna; una excepción durante la escritura/validación revierte la copia completa de esa ejecución. No hay Commit interno ni confirmaciones parciales por tabla. Una excepción también revierte sus registros de auditoría: conservar el mensaje de error y repetir primero Verificar.
5. La copia rellena únicamente destinos vacíos desde orígenes informados. No trunca, borra orígenes, sustituye importes estándar, registra facturas ni consume CAI. Después de cada tabla se compara nuevamente; un pendiente/conflicto revierte la operación. Revisar **VALIDACIÓN AUTOMÁTICA** y **RESULTADO DE EJECUCIÓN**, y exportar ese identificador.
6. Elegir **Validar después de la migración**, Tabla = 0. Esta operación no copia: compara otra vez y enlaza con la última copia Correcta del mismo alcance en la empresa. Sin una copia previa trazable el resultado queda Bloqueado. La acción **Validar las siete tablas** ejecuta esta misma validación.
7. Revisar también **REVISIÓN FISCAL** de facturas y abonos que tengan número POS en destino: duplicados, formato del número, CAI completo, rango/prefijo y fecha de documento frente al vencimiento. Una incidencia deja el resultado Bloqueado para revisión del comprobante original; la rutina nunca inventa números, CAI ni fechas para corregirla. No se compara el vencimiento histórico con la fecha de hoy.
8. El resultado final esperado de la validación es **Correcto**, cero pendientes y cero conflictos. Además, completar la prueba funcional y la conciliación contable descritas en [EJECUCION_MIGRACION.md](EJECUCION_MIGRACION.md). Un resultado Correcto certifica el mapa y revisión indicados, no toda la extensión ni una autorización de desinstalación.

La tabla 115 aparece **Sin correspondencias**: los símbolos revisados no contienen campos de origen confirmados para sus líneas históricas. Se informa de esa exclusión; no se inventan valores ni se acredita una copia de sus líneas. Los valores vacíos/cero/false son valores por defecto a efectos de esta copia y se contabilizan como Origen vacío; no borran destinos. La revisión fiscal se aplica a las cabeceras con número POS, no a todos los posibles documentos o campos no incluidos en el mapa.

La primera copia y su validación se realizan con la API, usuarios y tareas que escriban en esas tablas detenidos de forma coordinada durante la ventana. Repetir una copia idéntica conserva lo ya igual y copia cero campos. La herramienta no sincroniza continuamente el motor viejo con V2.

El origen debe permanecer instalado y accesible durante verificación, copia y validación posterior. No se ha ejecutado una migración, corte ni desinstalación. Catálogos completos, históricos propios de retenciones/notas y dependencias fuera del mapa siguen pendientes de análisis y traslado antes de retirar la localización anterior.

## Adaptación del receptor y cierre pendiente antes del corte

No se ha cambiado el endpoint ni el contrato JSON. La API existente continúa con su código actual; instalar campos nuevos por sí solo no redirige sus escrituras.

1. Resolver los conflictos de objetos/campos y compilar el conjunto de extensiones afectadas.
2. Reemplazar las escrituras/lecturas tipadas del receptor, páginas de clientes y comprobaciones de duplicados por los destinos del mapa. Mantener los campos que ya pertenecen a API_BCPOS y el mensaje original de staging.
3. Corregir la semántica observada: el receptor usa `TransactionNumber` antiguo para el número fiscal POS; el identificador de transacción real ya está en el campo de API_BCPOS. Mantener ambas identidades, sin intercambiarlas. No afirmar idempotencia por sucursal hasta comprobar su clave completa.
4. Resolver el catálogo de CAI y exoneraciones antes de eliminar sus dependencias. El receptor actual copia `codigoCai` tanto a código como a CAI completo: no heredar esa equivalencia. No fabricar autorizaciones a partir de un código ni truncar valores de 37 caracteres a 20.
5. Adaptar referencias dinámicas en Sales Order Validation: actualmente busca IDs/nombres antiguos. Revisar IsBomberoField en la página y el codeunit de revisión: reconoce `Usuario`, por lo que los nuevos nombres requieren cambio explícito. Examinar también cualquier configuración de Invtech_tool2 y todas las dependencias instaladas.
6. Mantener la fecha operativa recibida en POS Shift Date y el closeId del turno. No cambiar fechas contables para corregir T3 ni restar un día indiscriminadamente. La preparación de campos no corrige el servicio ni los históricos nocturnos.
7. Verificar devoluciones reales, signo, vínculo a venta original, reenvíos, medios de pago múltiples y cierre. La existencia de campos en abonos no demuestra el recorrido completo.
8. Copiar históricos, conciliar y ensayar el corte con recepción pendiente y reintentos. Mantener la extensión origen y un mecanismo probado de recuperación hasta terminar la validación.

## Validación pendiente en Business Central

Venta gravada/exonerada/crédito; RTN y referencias con longitud máxima; pagos múltiples; dos sucursales con ID repetido; reenvío idéntico/alterado; T3 de dos días consecutivos; devolución; transferencia al registrar; históricos; conciliación y cierre completo. Probar también permisos de la herramienta y el rechazo de esquema/propietario inesperados. La compilación de V2 no valida estos escenarios.
