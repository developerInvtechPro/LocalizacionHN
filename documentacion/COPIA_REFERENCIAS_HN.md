# Copia de referencias anteriores a campos propios de V2

Versión 1.2.2.0 · 26 de octubre de 2026

La migración conserva los valores de referencia en campos y tablas que pertenecen a V2. No exige que la información histórica cumpla la lógica fiscal nueva para poder copiarla. Tampoco registra documentos, consume correlativos, habilita autorizaciones ni convierte retenciones antiguas en movimientos activos.

## Alcance preparado

El mapa se amplió de 68 a **236 correspondencias**, contrastadas con el paquete base 1.0.1.69. Se conservan las correspondencias publicadas y se añaden los datos de referencia que faltaban de compras, ventas, proveedores y empresa.

- Ventas: número fiscal, CAI y rangos existentes, origen/proyecto/ubicación, datos de exoneración, valores históricos almacenados, textos de entrega/descripción y referencias de la nota de débito. Las imágenes Blob y los GUID se conservan con su tipo, sin convertirlos a texto.
- Compras: CAI completo, rango y vencimiento del documento, código CAI anterior completo, referencias fiscales/externas, órdenes/exoneraciones, totales almacenados e indicadores históricos de retención. No se modifica Vendor Invoice No. ni el correlativo interno estándar.
- Proveedores: RTN Code[50], código anterior Code[50], extranjero, condición y fecha histórica de retención.
- Empresa: teléfono y RTN anteriores con sus longitudes originales, sin reemplazar automáticamente valores estándar de configuración.

Los campos nuevos son de consulta. En los documentos se accede mediante **Acciones → Referencias anteriores**, incluida la línea seleccionada en las subpáginas de compras/ventas. El número fiscal de una factura antigua sigue disponible en Documento fiscal de origen POS, y el selector de origen de notas de débito utiliza ese valor.

## Catálogos e históricos guardados como referencias

| Origen | Destino de V2 | Tratamiento |
| --- | --- | --- |
| Gestión CAI | CAI de proveedores (referencia) | Se conserva Proveedor + CAI + Sucursal, rangos y fechas. |
| CAI Facturación | CAI de ventas (referencia) | Se conserva el código, CAI, correlativo Code[50], fechas, opción y banderas anteriores. |
| Grupo Impuestos Honduras | Grupos de impuesto (referencia) | Solo datos originales, sin activar cálculo. |
| Exoneración | Exoneraciones (referencia) | Porcentaje, límites, opción y fechas originales. |
| salesPaymentMethods | Medios de pago POS (referencia) | Identidad, vínculo al documento y montos anteriores. |
| Sales Payment Detail | Distribución de pagos (ref.) | Se conserva Tipo + Documento + Línea y todos sus valores. |
| Boleta de Compra | Boletas de compra (referencia) | No se crea una factura registrada ni se emite CAI. |
| Configuración Impuestos HN | Configuración fiscal (ref.) | Se guarda como referencia, sin aplicar sus opciones a V2. |

Estos destinos tienen IDs propios y pueden consultarse desde V2 sin leer tablas de la extensión antigua. Su información se conserva en V2 aunque se retire posteriormente la extensión anterior. La herramienta no desinstala ni borra el origen.

## Propiedades y conservación

Los tipos y longitudes se mantienen. Un Código CAI de compras Code[37] no se trunca a una clave nueva Code[20]; se guarda su referencia completa. Un correlativo anterior Code[50] no se interpreta ni se reduce a un correlativo activo Code[20]. Las opciones anteriores mantienen sus miembros y su orden; los tipos estándar de documento mantienen su enum. Las claves compuestas se trasladan sin generar códigos sustitutos.

Los valores estándar y los IDs ya publicados por V2 se conservan. La copia de CAI/rango/vencimiento de compras rellena los campos de referencia de documento que ya posee V2 cuando están vacíos. Los otros datos anteriores se guardan en campos propios de referencia. No se activan las reglas antiguas ni se disparan validaciones de configuración del catálogo activo.

Los campos calculados (FlowFields/FlowFilters) no representan datos almacenados que deban copiarse: se conservan sus datos base estándar y se revisa la consulta por separado. Esta etapa no incluye los otros 30 campos del portal de clientes, credenciales, galería general de artículos ni tablas adicionales de retenciones/declaraciones fuera del mapa. No se promete aquí el traslado de módulos no seleccionados.

## Ejecución en sandbox

1. Publicar en una copia compatible, usando sincronización normal. Resolver antes los conflictos de IDs documentados con otras apps. Mantener la extensión origen y sus datos accesibles.
2. Asignar HN MIGRATION y permisos de lectura de los catálogos anteriores al responsable. Coordinar una ventana sin escrituras de usuarios, API ni tareas.
3. Abrir Verificación de migración HN → Preparar, copiar o validar migración. Seleccionar Verificar antes de copiar, Tabla = 0 para el conjunto ampliado.
4. Revisar propietarios, nombres, tipos, longitudes, opciones y conflictos. Exportar la ejecución CSV. Un destino diferente no se sobrescribe para forzar una igualdad.
5. Seleccionar Copiar y validar automáticamente, Tabla = 0. Se revisan todas las tablas antes de escribir. Las tablas de referencia nuevas se llenan conservando sus claves. Después se compara origen y destino; un fallo revierte toda la ejecución.
6. Revisar los resúmenes por tabla y RESULTADO DE EJECUCIÓN. Exportar la copia correcta.
7. Ejecutar Validar después de la migración. Comprobar la copia de referencia, cero pendientes y cero diferencias. Esta validación acredita la copia de valores; no rechaza ni corrige fechas, rangos o CAI históricos por reglas fiscales nuevas.
8. Abrir Referencias anteriores desde un pedido/factura/cliente proveedor y revisar muestras; consultar también las ocho listas de referencia. En adjuntos, la comparación usa SHA-256 de su contenido; la consulta muestra bytes conservados.
9. Comparar número fiscal, CAI, RTN y textos/decimales largos con el original. Probar selección de factura de origen de nota de débito. Verificar que no avanzó ningún correlativo CAI ni se crearon movimientos contables.
10. Repetir la copia para comprobar idempotencia. Conservar CSV y aceptación del responsable. No desinstalar como parte de esta ejecución.

## Resultado y límites de la validación

La revisión posterior compara los datos contra el origen mientras este siga accesible, y vincula su resultado con una copia anterior correcta del mismo mapa y alcance. La firma de versión del mapa se conserva en el registro y en el CSV; una copia del mapa antiguo no acredita el ampliado. Se comprueba la existencia de las filas de referencia, las claves y los valores; no solo los conteos. Los Blob se comparan por contenido y las opciones por tipo/miembros/orden antes de copiar.

Se conservan los destinos no vacíos. Para los campos nuevos exclusivamente de referencia, un origen vacío y un destino distinto también se informa como conflicto; no se borra para ocultarlo. Para los 68 destinos existentes se conserva el criterio previo de no borrar información propia cuando el origen está vacío. Los campos por defecto se contabilizan aparte.

La copia y su comparación automática forman una transacción sin Commit interno. Un conflicto previo no copia ninguna tabla; una excepción durante escritura o validación revierte los cambios y su auditoría transaccional. Los registros creados solo con claves/defaults también se conservan y se comprueba su existencia; el contador de campos copiados refleja valores informados, no valores por defecto.

No se ha ejecutado la migración en Business Central. La compilación y contraste de esquema son comprobaciones locales, no una validación de datos reales ni una autorización de retiro del origen. La adaptación futura de la API y de las funciones activas sigue siendo distinta de esta copia de referencias.
