# Desarrollo y conservación de datos

Versión 1.2.1.0 · 26 de octubre de 2026

## Organización y responsabilidad

Los módulos se encuentran en src/ y sus subcarpetas. Mueva archivos por responsabilidad funcional sin cambiar IDs o nombres de objetos de datos publicados. Las configuraciones por empresa son independientes: HN Localization Setup controla retenciones/débito y HN Config. Facturacion controla emisión de ventas y validación de compras.

Los nuevos objetos de configuración, proveedor, registro fiscal, informes y extensiones utilizan el rango 71100–71199, junto con los objetos de migración de la entrega anterior. Los objetos publicados 50100–50149 se conservan. Las pruebas utilizan 71250–71299. Los números se pueden repetir entre clases de objeto, pero no dentro de una clase ni entre campos de extensiones sobre la misma tabla destino.

## Español y compatibilidad

Use títulos, mensajes, comentarios y documentación en español. Las palabras reservadas de AL, los namespaces Microsoft y los nombres técnicos publicados siguen el contrato del compilador y del esquema. La presentación se traduce mediante Caption y ToolTip. No cambie un nombre/ID de campo o un tipo para traducirlo; revise primero migración y compatibilidad.

Los nombres técnicos de objetos AL tienen un máximo de 30 caracteres. Los títulos visibles pueden ser más descriptivos mediante Caption. El generador crear_informes.py y verificar_artefactos.py protegen esta condición; una corrección manual en un archivo generado debe incorporarse también al generador.

## Emisión fiscal de ventas

HN Gestion Facturacion se suscribe al registro estándar Sales-Post y aplica la configuración por empresa automáticamente a pedidos/facturas y abonos/devoluciones. La marca anterior de cabecera y la opción de activar documentos nuevos conservan sus IDs por compatibilidad, pero ya no controlan la emisión ni aparecen en la interfaz. Las notas de débito conservan su gestor. Las ventas con identidad INV POS Transaction No. quedan excluidas para evitar emitir otra vez un documento POS; una referencia fiscal externa sin esa identidad bloquea la emisión para revisión.

Se valida la fecha documento como fecha de emisión y se selecciona tipo 01 o 06. Se conservan cliente y moneda y se exige origen/motivo en notas de crédito. La emisión usa HN CAI Management para bloquear/validar autorización y consumir el correlativo. El pedido no recibe una numeración fiscal fija que se reutilice en facturaciones parciales.

Los datos se guardan en la factura/abono registrado y en HN Movimiento Fiscal. En vista previa se propone el próximo número sin consumirlo ni insertar el registro fiscal definitivo. La atomicidad completa del registro y los casos de concurrencia deben comprobarse en Business Central.

## Validación de compras

HN CAI Proveedor tiene clave compuesta por proveedor y código. El nombre se obtiene con FlowField. Se conserva rango, tipo, fechas y última utilización. Una autorización utilizada no puede reescribirse desde la interfaz.

HN Gestion CAI Proveedor comprueba el emisor Comprar a, número fiscal, tipo y fecha documento. La ausencia de selección solo se resuelve si hay una única autorización compatible. La configuración deshabilitada deja este recorrido sin exigir el catálogo nuevo, para permitir preparación y transición.

Los eventos de Purch.-Post validan antes de facturar y conservan datos en Purch. Inv. Header o Purch. Cr. Memo Hdr. Recibir sin facturar no requiere consumir ni emitir un número de factura del proveedor. El rango del proveedor no funciona como un contador propio de esta extensión.

## Retenciones y anulación

Las facturas incluidas están en HN Retention Invoice y los conceptos en HN Retention Line. Se valida proveedor de pago y moneda, se evita duplicar facturas activas y se comprueba saldo por factura al registrar. La generación continúa siendo manual; pagos parciales y disparadores automáticos se desarrollarán por separado.

