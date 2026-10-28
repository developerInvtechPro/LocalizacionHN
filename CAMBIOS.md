# Cambios

## Variante de producción 1.3.0.0 — 28 de octubre de 2026

- Paquete separado para primera instalación de V2 en producción: identidades 50100–50149 trasladadas a 73000–73049, conservando el rango 71100–71199 y el App ID.
- Resueltas las 14 colisiones de IDs identificadas con API_BCPOS 1.0.0.41. Auditoría local sin colisiones con los 308 paquetes no Microsoft examinados; no equivale a inventario del servidor.
- Conservados nombres, tipos/longitudes y valores de enumeración. Destinos y firma del mapa de referencias actualizados en la variante, sin modificar el mapa/base del sandbox.
- Entrega de aplicación, fuentes de producción y auditoría de transformaciones/hashes. No se publica, instala ni migra información. No usar esta variante como actualización directa del sandbox 1.2.x con datos.

## 1.2.6.0 — 27 de octubre de 2026

- Impresión V2 limitada a retención (comprobante/borrador) y nota de débito. Los otros 17 formatos dejan de aparecer en búsqueda, centro de informes y acciones V2; su ejecución directa se bloquea mientras se define la migración.
- Conservados objetos, diseños y permisos existentes para futura reactivación. No se cambian selecciones de informes ni diseños de la localización anterior; tampoco se desinstalan sus aplicaciones.
- Nota de débito adaptada a la plantilla compacta de retención: emisor/CAI a la izquierda, cliente/documento a la derecha, origen y motivo, columnas centradas y espacio de firmas.
- Dos pruebas de control de alcance preparadas (82 pruebas AL en total, sin ejecutar en BC). Seis pruebas Python de estructura aprobadas. Impresión real de nota de débito y convivencia pendientes de validar en sandbox.

## 1.2.5.10 — 27 de octubre de 2026

- Títulos y valores de todas las columnas del detalle de retención centrados.
- Área de firmas ampliada a 1.15 pulgadas, con líneas y etiquetas ELABORADO POR / RECIBIDO POR en la parte inferior.
- Eliminado el aviso superior de la muestra PDF a solicitud del usuario; la muestra sigue siendo una ilustración, no una impresión de BC.

## 1.2.5.9 — 27 de octubre de 2026

- Eliminada la repetición de factura y fecha de origen en el recuadro del proveedor; esos datos permanecen en las líneas.
- Dirección del emisor rotulada explícitamente. Espaciado de párrafos y márgenes uniformes en ambos recuadros, alineación superior y altura más compacta.

## 1.2.5.8 — 27 de octubre de 2026

- Número fiscal, documento BC y fecha de emisión trasladados al recuadro derecho del comprobante y borrador de retención; el izquierdo queda reservado a emisor y CAI.

## 1.2.5.7 — 27 de octubre de 2026

- Cabecera de retención reorganizada: emisor, documento y autorización CAI en el recuadro izquierdo; proveedor y referencia de factura en el derecho.
- Eliminada la fila de CAI que ocupaba todo el ancho. Con varias facturas, el recuadro del proveedor remite al detalle, sin presentar una sola factura como origen del grupo.

## 1.2.5.6 — 27 de octubre de 2026

- El asiento de retención asigna Tipo documento Pago; la compensación de anulación asigna Reembolso por su signo negativo. Se conservan proveedor, contrapartida fiscal, importe y número externo.
- Dos pruebas de inicialización preparadas para emisión y compensación. No se reclasifican movimientos ya contabilizados. Total de pruebas AL: 80, pendientes de ejecución en BC.

## 1.2.5.5 — 27 de octubre de 2026

- Moneda de los comprobantes identificada por nombre y código: Lempiras (HNL), Dólares estadounidenses (USD) y Euros (EUR); otras divisas conservan su código.
- Se conserva la moneda del documento y el importe en letras correspondiente, sin conversiones ni modificaciones de documentos registrados. Una divisa vacía utiliza el código local configurado.

## 1.2.5.4 — 27 de octubre de 2026

