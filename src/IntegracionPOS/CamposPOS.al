namespace INVTECH.Honduras;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Customer;

tableextension 71101 "HN POS Metadata 1" extends "Sales Header"
{
    fields
    {
        field(71100; "INV POS Transaction No."; Code[30]) { Caption = 'Documento fiscal de origen POS'; DataClassification = CustomerContent; }
        field(71101; "INV POS Station"; Code[5]) { Caption = 'Sucursal POS'; DataClassification = CustomerContent; }
        field(71102; "INV POS Terminal"; Code[5]) { Caption = 'Terminal POS'; DataClassification = CustomerContent; }
        field(71103; "INV POS Shift"; Integer) { Caption = 'Turno POS'; DataClassification = CustomerContent; }
        field(71104; "INV POS Document Type"; Integer) { Caption = 'Tipo de documento POS'; DataClassification = CustomerContent; }
        field(71105; "INV POS Billing Type"; Integer) { Caption = 'Tipo de facturación POS'; DataClassification = CustomerContent; }
        field(71106; "INV POS Received Total"; Decimal) { Caption = 'Total recibido del POS'; DataClassification = CustomerContent; }
        field(71107; "INV POS Received VAT"; Decimal) { Caption = 'ISV recibido del POS'; DataClassification = CustomerContent; }
        field(71108; "INV POS Operator"; Text[60]) { Caption = 'Operador POS'; DataClassification = CustomerContent; }
        field(71109; "INV POS Purchase Order"; Text[60]) { Caption = 'Orden de compra del cliente POS'; DataClassification = CustomerContent; }
        field(71110; "INV POS Plate"; Text[60]) { Caption = 'Placa POS'; DataClassification = CustomerContent; }
        field(71111; "INV POS Mileage"; Text[60]) { Caption = 'Kilometraje POS'; DataClassification = CustomerContent; }
        field(71112; "INV POS Driver"; Text[60]) { Caption = 'Conductor POS'; DataClassification = CustomerContent; }
        field(71113; "INV POS Comment"; Text[60]) { Caption = 'Comentario POS'; DataClassification = CustomerContent; }
        field(71114; "INV POS CAI Code"; Code[20]) { Caption = 'Código de autorización CAI POS'; DataClassification = CustomerContent; }
        field(71115; "INV POS CAI"; Code[37]) { Caption = 'CAI completo POS'; DataClassification = CustomerContent; }
        field(71116; "INV POS CAI Expiration"; Date) { Caption = 'Fecha límite del CAI POS'; DataClassification = CustomerContent; }
        field(71117; "INV POS CAI Start"; Code[20]) { Caption = 'Rango inicial CAI POS'; DataClassification = CustomerContent; }
        field(71118; "INV POS CAI End"; Code[20]) { Caption = 'Rango final CAI POS'; DataClassification = CustomerContent; }
        field(71119; "INV POS Exemption Code"; Code[20]) { Caption = 'Código de exoneración POS'; DataClassification = CustomerContent; }
        field(71120; "INV POS Exempted Amount"; Decimal) { Caption = 'Importe exonerado POS'; DataClassification = CustomerContent; }
        field(71121; "INV POS Exempt Order"; Code[50]) { Caption = 'Orden de compra exenta POS'; DataClassification = CustomerContent; }
        field(71122; "INV POS Exemption Register"; Code[50]) { Caption = 'Registro de exoneración POS'; DataClassification = CustomerContent; }
        field(71123; "INV POS SAG Reference"; Code[50]) { Caption = 'Referencia SAG POS'; DataClassification = CustomerContent; }
        field(71124; "INV POS Additional CAI"; Code[37]) { Caption = 'CAI adicional de origen POS'; DataClassification = CustomerContent; }
    }
}