La anulación utiliza el vínculo al movimiento de proveedor, el gestor estándar de desliquidación y un diario compensatorio. Conserva documento, fiscal, líneas, usuario, fecha y motivo. El procedimiento protege contra commits explícitos mediante CommitBehavior y solicita a la desliquidación estándar no confirmar por separado. Verificar en sandbox las diferencias de cambio, aplicaciones posteriores, períodos y reversión completa ante error.

Las retenciones antiguas sin un vínculo fiable no se relacionan por coincidencia de importes. Requieren conciliación. La referencia de tratamiento fiscal es información de control; no presenta ni rectifica declaraciones del SAR.

## Informes

Los datasets se definen en Comprobantes.al y DocumentosYMovimientos.al. Los 20 layouts están en Informes/Disenos/. Los generadores mantienen sincronizados columnas y campos XML. El verificador examina nombres, expresiones, celdas, formatos y conservación del esquema anterior. No sustituye un motor RDLC ni una prueba de impresión.

Los movimientos de clientes/proveedores muestran saldo pendiente actual. Los de contabilidad y aplicaciones muestran el importe de cada movimiento. El informe de ISV identifica base e impuesto. No se agregan monedas diferentes ni se presenta el saldo actual como un saldo histórico a fecha de corte.

El centro de informes concentra comprobantes, borradores, movimientos y catálogos. Los borradores no consumen CAI. Los comprobantes de compra son internos y no sustituyen el original del proveedor.

## Migración y datos

El funcionamiento diario usa campos propios. La herramienta HN Metadata Migration es la única lectura autorizada de metadatos de la extensión anterior y se ejecuta por solicitud con el permiso separado HN MIGRATION.

migracion/mapa-campos.json contiene las correspondencias confirmadas. migracion/esquema-v2-base.json protege nombres, números y tipos V2 publicados. El inventario de referencias y conflictos se puede regenerar con herramientas/inventariar_migracion.py en una máquina con las fuentes inspeccionadas disponibles en Descargas. Ese inventario local incluye rutas y queda excluido de Git.

No se usa ForceSync, Recreate, borrado del origen ni renumeración directa como estrategia de traslado. No se incluyen bibliotecas de la localización anterior en el repositorio ni en la caché de compilación diaria.

## Compilación y documentación

Use herramientas/compilar.py y herramientas/verificar_artefactos.py. Si cambia fuentes generadas, actualice su generador y ejecute traducir_textos.py. Los nombres técnicos de los campos del mapa no se traducen ni se alteran por ese paso.

Los PDF requieren las bibliotecas de requisitos-documentacion.pip. Los generadores de guía y manual utilizan Arial.ttf y Arial Bold.ttf de /System/Library/Fonts/Supplemental; adapte FONTROOT/F si trabaja en otro sistema, manteniendo soporte de tildes y ñ. Las ilustraciones se derivan del código; no simulan resultados de pruebas en un servidor real.

## Estado y evidencia

La codeunit de pruebas es 71250. Su ejecución requiere un ejecutor estándar de pruebas AL en una empresa desechable de sandbox. Conserve diagnóstico de compilación, resultado de pruebas, conciliación y PDF impresos de casos reales de prueba.

No publique datos del tenant, símbolos, paquetes anteriores, credenciales o rutas locales del inventario. Git excluye esos archivos; utilice launch.ejemplo.json como plantilla. La publicación en GitHub requiere un repositorio de destino accesible y no implica publicación en Business Central.


## Emisión transaccional y boletas, versión 1.2

`HN CAI Management.EmitirEnRegistro` valida y devuelve vacío en vista previa; en registro real llama Issue, que bloquea/relee la autorización y actualiza último/próximo sin Commit. Los suscriptores de inserción de cabeceras registradas llaman este punto después de las validaciones. La creación y la validación manual no llaman Issue. Cada factura parcial consume un correlativo; el fiscal no se almacena en el pedido abierto. La integración respeta la transacción estándar; extensiones externas que introduzcan commits en la fase de contabilización deben auditarse antes del despliegue.

