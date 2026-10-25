namespace INVTECH.Honduras;

using Microsoft.Purchases.History;

table 71100 "HN Retention Invoice"
{
    Caption = 'Facturas del comprobante de retención';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Document No."; Code[20]) { Caption = 'Número de documento'; TableRelation = "HN Retention Header"; }
        field(2; "Invoice No."; Code[20]) { Caption = 'Factura registrada'; TableRelation = "Purch. Inv. Header"; }
        field(3; "Vendor Invoice No."; Code[35]) { Caption = 'Factura del proveedor'; }
        field(4; "Invoice CAI"; Code[37]) { Caption = 'CAI factura'; }
        field(5; "Invoice Date"; Date) { Caption = 'Fecha de factura'; }
    }
    keys
    {
        key(PK; "Document No.", "Invoice No.") { Clustered = true; }
        key(Invoice; "Invoice No.") { }
    }
    trigger OnInsert()
    begin
        CheckDraft();
    end;
    trigger OnModify()
    begin
        Error('Quite la factura y vuelva a seleccionarla para actualizar sus datos.');
    end;
    trigger OnDelete()
    begin
        CheckDraft();
    end;
    trigger OnRename()
    begin
        Error('No se puede renombrar la factura del comprobante.');
    end;
    local procedure CheckDraft()
    var
        Header: Record "HN Retention Header";
    begin
        Header.Get("Document No.");
        Header.TestField(Status, Header.Status::Draft);
    end;
}

page 71100 "HN Retention Invoices"
{
    PageType = ListPart;
    SourceTable = "HN Retention Invoice";
    Caption = 'Facturas incluidas';
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(Invoices)
            {
                field(Invoice; Rec."Invoice No.") { ApplicationArea = All; }
                field(VendorInvoice; Rec."Vendor Invoice No.") { ApplicationArea = All; }
                field(CAI; Rec."Invoice CAI") { ApplicationArea = All; }
                field(Date; Rec."Invoice Date") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(RemoveInvoice)
            {
                Caption = 'Quitar factura'; ApplicationArea = All; Image = Delete;
                trigger OnAction()
                var
                    Header: Record "HN Retention Header";
                    Management: Codeunit "HN Retention Management";
                begin
                    Header.Get(Rec."Document No.");
                    Management.RemoveInvoice(Header, Rec."Invoice No.");
                    CurrPage.Update(false);
                end;
            }
        }
    }
}

codeunit 71100 "HN Retention Upgrade"
{
    Subtype = Upgrade;
    trigger OnUpgradePerCompany()
    var
        Header: Record "HN Retention Header";
        Line: Record "HN Retention Line";
        Source: Record "HN Retention Invoice";
        Invoice: Record "Purch. Inv. Header";
    begin
        // Completa relaciones del esquema V2 existente sin emitir correlativos ni registrar contabilidad.
        Header.SetFilter("Invoice No.", '<>%1', '');
        if Header.FindSet() then
            repeat
                if not Source.Get(Header."No.", Header."Invoice No.") then begin
                    Source.Init();
                    Source."Document No." := Header."No.";
                    Source."Invoice No." := Header."Invoice No.";
                    Source."Vendor Invoice No." := Header."Vendor Invoice No.";
                    Source."Invoice CAI" := Header."Invoice CAI";
                    if Invoice.Get(Header."Invoice No.") then begin
                        Source."Invoice Date" := Invoice."Document Date";
                        if Source."Invoice Date" = 0D then
                            Source."Invoice Date" := Invoice."Posting Date";
                    end;
                    Source.Insert(false);
                end;
                Line.SetRange("Document No.", Header."No.");
                Line.SetRange("Invoice No.", '');
                if Line.FindSet(true) then
                    repeat
                        Line."Invoice No." := Header."Invoice No.";
                        Line."Vendor Invoice No." := Header."Vendor Invoice No.";
                        Line."Invoice CAI" := Header."Invoice CAI";
                        Line."Invoice Date" := Source."Invoice Date";
                        Line.Modify(false);
                    until Line.Next() = 0;
            until Header.Next() = 0;
    end;
}
