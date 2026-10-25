# Manual de usuario de Localización Honduras V2

Versión 1.2.0.0 · 24 de octubre de 2026 · INVTECH

Este manual explica la configuración y el uso de los módulos implementados. Las pantallas de la guía visual son ilustraciones del código, no capturas de un entorno operativo. La compilación y las comprobaciones locales no sustituyen la validación del registro y de la impresión en Business Central.

## 1. Preparar el entorno

1. Utilice una empresa de pruebas con clientes, proveedores, productos, cuentas, grupos contables, grupos de ISV, dimensiones y series estándar configurados.
2. Revise primero MIGRACION_POS.md. Se detectaron conflictos preexistentes entre los IDs de esta aplicación y API_BCPOS 1.0.0.41. No instale ambas juntas hasta resolver el traslado de esquema y datos en una copia del entorno.
3. Mantenga disponibles los datos de la localización anterior durante la preparación de migración. Habilitar V2 no desactiva sus suscriptores ni adapta la API existente.
4. Asigne HN LOCALIZATION y los permisos estándar que correspondan a compras, ventas, contabilidad e informes. Asigne HN MIGRATION solo a quienes ejecutarán la copia de metadatos.
5. Abra las páginas con la búsqueda de Business Central. Los nombres que aparecen en este manual son los títulos de búsqueda.
6. Use autorizaciones y documentos de prueba. Conciliar el último número emitido es un requisito previo a cualquier transición operativa.

## 2. Configurar la empresa y los módulos

1. Abra Información empresa. Complete nombre, dirección y RTN en N.º registro IVA, según la configuración estándar que utiliza el cliente.
2. Abra Configuración localización HN.
3. Defina una serie interna para retenciones y otra para notas de débito. Estas series identifican documentos BC y son diferentes del número fiscal SAR.
4. Habilite únicamente los módulos que probará.
5. Configure las series de pedidos, facturas registradas y abonos estándar de Business Central. La nueva facturación conserva esos números internos y añade un número fiscal propio.
6. No utilice el mismo correlativo fiscal en dos motores activos.

## 3. Registrar autorizaciones CAI propias

1. Entre desde Configuración de facturación HN → Autorizaciones CAI de ventas, o desde Retenciones HN / Notas de débito HN → Acciones → Configurar CAI.
2. Cree una autorización por rango y tipo de documento. Para ventas, seleccione Factura o Nota de crédito; la vista puede mostrar ambos tipos.
3. Complete código, CAI, número inicial, número final, próximo número, fecha inicial y fecha límite de emisión.
4. El CAI utiliza 37 caracteres en grupos XXXXXX-XXXXXX-XXXXXX-XXXXXX-XXXXXX-XX. El número fiscal utiliza 000-000-00-00000000.
5. Verifique establecimiento y punto de emisión. Inicial, final y próximo número deben compartir el mismo prefijo.
6. Los tipos soportados son 01 factura, 05 retención, 06 nota de crédito, 07 nota de débito y 11 boleta de compra. Cada autorización debe corresponder al documento que emitirá.
7. Concilie el próximo número con los comprobantes emitidos anteriormente y luego habilite la autorización.
8. Al renovar, cree otra autorización. Después de emitir, la autorización conserva su rango, vigencia y correlativos para auditoría; puede deshabilitarla.

Las comprobaciones son locales sobre las autorizaciones configuradas; no consultan una aprobación en línea del SAR.

La vigencia incluye el último día y el rango incluye el último número. Cuando se emite el número final, la autorización queda deshabilitada. Las vistas previas y los borradores no deben consumir números persistentes.

## 4. Configurar la facturación de ventas

1. Abra Configuración de facturación HN.
2. Seleccione la autorización predeterminada de facturas, de tipo 01.
3. Si emitirá abonos fiscales, seleccione una autorización predeterminada de notas de crédito, de tipo 06.
4. Active Habilitar facturación de ventas HN.
5. Guarde la configuración. Aplica automáticamente al registrar pedidos y facturas, incluidos los borradores existentes.
6. No hay casilla de aplicación por documento. El CAI se resuelve desde esta configuración al registrar; crear documentos no lo reserva ni asigna correlativos.
7. Valide la fecha documento: representa la fecha de emisión y debe encontrarse dentro de la vigencia autorizada. La fecha de registro continúa sujeta a los controles contables estándar.