tableextension 71102 "HN POS Metadata 2" extends "Sales Invoice Header"
{
    fields
    {
        field(71100; "INV POS Transaction No."; Code[30]) { Caption = 'Documento fiscal de origen POS'; DataClassification = CustomerContent; Editable = false; }
        field(71101; "INV POS Station"; Code[5]) { Caption = 'Sucursal POS'; DataClassification = CustomerContent; Editable = false; }
        field(71102; "INV POS Terminal"; Code[5]) { Caption = 'Terminal POS'; DataClassification = CustomerContent; Editable = false; }
        field(71103; "INV POS Shift"; Integer) { Caption = 'Turno POS'; DataClassification = CustomerContent; Editable = false; }
        field(71104; "INV POS Document Type"; Integer) { Caption = 'Tipo de documento POS'; DataClassification = CustomerContent; Editable = false; }
        field(71105; "INV POS Billing Type"; Integer) { Caption = 'Tipo de facturación POS'; DataClassification = CustomerContent; Editable = false; }
        field(71106; "INV POS Received Total"; Decimal) { Caption = 'Total recibido del POS'; DataClassification = CustomerContent; Editable = false; }
        field(71107; "INV POS Received VAT"; Decimal) { Caption = 'ISV recibido del POS'; DataClassification = CustomerContent; Editable = false; }
        field(71108; "INV POS Operator"; Text[60]) { Caption = 'Operador POS'; DataClassification = CustomerContent; Editable = false; }
        field(71109; "INV POS Purchase Order"; Text[60]) { Caption = 'Orden de compra del cliente POS'; DataClassification = CustomerContent; Editable = false; }
        field(71110; "INV POS Plate"; Text[60]) { Caption = 'Placa POS'; DataClassification = CustomerContent; Editable = false; }
        field(71111; "INV POS Mileage"; Text[60]) { Caption = 'Kilometraje POS'; DataClassification = CustomerContent; Editable = false; }
        field(71112; "INV POS Driver"; Text[60]) { Caption = 'Conductor POS'; DataClassification = CustomerContent; Editable = false; }
        field(71113; "INV POS Comment"; Text[60]) { Caption = 'Comentario POS'; DataClassification = CustomerContent; Editable = false; }
        field(71114; "INV POS CAI Code"; Code[20]) { Caption = 'Código de autorización CAI POS'; DataClassification = CustomerContent; Editable = false; }
        field(71115; "INV POS CAI"; Code[37]) { Caption = 'CAI completo POS'; DataClassification = CustomerContent; Editable = false; }
        field(71116; "INV POS CAI Expiration"; Date) { Caption = 'Fecha límite del CAI POS'; DataClassification = CustomerContent; Editable = false; }
        field(71117; "INV POS CAI Start"; Code[20]) { Caption = 'Rango inicial CAI POS'; DataClassification = CustomerContent; Editable = false; }
        field(71118; "INV POS CAI End"; Code[20]) { Caption = 'Rango final CAI POS'; DataClassification = CustomerContent; Editable = false; }
        field(71119; "INV POS Exemption Code"; Code[20]) { Caption = 'Código de exoneración POS'; DataClassification = CustomerContent; Editable = false; }
        field(71120; "INV POS Exempted Amount"; Decimal) { Caption = 'Importe exonerado POS'; DataClassification = CustomerContent; Editable = false; }
        field(71121; "INV POS Exempt Order"; Code[50]) { Caption = 'Orden de compra exenta POS'; DataClassification = CustomerContent; Editable = false; }
        field(71122; "INV POS Exemption Register"; Code[50]) { Caption = 'Registro de exoneración POS'; DataClassification = CustomerContent; Editable = false; }
        field(71123; "INV POS SAG Reference"; Code[50]) { Caption = 'Referencia SAG POS'; DataClassification = CustomerContent; Editable = false; }
        field(71124; "INV POS Additional CAI"; Code[37]) { Caption = 'CAI adicional de origen POS'; DataClassification = CustomerContent; Editable = false; }
    }
}

