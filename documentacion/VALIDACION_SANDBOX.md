# Validación de la extensión independiente

## Identidad y publicación

- Aplicación: `LocalizacionHN_V2`, publisher `INVTECH`, versión `1.2.2.0`.
- ID propio: `0afcac2a-37c1-4666-b0a6-72d4e5320046`.
- BC28/runtime17; sin dependencias de extensiones de terceros.
- Paquete local de preparación: `artefactos/INVTECH_LocalizacionHN_V2_1.2.2.0.app`. **No publicar junto a API_BCPOS 1.0.0.41** hasta resolver los conflictos de IDs documentados en [MIGRACION_POS.md](MIGRACION_POS.md). Las pruebas iniciales requieren un sandbox aislado compatible y sincronización normal.
- No requiere el paquete anterior de compatibilidad 1.0.1.74 ni sus fuentes.

El manifiesto y el paquete compilado fueron comprobados sin dependencias. La compilación se ejecuta con símbolos de Microsoft únicamente. Las pruebas AL se compilaron, pero no se ejecutaron en Business Central; tampoco se validó visualmente la impresión.

Si una versión dependiente de V2 llegó a instalarse previamente, revisar la actualización en una copia del sandbox: se retiraron sus extensiones sobre tablas de la otra localización y se sustituyeron por campos en tablas estándar. Mantener sincronización normal y preservar los datos existentes; un rechazo de esquema requiere un plan de actualización específico, no ForceSync ni eliminación de datos.

## Convivencia con la localización anterior

Los datos anteriores permanecen sin cambios y no se utilizan durante el funcionamiento de V2. El funcionamiento diario de V2 no lee sus tablas/campos ni llama a sus codeunits. La herramienta de migración separada puede leer campos de origen bajo demanda y tras verificar el esquema/propietario.

Que V2 sea independiente no impide que otro módulo instalado siga ejecutando sus propios eventos. Antes de operar retenciones en la misma empresa, desactivar por separado el cálculo, generación, contabilización y consumo de CAI del motor anterior. Si no puede desactivarse todavía, realizar las pruebas en una empresa/entorno donde ese motor no procese las compras.

Conciliar documentos y diarios pendientes, saldos y correlativos emitidos antes del cambio operativo. La nueva configuración no puede detectar duplicados almacenados únicamente en la extensión anterior y no debe suponerse que lo haga.

## Configuración inicial

1. Asignar `HN LOCALIZATION`, además de los permisos estándar de compras, ventas y contabilidad.
2. Abrir **Configuración localización HN**. Definir series internas distintas para retenciones y notas de débito y habilitar los módulos que se probarán. Estas opciones afectan únicamente a V2.
3. Configurar **Conceptos de retención HN**: código, descripción, porcentaje, base neta o impuesto, mínimo, cuenta de retención por pagar y estado activo. Es un catálogo nuevo, no una vista del catálogo anterior.
4. En cada proveedor que corresponda, configurar **Sujeto a retención HN** y, cuando aplique, su fecha de vencimiento. Estos son campos nuevos; los indicadores anteriores no se consultan.
5. En **Retenciones HN** y **Notas de débito HN**, abrir **Acciones → Configurar CAI**. La configuración se abre a demanda y no ocupa espacio permanente en la lista ni en la ficha. Crear un registro por autorización y tipo, completar vigencia, rango y próximo número conciliado antes de habilitarlo.

El número tiene formato `000-000-00-00000000`. Los controles vigentes usan tipo 05 para retenciones y 07 para notas de débito. La fecha límite es inclusiva y puede emitirse el último número autorizado. Después, la autorización queda deshabilitada. Los datos de una autorización utilizada se conservan; una renovación crea otra autorización.

## Primer acceso y configuración general

La configuración por empresa se crea al abrir el módulo y se conserva sin reiniciar sus valores. Al abrir una nota de débito sin habilitación o serie, se abre la configuración general antes de permitir editar el documento. Si se cierra sin completar ambos datos, no se continúa con la creación de la nota. La selección de la factura ya no debe provocar un error genérico de configuración inexistente.

Los datos fiscales de una nota se editan en **Acciones → Datos fiscales**; el CAI no se muestra en su sección general. Las autorizaciones se mantienen en **Acciones → Configurar CAI**, filtradas al tipo correspondiente.

## Retenciones