BoletaCompra se añade como valor 4 al enum fiscal existente y exige código 11. Las extensiones de tablas 71116–71118 mantienen campos propios: boleta, identidad y teléfono en Purchase Header; snapshots completos en Purch. Inv. Header; elegibilidad e identidad en Vendor. Las páginas 71114–71116 exponen lista/ficha/histórico y las extensiones 71127–71129 integran los documentos estándar. Se admite factura de compra directa y facturación de pedidos; las recepciones solas no emiten.

`HN Gestion Boletas` valida proveedor natural hondureño, identificación, dirección, teléfono, moneda HNL, datos del emisor, autorización y líneas sin crédito ISV. Omite exclusivamente para boletas la exigencia de número de factura del proveedor mediante OnBeforeCheckExtDocNo. La autorización recibida del proveedor no se usa para este documento. Al insertar la cabecera registrada asigna el fiscal y lo mantiene en la referencia de factura del proveedor de la variable en memoria durante el registro, para que proveedor/contabilidad utilicen ese número. Limpia esa referencia antes de actualizar/archivar el pedido abierto; no persiste un número reservado en el origen. Los abonos/devoluciones que hereden la marca de boleta se bloquean: no se implementa una corrección fiscal automática del tipo 11.

En HN Movimiento Fiscal, Es compra mantiene su ID/valores pero su caption pasa a Recibido de proveedor: true son comprobantes recibidos; false son emitidos con CAI propio (incluye boleta). Esta semántica permite el mismo bloqueo antirrepetición para todas las emisiones propias.

Los informes 71126/71127 y sus RDLC se generan con crear_informes_boletas.py; incluyen letras, firma/huella, datos de contacto, exoneración y destino de ejemplares. Los límites fiscales agregados del art. 22 se controlan fuera de esta versión; no hay anulación fiscal de boletas, cálculo automático de límites anuales ni comunicación SAR.


## Alta de CAI desde vistas filtradas

El catálogo inicializa el tipo de documento respetando los grupos de filtros 0 a 4, incluidos RunPageView y SetTableView. Si el filtro permite un único tipo, el campo no se puede modificar desde esa vista. DelayedInsert evita insertar una nueva fila mientras se están completando y validando sus campos. La acción Ver todas las autorizaciones abre el catálogo general para localizar códigos ya existentes y corregir autorizaciones no utilizadas que quedaron fuera del filtro del módulo. No cambia datos de autorizaciones emitidas ni adapta numeraciones fiscales a otro tipo de documento.


## Validación al capturar autorizaciones

Los campos de tipo, CAI, números y fechas validan su coherencia en OnValidate; OnInsert/OnModify repiten el control para asignaciones directas con triggers. Una autorización deshabilitada puede quedar incompleta durante la captura, pero no con fechas/rangos contradictorios. Se admite inicial=final para un único correlativo y fechas iguales para vigencia de un día. El tipo fiscal, prefijo de establecimiento/punto, formato y correlativo positivo se comprueban en los tres números. Habilitar y emitir exige datos completos; emitir vuelve a comprobar vigencia contra la fecha del documento, rango, último emitido y duplicados. Los números nunca se consumen mediante estas validaciones.


Al validar el CAI o habilitarlo en su catálogo se guarda y actualiza la misma lista, conservando la selección de la línea por su clave. No se requiere abrir el catálogo general para ver una autorización recién creada; esa acción se reserva para recuperar registros anteriores fuera del filtro del módulo.


## Selector de factura de origen y cambio de cliente

Los dos campos de búsqueda y la acción Seleccionar factura origen guardan y confirman exclusivamente el borrador antes de llamar al selector modal. Esto evita el error RunModal dentro de una transacción de escritura tras crear la nota o cambiar el cliente. No se introduce Commit en SelectOriginal ni en el registro/emisión fiscal: la numeración fiscal conserva su transacción original. Al validar un cambio de cliente de venta, cliente de facturación o moneda en una nota de débito se borran la referencia, fecha, número fiscal y CAI de origen; la próxima búsqueda usa los valores nuevos.