tableextension 71103 "HN POS Metadata 3" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(71100; "INV POS Transaction No."; Code[30]) { Caption = 'Documento fiscal de origen POS'; DataClassification = CustomerContent; Editable = false; }
        field(71101; "INV POS Station"; Code[5]) { Caption = 'Sucursal POS'; DataClassification = CustomerContent; Editable = false; }
        field(71102; "INV POS Terminal"; Code[5]) { Caption = 'Terminal POS'; DataClassification = CustomerContent; Editable = false; }
        field(71103; "INV POS Shift"; Integer) { Caption = 'Turno POS'; DataClassification = CustomerContent; Editable = false; }
        field(71104; "INV POS Document Type"; Integer) { Caption = 'Tipo de documento POS'; DataClassification = CustomerContent; Editable = false; }
        field(71105; "INV POS Billing Type"; Integer) { Caption = 'Tipo de facturación POS'; DataClassification = CustomerContent; Editable = false; }
        field(71106; "INV POS Received Total"; Decimal) { Caption = 'Total recibido del POS'; DataClassification = CustomerContent; Editable = false; }
        field(71107; "INV POS Received VAT"; Decimal) { Caption = 'ISV recibido del POS'; DataClassification = CustomerContent; Editable = false; }
        field(71108; "INV POS Operator"; Text[60]) { Caption = 'Operador POS'; DataClassification = CustomerContent; Editable = false; }
        field(71109; "INV POS Purchase Order"; Text[60]) { Caption = 'Orden de compra del cliente POS'; DataClassification = CustomerContent; Editable = false; }
        field(71110; "INV POS Plate"; Text[60]) { Caption = 'Placa POS'; DataClassification = CustomerContent; Editable = false; }
        field(71111; "INV POS Mileage"; Text[60]) { Caption = 'Kilometraje POS'; DataClassification = CustomerContent; Editable = false; }
        field(71112; "INV POS Driver"; Text[60]) { Caption = 'Conductor POS'; DataClassification = CustomerContent; Editable = false; }
        field(71113; "INV POS Comment"; Text[60]) { Caption = 'Comentario POS'; DataClassification = CustomerContent; Editable = false; }
        field(71114; "INV POS CAI Code"; Code[20]) { Caption = 'Código de autorización CAI POS'; DataClassification = CustomerContent; Editable = false; }
        field(71115; "INV POS CAI"; Code[37]) { Caption = 'CAI completo POS'; DataClassification = CustomerContent; Editable = false; }
        field(71116; "INV POS CAI Expiration"; Date) { Caption = 'Fecha límite del CAI POS'; DataClassification = CustomerContent; Editable = false; }
        field(71117; "INV POS CAI Start"; Code[20]) { Caption = 'Rango inicial CAI POS'; DataClassification = CustomerContent; Editable = false; }
        field(71118; "INV POS CAI End"; Code[20]) { Caption = 'Rango final CAI POS'; DataClassification = CustomerContent; Editable = false; }
        field(71119; "INV POS Exemption Code"; Code[20]) { Caption = 'Código de exoneración POS'; DataClassification = CustomerContent; Editable = false; }
        field(71120; "INV POS Exempted Amount"; Decimal) { Caption = 'Importe exonerado POS'; DataClassification = CustomerContent; Editable = false; }
        field(71121; "INV POS Exempt Order"; Code[50]) { Caption = 'Orden de compra exenta POS'; DataClassification = CustomerContent; Editable = false; }
        field(71122; "INV POS Exemption Register"; Code[50]) { Caption = 'Registro de exoneración POS'; DataClassification = CustomerContent; Editable = false; }
        field(71123; "INV POS SAG Reference"; Code[50]) { Caption = 'Referencia SAG POS'; DataClassification = CustomerContent; Editable = false; }
        field(71124; "INV POS Additional CAI"; Code[37]) { Caption = 'CAI adicional de origen POS'; DataClassification = CustomerContent; Editable = false; }
    }
}