- Seleccionar **Códigos de retención HN** en cada línea del pedido o factura. Los códigos de otro módulo no se interpretan automáticamente.
- Indicar el CAI del documento del proveedor en el campo propio de la compra. Se conserva al registrar la factura.
- El registro estándar conserva los códigos y el importe de retención de V2 en campos propios de la factura registrada. La base definitiva se toma de los importes facturados, incluidos los efectos de descuentos y facturación parcial.
- Desde **Retenciones HN**, generar el borrador seleccionando una o varias facturas registradas del mismo proveedor/moneda. La ficha permite agregar o quitar facturas antes de registrar. Revisar líneas, fecha y autorización CAI.
- **Recalcular** actualiza un borrador con las reglas propias vigentes. **Vista previa de registro** simula el registro y revierte sus cambios.
- **Registrar** utiliza la contabilización estándar: cargo al proveedor, abono a la cuenta fiscal configurada y aplicación a la factura. Valida saldo pendiente y utiliza moneda/dimensiones de los documentos.
- Consultar **Retenciones registradas HN** e imprimir el comprobante con los datos conservados al emitir.

La generación es manual desde facturas registradas. No se crea automáticamente un comprobante al registrar compras o pagos. Se admiten varias facturas por comprobante; se valida el saldo por factura. No se divide una retención por cada pago parcial. La emisión manual no es autorización para posponer una obligación fiscal ya nacida.

Los documentos históricos que no tengan los campos propios requieren un proceso de preparación/migración antes de generar sus retenciones. No se aplican todos los conceptos activos como sustitución de códigos ausentes.

## Notas de débito de ventas

- Abrir **Notas de débito HN → Nueva nota de débito**.
- Seleccionar cliente, fechas y moneda. La autorización y el CAI del origen se completan en **Acciones → Datos fiscales**.
- Seleccionar la factura origen. La referencia interna y la fecha provienen del documento estándar.
- Completar los datos de origen; el **CAI factura origen** se encuentra en **Acciones → Datos fiscales**. Para documentos que tengan datos propios de V2 se proponen esos datos. Para otras facturas, el número estándar externo se propone como referencia y debe revisarse; el CAI se completa explícitamente, sin leer campos de otra extensión.
- Indicar motivo y líneas. Se usa el subformulario estándar de factura de venta.
- Previsualizar, registrar o registrar e imprimir.
- Consultar **Notas de débito registradas HN** para imprimir y buscar movimientos. El histórico muestra únicamente notas identificadas por el campo propio de V2.

Se valida cliente de venta/facturación, moneda, fecha, motivo y datos fiscales del origen. Cada nota genera su propio saldo por cobrar. Los datos fiscales, motivo y referencia se guardan en campos propios de la factura registrada.

## Verificación local y pruebas pendientes

`python3 herramientas/compilar.py` compila V2 y el proyecto de pruebas con una caché aislada de Microsoft, sin símbolos de la localización anterior. `python3 herramientas/verificar_artefactos.py` comprueba que no hay dependencias en el manifiesto ni en el paquete, que los campos requeridos están declarados por V2 y que los datasets coinciden con las expresiones RDLC.

El archivo `pruebas/PruebasNucleo.template` contiene 63 pruebas AL. Para ejecutarlas, instalar `artefactos/INVTECH_LocalizacionHN_V2_Pruebas_1.2.2.0.app` en sandbox y ejecutar la codeunit **71250 HN Core Tests** con el ejecutor de pruebas de Business Central.

Escenarios de aceptación que requieren Business Central:

- Instalación y operación sin la otra localización instalada.
- Validar las diferencias entre operar sin la otra extensión y convivir con sus funciones restantes tras desactivar su motor de retenciones.
- Pedido parcialmente facturado, factura directa, varias retenciones, mínimos y redondeo.
- Descuentos de línea/factura, precios con ISV incluido y base sobre impuesto.
- Facturas pagadas o parcialmente pagadas, proveedor de pago distinto y moneda extranjera.
- Dimensiones obligatorias y conciliación de movimientos contables/proveedor.
- Fallo contable después de asignar CAI: sin contabilización parcial, sin estado registrado y sin consumo persistido del número.
- Vistas previas repetidas, dos sesiones con el mismo CAI, vencimiento y último número.
- Nota de débito basada en factura estándar con datos fiscales capturados explícitamente.
- Impresión y reimpresión de ambos diseños, verificando nombres, RTN, origen, CAI, rango, fechas y totales.

## Alcance pendiente

