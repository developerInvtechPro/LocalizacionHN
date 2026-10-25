namespace INVTECH.Honduras;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;

tableextension 71116 "HN Boleta Cabecera" extends "Purchase Header"
{
    fields
    {
        field(71160; "HN Boleta Compra"; Boolean) { Caption = 'Boleta de compra HN'; DataClassification = CustomerContent; Editable = false; }
        field(71167; "HN Identidad Boleta"; Text[20]) { Caption = 'RTN o identidad del proveedor'; DataClassification = CustomerContent; }
        field(71168; "HN Telefono Boleta"; Text[30]) { Caption = 'Teléfono del proveedor'; DataClassification = CustomerContent; }
        field(71174; "HN Orden Exenta Boleta"; Text[100]) { Caption = 'Orden de compra exenta'; DataClassification = CustomerContent; }
        field(71175; "HN Registro Exento Boleta"; Text[100]) { Caption = 'Constancia de exonerados'; DataClassification = CustomerContent; }
        field(71176; "HN Registro SAG Boleta"; Text[100]) { Caption = 'Registro SAG'; DataClassification = CustomerContent; }
    }
}

tableextension 71117 "HN Boleta Registrada" extends "Purch. Inv. Header"
{
    fields
    {
        field(71160; "HN Boleta Compra"; Boolean) { Caption = 'Boleta de compra HN'; DataClassification = CustomerContent; Editable = false; }
        field(71161; "HN Numero Boleta"; Code[20]) { Caption = 'Número fiscal de boleta'; DataClassification = CustomerContent; Editable = false; }
        field(71162; "HN CAI Boleta"; Code[37]) { Caption = 'CAI de boleta'; DataClassification = CustomerContent; Editable = false; }
        field(71163; "HN Autorizacion Boleta"; Code[20]) { Caption = 'Autorización de boleta'; DataClassification = CustomerContent; Editable = false; }
        field(71164; "HN Inicio Boleta"; Code[20]) { Caption = 'Rango inicial de boleta'; DataClassification = CustomerContent; Editable = false; }
        field(71165; "HN Fin Boleta"; Code[20]) { Caption = 'Rango final de boleta'; DataClassification = CustomerContent; Editable = false; }
        field(71166; "HN Vence Boleta"; Date) { Caption = 'Fecha límite de boleta'; DataClassification = CustomerContent; Editable = false; }
        field(71167; "HN Identidad Boleta"; Text[20]) { Caption = 'RTN o identidad del proveedor'; DataClassification = CustomerContent; Editable = false; }
        field(71168; "HN Telefono Boleta"; Text[30]) { Caption = 'Teléfono del proveedor'; DataClassification = CustomerContent; Editable = false; }
        field(71169; "HN Nombre Emisor Boleta"; Text[100]) { Caption = 'Nombre del emisor'; DataClassification = CustomerContent; Editable = false; }
        field(71170; "HN RTN Emisor Boleta"; Text[20]) { Caption = 'RTN del emisor'; DataClassification = CustomerContent; Editable = false; }
        field(71171; "HN Direccion Emisor Boleta"; Text[200]) { Caption = 'Dirección del emisor'; DataClassification = CustomerContent; Editable = false; }
        field(71172; "HN Telefono Emisor Boleta"; Text[30]) { Caption = 'Teléfono del emisor'; DataClassification = CustomerContent; Editable = false; }
        field(71173; "HN Correo Emisor Boleta"; Text[80]) { Caption = 'Correo del emisor'; DataClassification = CustomerContent; Editable = false; }
        field(71174; "HN Orden Exenta Boleta"; Text[100]) { Caption = 'Orden de compra exenta'; DataClassification = CustomerContent; Editable = false; }
        field(71175; "HN Registro Exento Boleta"; Text[100]) { Caption = 'Constancia de exonerados'; DataClassification = CustomerContent; Editable = false; }
        field(71176; "HN Registro SAG Boleta"; Text[100]) { Caption = 'Registro SAG'; DataClassification = CustomerContent; Editable = false; }
    }
}

tableextension 71118 "HN Proveedor Boleta" extends Vendor
{
    fields
    {
        field(71160; "HN Persona Natural Hondurena"; Boolean) { Caption = 'Persona natural hondureña para boletas'; DataClassification = CustomerContent; }
        field(71167; "HN Identidad Boleta"; Text[20]) { Caption = 'RTN o identidad para boletas'; DataClassification = CustomerContent; }
    }
}
