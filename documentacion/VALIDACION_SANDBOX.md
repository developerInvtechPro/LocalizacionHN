# Validación de la extensión independiente

## Identidad y publicación

- Aplicación: `LocalizacionHN_V2`, publisher `INVTECH`, versión `1.1.0.0`.
- ID propio: `0afcac2a-37c1-4666-b0a6-72d4e5320046`.
- BC28/runtime17; sin dependencias de extensiones de terceros.
- Paquete local de preparación: `artefactos/INVTECH_LocalizacionHN_V2_1.1.0.0.app`. **No publicar junto a API_BCPOS 1.0.0.41** hasta resolver los conflictos de IDs documentados en [MIGRACION_POS.md](MIGRACION_POS.md). Las pruebas iniciales requieren un sandbox aislado compatible y sincronización normal.
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

El archivo `pruebas/PruebasNucleo.template` contiene 31 pruebas AL. Para ejecutarlas, instalar `artefactos/INVTECH_LocalizacionHN_V2_Pruebas_1.1.0.0.app` en sandbox y ejecutar la codeunit **71250 HN Core Tests** con el ejecutor de pruebas de Business Central.

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

## Facturación, proveedores e informes de la versión 1.1.0.0

Seguir MANUAL_USUARIO.md para habilitar la configuración de facturación y los CAI por tipo. Probar emisión desde pedido y factura directa, facturación parcial, envío sin factura, abono de venta con origen y comprobantes recibidos de proveedores. Verificar último día, último número, tipo/prefijo incorrectos y dos autorizaciones del mismo proveedor.

Ejecutar las 31 pruebas AL en una empresa desechable y revisar los 18 RDLC en el motor de Business Central, incluidos documentos multipágina y movimientos/aplicaciones en moneda extranjera. La validación local de XML no acredita renderizado real.