Los documentos POS con identidad propia o referencia fiscal externa requieren revisar su procedencia antes de activar otra emisión. No genere otro número fiscal para una venta ya emitida por el POS. La adaptación del receptor y del cierre se realiza como parte de la migración pendiente.

## 5. Facturar desde un pedido de venta

1. Abra Pedidos de venta y cree un pedido.
2. Seleccione cliente, fechas, moneda, almacén y dimensiones.
3. Complete líneas, cantidades, unidades, precios, descuentos y grupos de ISV.
4. Complete el documento. Se utilizará automáticamente el CAI predeterminado vigente al registrar.
5. Abra Acciones → Validar facturación HN y corrija cualquier incidencia.
6. Si necesita revisar el documento antes del registro, use Centro de informes de localización HN → Borrador de venta y filtre por tipo y número interno. El borrador no tiene validez fiscal.
7. Ejecute la vista previa contable estándar y compruebe importes y dimensiones.
8. Registre Enviar y facturar, o Facturar si el envío ya está realizado.
9. Abra la factura registrada. Compruebe el número interno BC y el número fiscal HN.
10. Use Imprimir comprobante fiscal HN para generar el RDLC de factura de venta.
11. Consulte Movimientos fiscales HN y los movimientos contables y de cliente del documento.

Enviar sin facturar no consume un número de factura fiscal. Si factura parcialmente un pedido, cada factura registrada obtiene un correlativo nuevo; el pedido mantiene su identidad interna. Compruebe este recorrido en sandbox antes de operarlo.

## 6. Crear una factura de venta directa

1. Abra Facturas de venta → Nuevo.
2. Complete cliente, fecha documento, fecha de registro, moneda y líneas.
3. Complete las líneas. La configuración de facturación HN se aplica automáticamente al registrar.
4. Use Validar facturación HN y la vista previa estándar.
5. Registre el documento.
6. Abra la factura registrada y use Imprimir comprobante fiscal HN.
7. Compruebe que el CAI, rango, fecha límite, RTN y detalle coinciden con los datos emitidos.

La asignación fiscal utiliza el mismo control desde pedidos y facturas directas. No se cambia la serie interna estándar para convertirla en una serie fiscal.

## 7. Emitir una nota de crédito de venta

1. Cree un abono de venta o una devolución estándar que vaya a facturarse.
2. Revise en Configuración de facturación HN la autorización predeterminada de tipo 06; no hay aplicación manual por documento.
3. Seleccione Factura origen. Debe corresponder al mismo cliente de venta, cliente de facturación y moneda.
4. Revise número fiscal y CAI de origen. El sistema propone datos propios V2 o los metadatos POS preparados; no inventa un CAI ausente.
5. Complete el motivo de la nota de crédito.
6. Complete líneas y cantidades siguiendo el funcionamiento estándar del abono; no invierta signos por segunda vez.
7. Valide, previsualice y registre.
8. Abra el abono registrado y use Imprimir comprobante fiscal HN.
9. Compruebe la aplicación al cliente y sus efectos en cuentas, impuestos e inventario mediante los procesos estándar.

Una corrección estándar que cree documentos debe completar también la referencia fiscal y el motivo. No se implementa una anulación directa de facturas mediante borrado de movimientos; utilice los documentos correctivos de Business Central con el tratamiento fiscal que corresponda.

## 8. Gestionar varios CAI de un proveedor

1. Abra Gestión de CAI de proveedores HN. También puede entrar desde la ficha del proveedor o desde un documento de compra.
2. Seleccione N.º proveedor. La lista muestra su nombre para identificarlo sin memorizar el código.
3. Cree un código distinto por autorización, rango o punto de emisión.
4. Seleccione Factura para tipo 01 o Nota de crédito para tipo 06.
5. Capture CAI, rango inicial, rango final, fecha inicial y fecha límite exactamente como aparecen en el documento autorizado del proveedor.
6. Habilite la autorización después de completar los datos.
7. Repita para otros CAI del mismo proveedor. Los registros anteriores pueden conservarse deshabilitados.
8. Una autorización utilizada conserva sus datos: para renovarla, cree otra. No altere su vigencia histórica para permitir registrar una factura fuera de fecha.

