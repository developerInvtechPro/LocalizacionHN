namespace INVTECH.Honduras;
codeunit 71103 "HN Migration Field Map"
{
    procedure Fill(TableID: Integer; var Map: Record "HN Migration Field" temporary)
    begin
        Map.Reset(); Map.DeleteAll();
        case TableID of
            18:
                begin
                    Add(Map, 60483, 'RTN', 71100, 'INV HN RTN', 18, false);
                    Add(Map, 60484, 'CLienteExonerado', 71101, 'INV HN Exempt Customer', 18, false);
                end;
            23:
                begin
                    Add(Map, 60450, 'RTN', 71100, 'HN Ref 60450', 23, true);
                    Add(Map, 60451, 'Código de Proveedor', 71101, 'HN Ref 60451', 23, true);
                    Add(Map, 60452, 'Proveedor Extranjero', 71102, 'HN Ref 60452', 23, true);
                    Add(Map, 60453, 'Requiere Retención', 71103, 'HN Ref 60453', 23, true);
                    Add(Map, 60454, 'Fecha Vencimiento Retención', 71104, 'HN Ref 60454', 23, true);
                end;
            36:
                begin
                    Add(Map, 60452, 'TransactionNumber', 71100, 'INV POS Transaction No.', 36, false);
                    Add(Map, 60481, 'Gas Station Code', 71101, 'INV POS Station', 36, false);
                    Add(Map, 60482, 'POS Code', 71102, 'INV POS Terminal', 36, false);
                    Add(Map, 60451, 'Batch', 71103, 'INV POS Shift', 36, false);
                    Add(Map, 60477, 'POS Sales Doc_ Type', 71104, 'INV POS Document Type', 36, false);
                    Add(Map, 60478, 'Billing Type', 71105, 'INV POS Billing Type', 36, false);
                    Add(Map, 60479, 'AmountTotal', 71106, 'INV POS Received Total', 36, false);
                    Add(Map, 60480, 'VATAmount', 71107, 'INV POS Received VAT', 36, false);
                    Add(Map, 60506, 'Usuario', 71108, 'INV POS Operator', 36, false);
                    Add(Map, 60487, 'OC', 71109, 'INV POS Purchase Order', 36, false);
                    Add(Map, 60488, 'NumeroDePlaca', 71110, 'INV POS Plate', 36, false);
                    Add(Map, 60489, 'Kilometraje', 71111, 'INV POS Mileage', 36, false);
                    Add(Map, 60490, 'Chofer', 71112, 'INV POS Driver', 36, false);
                    Add(Map, 60483, 'Comentario', 71113, 'INV POS Comment', 36, false);
                    Add(Map, 60106, 'Código CAI', 71114, 'INV POS CAI Code', 36, false);
                    Add(Map, 60100, 'No. CAI', 71115, 'INV POS CAI', 36, false);
                    Add(Map, 60120, 'Fecha Límite Emisión', 71116, 'INV POS CAI Expiration', 36, false);
                    Add(Map, 60121, 'Factura Inicial', 71117, 'INV POS CAI Start', 36, false);
                    Add(Map, 60122, 'Factura Final', 71118, 'INV POS CAI End', 36, false);
                    Add(Map, 60103, 'Código Exoneración', 71119, 'INV POS Exemption Code', 36, false);
                    Add(Map, 60101, 'Monto Exonerado', 71120, 'INV POS Exempted Amount', 36, false);
                    Add(Map, 60133, 'OrdenDeCompraEXENTA', 71121, 'INV POS Exempt Order', 36, false);
                    Add(Map, 60134, 'OrdenDeRegistroExonerados', 71122, 'INV POS Exemption Register', 36, false);
                    Add(Map, 60135, 'OrdenDeCompraSAG', 71123, 'INV POS SAG Reference', 36, false);
                    Add(Map, 60109, 'Campo Booleano', 74050, 'HN Copia 60109', 36, true);
                    Add(Map, 60132, 'OrdenDeCompras', 74053, 'HN Copia 60132', 36, true);
                    Add(Map, 60124, 'Fecha Inicio', 74051, 'HN Copia 60124', 36, true);
                    Add(Map, 60125, 'Fecha Fin', 74052, 'HN Copia 60125', 36, true);
                    Add(Map, 60102, 'Importe Retención', 74047, 'HN Copia 60102', 36, true);
                    Add(Map, 60104, 'Nuevo Código Exoneración', 74048, 'HN Copia 60104', 36, true);
                    Add(Map, 60105, 'Grupo Impuestos Honduras', 74049, 'HN Copia 60105', 36, true);
                    Add(Map, 60455, 'LabelSalesInvoice', 74054, 'HN Copia 60455', 36, true);
                    Add(Map, 60486, 'Image1', 74055, 'HN Copia 60486', 36, true);
                    Add(Map, 60507, 'Fuente', 74056, 'HN Copia 60507', 36, true);
                    Add(Map, 60508, 'Proyecto', 74057, 'HN Copia 60508', 36, true);
                    Add(Map, 60509, 'ProyectoUbicacion', 74058, 'HN Copia 60509', 36, true);
                    Add(Map, 60510, 'Total IVA 18%', 74059, 'HN Copia 60510', 36, true);
                    Add(Map, 60511, 'Total IVA 0%', 74060, 'HN Copia 60511', 36, true);
                    Add(Map, 60512, 'Total IVA Otros', 74061, 'HN Copia 60512', 36, true);
                    Add(Map, 60513, 'Resumen Impuestos', 74062, 'HN Copia 60513', 36, true);
                    Add(Map, 60514, 'Total Exento', 74063, 'HN Copia 60514', 36, true);
                    Add(Map, 60515, 'Total IVA 15%', 74064, 'HN Copia 60515', 36, true);
                    Add(Map, 60516, 'Total Exonerado', 74065, 'HN Copia 60516', 36, true);
                    Add(Map, 60517, 'Is Debit Note', 74066, 'HN Copia 60517', 36, true);
                    Add(Map, 60518, 'Debit Note Reason', 74067, 'HN Copia 60518', 36, true);
                    Add(Map, 60519, 'Debit Original Invoice No.', 74068, 'HN Copia 60519', 36, true);
                    Add(Map, 60520, 'Debit Original Invoice Date', 74069, 'HN Copia 60520', 36, true);
                end;
            37:
                begin
                    Add(Map, 60451, 'Pump_No', 71100, 'INV POS Pump', 37, false);
                    Add(Map, 60452, 'Pump_Position_No', 71101, 'INV POS Pump Position', 37, false);
                    Add(Map, 60453, 'Tank_No', 71102, 'INV POS Tank', 37, false);
                    Add(Map, 60462, 'Usuario', 71103, 'INV POS Line Operator', 37, false);
                    Add(Map, 60454, 'VAT_PROD_POSTING_GROUP', 71104, 'INV POS Received VAT Rate', 37, false);
                    Add(Map, 60455, 'VAT_AMOUNT', 71105, 'INV POS Line Received VAT', 37, false);
                    Add(Map, 60456, 'AMOUNT_INCLUDING_VAT', 71106, 'INV POS Line Received Total', 37, false);
                    Add(Map, 60101, 'Importe Impuesto', 74070, 'HN Copia 60101', 37, true);
                    Add(Map, 60450, 'VATExcentoLine', 74071, 'HN Copia 60450', 37, true);
                    Add(Map, 60458, 'PictureGuid', 74072, 'HN Copia 60458', 37, true);
                    Add(Map, 60459, 'ZY Thumbail', 71110, 'HN Ref 60459', 37, true);
                    Add(Map, 60531, 'ZY Extended Description', 74074, 'HN Copia 60531', 37, true);
                    Add(Map, 60530, 'Tiempo Entrega', 74073, 'HN Copia 60530', 37, true);
                end;
            38:
                begin
                    Add(Map, 60450, 'No. CAI', 50102, 'HN Vendor CAI', 38, false);
                    Add(Map, 60460, 'Código CAI', 74005, 'HN Copia 60460', 38, true);
                    Add(Map, 60461, 'Fecha Límite Emisión', 71143, 'HN Vence CAI Proveedor', 38, false);
                    Add(Map, 60462, 'Factura Inicial', 71141, 'HN Inicio CAI Proveedor', 38, false);
                    Add(Map, 60463, 'Factura Final', 71142, 'HN Fin CAI Proveedor', 38, false);
                    Add(Map, 60451, 'Importe Retención', 74000, 'HN Copia 60451', 38, true);
                    Add(Map, 60452, 'CAI Fecha Inicio', 74001, 'HN Copia 60452', 38, true);
                    Add(Map, 60453, 'CAI Fecha Fin', 74002, 'HN Copia 60453', 38, true);
                    Add(Map, 60454, 'Check Total', 74003, 'HN Copia 60454', 38, true);
                    Add(Map, 60459, 'Monto Exonerado', 74004, 'HN Copia 60459', 38, true);
                    Add(Map, 60464, 'OrdenDeCompras', 74006, 'HN Copia 60464', 38, true);
                    Add(Map, 60477, 'OrdenDeCompraEXENTA', 74012, 'HN Copia 60477', 38, true);
                    Add(Map, 60466, 'OrdenDeRegistroExonerados', 74007, 'HN Copia 60466', 38, true);
                    Add(Map, 60467, 'OrdenDeCompraSAG', 74008, 'HN Copia 60467', 38, true);
                    Add(Map, 60473, 'Fecha Inicio', 74009, 'HN Copia 60473', 38, true);
                    Add(Map, 60474, 'Fecha Fin', 74010, 'HN Copia 60474', 38, true);
                    Add(Map, 60476, 'Código Exoneración', 74011, 'HN Copia 60476', 38, true);
                    Add(Map, 60478, 'Grupo Impuestos Honduras', 74013, 'HN Copia 60478', 38, true);
                    Add(Map, 60491, 'Batch', 74021, 'HN Copia 60491', 38, true);
                    Add(Map, 60492, 'TransactionNumber', 74022, 'HN Copia 60492', 38, true);
                    Add(Map, 60495, 'LabelSalesInvoice', 74023, 'HN Copia 60495', 38, true);
                    Add(Map, 60563, 'Expected Receipt Date (Hdr)', 74040, 'HN Copia 60563', 38, true);
                    Add(Map, 60498, 'POS Sales Doc_ Type', 74024, 'HN Copia 60498', 38, true);
                    Add(Map, 60499, 'Billing Type', 74025, 'HN Copia 60499', 38, true);
                    Add(Map, 60500, 'AmountTotal', 74026, 'HN Copia 60500', 38, true);
                    Add(Map, 60501, 'VATAmount', 74027, 'HN Copia 60501', 38, true);
                    Add(Map, 60502, 'Gas Station Code', 74028, 'HN Copia 60502', 38, true);
                    Add(Map, 60482, 'POS Code', 74014, 'HN Copia 60482', 38, true);
                    Add(Map, 60483, 'Comentario', 74015, 'HN Copia 60483', 38, true);
                    Add(Map, 60564, 'Proveedor Extranjero', 74041, 'HN Copia 60564', 38, true);
                    Add(Map, 60486, 'Image1', 74016, 'HN Copia 60486', 38, true);
                    Add(Map, 60487, 'OC', 74017, 'HN Copia 60487', 38, true);
                    Add(Map, 60488, 'NumeroDePlaca', 74018, 'HN Copia 60488', 38, true);
                    Add(Map, 60489, 'Kilometraje', 74019, 'HN Copia 60489', 38, true);
                    Add(Map, 60490, 'Chofer', 74020, 'HN Copia 60490', 38, true);
                    Add(Map, 60506, 'Usuario', 74032, 'HN Copia 60506', 38, true);
                    Add(Map, 60503, 'Campo Booleano', 74029, 'HN Copia 60503', 38, true);
                    Add(Map, 60504, 'Nuevo Código Exoneración', 74030, 'HN Copia 60504', 38, true);
                    Add(Map, 60505, 'External Document No.', 74031, 'HN Copia 60505', 38, true);
                    Add(Map, 60507, 'Total Exento', 74033, 'HN Copia 60507', 38, true);
                    Add(Map, 60508, 'Total IVA 15%', 74034, 'HN Copia 60508', 38, true);
                    Add(Map, 60509, 'Total IVA 18%', 74035, 'HN Copia 60509', 38, true);
                    Add(Map, 60510, 'Total IVA 0%', 74036, 'HN Copia 60510', 38, true);
                    Add(Map, 60511, 'Total IVA Otros', 74037, 'HN Copia 60511', 38, true);
                    Add(Map, 60512, 'Resumen Impuestos', 74038, 'HN Copia 60512', 38, true);
                    Add(Map, 60513, 'Total Exonerado', 74039, 'HN Copia 60513', 38, true);
                end;
            39:
                begin
                    Add(Map, 60100, 'Aplicar Retención 1', 74042, 'HN Copia 60100', 39, true);
                    Add(Map, 60101, 'Aplicar Retención 2', 74043, 'HN Copia 60101', 39, true);
                    Add(Map, 60102, 'Aplicar Retención 3', 74044, 'HN Copia 60102', 39, true);
                    Add(Map, 60104, 'Retenciones Aplicadas', 74046, 'HN Copia 60104', 39, true);
                    Add(Map, 60103, 'Importe Retención', 74045, 'HN Copia 60103', 39, true);
                end;
            79:
                begin
                    Add(Map, 60482, 'CompanyPhone', 71100, 'HN Ref 60482', 79, true);
                    Add(Map, 60483, 'CompanyRTN', 71101, 'HN Ref 60483', 79, true);
                end;
            112:
                begin
                    Add(Map, 60463, 'TransactionNumber', 71100, 'INV POS Transaction No.', 112, false);
                    Add(Map, 60481, 'Gas Station Code', 71101, 'INV POS Station', 112, false);
                    Add(Map, 60482, 'POS Code', 71102, 'INV POS Terminal', 112, false);
                    Add(Map, 60462, 'Batch', 71103, 'INV POS Shift', 112, false);
                    Add(Map, 60477, 'POS Sales Doc_ Type', 71104, 'INV POS Document Type', 112, false);
                    Add(Map, 60478, 'Billing Type', 71105, 'INV POS Billing Type', 112, false);
                    Add(Map, 60479, 'AmountTotal', 71106, 'INV POS Received Total', 112, false);
                    Add(Map, 60480, 'VATAmount', 71107, 'INV POS Received VAT', 112, false);
                    Add(Map, 60506, 'Usuario', 71108, 'INV POS Operator', 112, false);
                    Add(Map, 60487, 'OC', 71109, 'INV POS Purchase Order', 112, false);
                    Add(Map, 60488, 'NumeroDePlaca', 71110, 'INV POS Plate', 112, false);
                    Add(Map, 60489, 'Kilometraje', 71111, 'INV POS Mileage', 112, false);
                    Add(Map, 60490, 'Chofer', 71112, 'INV POS Driver', 112, false);
                    Add(Map, 60483, 'Comentario', 71113, 'INV POS Comment', 112, false);
                    Add(Map, 60484, 'Código CAI', 71114, 'INV POS CAI Code', 112, false);
                    Add(Map, 60460, 'No. CAI', 71115, 'INV POS CAI', 112, false);
                    Add(Map, 60120, 'Fecha Límite Emisión', 71116, 'INV POS CAI Expiration', 112, false);
                    Add(Map, 60121, 'Factura Inicial', 71117, 'INV POS CAI Start', 112, false);
                    Add(Map, 60122, 'Factura Final', 71118, 'INV POS CAI End', 112, false);
                    Add(Map, 60461, 'CAI', 71124, 'INV POS Additional CAI', 112, false);
                    Add(Map, 60507, 'Fuente', 74056, 'HN Copia 60507', 112, true);
                    Add(Map, 60508, 'Proyecto', 74057, 'HN Copia 60508', 112, true);
                    Add(Map, 60509, 'ProyectoUbicacion', 74058, 'HN Copia 60509', 112, true);
                    Add(Map, 60510, 'Total IVA 18%', 74059, 'HN Copia 60510', 112, true);
                    Add(Map, 60511, 'Total IVA 0%', 74060, 'HN Copia 60511', 112, true);
                    Add(Map, 60512, 'Total IVA Otros', 74061, 'HN Copia 60512', 112, true);
                    Add(Map, 60513, 'Resumen Impuestos', 74062, 'HN Copia 60513', 112, true);
                    Add(Map, 60514, 'Total Exento', 74063, 'HN Copia 60514', 112, true);
                    Add(Map, 60515, 'Total IVA 15%', 74064, 'HN Copia 60515', 112, true);
                    Add(Map, 60516, 'Total Exonerado', 74065, 'HN Copia 60516', 112, true);
                    Add(Map, 60517, 'Is Debit Note', 74066, 'HN Copia 60517', 112, true);
                    Add(Map, 60518, 'Debit Note Reason', 74067, 'HN Copia 60518', 112, true);
                    Add(Map, 60519, 'Debit Original Invoice No.', 74068, 'HN Copia 60519', 112, true);
                    Add(Map, 60520, 'Debit Original Invoice Date', 74069, 'HN Copia 60520', 112, true);
                end;
            113:
                begin
                    Add(Map, 60451, 'Pump_No', 71100, 'INV POS Pump', 113, false);
                    Add(Map, 60452, 'Pump_Position_No', 71101, 'INV POS Pump Position', 113, false);
                    Add(Map, 60453, 'Tank_No', 71102, 'INV POS Tank', 113, false);
                    Add(Map, 60462, 'Usuario', 71103, 'INV POS Line Operator', 113, false);
                    Add(Map, 60454, 'VAT_PROD_POSTING_GROUP', 71104, 'INV POS Received VAT Rate', 113, false);
                    Add(Map, 60455, 'VAT_AMOUNT', 71105, 'INV POS Line Received VAT', 113, false);
                    Add(Map, 60456, 'AMOUNT_INCLUDING_VAT', 71106, 'INV POS Line Received Total', 113, false);
                    Add(Map, 60450, 'VATExcentoLine', 74071, 'HN Copia 60450', 113, true);
                end;
            114:
                begin
                    Add(Map, 60463, 'TransactionNumber', 71100, 'INV POS Transaction No.', 114, false);
                    Add(Map, 60462, 'Batch', 71103, 'INV POS Shift', 114, false);
                    Add(Map, 60484, 'Código CAI', 71114, 'INV POS CAI Code', 114, false);
                    Add(Map, 60460, 'No. CAI', 71115, 'INV POS CAI', 114, false);
                    Add(Map, 60120, 'Fecha Límite Emisión', 71116, 'INV POS CAI Expiration', 114, false);
                    Add(Map, 60121, 'Factura Inicial', 71117, 'INV POS CAI Start', 114, false);
                    Add(Map, 60122, 'Factura Final', 71118, 'INV POS CAI End', 114, false);
                    Add(Map, 60461, 'CAI', 71124, 'INV POS Additional CAI', 114, false);
                end;
            115:
                begin
                end;
            122:
                begin
                    Add(Map, 60450, 'No. CAI', 50102, 'HN Vendor CAI', 122, false);
                    Add(Map, 60460, 'Código CAI', 74005, 'HN Copia 60460', 122, true);
                    Add(Map, 60461, 'Fecha Límite Emisión', 71143, 'HN Vence CAI Proveedor', 122, false);
                    Add(Map, 60462, 'Factura Inicial', 71141, 'HN Inicio CAI Proveedor', 122, false);
                    Add(Map, 60463, 'Factura Final', 71142, 'HN Fin CAI Proveedor', 122, false);
                    Add(Map, 60491, 'Batch', 74021, 'HN Copia 60491', 122, true);
                    Add(Map, 60492, 'TransactionNumber', 74022, 'HN Copia 60492', 122, true);
                    Add(Map, 60454, 'Check Total', 74003, 'HN Copia 60454', 122, true);
                end;
            123:
                begin
                    Add(Map, 60104, 'Retenciones Aplicadas', 74046, 'HN Copia 60104', 123, true);
                    Add(Map, 60103, 'Importe Retención', 74045, 'HN Copia 60103', 123, true);
                end;
            60450:
                begin
                    Add(Map, 1, 'No. Proveedor', 1, 'Ref 1', 71113, true);
                    Add(Map, 2, 'No. CAI', 2, 'Ref 2', 71113, true);
                    Add(Map, 3, 'Fecha Límite Emisión', 3, 'Ref 3', 71113, true);
                    Add(Map, 4, 'Factura Inicial', 4, 'Ref 4', 71113, true);
                    Add(Map, 5, 'Factura Final', 5, 'Ref 5', 71113, true);
                    Add(Map, 6, 'Código Sucursal', 6, 'Ref 6', 71113, true);
                    Add(Map, 7, 'Fecha Inicio', 7, 'Ref 7', 71113, true);
                    Add(Map, 8, 'Fecha Fin', 8, 'Ref 8', 71113, true);
                end;
            60451:
                begin
                    Add(Map, 1, 'Código', 1, 'Ref 1', 71115, true);
                    Add(Map, 2, 'Descripción', 2, 'Ref 2', 71115, true);
                    Add(Map, 3, 'Tasa Impuesto', 3, 'Ref 3', 71115, true);
                    Add(Map, 4, 'Tipo Impuesto', 4, 'Ref 4', 71115, true);
                end;
            60452:
                begin
                    Add(Map, 1, 'Código', 1, 'Ref 1', 71116, true);
                    Add(Map, 2, 'Descripción', 2, 'Ref 2', 71116, true);
                    Add(Map, 3, 'Tipo Exoneración', 3, 'Ref 3', 71116, true);
                    Add(Map, 4, 'Porcentaje Exoneración', 4, 'Ref 4', 71116, true);
                    Add(Map, 5, 'Monto Máximo', 5, 'Ref 5', 71116, true);
                    Add(Map, 6, 'Fecha Inicio', 6, 'Ref 6', 71116, true);
                    Add(Map, 7, 'Fecha Fin', 7, 'Ref 7', 71116, true);
                end;
            60457:
                begin
                    Add(Map, 1, 'Clave Primaria', 1, 'Ref 1', 71120, true);
                    Add(Map, 2, 'Versión Actual DAI', 2, 'Ref 2', 71120, true);
                    Add(Map, 3, 'Ruta Exportación Informes', 3, 'Ref 3', 71120, true);
                    Add(Map, 4, 'Serie Comprobantes Retención', 4, 'Ref 4', 71120, true);
                    Add(Map, 5, 'Validar Número de Factura', 5, 'Ref 5', 71120, true);
                    Add(Map, 6, 'Template Diario Recepción', 6, 'Ref 6', 71120, true);
                    Add(Map, 7, 'Batch Diario Recepción', 7, 'Ref 7', 71120, true);
                end;
            60459:
                begin
                    Add(Map, 60450, 'salesPaymentMethodId', 60450, 'Ref 60450', 71117, true);
                    Add(Map, 60451, 'PaymentMethodsCode', 60451, 'Ref 60451', 71117, true);
                    Add(Map, 60452, 'SalesHeaderNo', 60452, 'Ref 60452', 71117, true);
                    Add(Map, 60453, 'TransactionNumber', 60453, 'Ref 60453', 71117, true);
                    Add(Map, 28, 'Amount', 28, 'Ref 28', 71117, true);
                end;
            60477:
                begin
                    Add(Map, 1, 'No.', 1, 'Ref 1', 71119, true);
                    Add(Map, 2, 'Fecha', 2, 'Ref 2', 71119, true);
                    Add(Map, 3, 'Nombre Vendedor', 3, 'Ref 3', 71119, true);
                    Add(Map, 4, 'Identidad Vendedor', 4, 'Ref 4', 71119, true);
                    Add(Map, 5, 'Descripción Compra', 5, 'Ref 5', 71119, true);
                    Add(Map, 6, 'Monto Total', 6, 'Ref 6', 71119, true);
                end;
            60489:
                begin
                    Add(Map, 1, 'Código', 1, 'Ref 1', 71114, true);
                    Add(Map, 2, 'No. CAI', 2, 'Ref 2', 71114, true);
                    Add(Map, 3, 'Fecha Límite Emisión', 3, 'Ref 3', 71114, true);
                    Add(Map, 4, 'Factura Inicial', 4, 'Ref 4', 71114, true);
                    Add(Map, 5, 'Factura Final', 5, 'Ref 5', 71114, true);
                    Add(Map, 9, 'Num Predeterminado', 9, 'Ref 9', 71114, true);
                    Add(Map, 6, 'Habilitado', 6, 'Ref 6', 71114, true);
                    Add(Map, 7, 'Fecha Inicio', 7, 'Ref 7', 71114, true);
                    Add(Map, 8, 'Fecha Fin', 8, 'Ref 8', 71114, true);
                    Add(Map, 10, 'Tipo CAI', 10, 'Ref 10', 71114, true);
                    Add(Map, 20, 'Predeterminado', 20, 'Ref 20', 71114, true);
                end;
            60510:
                begin
                    Add(Map, 1, 'Document Type', 1, 'Ref 1', 71118, true);
                    Add(Map, 2, 'Document No.', 2, 'Ref 2', 71118, true);
                    Add(Map, 3, 'Line No.', 3, 'Ref 3', 71118, true);
                    Add(Map, 4, 'Payment Method Code', 4, 'Ref 4', 71118, true);
                    Add(Map, 5, 'Amount Including VAT', 5, 'Ref 5', 71118, true);
                    Add(Map, 6, 'Percentage', 6, 'Ref 6', 71118, true);
                    Add(Map, 7, 'Currency Code', 7, 'Ref 7', 71118, true);
                    Add(Map, 8, 'Description', 8, 'Ref 8', 71118, true);
                end;
            else Error('Tabla no autorizada para migración de referencias.');
        end;
    end;
    procedure TargetTable(TableID: Integer): Integer
    begin
        case TableID of
            60450: exit(71113);
            60489: exit(71114);
            60451: exit(71115);
            60452: exit(71116);
            60459: exit(71117);
            60510: exit(71118);
            60477: exit(71119);
            60457: exit(71120);
        end;
        exit(TableID);
    end;
    procedure VersionMap(): Code[20]
    begin
        exit('F7864C765DF7F45661FB');
    end;
    local procedure Add(var Map: Record "HN Migration Field" temporary; SourceID: Integer; SourceName: Text[30]; TargetID: Integer; TargetName: Text[30]; TargetTable: Integer; ReferenceOnly: Boolean)
    begin
        Map.Init(); Map."Source ID" := SourceID; Map."Source Name" := SourceName;
        Map."Target ID" := TargetID; Map."Target Name" := TargetName;
        Map."Target Table ID" := TargetTable; Map."Reference Only" := ReferenceOnly; Map.Insert();
    end;
}
