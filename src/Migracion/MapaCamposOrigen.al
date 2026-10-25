namespace INVTECH.Honduras;
codeunit 71103 "HN Migration Field Map"
{
    procedure Fill(TableID: Integer; var Map: Record "HN Migration Field" temporary)
    begin
        Map.Reset();
        Map.DeleteAll();
        case TableID of
            36:
                begin
                    Add(Map, 60452, 'TransactionNumber', 71100);
                    Add(Map, 60481, 'Gas Station Code', 71101);
                    Add(Map, 60482, 'POS Code', 71102);
                    Add(Map, 60451, 'Batch', 71103);
                    Add(Map, 60477, 'POS Sales Doc_ Type', 71104);
                    Add(Map, 60478, 'Billing Type', 71105);
                    Add(Map, 60479, 'AmountTotal', 71106);
                    Add(Map, 60480, 'VATAmount', 71107);
                    Add(Map, 60506, 'Usuario', 71108);
                    Add(Map, 60487, 'OC', 71109);
                    Add(Map, 60488, 'NumeroDePlaca', 71110);
                    Add(Map, 60489, 'Kilometraje', 71111);
                    Add(Map, 60490, 'Chofer', 71112);
                    Add(Map, 60483, 'Comentario', 71113);
                    Add(Map, 60106, 'Código CAI', 71114);
                    Add(Map, 60100, 'No. CAI', 71115);
                    Add(Map, 60120, 'Fecha Límite Emisión', 71116);
                    Add(Map, 60121, 'Factura Inicial', 71117);
                    Add(Map, 60122, 'Factura Final', 71118);
                    Add(Map, 60103, 'Código Exoneración', 71119);
                    Add(Map, 60101, 'Monto Exonerado', 71120);
                    Add(Map, 60133, 'OrdenDeCompraEXENTA', 71121);
                    Add(Map, 60134, 'OrdenDeRegistroExonerados', 71122);
                    Add(Map, 60135, 'OrdenDeCompraSAG', 71123);
                end;
            112:
                begin
                    Add(Map, 60463, 'TransactionNumber', 71100);
                    Add(Map, 60481, 'Gas Station Code', 71101);
                    Add(Map, 60482, 'POS Code', 71102);
                    Add(Map, 60462, 'Batch', 71103);
                    Add(Map, 60477, 'POS Sales Doc_ Type', 71104);
                    Add(Map, 60478, 'Billing Type', 71105);
                    Add(Map, 60479, 'AmountTotal', 71106);
                    Add(Map, 60480, 'VATAmount', 71107);
                    Add(Map, 60506, 'Usuario', 71108);
                    Add(Map, 60487, 'OC', 71109);
                    Add(Map, 60488, 'NumeroDePlaca', 71110);
                    Add(Map, 60489, 'Kilometraje', 71111);
                    Add(Map, 60490, 'Chofer', 71112);
                    Add(Map, 60483, 'Comentario', 71113);
                    Add(Map, 60484, 'Código CAI', 71114);
                    Add(Map, 60460, 'No. CAI', 71115);
                    Add(Map, 60120, 'Fecha Límite Emisión', 71116);
                    Add(Map, 60121, 'Factura Inicial', 71117);
                    Add(Map, 60122, 'Factura Final', 71118);
                    Add(Map, 60461, 'CAI', 71124);
                end;
            114:
                begin
                    Add(Map, 60463, 'TransactionNumber', 71100);
                    Add(Map, 60462, 'Batch', 71103);
                    Add(Map, 60484, 'Código CAI', 71114);
                    Add(Map, 60460, 'No. CAI', 71115);
                    Add(Map, 60120, 'Fecha Límite Emisión', 71116);
                    Add(Map, 60121, 'Factura Inicial', 71117);
                    Add(Map, 60122, 'Factura Final', 71118);
                    Add(Map, 60461, 'CAI', 71124);
                end;
            37:
                begin
                    Add(Map, 60451, 'Pump_No', 71100);
                    Add(Map, 60452, 'Pump_Position_No', 71101);
                    Add(Map, 60453, 'Tank_No', 71102);
                    Add(Map, 60462, 'Usuario', 71103);
                    Add(Map, 60454, 'VAT_PROD_POSTING_GROUP', 71104);
                    Add(Map, 60455, 'VAT_AMOUNT', 71105);
                    Add(Map, 60456, 'AMOUNT_INCLUDING_VAT', 71106);
                end;
            113:
                begin
                    Add(Map, 60451, 'Pump_No', 71100);
                    Add(Map, 60452, 'Pump_Position_No', 71101);
                    Add(Map, 60453, 'Tank_No', 71102);
                    Add(Map, 60462, 'Usuario', 71103);
                    Add(Map, 60454, 'VAT_PROD_POSTING_GROUP', 71104);
                    Add(Map, 60455, 'VAT_AMOUNT', 71105);
                    Add(Map, 60456, 'AMOUNT_INCLUDING_VAT', 71106);
                end;
            115:
                begin
                end;
            18:
                begin
                    Add(Map, 60483, 'RTN', 71100);
                    Add(Map, 60484, 'CLienteExonerado', 71101);
                end;
            else Error('Tabla no autorizada para migración de metadatos.');
        end;
    end;
    local procedure Add(var Map: Record "HN Migration Field" temporary; SourceID: Integer; SourceName: Text[30]; TargetID: Integer)
    begin
        Map.Init();
        Map."Source ID" := SourceID;
        Map."Source Name" := SourceName;
        Map."Target ID" := TargetID;
        Map.Insert();
    end;
}