El catálogo corresponde al proveedor que emite la factura, identificado por Comprar a. El proveedor de pago puede ser distinto; eso no cambia quién emitió el documento fiscal.

## 9. Validar pedidos y facturas de compra

1. Abra Configuración de facturación HN y active Exigir CAI del proveedor al registrar compras, cuando la empresa esté preparada para este control.
2. Abra el pedido o la factura de compra y seleccione el proveedor.
3. Capture el número completo de factura del proveedor y su fecha documento real.
4. Seleccione Autorización CAI del proveedor. Si no selecciona una, el sistema solo propone una automáticamente cuando existe una única coincidencia válida por proveedor, tipo, fecha y rango.
5. Use Validar CAI del proveedor para revisar el documento antes del registro.
6. Se comprueban habilitación, formato, tipo, prefijo, rango y vigencia respecto de la fecha documento. Si el CAI capturado difiere del catálogo elegido, debe resolverlo antes de continuar.
7. Al registrar la factura, se repite la validación y se guardan CAI, código, rango y fecha límite en el histórico.
8. Para abonos de compra, capture el número de abono del proveedor y seleccione una autorización de nota de crédito.
9. Abra el documento registrado y consulte su comprobante interno y sus movimientos.

Recibir mercancía sin facturar no emite la factura del proveedor. Una factura emitida dentro de la vigencia puede registrarse después del vencimiento: la comprobación fiscal utiliza su fecha de emisión, no modifica fechas para evitar el control. La fecha debe reflejar el documento real.

La impresión de compras es un comprobante interno y no sustituye el original emitido por el proveedor. El control nuevo no rellena automáticamente CAI históricos de otra localización.

## 10. Configurar y generar retenciones

1. Abra Conceptos de retención HN.
2. Defina código, descripción, porcentaje, base neta o ISV, mínimo, cuenta de retención por pagar y habilitación. Revise el concepto fiscal con el responsable contable.
3. En el proveedor, active Sujeto a retención HN y configure su vencimiento cuando corresponda.
4. En las líneas de compra, seleccione Códigos de retención HN. Puede elegir varios conceptos; no repita un código.
5. Registre la compra. La base definitiva proviene de las líneas efectivamente facturadas.
6. Abra Retenciones HN → Generar desde factura registrada. Seleccione una o varias facturas del mismo proveedor de pago y moneda.
7. En el borrador, revise Facturas incluidas. Use Agregar facturas o Quitar factura antes de registrar.
8. Seleccione autorización CAI de tipo 05, fecha y revise bases, porcentajes, importes y cuentas.
9. Use Recalcular si cambió la configuración y necesita actualizar un borrador.
10. Use Imprimir borrador o comprobante para revisar un documento sin validez fiscal y Vista previa de registro para inspeccionar los movimientos proyectados.
11. Registre. Se carga al proveedor, se abona la cuenta fiscal y se aplica la retención a cada factura, validando su saldo.
12. Compruebe el histórico, el comprobante y los movimientos contables y de proveedor.

La emisión de retenciones sigue siendo manual desde facturas registradas. No existe todavía automatización al contabilizar compras o pagos, ni prorrateo de retenciones por pagos parciales. La operación manual no autoriza posponer una obligación tributaria ya originada. No se vuelven a seleccionar facturas reservadas por otro comprobante activo de V2.

## 11. Anular y sustituir una retención

1. Abra Retenciones registradas HN y entre al comprobante.
2. Si ya se declaró o enteró al SAR, utilice Marcar declarada o enterada al SAR para dejar esa condición identificada.
3. Seleccione Anular y capture motivo y fecha contable.
4. Si está marcada como declarada o enterada, informe la referencia del tratamiento fiscal externo. Esta acción no modifica declaraciones ni recupera impuestos del SAR.
5. Confirme y revise el resultado. El sistema utiliza desliquidación estándar y movimientos compensatorios; un rechazo de BC debe impedir dejar una anulación parcial.
6. Reimprima. El documento debe mostrar ANULADA y conservar su correlativo, CAI y detalle.
7. Si necesita reemplazo, seleccione Crear sustituto. Revise el nuevo borrador, sus facturas y su autorización; al registrar recibirá otro número fiscal.
8. Concilie proveedor, cuenta fiscal y aplicaciones mediante los informes de movimientos y aplicaciones.

