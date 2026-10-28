namespace INVTECH.Honduras;

using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;

table 50102 "HN Retention Header"
{
    Caption = 'Comprobante de retención HN';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "No."; Code[20]) { Caption = 'Número interno'; }
        field(2; Status; Enum "HN Retention Status") { Caption = 'Estado'; Editable = false; }
        field(3; "Vendor No."; Code[20]) { Caption = 'Proveedor'; TableRelation = Vendor; Editable = false; }
        field(4; "Vendor Name"; Text[100]) { Caption = 'Nombre del proveedor'; Editable = false; }
        field(5; "Vendor RTN"; Text[20]) { Caption = 'RTN proveedor'; Editable = false; }
        field(6; "Invoice No."; Code[20]) { Caption = 'Factura de compra registrada'; TableRelation = "Purch. Inv. Header"; Editable = false; }
        field(7; "Vendor Invoice No."; Code[35]) { Caption = 'Factura del proveedor'; Editable = false; }
        field(8; "Posting Date"; Date) { Caption = 'Fecha de emisión y registro'; }
        field(9; "Currency Code"; Code[10]) { Caption = 'Moneda'; TableRelation = Currency; Editable = false; }
        field(10; "CAI Code"; Code[20]) { Caption = 'Autorización CAI'; TableRelation = "HN CAI Authorization" where("Document Type" = const(Retention)); }
        field(11; "Fiscal No."; Code[20]) { Caption = 'Número fiscal'; Editable = false; }
        field(12; CAI; Code[37]) { Caption = 'CAI'; Editable = false; }
        field(13; "CAI Starting No."; Code[20]) { Caption = 'Rango inicial'; Editable = false; }
        field(14; "CAI Ending No."; Code[20]) { Caption = 'Rango final'; Editable = false; }
        field(15; "CAI Valid Until"; Date) { Caption = 'Fecha límite de emisión'; Editable = false; }
        field(16; Amount; Decimal) { Caption = 'Total retenido'; FieldClass = FlowField; CalcFormula = sum("HN Retention Line".Amount where("Document No." = field("No."))); Editable = false; }
        field(17; "Registered At"; DateTime) { Caption = 'Registrado el'; Editable = false; }
        field(18; "Registered By"; Code[50]) { Caption = 'Registrado por'; Editable = false; }
        field(19; "Dimension Set ID"; Integer) { Caption = 'Conjunto de dimensiones'; Editable = false; }
        field(21; "Issuer Name"; Text[100]) { Caption = 'Emisor'; Editable = false; }
        field(22; "Issuer RTN"; Text[20]) { Caption = 'RTN emisor'; Editable = false; }
        field(23; "Issuer Address"; Text[200]) { Caption = 'Dirección emisor'; Editable = false; }
        field(20; "Invoice CAI"; Code[37]) { Caption = 'CAI de la factura origen'; Editable = false; }
        field(30; "Cancelled At"; DateTime) { Caption = 'Anulada el'; Editable = false; }
        field(31; "Cancelled By"; Code[50]) { Caption = 'Anulada por'; Editable = false; }
        field(32; "Cancellation Reason"; Text[250]) { Caption = 'Motivo de anulación'; Editable = false; }
        field(33; "Cancellation Date"; Date) { Caption = 'Fecha contable de anulación'; Editable = false; }
        field(34; "Replaces No."; Code[20]) { Caption = 'Sustituye al comprobante'; TableRelation = "HN Retention Header" where(Status = const(Cancelled)); Editable = false; }
        field(35; "Tax Reported"; Boolean) { Caption = 'Declarada o enterada al SAR'; Editable = false; }
        field(36; "Tax Correction Ref."; Text[100]) { Caption = 'Referencia de revisión fiscal'; Editable = false; }
        field(38; "RTN proveedor completo"; Text[50])
        {
            Caption = 'RTN proveedor';
            trigger OnValidate()
            var Gestion: Codeunit "HN Gestion RTN Proveedor";
            begin
                Gestion.ValidarEleccion(Rec,"RTN proveedor completo");
                // Campo anterior conservado sin cambiar su tipo ni truncar un RTN largo.
                if StrLen("RTN proveedor completo") <= MaxStrLen("Vendor RTN") then
                    "Vendor RTN" := "RTN proveedor completo"
                else Clear("Vendor RTN");
            end;
        }
        field(37; "Invoice Count"; Integer) { Caption = 'Cantidad de facturas'; FieldClass = FlowField; CalcFormula = count("HN Retention Invoice" where("Document No." = field("No."))); Editable = false; }
    }
    keys
    {
        key(PK; "No.") { Clustered = true; }
        key(Invoice; "Invoice No.") { }
    }
    procedure ObtenerRTNProveedor(): Text[50]
    begin
        if "RTN proveedor completo" <> '' then exit("RTN proveedor completo");
        exit("Vendor RTN");
    end;
    trigger OnModify()
    var Guardado: Record "HN Retention Header";
    begin
        // En llamadas AL, xRec puede reflejar el estado recién asignado en Rec.
        // La protección debe comprobar el estado persistido antes de modificar.
        if IsTemporary() then Guardado.Copy(Rec,true);
        Guardado.LockTable();
        Guardado.Get("No.");
        if Guardado.Status <> Guardado.Status::Draft then
            Error('No se puede modificar un comprobante registrado.');
    end;
    trigger OnDelete()
    var
        Lines: Record "HN Retention Line";
        Seleccion: Record "HN Seleccion Ret. Factura";
    begin
        TestField(Status, Status::Draft);
        Lines.SetRange("Document No.", "No.");
        Lines.DeleteAll(true);
        Seleccion.SetRange(Documento,"No."); Seleccion.DeleteAll(true);
        DeleteSources();
    end;
    trigger OnRename()
    begin
        Error('No se puede renombrar el comprobante.');
    end;
    local procedure DeleteSources()
    var
        Source: Record "HN Retention Invoice";
    begin
        Source.SetRange("Document No.", "No.");
        Source.DeleteAll(true);
    end;
}
table 50103 "HN Retention Line"
{
    Caption = 'Línea de retención HN';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Document No."; Code[20]) { Caption = 'Número de documento'; TableRelation = "HN Retention Header"; }
        field(2; "Line No."; Integer) { Caption = 'Número de línea'; }
        field(3; "Invoice Line No."; Integer) { Caption = 'Línea factura'; }
        field(4; "Retention Code"; Code[20]) { Caption = 'Retención'; TableRelation = "HN Retention Rule"; }
        field(5; Description; Text[100]) { Caption = 'Descripción'; }
        field(6; Base; Decimal) { Caption = 'Base imponible'; }
        field(7; Percentage; Decimal) { Caption = 'Porcentaje'; DecimalPlaces = 0 : 5; }
        field(8; Amount; Decimal) { Caption = 'Importe retenido'; }
        field(9; "G/L Account No."; Code[20]) { Caption = 'Cuenta por pagar al fisco'; TableRelation = "G/L Account"; }
        field(10; "Dimension Set ID"; Integer) { Caption = 'Conjunto de dimensiones'; }
        field(11; "Invoice No."; Code[20]) { Caption = 'Factura registrada'; TableRelation = "Purch. Inv. Header"; }
        field(12; "Vendor Invoice No."; Code[35]) { Caption = 'Factura del proveedor'; }
        field(13; "Invoice CAI"; Code[37]) { Caption = 'CAI de factura'; }
        field(14; "Vendor Entry No."; Integer) { Caption = 'Movimiento de retención'; Editable = false; TableRelation = "Vendor Ledger Entry"; }
        field(15; "Invoice Date"; Date) { Caption = 'Fecha factura origen'; }
    }
    keys { key(PK; "Document No.", "Line No.") { Clustered = true; } }
    trigger OnInsert()
    begin
        CheckDraft();
    end;
    trigger OnModify()
    begin
        CheckDraft();
    end;
    trigger OnDelete()
    begin
        CheckDraft();
    end;
    trigger OnRename()
    begin
        Error('No se puede renombrar la línea.');
    end;
    local procedure CheckDraft()
    var
        Header: Record "HN Retention Header";
    begin
        Header.Get("Document No.");
        Header.TestField(Status, Header.Status::Draft);
    end;
}
