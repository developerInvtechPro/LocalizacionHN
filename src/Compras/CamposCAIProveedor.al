namespace INVTECH.Honduras;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;

tableextension 71110 "HN CAI Cabecera Compra" extends "Purchase Header"
{
    fields
    {
        field(71140; "HN Codigo CAI Proveedor"; Code[20])
        {
            Caption = 'Autorización CAI del proveedor'; DataClassification = CustomerContent;
            TableRelation = "HN CAI Proveedor".Codigo where("No. proveedor" = field("Buy-from Vendor No."));
            trigger OnValidate()
            var
                Gestion: Codeunit "HN Gestion CAI Proveedor";
            begin
                Gestion.ProponerDatos(Rec);
            end;
        }
        field(71141; "HN Inicio CAI Proveedor"; Code[20])
        {
            Caption = 'Rango inicial del proveedor'; DataClassification = CustomerContent;
            Editable = false;
        }
        field(71142; "HN Fin CAI Proveedor"; Code[20])
        {
            Caption = 'Rango final del proveedor'; DataClassification = CustomerContent;
            Editable = false;
        }
        field(71143; "HN Vence CAI Proveedor"; Date)
        {
            Caption = 'Fecha límite CAI del proveedor'; DataClassification = CustomerContent;
            Editable = false;
        }
    }
}

tableextension 71111 "HN CAI Factura Compra" extends "Purch. Inv. Header"
{
    fields
    {
        field(71140; "HN Codigo CAI Proveedor"; Code[20])
        {
            Caption = 'Autorización CAI del proveedor'; DataClassification = CustomerContent;
            Editable = false;
        }
        field(71141; "HN Inicio CAI Proveedor"; Code[20])
        {
            Caption = 'Rango inicial del proveedor'; DataClassification = CustomerContent;
            Editable = false;
        }
        field(71142; "HN Fin CAI Proveedor"; Code[20])
        {
            Caption = 'Rango final del proveedor'; DataClassification = CustomerContent;
            Editable = false;
        }
        field(71143; "HN Vence CAI Proveedor"; Date)
        {
            Caption = 'Fecha límite CAI del proveedor'; DataClassification = CustomerContent;
            Editable = false;
        }
    }
}

tableextension 71112 "HN CAI Abono Compra" extends "Purch. Cr. Memo Hdr."
{
    fields
    {
        field(71140; "HN Codigo CAI Proveedor"; Code[20])
        {
            Caption = 'Autorización CAI del proveedor'; DataClassification = CustomerContent;
            Editable = false;
        }
        field(71141; "HN Inicio CAI Proveedor"; Code[20])
        {
            Caption = 'Rango inicial del proveedor'; DataClassification = CustomerContent;
            Editable = false;
        }
        field(71142; "HN Fin CAI Proveedor"; Code[20])
        {
            Caption = 'Rango final del proveedor'; DataClassification = CustomerContent;
            Editable = false;
        }
        field(71143; "HN Vence CAI Proveedor"; Date)
        {
            Caption = 'Fecha límite CAI del proveedor'; DataClassification = CustomerContent;
            Editable = false;
        }
        field(71144; "HN Vendor CAI"; Code[37]) { Caption = 'CAI del proveedor'; Editable = false; DataClassification = CustomerContent; }
    }
}
