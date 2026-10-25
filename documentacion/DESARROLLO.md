# Desarrollo y conservación de datos

Versión 1.1.0.0 · 24 de octubre de 2026

## Organización y responsabilidad

Los módulos se encuentran en src/ y sus subcarpetas. Mueva archivos por responsabilidad funcional sin cambiar IDs o nombres de objetos de datos publicados. Las configuraciones por empresa son independientes: HN Localization Setup controla retenciones/débito y HN Config. Facturacion controla emisión de ventas y validación de compras.

Los nuevos objetos de configuración, proveedor, registro fiscal, informes y extensiones utilizan el rango 71100–71199, junto con los objetos de migración de la entrega anterior. Los objetos publicados 50100–50149 se conservan. Las pruebas utilizan 71250–71299. Los números se pueden repetir entre clases de objeto, pero no dentro de una clase ni entre campos de extensiones sobre la misma tabla destino.

## Español y compatibilidad

Use títulos, mensajes, comentarios y documentación en español. Las palabras reservadas de AL, los namespaces Microsoft y los nombres técnicos publicados siguen el contrato del compilador y del esquema. La presentación se traduce mediante Caption y ToolTip. No cambie un nombre/ID de campo o un tipo para traducirlo; revise primero migración y compatibilidad.

Los nombres técnicos de objetos AL tienen un máximo de 30 caracteres. Los títulos visibles pueden ser más descriptivos mediante Caption. El generador crear_informes.py y verificar_artefactos.py protegen esta condición; una corrección manual en un archivo generado debe incorporarse también al generador.

## Emisión fiscal de ventas

HN Gestion Facturacion se suscribe al registro estándar Sales-Post. Comprueba la marca Aplicar facturación HN y la configuración, dejando el recorrido de notas de débito a su gestor publicado. Los documentos API no reciben automáticamente la marca por habilitar documentos nuevos de la interfaz.

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

Los datasets se definen en Comprobantes.al y DocumentosYMovimientos.al. Los 18 layouts están en Informes/Disenos/. Los generadores mantienen sincronizados columnas y campos XML. El verificador examina nombres, expresiones, celdas, formatos y conservación del esquema anterior. No sustituye un motor RDLC ni una prueba de impresión.

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