Están preparados los campos y la copia histórica de metadatos POS; faltan resolver convivencia, adaptar receptor/cierre y migrar catálogos/configuraciones. Las reversiones automáticas vinculadas a devoluciones/abonos, notas de débito de proveedores y exportaciones de declaraciones no están implementadas en esta entrega. Se desarrollarán sin convertir la otra aplicación en una dependencia de V2.

## Anulación y sustitución de retenciones

- Desde el histórico abrir el comprobante, elegir **Anular**, informar motivo y fecha contable. La operación desliquida los movimientos propios mediante BC y registra su compensación, conservando correlativo, CAI y líneas. Cualquier rechazo de BC revierte toda la operación.
- Si se marcó **declarada o enterada al SAR**, informar la referencia del tratamiento fiscal externo. No se ejecuta una rectificación del SAR desde esta acción.
- Imprimir de nuevo: debe figurar **ANULADA**. Crear sustituto abre otro borrador con las mismas facturas y vínculo al documento anterior; requiere revisión y otro número al registrar.
- No se borran históricos ni se reutiliza el correlativo anulado. Documentos V2 anteriores sin vínculo al movimiento de proveedor requieren conciliación; no se deduce ese vínculo por importes parecidos.
- Probar anulación en moneda local/extranjera, varias facturas/conceptos, documentos pagados y períodos cerrados; comprobar saldo, diferencias de cambio, dimensiones, cierre de movimientos compensados e impresión multipágina.

## Facturación, proveedores e informes de la versión 1.2.2.0

Seguir MANUAL_USUARIO.md para habilitar la configuración de facturación y los CAI por tipo. Probar emisión desde pedido y factura directa, facturación parcial, envío sin factura, abono de venta con origen y comprobantes recibidos de proveedores. Verificar último día, último número, tipo/prefijo incorrectos y dos autorizaciones del mismo proveedor.

Ejecutar las 63 pruebas AL en una empresa desechable y revisar los 20 RDLC en el motor de Business Central, incluidos documentos multipágina y movimientos/aplicaciones en moneda extranjera. La validación local de XML no acredita renderizado real.


## Emisión sin reserva y boleta de compra 1.2

- Habilitar ventas, dejar la antigua marca por documento desactivada y registrar desde pedido/factura: debe emitir automáticamente.
- Crear varios documentos; validar, guardar, eliminar un borrador y previsualizar. CAI/último/próximo deben conservarse; la vista previa no asigna número.
- Cambiar la autorización predeterminada entre creación y registro; debe utilizar la configuración vigente al registrar.
- Registrar en orden distinto al de creación y desde dos sesiones simultáneas; comprobar consecutivos únicos. Simular un error contable posterior a asignar y comprobar rollback del fiscal y movimiento.
- Configurar boletas tipo 11; proveedor natural hondureño, identidad, dirección, teléfono; emisor con contactos y moneda local HNL.
- Crear boleta directa y pedido convertido a boleta. Recibir sin facturar, facturar parcialmente, previsualizar y registrar. Cada factura parcial tiene su propio fiscal; el pedido no conserva una reserva.
- Exigir CAI de proveedores simultáneamente: la boleta usa la autorización propia y no debe pedir número ni CAI del proveedor.
- Rechazar proveedor no elegible, datos incompletos, CAI vencido/agotado/tipo incorrecto, ISV mayor a cero, inversión de sujeto pasivo, moneda extranjera, cantidades no positivas y valores negativos.
- Conciliar referencia fiscal en el histórico y movimientos de proveedor/contabilidad. En Movimiento fiscal, Recibido de proveedor=false para boletas emitidas.
- Imprimir borrador de pedido y boleta directa con SIN EMITIR, comprobante fiscal con número real, importe en letras, contactos, exoneraciones, firma/huella y destino de ejemplares; reimpresión sin avanzar correlativos.
- Conciliar por separado límites fiscales anuales de boletas y gastos externos. Probar que no se registra un abono/devolución que herede el indicador de boleta, sin un tratamiento fiscal específico.

Estado: 63 pruebas AL compilables; su ejecución y las comprobaciones de integración anteriores requieren sandbox. No se publicaron cambios ni se ejecutó migración.


Para la migración 1.2.1 seguir EJECUCION_MIGRACION.md. Ejecutar las pruebas AL de clasificación/copia con tipos reales y comprobar manualmente bloqueo global por conflicto, reversión completa ante excepción, validación posterior, incidencias fiscales y CSV. Las pruebas del mapa de datos no acreditan convivencia con API_BCPOS.


