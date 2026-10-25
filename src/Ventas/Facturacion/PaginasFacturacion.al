namespace INVTECH.Honduras;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;

pageextension 71120 "HN Facturacion Pagina 71120" extends "Sales Order"
{
    layout
    {
        addlast(General)
        {
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(ConfiguracionFacturacionHN)
            {
                Caption = 'Configuración de facturación HN'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN Config. Facturacion";
            }
            action(ValidarFacturacionHN)
            {
                Caption = 'Validar facturación HN'; ApplicationArea = All; Image = Check;
                trigger OnAction()
                var
                    Gestion: Codeunit "HN Gestion Facturacion";
                    Documento: Record "Sales Header";
                begin
                    CurrPage.SaveRecord();
                    Documento := Rec;
                    Gestion.ValidarDocumento(Documento);
                    Message('El documento cumple la configuración fiscal de esta extensión.');
                end;
            }
        }
    }
}

pageextension 71121 "HN Facturacion Pagina 71121" extends "Sales Invoice"
{
    layout
    {
        addlast(General)
        {
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(ConfiguracionFacturacionHN)
            {
                Caption = 'Configuración de facturación HN'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN Config. Facturacion";
            }
            action(ValidarFacturacionHN)
            {
                Caption = 'Validar facturación HN'; ApplicationArea = All; Image = Check;
                trigger OnAction()
                var
                    Gestion: Codeunit "HN Gestion Facturacion";
                    Documento: Record "Sales Header";
                begin
                    CurrPage.SaveRecord();
                    Documento := Rec;
                    Gestion.ValidarDocumento(Documento);
                    Message('El documento cumple la configuración fiscal de esta extensión.');
                end;
            }
        }
    }
}

pageextension 71122 "HN Facturacion Pagina 71122" extends "Sales Credit Memo"
{
    layout
    {
        addlast(General)
        {
            field(HNFacturaOrigen; Rec."HN Original Invoice No.")
            {
                ApplicationArea = All;
                trigger OnValidate()
                var
                    Gestion: Codeunit "HN Gestion Facturacion";
                begin
                    Gestion.EstablecerOrigen(Rec);
                end;
            }
            field(HNNumeroOrigen; Rec."HN Source Fiscal No.") { ApplicationArea = All; }
            field(HNCAIOrigen; Rec."HN Source CAI") { ApplicationArea = All; }
            field(HNMotivoAbono; Rec."HN Debit Reason") { ApplicationArea = All; Caption = 'Motivo de la nota de crédito'; }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(ConfiguracionFacturacionHN)
            {
                Caption = 'Configuración de facturación HN'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN Config. Facturacion";
            }
            action(ValidarFacturacionHN)
            {
                Caption = 'Validar facturación HN'; ApplicationArea = All; Image = Check;
                trigger OnAction()
                var
                    Gestion: Codeunit "HN Gestion Facturacion";
                    Documento: Record "Sales Header";
                begin
                    CurrPage.SaveRecord();
                    Documento := Rec;
                    Gestion.ValidarDocumento(Documento);
                    Message('El documento cumple la configuración fiscal de esta extensión.');
                end;
            }
        }
    }
}

pageextension 71123 "HN Facturacion Pagina 71123" extends "Sales Return Order"
{
    layout
    {
        addlast(General)
        {
            field(HNFacturaOrigen; Rec."HN Original Invoice No.")
            {
                ApplicationArea = All;
                trigger OnValidate()
                var
                    Gestion: Codeunit "HN Gestion Facturacion";
                begin
                    Gestion.EstablecerOrigen(Rec);
                end;
            }
            field(HNNumeroOrigen; Rec."HN Source Fiscal No.") { ApplicationArea = All; }
            field(HNCAIOrigen; Rec."HN Source CAI") { ApplicationArea = All; }
            field(HNMotivoAbono; Rec."HN Debit Reason") { ApplicationArea = All; Caption = 'Motivo de la nota de crédito'; }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(ConfiguracionFacturacionHN)
            {
                Caption = 'Configuración de facturación HN'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN Config. Facturacion";
            }
            action(ValidarFacturacionHN)
            {
                Caption = 'Validar facturación HN'; ApplicationArea = All; Image = Check;
                trigger OnAction()
                var
                    Gestion: Codeunit "HN Gestion Facturacion";
                    Documento: Record "Sales Header";
                begin
                    CurrPage.SaveRecord();
                    Documento := Rec;
                    Gestion.ValidarDocumento(Documento);
                    Message('El documento cumple la configuración fiscal de esta extensión.');
                end;
            }
        }
    }
}

pageextension 71124 "HN Impresion Venta 71124" extends "Posted Sales Invoice"
{
    layout
    {
        addlast(General)
        {
            field(HNNumeroFiscal; Rec."HN Fiscal No.") { ApplicationArea = All; }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(ImprimirFiscalHN)
            {
                Caption = 'Imprimir comprobante fiscal HN'; ApplicationArea = All; Image = Print;
                trigger OnAction()
                var
                    Documento: Record "Sales Invoice Header";
                begin
                    Documento := Rec;
                    Documento.SetRecFilter();
                    Report.RunModal(Report::"HN Factura Venta", true, false, Documento);
                end;
            }
        }
    }
}

pageextension 71125 "HN Impresion Venta 71125" extends "Posted Sales Credit Memo"
{
    layout
    {
        addlast(General)
        {
            field(HNNumeroFiscal; Rec."HN Fiscal No.") { ApplicationArea = All; }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(ImprimirFiscalHN)
            {
                Caption = 'Imprimir comprobante fiscal HN'; ApplicationArea = All; Image = Print;
                trigger OnAction()
                var
                    Documento: Record "Sales Cr.Memo Header";
                begin
                    Documento := Rec;
                    Documento.SetRecFilter();
                    Report.RunModal(Report::"HN Nota Credito Venta", true, false, Documento);
                end;
            }
        }
    }
}