- Datos del emisor trasladados al recuadro izquierdo debajo del título en comprobante y borrador de retención. Se conserva el proveedor en el derecho.
- Eliminado el bloque superior independiente y omitido el contacto vacío o compuesto solo por el separador. Mayor altura del recuadro para evitar recortes.

## 1.2.5.3 — 27 de octubre de 2026

- Restaurada la presentación compacta anterior en comprobante y borrador de retención, a elección del usuario.
- Eliminada únicamente la columna visible CAI factura del detalle; se conserva el campo y su información histórica, además del CAI del comprobante en cabecera.
- Títulos «COMPROBANTE DE RETENCIÓN» y «BORRADOR DE RETENCIÓN». Se conserva la corrección de fecha de impresión y de celdas combinadas.

## 1.2.5.2 — 27 de octubre de 2026

- Cabecera común ajustada a la factura de referencia: marco negro de empresa, espacio para logo, nombre destacado, RTN/dirección/contacto separados y título enmarcado.
- Datos fiscales y CAI en el recuadro izquierdo; tercero y referencias de exoneración en el derecho, con etiquetas en negrita y valores normales.
- Suprimido el separador de contacto cuando no hay teléfono/correo. Fecha de impresión preparada en AL para sustituir la expresión de pie que mostraba #Error en el PDF proporcionado.
- Sin cambios en la emisión fiscal ni en el cálculo de importes. Requiere validar la presentación final en BC.

## 1.2.5.1 — 27 de octubre de 2026

- Corregidas las combinaciones de celdas de los 20 RDLC: una celda física por columna y sin CellContents en las posiciones cubiertas por ColSpan.
- Corregido el generador y el verificador, que antes solo comprobaba la suma de amplitudes y no detectaba las posiciones cubiertas.
- Seis pruebas Python de regresión, incluidas la estructura fallida de 1.2.5.0 y la revisión de todos los diseños. Sin cambios en documentos, contabilización o CAI.

## 1.2.5.0 — 27 de octubre de 2026

- Sustituidos los 20 diseños RDLC de V2 con una presentación basada en las muestras del archivo FORMATOS ACTUALIZADOS: cabecera/logo, cajas fiscales y tercero, detalle, totales, letras, firmas y paginación.
- Datasets ampliados con logo configurable, contacto, moneda efectiva, letras por moneda, código/unidad, descuentos e impuesto por línea. Sin dependencias de los informes anteriores y sin cambiar IDs o campos publicados.
- Retenciones con factura, CAI y fecha por línea, aviso de anulación y desglose de base, porcentaje e importe. Borradores identificados sin validez fiscal.
- Movimientos en horizontal, con tercero, moneda por fila y etiquetas de base/impuesto para ISV. No se suman monedas distintas.
- Generadores anteriores retirados para evitar sobrescritura de las ampliaciones. Verificación de identidad entre cada RDLC fuente y su contenido empaquetado, y entre filas y jerarquías.
- Dos pruebas preparadas de letras/moneda y redondeo; 78 pruebas en total, pendientes de ejecución en BC. PDF ilustrativo separado de la impresión real.

## 1.2.4.3 — 27 de octubre de 2026

- Actualización de los 20 RDLC del esquema 2008 al esquema 2016 con ReportSections, conservando textos, expresiones, estilos, medidas y campos.
- Los generadores guardan el esquema actualizado y el verificador rechaza la estructura anterior. No se regeneran los diseños existentes.
- Preparación ante el rechazo de compatibilidad del informe 50100 en sandbox; la resolución requiere comprobar el informe instalado y su impresión real.

## 1.2.4.2 — 27 de octubre de 2026

- Protección de cabeceras de retención basada en el estado guardado bajo bloqueo, en lugar de xRec. Permite finalizar el registro desde borrador tanto en registro real como en vista previa.
- Conserva el bloqueo de modificaciones sobre documentos ya registrados y evita sobrescribirlos desde un búfer desactualizado.
- Tres pruebas de regresión preparadas para la transición y la inmutabilidad; no se añaden commits al registro ni se cambia el tratamiento transaccional del CAI.

## 1.2.4.1 — 27 de octubre de 2026