Para 1.2.2 seguir COPIA_REFERENCIAS_HN.md. Validar fuentes y destinos de las 21 tablas seleccionadas (20 con correspondencias; la línea histórica de abono de venta solo tiene campos calculados), opciones, GUID, Blob, claves compuestas, filas faltantes, destinos distintos, repetición y reversión de fallo. Confirmar que la copia de catálogos es de referencia y no habilita autorizaciones ni documentos activos.


## Retención sin conceptos previos — 1.2.3.0

Registrar una factura de compra sin códigos. Generar borrador de retención y elegir conceptos por línea desde Seleccionar retenciones. Confirmar bases/IVA de la factura, redondeo y que la factura y sus códigos quedan intactos. Limpiar/reseleccionar conceptos y recalcular; no deben restaurarse automáticamente las elecciones borradas. En un grupo, una factura sin importe debe impedir el registro. Probar duplicados de V2, falta de saldo, edición concurrente frente a registro, cancelación/sustituto y borrado de borrador. Verificar que los conceptos de documentos registrados son inmutables y que no se consumió CAI antes de registrar. Las 66 pruebas AL están preparadas; su ejecución operativa sigue pendiente.


## RTN seleccionable de proveedor — 1.2.4.0

Probar proveedor con solo RTN estándar, solo referencia migrada, solo RTN anterior instalado y solo RTN V2. Valores iguales deben agruparse; distintos deben dejar el nuevo borrador sin propuesta hasta elegir. En un borrador existente vacío abrir el selector, aceptar y cerrar: el valor debe conservarse. Verificar que cancelar no cambia el valor previo, que la elección no modifica al proveedor y que el RTN largo se imprime completo. Los comprobantes anteriores siguen usando su RTN almacenado y los emitidos no admiten cambios. Probar ausencia de la app anterior usando V2/migrado/estándar. Total de pruebas preparadas: 71; ejecución en BC pendiente.

### Diagnóstico de acceso al selector de RTN

Incidencia comunicada el 27/10/2026: el cliente rechaza Ejecutar en la codeunit 71116 «HN Gestion RTN Proveedor» con el mensaje «Su licencia no le concede…». El conjunto `HN LOCALIZATION` del código 1.2.4.0 ya incluye el permiso de ejecución para esa codeunit. Esto no demuestra que el conjunto esté actualizado o asignado en el entorno ni que la licencia conceda acceso. La causa concreta sigue pendiente de comprobar en el servidor.

1. Confirmar la versión de LocalizacionHN_V2 instalada en el sandbox afectado.
2. Abrir **Usuarios**, seleccionar el usuario afectado y consultar **Permisos en vigor**. Filtrar por tipo **Codeunit**, número **71116** y revisar Ejecutar tanto en los permisos de licencia como en los de seguridad.
3. Si falta seguridad, comprobar la publicación del conjunto actualizado y la asignación de **HN LOCALIZATION** para la empresa correspondiente. Si falta licencia, el administrador debe revisar los derechos efectivos del usuario; añadir permisos AL o asignar SUPER no amplía los derechos de licencia.
4. Tras corregir el acceso, cerrar sesión y volver a entrar. Actualizar el borrador afectado para descartar la edición fallida, abrir el selector, elegir RTN, salir y volver a abrir el documento para verificar la persistencia. Revisar también que siguen presentes las facturas y los importes del borrador. No borrar el comprobante para repetir la prueba.

No se ha confirmado que el RTN de la edición fallida se guardara. Esta incidencia no exige renumerar objetos, desinstalar extensiones ni ejecutar la migración de datos.

Referencia de Microsoft: [Licencias y permisos efectivos](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/deployment/licensing). Los derechos de licencia limitan los permisos asignados, también en sandbox.


## Consulta de RTN anterior — 1.2.4.1

El error de licencia inicial dejó de reproducirse y el usuario comunicó errores de selección sin candidatos. No se ha confirmado todavía si el proveedor P00235 tiene RTN guardado en el campo anterior. La coincidencia del texto tecleado con un dato existente sigue siendo obligatoria.

La nueva lectura consulta el registro guardado y comprueba todos los paquetes instalados que puedan ser propietarios del campo, conservando App ID, nombre y esquema esperado. Si no hay candidatos, el mensaje debe explicar si falta el campo, no se pudo verificar su propietario o está vacío. No implica que estas condiciones se hayan observado en el servidor.