No se elimina el comprobante ni se reutiliza el número anulado. Los comprobantes V2 anteriores sin vínculo fiable al movimiento requieren conciliación antes de anularlos. Cambiar un comprobante no elimina por sí solo una obligación tributaria real.

## 12. Crear una nota de débito de venta

1. Abra Notas de débito HN y cree el documento.
2. Si falta configuración, complete habilitación y serie interna antes de continuar.
3. Seleccione cliente, fechas y moneda.
4. Seleccione la factura de origen y revise que corresponda al mismo cliente y moneda.
5. Abra Acciones → Datos fiscales y complete número fiscal de origen, CAI de origen y autorización de tipo 07.
6. Complete motivo y líneas del cargo adicional.
7. Use la vista previa estándar. Para impresión previa, el informe Borrador de venta puede filtrar este documento interno.
8. Registre o registre e imprima.
9. Revise el histórico y los movimientos del cliente. La nota genera su propio saldo por cobrar.

El CAI no ocupa un panel permanente en la página principal de notas de débito. Su configuración y los datos fiscales se abren desde acciones. La autorización de facturas de tipo 01 no sustituye la de notas de débito de tipo 07.

## 13. Consultar e imprimir los 20 formatos RDLC

Abra Centro de informes de localización HN. Elija el informe, aplique los filtros y revise antes de exportar a PDF o imprimir. Los comprobantes de documentos también están disponibles desde sus páginas registradas.

| Formato | Utilidad |
|---|---|
| Comprobante de retención | Emisión, reimpresión y documento anulado conservado. |
| Comprobante de nota de débito | Cargo adicional con referencia y CAI de origen. |
| Factura de venta | Facturación propia desde pedido o factura directa. |
| Nota de crédito de venta | Documento correctivo y referencia fiscal de origen. |
| Comprobante interno de compra | Respaldo de la factura de compra registrada. |
| Comprobante interno de abono de compra | Respaldo del abono registrado del proveedor. |
| Boleta de compra | Comprobante fiscal propio de tipo 11; se imprime después de registrar. |
| Borrador de boleta | Revisión sin número reservado ni validez fiscal. |
| Borrador de venta | Revisión de pedidos, facturas, abonos y notas de débito abiertos. |
| Borrador de compra | Revisión del documento de compra abierto. |
| Borrador de retención | Revisión previa sin emisión fiscal. |
| Movimientos contables | Cargos y abonos por cuenta, fecha y documento. |
| Movimientos de proveedores | Importes y saldo pendiente actual por movimiento. |
| Movimientos de clientes | Importes y saldo pendiente actual por movimiento. |
| Movimientos fiscales y CAI | Registro de autorizaciones utilizadas y documentos recibidos/emitidos por el nuevo recorrido. |
| Autorizaciones CAI de ventas | Rango, próximo número, estado y vigencia. |
| Autorizaciones CAI de proveedores | Proveedor, nombre, CAI, rango y vigencia. |
| Aplicaciones y desliquidaciones de proveedores | Detalle de aplicaciones, anulaciones de aplicación y movimientos relacionados. |
| Aplicaciones y desliquidaciones de clientes | Detalle equivalente para cuentas por cobrar. |
| Movimientos de impuestos ISV | Base e impuesto por documento, fecha y grupo fiscal. |

Filtre los informes contables por el número interno BC; el registro fiscal relaciona ese número con el número fiscal. En las aplicaciones, utilice el número de movimiento del cliente/proveedor cuando necesite identificar una aplicación concreta. Los saldos mostrados son actuales, no un estado de cuenta histórico a una fecha de corte. Moneda vacía o ML representa moneda local; no sume importes de divisas distintas. El registro fiscal nuevo no importa automáticamente todos los consumos de autorizaciones anteriores.

## 14. Preparar la migración POS sin perder información

