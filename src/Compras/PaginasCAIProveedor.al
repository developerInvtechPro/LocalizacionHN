namespace INVTECH.Honduras;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;

pageextension 71110 "HN CAI Compra Pagina 71110" extends "Purchase Order"
{
    layout
    {
        addafter("Vendor Invoice No.")
        {
            field(HNAutorizacionProveedor; Rec."HN Codigo CAI Proveedor") { ApplicationArea = All; }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(ValidarCAIProveedor)
            {
                Caption = 'Validar CAI del proveedor'; ApplicationArea = All; Image = Check;
                trigger OnAction()
                var
                    Gestion: Codeunit "HN Gestion CAI Proveedor";
                begin
                    CurrPage.SaveRecord();
                    Gestion.ValidarCompra(Rec);
                    CurrPage.SaveRecord();
                    Message('La comprobación finalizó. Si la validación de compras está habilitada, el documento cumple las reglas configuradas.');
                end;
            }
            action(GestionCAIProveedor)
            {
                Caption = 'Gestión de CAI del proveedor'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN CAI Proveedores";
                RunPageLink = "No. proveedor" = field("Buy-from Vendor No.");
            }
        }
    }
}

pageextension 71111 "HN CAI Compra Pagina 71111" extends "Purchase Invoice"
{
    layout
    {
        addafter("Vendor Invoice No.")
        {
            field(HNAutorizacionProveedor; Rec."HN Codigo CAI Proveedor") { ApplicationArea = All; }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(ValidarCAIProveedor)
            {
                Caption = 'Validar CAI del proveedor'; ApplicationArea = All; Image = Check;
                trigger OnAction()
                var
                    Gestion: Codeunit "HN Gestion CAI Proveedor";
                begin
                    CurrPage.SaveRecord();
                    Gestion.ValidarCompra(Rec);
                    CurrPage.SaveRecord();
                    Message('La comprobación finalizó. Si la validación de compras está habilitada, el documento cumple las reglas configuradas.');
                end;
            }
            action(GestionCAIProveedor)
            {
                Caption = 'Gestión de CAI del proveedor'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN CAI Proveedores";
                RunPageLink = "No. proveedor" = field("Buy-from Vendor No.");
            }
        }
    }
}

pageextension 71112 "HN CAI Compra Pagina 71112" extends "Purchase Credit Memo"
{
    layout
    {
        addafter("Vendor Cr. Memo No.")
        {
            field(HNAutorizacionProveedor; Rec."HN Codigo CAI Proveedor") { ApplicationArea = All; }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(ValidarCAIProveedor)
            {
                Caption = 'Validar CAI del proveedor'; ApplicationArea = All; Image = Check;
                trigger OnAction()
                var
                    Gestion: Codeunit "HN Gestion CAI Proveedor";
                begin
                    CurrPage.SaveRecord();
                    Gestion.ValidarCompra(Rec);
                    CurrPage.SaveRecord();
                    Message('La comprobación finalizó. Si la validación de compras está habilitada, el documento cumple las reglas configuradas.');
                end;
            }
            action(GestionCAIProveedor)
            {
                Caption = 'Gestión de CAI del proveedor'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN CAI Proveedores";
                RunPageLink = "No. proveedor" = field("Buy-from Vendor No.");
            }
        }
    }
}

pageextension 71113 "HN CAI Compra Pagina 71113" extends "Purchase Return Order"
{
    layout
    {
        addafter("Vendor Cr. Memo No.")
        {
            field(HNAutorizacionProveedor; Rec."HN Codigo CAI Proveedor") { ApplicationArea = All; }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(ValidarCAIProveedor)
            {
                Caption = 'Validar CAI del proveedor'; ApplicationArea = All; Image = Check;
                trigger OnAction()
                var
                    Gestion: Codeunit "HN Gestion CAI Proveedor";
                begin
                    CurrPage.SaveRecord();
                    Gestion.ValidarCompra(Rec);
                    CurrPage.SaveRecord();
                    Message('La comprobación finalizó. Si la validación de compras está habilitada, el documento cumple las reglas configuradas.');
                end;
            }
            action(GestionCAIProveedor)
            {
                Caption = 'Gestión de CAI del proveedor'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN CAI Proveedores";
                RunPageLink = "No. proveedor" = field("Buy-from Vendor No.");
            }
        }
    }
}

pageextension 71114 "HN CAI Compra Pagina 71114" extends "Posted Purchase Invoice"
{
    layout
    {
        addafter("Vendor Invoice No.")
        {
            field(HNAutorizacionProveedor; Rec."HN Codigo CAI Proveedor") { ApplicationArea = All; }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(GestionCAIProveedor)
            {
                Caption = 'Gestión de CAI del proveedor'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN CAI Proveedores";
                RunPageLink = "No. proveedor" = field("Buy-from Vendor No.");
            }
            action(ImprimirComprobanteHN)
            {
                Caption = 'Imprimir comprobante HN'; ApplicationArea = All; Image = Print;
                trigger OnAction()
                var
                    Documento: Record "Purch. Inv. Header";
                begin
                    Documento := Rec;
                    Documento.SetRecFilter();
                    Report.RunModal(Report::"HN Comprobante Compra", true, false, Documento);
                end;
            }
        }
    }
}

pageextension 71115 "HN CAI Compra Pagina 71115" extends "Posted Purchase Credit Memo"
{
    layout
    {
        addafter("Vendor Cr. Memo No.")
        {
            field(HNAutorizacionProveedor; Rec."HN Codigo CAI Proveedor") { ApplicationArea = All; }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(GestionCAIProveedor)
            {
                Caption = 'Gestión de CAI del proveedor'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN CAI Proveedores";
                RunPageLink = "No. proveedor" = field("Buy-from Vendor No.");
            }
            action(ImprimirComprobanteHN)
            {
                Caption = 'Imprimir comprobante HN'; ApplicationArea = All; Image = Print;
                trigger OnAction()
                var
                    Documento: Record "Purch. Cr. Memo Hdr.";
                begin
                    Documento := Rec;
                    Documento.SetRecFilter();
                    Report.RunModal(Report::"HN Comprobante Abono Compra", true, false, Documento);
                end;
            }
        }
    }
}

pageextension 71116 "HN Gestion CAI Ficha Proveedor" extends "Vendor Card"
{
    actions
    {
        addlast(Processing)
        {
            action(AutorizacionesCAI)
            {
                Caption = 'Gestionar CAI del proveedor'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN CAI Proveedores";
                RunPageLink = "No. proveedor" = field("No.");
            }
        }
    }
}
