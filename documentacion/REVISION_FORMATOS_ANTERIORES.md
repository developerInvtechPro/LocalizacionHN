# Referencia de formatos de la localización anterior

Revisión: 27 de octubre de 2026. Fuente facilitada por el usuario: `/Users/solmerlopez/Desktop/FORMATOS ACTUALIZADOS.rar`. Se interpreta como material de referencia, no como instrucciones para instalar paquetes ni ejecutar migraciones.

## Contenido revisado

El archivo contiene 26 archivos: 11 diseños editables RDL/RDLC, 11 PDF de muestra y cuatro paquetes `.app`. Los 11 diseños declaran el esquema de informes 2016/01. Se leyeron sus campos y los textos de todos los PDF; se inspeccionaron visualmente factura, nota de crédito y recibo de proveedor. Los paquetes se inspeccionaron como archivos, sin instalarlos.

| Documento | Diseño facilitado | Referencia para V2 |
|---|---|---|
| Factura de venta | FACTURA VENTA_2026.rdl | Cabecera con logo y RTN, número fiscal destacado, fechas, CAI/rango/límite; cliente y exoneración; detalle y resumen de impuestos. |
| Nota de crédito | NotadeCredito.rdlc | Misma identidad visual; detalle con descuentos, separación de bases e ISV 15/18, letras y firmas. |
| Cotización | Cotizacion_2026.rdlc | Cabecera, cliente, vigencia, entrega, cantidades/precios e importe en letras. |
| Orden de compra | OrdenDeCompra2026.rdlc | Identificación del proveedor, entrega, condiciones de pago, líneas y autorizaciones. |
| Comprobante de entrega | Comprobante de entrega.rdl | Referencia a pedido/factura, almacén y cantidades; firmas de facturado, recibido y entregado. |
| Pago de cliente | Pago_cliente.rdlc | Banco, referencia, método, usuario/fecha de registro y facturas con importe, saldo, abono y restante. |
| Pago a proveedor | Pago_vendedores.rdlc | Estructura equivalente, con terminología y moneda corregidas para proveedor. |
| Estado de cuenta | Estado_cuenta.rdl | Rango de fechas, historial de cargos/pagos, datos de vehículo cuando existan, resumen y conformidad. |
| Ticket | Formato_ticket.rdlc | Formato estrecho con datos fiscales, exoneración, vehículo/turno/terminal y formas de pago. |
| Ajuste positivo | Ajuste_positivo.rdlc | Movimientos de inventario, cantidades, costos y firmas. |
| Ajuste negativo | ajuste_negativo.rdlc | Misma estructura para salidas por ajuste. |

No se incluyen diseños ni muestras específicos de comprobante de retención, nota de débito o boleta de compra. Para ellos se puede conservar la identidad visual común, pero hace falta diseñar sus secciones propias.

## Diferencias respecto de V2

Los formatos fiscales de V2 tienen columnas propias para identidad, CAI, origen y totales, pero no reproducen todavía todo el contenido de estas muestras. Por ejemplo, los datasets de factura y nota de crédito de `DocumentosYMovimientos.al` contienen impuesto y subtotal globales; necesitan ampliar la separación de exento, exonerado, gravado e ISV por tasa antes de reproducir el resumen anterior. También deben incorporarse logo, unidad de medida, importe en letras y demás datos del documento según corresponda.

Los informes de movimientos/aplicaciones que existen en V2 no equivalen por sí solos a un recibo de pago ni a un estado de cuenta con saldo acumulado. Cotización, entrega, ticket y ajustes requieren contrastar su cobertura específica y sus puntos de impresión; la presencia de un borrador de venta/compra no acredita que se haya adaptado cada uno de estos documentos.

Los diseños anteriores usan nombres y estructuras de dataset diferentes. La factura declara 483 campos y la nota de crédito 361, incluyendo etiquetas y campos auxiliares. No se deben sustituir directamente los archivos V2 por estos diseños: primero hay que mapear las expresiones y agrupaciones a datos estándar o propios de V2. No se añadirá una dependencia a la localización antigua para conservar los formatos.

## Correcciones que no se deben heredar

- El PDF de pago a proveedor rotula al tercero como «CLIENTE», utiliza «Total recibido» y «Firma cliente»; debe usar terminología de proveedor y pago efectuado.
- Los dos recibos muestran «Moneda: DOLARES AMERICANOS», pero importes con `L.` y letras en lempiras. Se debe distinguir moneda del documento de moneda local y hacer coincidir importes, símbolos y letras.
- La cotización muestra duplicado el bloque de cliente. La factura muestra «Página 1.00». Normalizar bloques y paginación.
- La nota de crédito usa «070/100» y la orden de compra «046/100» para centavos, además de formatos numéricos mezclados. Mostrar dos posiciones y un formato coherente con la moneda.
- La orden de compra de muestra presenta códigos y descripciones cuya correspondencia debe verificarse contra las líneas reales. No deducir datos de artículos por su posición en el diseño.
- Verificar que el saldo del estado de cuenta sea acumulado y que las aplicaciones/desliquidaciones no dupliquen importes. La muestra no prueba la corrección de su cálculo.
- Razón social, logo, teléfono, correo, dirección y RTN deben proceder de configuración/datos guardados; no fijar los valores de la empresa de muestra en V2.

## Orden de adaptación propuesto

1. Unificar cabecera, tipografía, bloques fiscales, totales y firmas en factura, nota de crédito, nota de débito, retención y boleta. Mantener el número fiscal asignado al registrar y los datos históricos guardados.
2. Adaptar compra, cotización y entrega con sus datos y acciones de impresión específicos.
3. Preparar recibos de cliente/proveedor y estado de cuenta con aplicaciones reales, moneda y saldos conciliados.
4. Adaptar ticket y ajustes, conservando referencias POS/vehículos cuando existan y sin activar lógica antigua por leer sus campos históricos.

La revisión inicial dio paso a la sustitución de los 20 diseños existentes en V2 en la versión 1.2.5.0, mediante datasets propios. No se han instalado los paquetes adjuntos ni se ha modificado la contabilidad o la configuración de CAI. Los formatos específicos adicionales de ticket, entrega, estado de cuenta, recibos de pago y ajustes no se incorporan como informes nuevos en esta sustitución; continúan como referencias para su desarrollo posterior. Ver FORMATOS_V2.md para el alcance actualizado.

## Paquetes adjuntos identificados

| Aplicación | Versión | Informes encontrados |
|---|---|---|
| ALTest2 | 1.0.0.97 | 70160 INV Cash Receipt Reprint |
| INV Inventory Adjustment Reports | 1.0.0.7 | 70480 ajuste positivo, 70481 ajuste negativo |
| INV Reprint Customer Payment | 1.0.0.62 | 70521 recibo cliente, 70527 recibo proveedor |
| INV Sales Invoice Ticket | 1.0.0.14 | 70400 ticket borrador, 70401 ticket registrado, 70405/70406 ajustes |

Dos paquetes incluyen informes de ajuste con identidades distintas. Antes de retirar alguno en una migración habrá que identificar cuál está instalado y qué acciones o selecciones lo llaman. Este inventario no constituye autorización para desinstalarlo.