1. Lea MIGRACION_POS.md y el mapa de campos en migracion/mapa-campos.json.
2. Resuelva la convivencia de IDs antes de instalar extensiones juntas. No renumere directamente campos publicados ni use ForceSync para eliminar información.
3. Trabaje en una copia representativa, manteniendo el origen instalado y accesible.
4. Asigne HN MIGRATION y abra Verificación de migración HN.
5. Elija tabla 18, 36, 37, 112, 113, 114 o 115 y ejecute con Aplicar copia desactivado.
6. Revise propietario, ID, nombre, tipo, longitud, registros y conflictos. No continúe con diferencias sin conciliar.
7. Ejecute la copia revisada: solo rellena destinos vacíos y no modifica importes contables ni borra el origen.
8. Repita la verificación y concilie valores y conteos.
9. Adapte el receptor API, revisión/cierre y catálogos antes del corte. Los nombres del contrato JSON se conservan.
10. Pruebe dos sucursales con identificador repetido, reenvíos, pagos múltiples, devoluciones y turnos nocturnos T3. No cambie fechas contables para corregir pertenencia al turno.

Crear campos no redirige las escrituras de la API actual. Los campos publicados conservan sus nombres técnicos e IDs para mantener datos y contratos; sus títulos visibles están en español.

## 15. Resolver incidencias frecuentes

| Mensaje o situación | Qué revisar |
|---|---|
| CAI fuera de vigencia | Fecha de emisión real y autorización seleccionada; no ampliar el registro usado. |
| Número fuera del rango | Establecimiento, punto de emisión, tipo y consecutivo. |
| Más de un CAI de proveedor aplicable | Seleccionar expresamente la autorización correcta y revisar rangos superpuestos. |
| Factura reservada por otra retención | Abrir el comprobante existente o resolverlo antes de emitir otro. |
| Retención supera saldo pendiente | Pagos, aplicaciones existentes e importe que corresponde retener. |
| Nota de crédito sin origen fiscal | Referencia a factura, CAI completo y motivo; completar la migración si faltan datos. |
| Documento con referencia fiscal externa | Revisar si ya fue emitido por el POS antes de activar una nueva emisión. |
| Error al anular por período o aplicación | Revisar fecha contable permitida y secuencia de aplicaciones estándar. |
| AL0305 al desarrollar | El nombre técnico del objeto no puede superar 30 caracteres; el título visible puede ser descriptivo. |
| Migración con campos distintos | Verificar versión y propietario del origen; no truncar ni sobrescribir. |

## 16. Prueba de aceptación antes de operar

1. Configurar empresa, permisos, series, CAI propios y dos CAI del mismo proveedor.
2. Emitir desde pedido y factura directa; comprobar facturación parcial y envío sin factura.
3. Probar factura y abono de venta con CAI correcto, vencido, agotado y de tipo incorrecto.
4. Probar compra desde pedido/factura con proveedor correcto, dos rangos, fecha límite y número fuera del rango; recibir sin facturar.
5. Registrar varias retenciones, agrupar facturas, anular, sustituir y conciliar cuentas/aplicaciones.
6. Registrar nota de débito con origen y datos fiscales completos.
7. Verificar que las vistas previas no consuman números y que un fallo contable no deje estados o emisiones parciales.
8. Imprimir los 20 formatos, incluidos documentos largos de varias páginas, signos, moneda, direcciones, RTN, CAI, rangos y totales.
9. Ejecutar las pruebas AL con un ejecutor de pruebas estándar en una empresa desechable de sandbox y conservar evidencia.
10. Completar recepción POS, devoluciones, reenvíos, T3 y cierre antes de retirar dependencias.

Estado de esta entrega: código y pruebas preparados para compilación/verificación local. Sin resultados de ejecución en Business Central ni validación de impresión real. No se han migrado datos ni modificado las ventas recibidas por la API.


## 18. Configurar y registrar boletas de compra

