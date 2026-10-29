namespace INVTECH.Honduras;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Vendor;

page 71114 "HN Boletas Compra"
{
    Caption = 'Boletas de compra HN';
    PageType = List;
    SourceTable = "Purchase Header";
    SourceTableView = where("Document Type" = const(Invoice), "HN Boleta Compra" = const(true));
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "HN Boleta Compra";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(Documentos)
            {
                field(Numero; Rec."No.") { ApplicationArea = All; }
                field(Proveedor; Rec."Buy-from Vendor Name") { ApplicationArea = All; }
                field(Fecha; Rec."Document Date") { ApplicationArea = All; }
                field(Importe; Rec."Amount Including VAT") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Nueva) { Caption = 'Nueva boleta de compra'; ApplicationArea = All; Image = NewDocument; RunObject = page "HN Boleta Compra"; RunPageMode = Create; }
            action(Historico) { Caption = 'Boletas de compra registradas'; ApplicationArea = All; Image = History; RunObject = page "HN Boletas Registradas"; }
            action(Configuracion) { Caption = 'Configuración de facturación HN'; ApplicationArea = All; Image = Setup; RunObject = page "HN Config. Facturacion"; }
            action(CAI)
            {
                Caption = 'Configurar CAI';
                ApplicationArea = All;
                Image = Setup;
                trigger OnAction()
                var
                    Autorizaciones: Record "HN CAI Authorization";
                    PaginaCAI: Page "HN CAI Authorizations";
                begin
                    Autorizaciones.SetRange("Document Type", "HN Fiscal Document Type"::BoletaCompra);
                    PaginaCAI.SetTableView(Autorizaciones);
                    PaginaCAI.RunModal();
                end;
            }
        }
    }
}

page 71115 "HN Boleta Compra"
{
    Caption = 'Boleta de compra HN';
    PageType = Document;
    SourceTable = "Purchase Header";
    SourceTableView = where("Document Type" = const(Invoice), "HN Boleta Compra" = const(true));
    DelayedInsert = true;
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(Numero; Rec."No.") { ApplicationArea = All; }
                field(Proveedor; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        Gestion: Codeunit "HN Gestion Boletas";
                    begin
                        Gestion.Preparar(Rec);
                        CurrPage.Update(false);
                    end;
                }
                field(Nombre; Rec."Buy-from Vendor Name") { ApplicationArea = All; }
                field(Direccion; Rec."Buy-from Address") { ApplicationArea = All; }
                field(Ciudad; Rec."Buy-from City") { ApplicationArea = All; }
                field(Identidad; Rec."HN Identidad Boleta") { ApplicationArea = All; }
                field(Telefono; Rec."HN Telefono Boleta") { ApplicationArea = All; }
                field(Fecha; Rec."Document Date") { ApplicationArea = All; }
                field(Registro; Rec."Posting Date") { ApplicationArea = All; }
                field(Pago; Rec."Pay-to Vendor No.") { ApplicationArea = All; }
                field(Terminos; Rec."Payment Terms Code") { ApplicationArea = All; }
                field(Vencimiento; Rec."Due Date") { ApplicationArea = All; }
                field(FormaPago; Rec."Payment Method Code") { ApplicationArea = All; }
            }
            part(Lineas; "Purch. Invoice Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
            }
            group(Exoneracion)
            {
                Caption = 'Datos del adquirente exonerado';
                field(Orden; Rec."HN Orden Exenta Boleta") { ApplicationArea = All; }
                field(Constancia; Rec."HN Registro Exento Boleta") { ApplicationArea = All; }
                field(SAG; Rec."HN Registro SAG Boleta") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Validar)
            {
                Caption = 'Validar boleta';
                ApplicationArea = All;
                Image = Check;
                trigger OnAction()
                var
                    Gestion: Codeunit "HN Gestion Boletas";
                begin
                    CurrPage.SaveRecord();
                    Gestion.Validar(Rec);
                    Message('Boleta validada. El correlativo se asignará únicamente al registrar.');
                end;
            }
            action(VistaPrevia)
            {
                Caption = 'Vista previa de registro';
                ApplicationArea = All;
                Image = ViewPostedOrder;
                trigger OnAction()
                var
                    Registro: Codeunit "Purch.-Post (Yes/No)";
                begin
                    CurrPage.SaveRecord();
                    Registro.Preview(Rec);
                end;
            }
            action(Registrar)
            {
                Caption = 'Registrar';
                ApplicationArea = All;
                Image = Post;
                trigger OnAction()
                begin
                    CurrPage.SaveRecord();
                    Rec.SendToPosting(Codeunit::"Purch.-Post (Yes/No)");
                    CurrPage.Update(false);
                end;
            }
            action(Borrador)
            {
                Visible = false;
                Caption = 'Imprimir borrador sin validez fiscal';
                ApplicationArea = All;
                Image = Print;
                trigger OnAction()
                var
                    Documento: Record "Purchase Header";
                begin
                    CurrPage.SaveRecord();
                    Documento := Rec;
                    Documento.SetRecFilter();
                    Report.RunModal(Report::"HN Borrador Boleta", true, false, Documento);
                end;
            }
            action(Configuracion) { Caption = 'Configuración de facturación HN'; ApplicationArea = All; Image = Setup; RunObject = page "HN Config. Facturacion"; }
            action(CAI)
            {
                Caption = 'Configurar CAI';
                ApplicationArea = All;
                Image = Setup;
                trigger OnAction()
                var
                    Autorizaciones: Record "HN CAI Authorization";
                    PaginaCAI: Page "HN CAI Authorizations";
                begin
                    Autorizaciones.SetRange("Document Type", "HN Fiscal Document Type"::BoletaCompra);
                    PaginaCAI.SetTableView(Autorizaciones);
                    PaginaCAI.RunModal();
                end;
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Document Type" := Rec."Document Type"::Invoice;
        Rec."HN Boleta Compra" := true;
    end;
}

page 71116 "HN Boletas Registradas"
{
    Caption = 'Boletas de compra registradas HN';
    PageType = List;
    SourceTable = "Purch. Inv. Header";
    SourceTableView = where("HN Boleta Compra" = const(true));
    Editable = false;
    ApplicationArea = All;
    UsageCategory = History;
    CardPageId = "Posted Purchase Invoice";
    layout
    {
        area(Content)
        {
            repeater(Documentos)
            {
                field(Numero; Rec."No.") { ApplicationArea = All; }
                field(Fiscal; Rec."HN Numero Boleta") { ApplicationArea = All; }
                field(Proveedor; Rec."Buy-from Vendor Name") { ApplicationArea = All; }
                field(Fecha; Rec."Document Date") { ApplicationArea = All; }
                field(Importe; Rec."Amount Including VAT") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Imprimir)
            {
                Visible = false;
                Caption = 'Imprimir boleta de compra';
                ApplicationArea = All;
                Image = Print;
                trigger OnAction()
                var
                    Documento: Record "Purch. Inv. Header";
                begin
                    Documento := Rec;
                    Documento.SetRecFilter();
                    Report.RunModal(Report::"HN Boleta Compra", true, false, Documento);
                end;
            }
        }
    }
}

pageextension 71126 "HN Proveedor Boleta Pagina" extends "Vendor Card"
{
    layout
    {
        addlast(General)
        {
            field(HNPersonaNatural; Rec."HN Persona Natural Hondurena") { ApplicationArea = All; ToolTip = 'Confirme la condición de persona natural hondureña y la procedencia fiscal de emitir boletas a este proveedor.'; }
            field(HNIdentidadBoleta; Rec."HN Identidad Boleta") { ApplicationArea = All; }
        }
    }
}
