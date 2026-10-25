# Preparación de migración POS — 23 de octubre de 2026

Estado: código V2 y herramientas locales preparados. Sin cambios en Business Central, en el servicio POS ni en los proyectos de Descargas. No se ha demostrado aún la continuidad operativa con la nueva extensión.

## Bloqueo de despliegue confirmado

El inventario de símbolos detecta **14 colisiones preexistentes** entre V2 y API_BCPOS 1.0.0.41: tablas 50100–50104, página 50100, tableextension 50102, permissionset 50100 y seis campos de cabeceras de venta. Por ejemplo, Sales Header 50112 significa `HN Fiscal No.` en V2 y `POS Gas Station Code` en API_BCPOS. Eliminar la dependencia anterior no resuelve estos conflictos.

**No publicar V2 junto con esa API en un entorno operativo.** La versión 1.2.0.0 conserva las identidades del esquema V2 1.0.1.1 para proteger los datos que ya existen en sandbox. Los nuevos objetos/campos usan 71100–71199, sin colisiones con la API inventariada. Las pruebas usan 71250–71299, evitando el rango de Validacion_Facturas.

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

## Herramienta de copia histórica

Asignar el permiso separado **HN MIGRATION** en una copia de sandbox compatible. Abrir **Verificación de migración HN → Verificar o copiar metadatos POS**.

1. Elegir tabla: 18 cliente; 36/37 cabecera/línea abierta; 112/113 factura registrada; 114/115 abono registrado.
2. Ejecutar con **Aplicar copia desactivado**. El proceso valida el App ID/paquete propietario del origen, ID y nombre exactos, clase normal, tipo y longitud. Una diferencia bloquea esa tabla.
3. Revisar incidencias, filas verificadas y campos pendientes. El registro no incluye valores personales de los campos. Conciliar cualquier destino distinto del origen.
4. Solo tras revisar, ejecutar **Aplicar copia**. Se vuelve a verificar bajo bloqueo; cualquier conflicto aborta la copia completa de la tabla. Solo se rellenan destinos vacíos desde orígenes no vacíos. No hay truncamiento, sobrescritura de destinos, borrado de origen ni registro contable.
5. Repetir la verificación y conciliar conteos/valores con el origen. Repetir la copia idéntica no vuelve a cambiar destinos ya iguales.

Los valores vacíos/cero/false se consideran valores por defecto. La primera copia debe hacerse **antes** de que el receptor comience a escribir en destino; no es una sincronización permanente entre motores. Cada tabla constituye una transacción; no se ofrece una transacción única para las siete tablas.

La herramienta se ejecuta bajo demanda; no forma parte de instalación/upgrade automático. La única actualización automática en esta versión enriquece los comprobantes antiguos de **V2** con la relación de sus facturas, sin cambiar importes ni emitir números. El origen antiguo debe permanecer instalado y accesible durante la copia. Nunca se cambia su App ID para intentar trasladar datos.

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