Probar proveedor con RTN únicamente anterior y con RTN V2 diferente: ambos deben aparecer en el selector y conservar su origen. Seleccionar cada uno, guardar, cerrar y volver a abrir. Probar RTN vacío: el mensaje debe identificar al proveedor y «RTN proveedor HN (V2)». No escribir el RTN en el borrador si aún no está guardado en ninguna de sus fuentes. La prueba RTNConsultaCampoAnteriorGuardado cubre la lectura con carga parcial cuando está instalada la localización anterior; sin ella comprueba la disponibilidad del RTN propio. Total: 73 pruebas preparadas; ejecución en BC pendiente.


## Finalización de registro y vista previa — 1.2.4.2

El usuario comunicó «No se puede modificar un comprobante registrado» en modo de vista previa. El registro asignaba Posted antes de Modify(true) y el disparador comprobaba xRec, que puede reflejar la asignación nueva en llamadas desde AL. El disparador consulta ahora la cabecera guardada bajo bloqueo: permite modificar si aún es Draft y rechaza si ya está emitida o anulada.

Pruebas preparadas: transición Draft a Posted, rechazo de edición en Posted y rechazo de un búfer que aún indica Draft cuando la cabecera guardada ya está Posted. Total: 76 pruebas AL; pendientes de ejecución en BC. Estas pruebas no sustituyen el ensayo contable completo.

En sandbox: guardar borrador válido con factura pendiente, RTN, conceptos y CAI; ejecutar vista previa repetida y revisar movimientos propuestos. Tras cerrarla, comprobar que cabecera, movimientos reales y próximo número CAI permanecen como antes de previsualizar. Registrar realmente una vez, verificar aparición en Retenciones registradas HN, número fiscal, movimientos/aplicación y comprobante. Reintentar registrar o editar el emitido debe rechazarse. Un fallo contable debe revertir también la asignación fiscal. No se ha ejecutado ninguna de estas operaciones en el servidor desde esta sesión.


## Compatibilidad del comprobante RDLC — 1.2.4.3

El 28/10/2026 a las 02:46 UTC el informe 50100 de V2 1.2.4.2 fue rechazado antes de imprimir desde Print - OnAction. Los detalles proporcionados no incluyen excepción interna del motor de informes. Los RDLC locales eran 2008/01; su XML de origen valida contra el XSD oficial 2008. En los símbolos de Microsoft Base Application 28.5 disponibles, 378 diseños usan 2016/01 y uno 2010/01 (otro recurso no pudo interpretarse como XML). Esta comparación orienta la actualización, pero no demuestra por sí sola la causa del fallo en el servidor.

Se actualizan los 20 diseños a 2016/01 introduciendo ReportSections/ReportSection y conservando Body, Width y Page. Se verificó equivalencia de contenido al retirar el envoltorio y volver al espacio de nombres original, validación del contenido de origen con el XSD 2008 y conversión de ida/vuelta de los generadores. No se obtuvo un XSD completo 2016 ni se ejecutó el renderizador de BC localmente.

Después de publicar la actualización, imprimir la retención ya registrada sin volver a registrarla. Revisar en Diseños de informe el informe 50100 y el diseño de la extensión, distinguiéndolo de cualquier personalización seleccionada. Verificar número fiscal, RTN completo, CAI/rango/límite, facturas, importes y varias páginas; comprobar reimpresión de anulados. Si continúa el rechazo, usar la telemetría del entorno para obtener la excepción interna y comprobar compilador/versión de plataforma y diseño efectivo, sin alterar documentos ni renumerar informes. El renderizado y el resultado operativo siguen pendientes.

Especificación: https://learn.microsoft.com/en-us/openspecs/sql_server_protocols/ms-rdl/6bbaafec-020b-406c-b4e7-5e4318b616cb


## Sustitución de formatos — 1.2.5.0

Ver FORMATOS_V2.md. Compilar y verificar la identidad exacta de los 20 RDLC empaquetados. Ejecutar las 78 pruebas preparadas en BC. Renderizar en sandbox sin logo/con PNG y JPEG, en HNL/USD, con descuentos de línea/factura, precios con ISV, tasas mixtas, varias facturas y suficientes líneas para varias páginas. Comparar totales impresos con cabecera y movimientos. Probar filtro de varios documentos: cada uno debe conservar su RTN, fiscal, CAI, moneda y total propios. Verificar encabezados repetidos, salto entre documentos, y etiquetas de borrador/anulación. Confirmar que imprimir no consume CAI ni modifica estados.