1. En Información de empresa complete nombre, RTN, dirección, teléfono y correo electrónico. Configure la moneda local HNL y las series internas estándar de compras.
2. Abra Configuración de facturación HN → Acciones → CAI de boletas de compra. Cree una autorización de tipo Boleta de compra (11), con CAI completo, rango `000-001-11-00000001` a su límite real, próximo número y fechas vigentes. Habilítela.
3. En Configuración de facturación HN seleccione Autorización de boletas de compra y active Habilitar boletas de compra HN. Esta opción es independiente de la validación del CAI recibido del proveedor.
4. En la ficha del proveedor confirme Persona natural hondureña para boletas y capture RTN o identidad para boletas, nombre y apellidos, dirección y teléfono. La condición debe verificarse documentalmente antes de habilitarla.
5. Busque Boletas de compra HN → Nueva boleta de compra. Seleccione el proveedor, revise su identidad, teléfono, dirección, fechas, términos y forma de pago. No capture una factura ni un CAI del proveedor: el emisor de esta boleta es la empresa adquirente.
6. Añada bienes o servicios de mano de obra no calificada, descripción detallada, cantidades y costos. Use grupos contables de impuesto con ISV 0 %, cálculo normal y sin diferencia entre importe e importe con impuestos. El sistema rechaza líneas que generen crédito fiscal de ISV, cantidades no positivas o importes negativos.
7. Si corresponde, complete orden de compra exenta, constancia de exonerados y registro SAG en el grupo Datos del adquirente exonerado.
8. Use Validar boleta e Imprimir borrador sin validez fiscal. El borrador indica SIN EMITIR. La vista previa permite revisar la contabilidad sin emitir ni mostrar un número fiscal especulativo.
9. Pulse Registrar. Solo al crear la factura registrada se obtiene el próximo correlativo disponible del CAI vigente. La autorización, el histórico y los movimientos forman parte de la misma transacción de registro; un error revierte el consumo.
10. Abra Boletas de compra registradas HN, seleccione el documento y pulse Imprimir boleta de compra. El comprobante incluye CAI, rango, vencimiento, datos del emisor y proveedor, detalle, total en lempiras y letras, firma y huella. Reimprimir no consume otro número. Recoja firma y huella del proveedor en el comprobante físico.
11. Consulte los movimientos estándar de proveedor, contabilidad e ISV y el movimiento fiscal propio. El campo Recibido de proveedor aparece desactivado porque la boleta se emite con CAI de la empresa, aunque contabilice una compra.

Para emitir desde un pedido de compra, capture el proveedor y use Acciones → Emitir como boleta de compra. Esta acción identifica la clase de documento y no asigna ni reserva CAI ni correlativo. Complete los datos de identidad y teléfono visibles en el pedido. Recibir sin facturar no emite boleta. Cada facturación parcial genera su propia boleta; el pedido conserva únicamente su número interno. Si eligió la clase equivocada antes de registrar, use Volver a factura de proveedor y capture los datos fiscales del proveedor que correspondan.

Las boletas no reemplazan indiscriminadamente las facturas de proveedores. Los artículos 20–22 del [reglamento consolidado publicado por el SAR](https://www.sar.gob.hn/download/texto-consolidado-del-reglamento-del-regimen-de-facturacion-otros-documentos-fiscales-y-registro-de-imprentas-segun-acuerdos-609-2017-725-2018-y-817-2018-elaborado-por-la-direccion-nacional-juridc/) exigen su uso para los supuestos admitidos, establecen un límite agregado del 5 % de gastos operativos deducibles, excluidos los financieros, y un límite por persona vinculado a la base exenta anual de ISR. Esta versión valida los datos del comprobante y evita crédito de ISV; la procedencia fiscal, los límites anuales y los gastos externos deben conciliarse por contabilidad. No calcula automáticamente esos límites ni presenta declaraciones. La corrección/anulación fiscal de boletas emitidas requiere un desarrollo específico posterior; esta versión no habilita reutilizar ni borrar su correlativo.

### Comprobar que no se reservan números anticipados

1. Anote el Próximo número y Último número emitido de una autorización.
2. Cree dos pedidos y dos facturas de venta, guárdelos en distinto orden y elimine uno sin registrar. Ninguno debe tener número fiscal ni modificar el rango.
3. Valide e imprima borradores y ejecute vistas previas: los números deben seguir iguales y la vista previa no debe mostrar un fiscal especulativo.
4. Registre primero el documento creado al final: recibe el próximo número disponible. El siguiente registro exitoso recibe el consecutivo posterior.
5. Repita con una boleta directa y un pedido de compra identificado como boleta, incluyendo recepción sin factura y facturación parcial.
6. Provoque un error de contabilización posterior a la asignación en una empresa de pruebas. Compruebe que no existe documento/movimiento fiscal emitido ni avance del correlativo; corrija y registre de nuevo.
7. Pruebe dos sesiones que registren a la vez. El bloqueo de autorización debe serializar la emisión sin números duplicados. Esta comprobación operativa está pendiente en sandbox.
