# Formatos activos — versión 1.2.6.0

En esta etapa solo se imprimen desde V2 **retención** (comprobante y borrador) y **nota de débito**. Los formatos anteriores de los demás documentos continúan en uso hasta acordar su migración.

## Acciones disponibles

El Centro de informes de localización HN contiene tres acciones: Comprobante de retención, Borrador de retención y Comprobante de nota de débito. También se mantienen las acciones de impresión en las páginas propias de ambos módulos.

Los otros 17 formatos V2 están ocultos en búsqueda, centro y páginas. Una ejecución directa devuelve un mensaje de formato pospuesto. Sus objetos, IDs, columnas y diseños se conservan para reactivación futura; no se elimina información.

No se modifica la configuración de Selección de informes ni la selección de diseños, ni se instala o desinstala ninguna aplicación anterior. **Si la empresa ya había seleccionado un informe V2 de los ahora pospuestos como formato habitual, hay que elegir su informe anterior correcto antes de imprimir.** La extensión no deduce ese informe ni cambia selecciones automáticamente.

## Retención

Se mantiene el diseño aprobado: emisor, dirección y CAI en el recuadro izquierdo; proveedor e identificación del comprobante en el derecho. Factura y fecha de origen aparecen solo en las líneas. La columna CAI de líneas no se imprime, pero el dato se conserva. Títulos y valores del detalle están centrados. Las firmas tienen espacio de 1.15 pulgadas con ELABORADO POR / RECIBIDO POR abajo. Se mantienen borrador, reimpresión y aviso de anulación.

## Nota de débito

Utiliza la misma plantilla compacta y distribución que retención:

- Izquierda: emisor, RTN, dirección/contacto y autorización CAI.
- Derecha: cliente, RTN, dirección, número fiscal, documento BC y fechas.
- Bloque propio de factura fiscal de origen, fecha, CAI de origen y motivo.
- Detalle centrado con código, descripción, unidad, cantidad, precio, descuentos, ISV e importe.
- Moneda por nombre/código, subtotal, ISV, total, importe en letras y espacio para firmas.

Se conserva el origen y los importes del documento registrado. No se copian lógica ni campos activos de los informes antiguos. La imagen de muestra es ilustrativa y usa datos ficticios; no acredita impresión en Business Central.

## Moneda y datos históricos

El documento conserva su divisa. Los rótulos identifican Lempiras (HNL), Dólares estadounidenses (USD), Euros (EUR) u otro código. Las letras usan la misma moneda. Un código vacío utiliza la divisa local configurada. No se convierten importes al cambiar el rótulo.

La identidad fiscal y CAI se leen de los datos guardados del documento. El contacto del emisor procede de Información empresa. Imprimir no cambia el estado ni consume otro número CAI. La impresión de otros documentos sigue correspondiendo al formato anterior seleccionado.

## Validación

Compilación y comprobaciones locales de campos, expresiones, celdas, jerarquías, alcance de impresión y correspondencia entre fuentes RDLC y paquete. Seis pruebas Python de estructura aprobadas. Hay 82 pruebas AL preparadas y compiladas, pendientes de ejecutar en BC.

En sandbox comprobar impresión/reimpresión de retención y nota de débito, facturas agrupadas, descuentos, impuestos, divisas y varias páginas. Confirmar que los demás documentos se imprimen con sus formatos anteriores y que no hay selecciones operativas apuntando a los V2 pospuestos.

## Herramientas

La retención usa `herramientas/plantillas/RetencionCompacta.rdlc`; la nota de débito se adapta desde ella mediante `nota_debito_compacta.py`. `sustituir_formatos.py` regenera diseños; no cambia el control de activación. Los generadores anteriores están retirados para evitar sobrescribir las ampliaciones. Después de cambios ejecutar compilación, `verificar_artefactos.py` y las pruebas de estructura. La mera regeneración de un diseño pospuesto no lo activa.