Los formatos de movimientos conservan su finalidad y no pasan a ser recibos de pago ni estados de cuenta. La muestra PDF es ilustrativa y no acredita impresión en BC. La aceptación operativa sigue pendiente.


## Celdas combinadas RDLC — 1.2.5.1

El renderizador rechazó ComprobanteHN con «CellContents ... must be omitted because it is covered by a span». El generador emitía solo las celdas de inicio de las combinaciones, omitiendo las celdas físicas cubiertas. Ahora emite una TablixCell por columna; únicamente la primera de cada combinación contiene CellContents y ColSpan. La comprobación anterior de suma de amplitudes era insuficiente y se sustituye por validación posicional. Seis pruebas Python cubren la regresión y los 20 diseños; no sustituyen al renderizado en BC.

Después de actualizar, reimprimir RET0000000002 desde el histórico sin volver a registrarla. Probar también factura, nota de débito, boleta, borradores y movimientos: todos comparten el generador corregido. Confirmar impresión con logo, varias páginas y varios documentos. La aceptación en el renderizador sigue pendiente.


## Cabecera y pie — 1.2.5.2

El usuario confirmó que se descarga PDF y facilitó la impresión real de RET0000000002. Se observó ausencia del marco de empresa, tipografía poco diferenciada y #Error en el pie de impresión. Se ajusta la cabecera según Factura_venta.pdf: marco, logo configurable, nombre/RTN/dirección separados, título enmarcado y recuadros fiscal/tercero con etiquetas destacadas. Se prepara fecha de impresión como texto AL y se elimina la expresión de conversión del pie.

Reimprimir la misma retención y comparar cabecera con referencia. Probar sin logo y con logo PNG/JPEG, contacto vacío, nombres/direcciones largos y varias páginas. La presentación nueva aún no se ha renderizado en BC. No se concluye que el problema del visor esté resuelto por este ajuste.


## Tipo de documento de retención — 1.2.5.6

La retención usa Pago en Gen. Journal Line y su compensación negativa Reembolso. El motor estándar debe propagar el tipo a movimientos de proveedor y contabilidad. Se mantiene la identificación fiscal en Número documento externo y la descripción de retención. No se actualizan movimientos ya contabilizados cuyo tipo estaba vacío.

Preparadas dos pruebas de inicialización para comprobar tipo, signo, cuenta de proveedor, contrapartida y número fiscal; 80 pruebas AL en total, compiladas pero pendientes de ejecutar en BC. En sandbox registrar una nueva retención, comprobar Pago en movimientos, aplicación a factura, saldo y cuenta fiscal. Anularla, comprobar Reembolso, desliquidación y compensación. Probar también anulación de una retención anterior con tipo vacío y moneda extranjera. La validación contable completa sigue pendiente.


## Alcance de impresión vigente — 1.2.6.0

Comprobar que búsqueda y centro solo ofrecen retención, borrador de retención y nota de débito; que las acciones V2 de factura, abono, compras, boletas y movimientos no aparecen; y que una ejecución directa de esos 17 informes devuelve el mensaje de formato pospuesto. Los objetos permanecen para futura reactivación. No se modifican las selecciones anteriores. Revisar en cada empresa que las selecciones operativas no estuvieran apuntando ya a un V2 ahora pospuesto; si lo estaban, elegir el informe anterior correcto.

Imprimir una factura, abono y compra con el formato anterior y comparar con su salida previa. Imprimir nota de débito con origen/motivo, descuentos, impuestos, varias líneas/páginas y moneda; comparar con importes registrados. Comprobar encabezados y firmas según retención. 82 pruebas AL preparadas/compiladas, no ejecutadas; seis pruebas Python de estructura aprobadas. Las pruebas de impresión real siguen pendientes.


## Primera instalación de producción — 1.3.0.0

Variante construida en carpeta temporal desde la base 1.2.6.0, conservando el proyecto del sandbox. Antes de publicar, instalar en una copia de sandbox con las mismas apps que producción. Revisar auditoría de las 14 colisiones resueltas, permisos y que reportes activos de retención/nota de débito conservan su funcionamiento. Probar API/POS, registro de retención, anulación, impresión y captura/registro de nota de débito. El paquete de pruebas 1.3.0.0 contiene las mismas 82 pruebas AL compiladas; aún no se han ejecutado. No usar la variante como actualización del sandbox que tiene esquema 501xx ni ejecutar ForceSync/Recreate. La copia de referencias es un paso independiente que no se ejecuta al instalar.
