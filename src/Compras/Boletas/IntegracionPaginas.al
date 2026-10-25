namespace INVTECH.Honduras;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
pageextension 71127 "HN Boleta Pagina 71127" extends "Purchase Order"
{
    layout
    {
        addlast(General)
        {
            field(HNBoleta; Rec."HN Boleta Compra") { ApplicationArea = All; }
            field(HNIdentidadBoleta; Rec."HN Identidad Boleta") { ApplicationArea = All; Visible = Rec."HN Boleta Compra"; }
            field(HNTelefonoBoleta; Rec."HN Telefono Boleta") { ApplicationArea = All; Visible = Rec."HN Boleta Compra"; }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(PrepararBoleta)
            {
                Caption = 'Emitir como boleta de compra'; ApplicationArea = All; Image = Purchase;
                trigger OnAction()
                var Gestion: Codeunit "HN Gestion Boletas";
                begin CurrPage.SaveRecord(); Gestion.Preparar(Rec); Rec.Modify(true); CurrPage.Update(false); end;
            }
            action(BorradorBoleta)
            {
                Caption = 'Imprimir borrador de boleta'; ApplicationArea = All; Image = Print;
                trigger OnAction()
                var Documento: Record "Purchase Header";
                begin CurrPage.SaveRecord(); Documento := Rec; Documento.SetRecFilter(); Report.RunModal(Report::"HN Borrador Boleta", true, false, Documento); end;
            }
            action(QuitarBoleta)
            {
                Caption = 'Volver a factura de proveedor'; ApplicationArea = All; Image = Cancel;
                trigger OnAction()
                begin Rec."HN Boleta Compra" := false; Rec.Modify(true); CurrPage.Update(false); end;
            }
        }
    }
}
pageextension 71128 "HN Boleta Pagina 71128" extends "Purchase Invoice"
{
    layout
    {
        addlast(General)
        {
            field(HNBoleta; Rec."HN Boleta Compra") { ApplicationArea = All; }
            field(HNIdentidadBoleta; Rec."HN Identidad Boleta") { ApplicationArea = All; Visible = Rec."HN Boleta Compra"; }
            field(HNTelefonoBoleta; Rec."HN Telefono Boleta") { ApplicationArea = All; Visible = Rec."HN Boleta Compra"; }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(PrepararBoleta)
            {
                Caption = 'Emitir como boleta de compra'; ApplicationArea = All; Image = Purchase;
                trigger OnAction()
                var Gestion: Codeunit "HN Gestion Boletas";
                begin CurrPage.SaveRecord(); Gestion.Preparar(Rec); Rec.Modify(true); CurrPage.Update(false); end;
            }
            action(BorradorBoleta)
            {
                Caption = 'Imprimir borrador de boleta'; ApplicationArea = All; Image = Print;
                trigger OnAction()
                var Documento: Record "Purchase Header";
                begin CurrPage.SaveRecord(); Documento := Rec; Documento.SetRecFilter(); Report.RunModal(Report::"HN Borrador Boleta", true, false, Documento); end;
            }
            action(QuitarBoleta)
            {
                Caption = 'Volver a factura de proveedor'; ApplicationArea = All; Image = Cancel;
                trigger OnAction()
                begin Rec."HN Boleta Compra" := false; Rec.Modify(true); CurrPage.Update(false); end;
            }
        }
    }
}
pageextension 71129 "HN Boleta Historico Pagina" extends "Posted Purchase Invoice"
{
    layout
    {
        addlast(General)
        {
            field(HNBoleta; Rec."HN Boleta Compra") { ApplicationArea = All; }
            field(HNNumeroBoleta; Rec."HN Numero Boleta") { ApplicationArea = All; }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(ImprimirBoleta)
            {
                Caption = 'Imprimir boleta de compra HN'; ApplicationArea = All; Image = Print;
                trigger OnAction()
                var Documento: Record "Purch. Inv. Header";
                begin Documento := Rec; Documento.SetRecFilter(); Report.RunModal(Report::"HN Boleta Compra", true, false, Documento); end;
            }
        }
    }
}