## Migración 1.2.1.0 y validación posterior

HN Metadata Migration mantiene RunMigration como entrada compatible y añade Ejecutar(Modo, Tabla), con 0 para el conjunto de tablas. CommitBehavior::Error protege toda la ejecución. La copia hace prevalidación de todos los esquemas/registros bajo bloqueo antes de escribir, revalida esquema en la pasada de escritura y compara después de cada tabla. Un conflicto previo se registra y no copia ninguna tabla; un fallo posterior revierte todo, incluida su auditoría transaccional. No hay Commit interno.

El mapa ahora incluye nombre esperado de destino y el esquema comprueba también el paquete propietario de V2. Se conservan IDs, tipos y longitudes; los paquetes locales de origen .73/.74 coinciden en los 68 campos confirmados. CompararCampo solo cambia un FieldRef en memoria; la modificación persistente queda en CopiarTabla, después de validar el mapa/esquema.

Los registros 71103 añaden modo, fase, resumen, comparados/coincidentes/vacíos/copiados, resultado, paquetes y copia de referencia sin cambiar campos anteriores. Validar busca una copia previa Correcta del mismo alcance; no la sustituye por una comparación aislada. La revisión fiscal posterior detecta incidencias en las identidades POS copiadas. No rellena HN Fiscal No. de históricos: el origen POS conserva su campo propio. CSV identifica ejecución/empresa/registro/campo sin exportar sus valores, y protege textos contra fórmulas. Tabla 115 se marca Sin correspondencias.

La herramienta no mueve tablas de retenciones/CAI anteriores ni adapta la API. La validación contable, las pruebas de integración y el retiro del origen permanecen separados y pendientes en BC. Ver EJECUCION_MIGRACION.md.


## Referencias 1.2.2.0

El mapa incluye 236 campos y TargetTable/ReferenceOnly explícitos. Para documentos se usan campos propios añadidos en la misma fila estándar; catálogos y pagos se copian a ocho tablas de referencia con claves originales. PrepararDestino localiza una fila por la clave completa; CompareRecord prepara valores y CopiarTabla inserta/modifica solo el destino. No se usa Ref.Modify en el origen de un traslado entre tablas.

Las referencias no activan las configuraciones nuevas. Se retiró la revisión de coherencia fiscal del proceso de copia: la validación posterior acredita la igualdad de datos, no la vigencia jurídica del histórico. La revisión de esquema también comprueba que Option/Enum no se confundan y que OptionMembers coincida. Guid, Blob y opciones se conservan; los Blob se comparan por SHA-256. Las consultas de referencia no requieren la aplicación origen.

preparar_referencias_hn.py es el generador ampliado; preparar_migracion.py impide sobrescribirlo con la base antigua de 68 campos. crear_consulta_referencias.py mantiene las acciones de consulta. No se ejecutaron datos reales.


## Retenciones posteriores a la factura — 1.2.3.0

La tabla 71122 HN Seleccion Ret. Factura guarda los códigos por comprobante/factura/línea, separada de Purch. Inv. Line. PrepararSeleccion propone los códigos originales sin sobreescribir una elección existente. Recalculate permite borradores sin líneas calculadas y toma primero la selección propia, incluida una selección vacía; para borradores antiguos sin selección usa el campo original como compatibilidad.

Post recalcula y exige una retención positiva por factura antes de comprobar saldos y emitir CAI. Los importes siempre salen de la factura registrada, no de bases digitadas. Las elecciones requieren borrador y factura/línea incluidas; el bloqueo del encabezado serializa su edición frente al registro. Quitar factura/borrar borrador elimina sus selecciones; un sustituto copia la selección anterior al nuevo borrador y recalcula. No se modifica la factura original.

