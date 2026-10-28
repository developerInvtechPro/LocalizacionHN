# Comparación de compras y ventas: origen 1.0.1.69 frente a V2

Revisión del paquete y sus fuentes AL. No se ejecuta migración ni se modifica la extensión anterior.

- Origen: `IT Invtech_Localizacion_HN_1.0.1.69.app`; 160 fuentes AL. SHA-256: `b9641c3bc11ece8423cf81df2c6f79a9981f9a21eb637a89db303afaf8e45268`.
- Destino preparado: V2 1.2.2.0.
- **Resultado: el mapa ampliado conserva 236 referencias; no activa las funciones anteriores.**

| Tabla | Nombre | Campos antiguos | Mapeados | Pendientes normales | Calculados |
| --- | --- | --- | --- | --- | --- |
| 18 | Customer | 32 | 2 | 30 | 0 |
| 23 | Vendor | 5 | 5 | 0 | 0 |
| 36 | Sales Header | 57 | 47 | 0 | 10 |
| 37 | Sales Line | 17 | 13 | 0 | 4 |
| 38 | Purchase Header | 59 | 46 | 0 | 13 |
| 39 | Purchase Line | 5 | 5 | 0 | 0 |
| 79 | Company Information | 2 | 2 | 0 | 0 |
| 112 | Sales Invoice Header | 41 | 34 | 0 | 7 |
| 113 | Sales Invoice Line | 9 | 8 | 0 | 1 |
| 114 | Sales Cr.Memo Header | 11 | 8 | 0 | 3 |
| 115 | Sales Cr.Memo Line | 3 | 0 | 0 | 3 |
| 122 | Purch. Inv. Header | 8 | 8 | 0 | 0 |
| 123 | Purch. Inv. Line | 2 | 2 | 0 | 0 |
| 124 | Purch. Cr. Memo Hdr. | 0 | 0 | 0 | 0 |
| 125 | Purch. Cr. Memo Line | 0 | 0 | 0 | 0 |

## Catálogos e históricos fuera de la rutina actual

| Tabla | Nombre | Campos | Estado |
| --- | --- | --- | --- |
| 60450 | Gestión CAI | 8 | REFERENCIA_PREPARADA (8 campos en el mapa) |
| 60451 | Grupo Impuestos Honduras | 4 | REFERENCIA_PREPARADA (4 campos en el mapa) |
| 60452 | Exoneración | 7 | REFERENCIA_PREPARADA (7 campos en el mapa) |
| 60454 | Comprobante Retención | 12 | FUERA_DEL_MAPA_EJECUTABLE (0 campos en el mapa) |
| 60455 | Línea Comprobante Retención | 6 | FUERA_DEL_MAPA_EJECUTABLE (0 campos en el mapa) |
| 60456 | Resumen Ventas Diarias | 15 | FUERA_DEL_MAPA_EJECUTABLE (0 campos en el mapa) |
| 60457 | Configuración Impuestos HN | 7 | REFERENCIA_PREPARADA (7 campos en el mapa) |
| 60459 | salesPaymentMethods | 5 | REFERENCIA_PREPARADA (5 campos en el mapa) |
| 60460 | Historico Comp. Retencion | 18 | FUERA_DEL_MAPA_EJECUTABLE (0 campos en el mapa) |
| 60461 | Historico Linea Comp. Ret. | 6 | FUERA_DEL_MAPA_EJECUTABLE (0 campos en el mapa) |
| 60477 | Boleta de Compra | 6 | REFERENCIA_PREPARADA (6 campos en el mapa) |
| 60489 | CAI Facturación | 11 | REFERENCIA_PREPARADA (11 campos en el mapa) |
| 60491 | Libro de Ventas Temp | 14 | FUERA_DEL_MAPA_EJECUTABLE (0 campos en el mapa) |
| 60503 | TotalSalesInvoice | 8 | FUERA_DEL_MAPA_EJECUTABLE (0 campos en el mapa) |
| 60510 | Sales Payment Detail | 8 | REFERENCIA_PREPARADA (8 campos en el mapa) |
| 60580 | Tax Declaration | 18 | FUERA_DEL_MAPA_EJECUTABLE (0 campos en el mapa) |
| 60587 | Sales Post Print Options | 8 | FUERA_DEL_MAPA_EJECUTABLE (0 campos en el mapa) |

## Diferencias de tipos conservadas como referencia

- Purchase Header: `Código CAI` (Code[37]) frente a `HN Codigo CAI Proveedor` (Code[20]). Referencia conservada en HN Ref 60460 con tipo y longitud originales; no se convierte en una clave de configuración activa.
- Purch. Inv. Header: `Código CAI` (Code[37]) frente a `HN Codigo CAI Proveedor` (Code[20]). Referencia conservada en HN Ref 60460 con tipo y longitud originales; no se convierte en una clave de configuración activa.
- Vendor: `RTN` (Code[50]) frente a `VAT Registration No.` (Campo estándar: no es destino del mapa). Referencia conservada en HN Ref 60450 con tipo y longitud originales; no se convierte en una clave de configuración activa.