tableextension 71104 "HN POS Metadata 4" extends "Sales Line"
{
    fields
    {
        field(71100; "INV POS Pump"; Code[10]) { Caption = 'Identificador de bomba POS'; DataClassification = CustomerContent; }
        field(71101; "INV POS Pump Position"; Code[10]) { Caption = 'Posición de bomba POS'; DataClassification = CustomerContent; }
        field(71102; "INV POS Tank"; Code[10]) { Caption = 'Tanque POS'; DataClassification = CustomerContent; }
        field(71103; "INV POS Line Operator"; Code[50]) { Caption = 'Operador de línea POS'; DataClassification = CustomerContent; }
        field(71104; "INV POS Received VAT Rate"; Decimal) { Caption = 'Tasa de ISV recibida del POS'; DataClassification = CustomerContent; }
        field(71105; "INV POS Line Received VAT"; Decimal) { Caption = 'ISV de línea recibido del POS'; DataClassification = CustomerContent; }
        field(71106; "INV POS Line Received Total"; Decimal) { Caption = 'Total de línea recibido del POS'; DataClassification = CustomerContent; }
    }
}

tableextension 71105 "HN POS Metadata 5" extends "Sales Invoice Line"
{
    fields
    {
        field(71100; "INV POS Pump"; Code[10]) { Caption = 'Identificador de bomba POS'; DataClassification = CustomerContent; Editable = false; }
        field(71101; "INV POS Pump Position"; Code[10]) { Caption = 'Posición de bomba POS'; DataClassification = CustomerContent; Editable = false; }
        field(71102; "INV POS Tank"; Code[10]) { Caption = 'Tanque POS'; DataClassification = CustomerContent; Editable = false; }
        field(71103; "INV POS Line Operator"; Code[50]) { Caption = 'Operador de línea POS'; DataClassification = CustomerContent; Editable = false; }
        field(71104; "INV POS Received VAT Rate"; Decimal) { Caption = 'Tasa de ISV recibida del POS'; DataClassification = CustomerContent; Editable = false; }
        field(71105; "INV POS Line Received VAT"; Decimal) { Caption = 'ISV de línea recibido del POS'; DataClassification = CustomerContent; Editable = false; }
        field(71106; "INV POS Line Received Total"; Decimal) { Caption = 'Total de línea recibido del POS'; DataClassification = CustomerContent; Editable = false; }
    }
}

tableextension 71106 "HN POS Metadata 6" extends "Sales Cr.Memo Line"
{
    fields
    {
        field(71100; "INV POS Pump"; Code[10]) { Caption = 'Identificador de bomba POS'; DataClassification = CustomerContent; Editable = false; }
        field(71101; "INV POS Pump Position"; Code[10]) { Caption = 'Posición de bomba POS'; DataClassification = CustomerContent; Editable = false; }
        field(71102; "INV POS Tank"; Code[10]) { Caption = 'Tanque POS'; DataClassification = CustomerContent; Editable = false; }
        field(71103; "INV POS Line Operator"; Code[50]) { Caption = 'Operador de línea POS'; DataClassification = CustomerContent; Editable = false; }
        field(71104; "INV POS Received VAT Rate"; Decimal) { Caption = 'Tasa de ISV recibida del POS'; DataClassification = CustomerContent; Editable = false; }
        field(71105; "INV POS Line Received VAT"; Decimal) { Caption = 'ISV de línea recibido del POS'; DataClassification = CustomerContent; Editable = false; }
        field(71106; "INV POS Line Received Total"; Decimal) { Caption = 'Total de línea recibido del POS'; DataClassification = CustomerContent; Editable = false; }
    }
}

tableextension 71107 "HN POS Metadata 7" extends "Customer"
{
    fields
    {
        field(71100; "INV HN RTN"; Code[50]) { Caption = 'RTN Honduras'; DataClassification = CustomerContent; }
        field(71101; "INV HN Exempt Customer"; Boolean) { Caption = 'Cliente exonerado Honduras'; DataClassification = CustomerContent; }
    }
}