- Consulta del RTN anterior desde el registro guardado mediante RecordRef; conserva la comprobación de nombre, tipo, longitud y propietario.
- La comprobación del paquete admite cualquiera de las filas instaladas que corresponda al propietario del campo, sin depender de la primera fila.
- Mensajes de RTN sin opciones distinguen ausencia, incompatibilidad, propietario no verificado y valor anterior vacío; identifican el proveedor y el campo V2 que debe completarse.
- No se cambian datos existentes, claves ni campos publicados. Requiere validación operativa en sandbox.

## 1.2.4.0 — 27 de octubre de 2026

- RTN propio editable Code[50] en proveedor y selector en el borrador de retención.
- Fuentes disponibles: V2, referencia migrada, campo anterior dinámico verificado y registro estándar. Valores iguales agrupados; distintos requieren elegir.
- Snapshot de RTN completo Text[50] para comprobante y RDLC; se conserva el campo publicado de 20 caracteres y la compatibilidad de documentos anteriores.
- Lectura temporal del campo anterior sin dependencia de compilación; ausencia de la extensión origen no bloquea las otras fuentes.

## 1.2.3.1 — 27 de octubre de 2026

- El selector de conceptos devuelve el texto normalizado al control OnLookup para evitar que un valor vacío sobrescriba la elección guardada.
- Cancelar la búsqueda conserva la selección anterior. Prueba de página preparada para seleccionar, cerrar, leer de nuevo y recalcular.

## 1.2.3.0 — 27 de octubre de 2026

- Selección de retenciones desde el borrador para facturas registradas sin conceptos; datos separados de la factura original.
- Creación de borrador sin selección previa, cálculo sobre bases registradas y validación de importe positivo por factura al registrar.
- Conservación de selección al recalcular/sustituir, bloqueo de edición de documentos emitidos y limpieza al quitar factura/borrar borrador.
- Tres pruebas de cálculo posterior, factura inmutable y control de facturas agrupadas; 66 pruebas preparadas en total, pendientes de ejecución en BC.

## 1.2.2.0 — 26 de octubre de 2026

- Copia ampliada a 236 campos de referencia, incluyendo compras, proveedores, empresa, datos restantes de documentos y ocho catálogos/históricos.
- Claves, tipos y longitudes preservados; CAI Code[37], correlativos Code[50], opciones, GUID y Blob sin truncar.
- Consulta desde documentos/líneas/proveedores y listas propias, independiente de la extensión anterior.
- Validación de datos copiados sin convertirlos en configuración activa ni exigirles nuevas reglas fiscales. Sin registro contable ni consumo de CAI.
- 63 pruebas AL preparadas; ejecución y validación operativa pendientes en BC.

## 1.2.1.0 — 26 de octubre de 2026

- Migración por conjunto de tablas o tabla individual, con revisión previa, copia transaccional y comparación automática posterior.
- Validación independiente vinculada a una copia Correcta; auditoría por fase, pendientes/coincidencias/copias/conflictos y exportación CSV.
- Revisión fiscal posterior de identidades POS: duplicados, CAI completo, rangos, prefijos y fechas históricas. Sin correcciones automáticas de datos anteriores.
- Verificación de propietario y nombre de destino. Contraste local del mapa con origen 1.0.1.73/1.0.1.74: 68 correspondencias sin diferencias.
- Tabla 115 explícitamente Sin correspondencias. Procedimiento, acta y manual actualizados; sin migración ni desinstalación ejecutadas en BC.

## 1.2.0.0 — 24 de octubre de 2026

- Facturación automática desde pedidos y facturas, sin casilla de aplicación ni CAI editable anticipado. Se conserva el esquema anterior.
- El CAI se resuelve con la configuración vigente; el próximo fiscal se consume únicamente en el registro real. Vistas previas devuelven fiscal vacío.
- Boletas de compra tipo 11: configuración, ficha, pedidos/facturas estándar, histórico, campos propios, validación sin crédito ISV y movimiento fiscal emitido.
- RDLC de boleta registrada y borrador: identificación, contacto, importe en letras, firma/huella y exoneraciones. Total: 20 diseños.
- 42 pruebas AL preparadas, documentación y manuales PDF actualizados. Compilación local; ejecución y renderizado en BC pendientes.

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