## Datos aún fuera del mapa: Customer (18)

| ID | Nombre | Tipo | Clasificación |
| --- | --- | --- | --- |
| 60450 | Password | Text[200] | PENDIENTE |
| 60451 | First Name | Text[30] | PENDIENTE |
| 60452 | Last Name | Text[30] | PENDIENTE |
| 60453 | Individual Person | Boolean | PENDIENTE |
| 60454 | Resident | Option | PENDIENTE |
| 60457 | Date of Birth | Date | PENDIENTE |
| 60458 | Place of Birth | Text[30] | PENDIENTE |
| 60461 | IsPlanActive | Integer | PENDIENTE |
| 60462 | Contact1 | Text[60] | PENDIENTE |
| 60463 | Contact2 | Text[60] | PENDIENTE |
| 60464 | Contact3 | Text[60] | PENDIENTE |
| 60465 | Contact4 | Text[60] | PENDIENTE |
| 60466 | Contact5 | Text[60] | PENDIENTE |
| 60467 | Contact6 | Text[60] | PENDIENTE |
| 60468 | Contact7 | Text[60] | PENDIENTE |
| 60469 | Contact8 | Text[60] | PENDIENTE |
| 60470 | Contact9 | Text[60] | PENDIENTE |
| 60471 | CellPhone1 | Text[30] | PENDIENTE |
| 60472 | CellPhone2 | Text[30] | PENDIENTE |
| 60473 | CellPhone3 | Text[30] | PENDIENTE |
| 60474 | CellPhone4 | Text[30] | PENDIENTE |
| 60475 | CellPhone5 | Text[30] | PENDIENTE |
| 60476 | CellPhone6 | Text[30] | PENDIENTE |
| 60477 | CellPhone7 | Text[30] | PENDIENTE |
| 60478 | CellPhone8 | Text[30] | PENDIENTE |
| 60479 | CellPhone9 | Text[30] | PENDIENTE |
| 60480 | CellPhone10 | Text[30] | PENDIENTE |
| 60481 | Contact10 | Text[60] | PENDIENTE |
| 60482 | Usual Billing Type | Integer | PENDIENTE |
| 60551 | Cargo | Text[50] | PENDIENTE |

## Evidencia de lógica anterior revisada

- `src/CodeUnit/Cod60454.PurchaseInvoiceHeader.al`
- `src/CodeUnit/Cod60455.AssignSaleCaiOnBeforePost.al`
  - `if (SalesHeader."Document Type" in [SalesHeader."Document Type"::"Credit Memo"]) then begin`
  - `if (CAIFacturacion."Fecha Límite Emisión" <= SalesHeader."Posting Date") then begin`
  - `if (IncStr(CAIFacturacion."Num Predeterminado") > CAIFacturacion."Factura Final") then begin`
  - `SalesHeader.TransactionNumber := CAIFacturacion."Num Predeterminado";`
  - `SalesHeader."External Document No." := CAIFacturacion."Num Predeterminado";`
  - `CAIFacturacion."Num Predeterminado" := IncStr(CAIFacturacion."Num Predeterminado");`
- `src/CodeUnit/Cod60456AssignPOCaiOnBeforePost.al`
  - `if Vend."Proveedor Extranjero" then`
  - `if (PurchaseHeader."No. CAI" = '') then begin`
  - `if GestionCAI.FindSet() then begin`
  - `if (GestionCAI."Fecha Límite Emisión" <= PurchaseHeader."Posting Date") then begin`
- `src/CodeUnit/Cod60570.CAIDefaultMgt.al`
- `src/PageExt/Pag-Ext60451.PurchaseInvoiceExt.al`
  - `TableRelation = "Gestión CAI"."No. CAI";`
- `src/PageExt/Pag-Ext60470.PurchaseCreditMemoExt.al`
  - `TableRelation = "CAI Facturación".Código;`
  - `Rec.TransactionNumber := CAIFacturacion."Num Predeterminado";`
  - `Rec."External Document No." := CAIFacturacion."Num Predeterminado";`
  - `CAIFacturacion."Num Predeterminado" := IncStr(CAIFacturacion."Num Predeterminado");`
- `src/PageExt/Pag-Ext60474.ExtPginaPedidoCompra.al`
  - `TableRelation = "Gestión CAI"."No. CAI";`
- `src/ReportExt/Rep-Ext60459.PurchaseInvoiceExt.al`
- `src/ReportExt/Rep-Ext60460.PurchaseCreditMemoExt.al`

El inventario identifica presencia y tipos; no demuestra que cada campo tenga datos en la empresa. Antes de copiar deben medirse uso, vacíos, conflictos, duplicados y vínculos en BC. Las tablas y campos estándar conservan su propietario de Microsoft; este inventario enumera adiciones de la localización anterior.