La página 71126 selecciona conceptos, y la acción de ficha finaliza el guardado del borrador antes de abrirla para evitar el error de modal en transacción. No se introduce Commit en Post. El saldo pendiente y la protección contra comprobantes activos duplicados se mantienen.


## RTN de proveedor — 1.2.4.0

Vendor.HN RTN Proveedor (71180 Code[50]) es el campo propio editable. El selector usa un temporal con valores distintos procedentes del campo V2, HN Ref 60450, antiguo 60450 y VAT Registration No. LeerRTNAnterior solo accede dinámicamente si existe el campo RTN Code[50] normal, pertenece al paquete instalado del App ID esperado y coincide el propietario. No incorpora dependencia de la app anterior.

Una única opción puede proponerse; varias opciones diferentes requieren selección. El campo nuevo 38 RTN proveedor completo Text[50] valida contra las fuentes disponibles y mantiene el snapshot. ObtenerRTNProveedor respalda los documentos antiguos con Vendor RTN Text[20]; no se cambian sus identidades/tipos ni se truncan valores largos para llenar ese campo. Borrador y certificado usan el getter. El selector finaliza el guardado del borrador antes de abrir modal y devuelve Text al control. No modifica datos maestros al elegir ni altera documentos emitidos.


## Sustitución de formatos — 1.2.5.0

Los 20 RDLC se reconstruyen con grupos por documento, repetición de cabeceras, salto entre documentos, moneda explícita, logo desde Información empresa y diseños de movimientos en horizontal. Se añaden columnas sin retirar las publicadas. CU 71117 HN Datos Formatos proporciona presentación de moneda, logo base64/MIME y letras por moneda sin escribir datos. El conversor existente conserva Convertir y añade ConvertirMoneda.

Herramientas: ampliar_datasets_formatos.py incorpora datos de presentación de forma idempotente; sustituir_formatos.py genera los RDLC desde las columnas AL actuales; crear_muestra_formatos.py produce un PDF ilustrativo separado. Los generadores anteriores se bloquean para impedir que borren ampliaciones de datasets. verificar_artefactos.py comprueba además que cada layout empaquetado coincide con su archivo y que filas/jerarquías son compatibles. Los diseños fueron contrastados estructuralmente con el XSD 2008 sobre una conversión inversa de la estructura; esto no equivale a validar ni renderizar el informe en BC.

No se añade lógica de emisión de CAI ni dependencia de la app anterior. La separación de exento/exonerado requiere definición posterior: no se deduce de VAT % = 0. Documentar y probar monedas, redondeos, descuentos, precios con ISV, agrupación y varias páginas en el sandbox. Se preparan dos pruebas adicionales de letras/moneda y redondeo; 78 en total, sin ejecución BC.


## Alcance de impresión 1.2.6.0

Solo se habilitan informes 50100, 50101 y 71116 (retención emitida, nota de débito y borrador de retención). HN Datos Formatos.FormatoActivo/ComprobarFormatoActivo controla la ejecución de los otros 17 en OnPreReport. Se ocultan sus acciones de página y UsageCategory=None; el centro ofrece tres acciones. Se mantienen objetos/diseños/columnas e IDs para evitar retiro de esquema o de personalizaciones. No se modifica Report Selections, Custom Report Selection ni selecciones de diseño. Una selección de empresa que ya apunte a un V2 pospuesto necesita revisión operativa para elegir el anterior; no se infiere un ID de legado.

La nota de débito se genera con nota_debito_compacta.py sobre la plantilla de retención aprobada: grupo por documento, ocho columnas centradas, emisor/CAI a la izquierda, cliente y documento a la derecha, origen/motivo, subtotal/ISV/total y firmas. No se copian procedimientos de las aplicaciones antiguas. El verificador exige que los formatos pospuestos estén ocultos y protegidos; 82 pruebas AL preparadas y compiladas, pendientes en BC.
