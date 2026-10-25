namespace INVTECH.Honduras;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;

tableextension 71113 "HN Emision Cabecera Venta" extends "Sales Header"
{
    fields
    {
        field(71140; "HN Emitir Documento Fiscal"; Boolean)
        {
            Caption = 'Emisión fiscal HN (compatibilidad)'; DataClassification = CustomerContent;
            Editable = false;
        }
    }
}

tableextension 71114 "HN Emision Factura Venta" extends "Sales Invoice Header"
{
    fields
    {
        field(71140; "HN Emitir Documento Fiscal"; Boolean) { Caption = 'Factura fiscal HN'; DataClassification = CustomerContent; Editable = false; }
        field(71149; "HN RTN Destinatario"; Text[50]) { Caption = 'RTN del cliente'; DataClassification = CustomerContent; Editable = false; }
    }
}

tableextension 71115 "HN Emision Abono Venta" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(71140; "HN Emitir Documento Fiscal"; Boolean) { Caption = 'Nota de crédito fiscal HN'; DataClassification = CustomerContent; Editable = false; }
        field(71141; "HN Fiscal No."; Code[20]) { Caption = 'Número fiscal'; DataClassification = CustomerContent; Editable = false; }
        field(71142; "HN CAI"; Code[37]) { Caption = 'CAI'; DataClassification = CustomerContent; Editable = false; }
        field(71143; "HN CAI Code"; Code[20]) { Caption = 'Código de autorización'; DataClassification = CustomerContent; Editable = false; }
        field(71144; "HN CAI Starting No."; Code[20]) { Caption = 'Rango inicial'; DataClassification = CustomerContent; Editable = false; }
        field(71145; "HN CAI Ending No."; Code[20]) { Caption = 'Rango final'; DataClassification = CustomerContent; Editable = false; }
        field(71146; "HN CAI Valid Until"; Date) { Caption = 'Fecha límite de emisión'; DataClassification = CustomerContent; Editable = false; }
        field(71147; "HN Source Fiscal No."; Code[30]) { Caption = 'Número fiscal de origen'; DataClassification = CustomerContent; Editable = false; }
        field(71148; "HN Source CAI"; Code[37]) { Caption = 'CAI de origen'; DataClassification = CustomerContent; Editable = false; }
        field(71149; "HN RTN Destinatario"; Text[50]) { Caption = 'RTN del cliente'; DataClassification = CustomerContent; Editable = false; }
        field(71150; "HN Motivo"; Text[250]) { Caption = 'Motivo de la nota de crédito'; DataClassification = CustomerContent; Editable = false; }
        field(71151; "HN Issuer Name"; Text[100]) { Caption = 'Nombre del emisor'; DataClassification = CustomerContent; Editable = false; }
        field(71152; "HN Issuer RTN"; Text[20]) { Caption = 'RTN del emisor'; DataClassification = CustomerContent; Editable = false; }
        field(71153; "HN Issuer Address"; Text[200]) { Caption = 'Dirección del emisor'; DataClassification = CustomerContent; Editable = false; }
        field(71154; "HN Original Invoice No."; Code[20]) { Caption = 'Factura registrada de origen'; DataClassification = CustomerContent; Editable = false; }
        field(71155; "HN Original Invoice Date"; Date) { Caption = 'Fecha de la factura de origen'; DataClassification = CustomerContent; Editable = false; }
    }
}
