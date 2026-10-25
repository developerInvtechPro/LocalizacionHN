namespace INVTECH.Honduras;

// La habilitación es explícita por empresa y documento para preservar el recorrido POS existente.
table 71110 "HN Config. Facturacion"
{
    Caption = 'Configuración de facturación HN';
    DataClassification = CustomerContent;
    fields
    {
        field(1; Clave; Code[10]) { Caption = 'Clave'; }
        field(2; "Ventas habilitadas"; Boolean) { Caption = 'Habilitar facturación de ventas HN'; }
        field(3; "CAI facturas"; Code[20]) { Caption = 'Autorización predeterminada de facturas'; TableRelation = "HN CAI Authorization" where("Document Type" = const(Factura)); }
        field(4; "CAI abonos"; Code[20]) { Caption = 'Autorización predeterminada de notas de crédito'; TableRelation = "HN CAI Authorization" where("Document Type" = const(NotaCredito)); }
        field(5; "Validar compras"; Boolean) { Caption = 'Exigir CAI del proveedor al registrar compras'; }
        field(6; "Activar documentos nuevos"; Boolean) { Caption = 'Activar facturación HN en documentos nuevos de la interfaz'; }
    }
    keys { key(PK; Clave) { Clustered = true; } }
}

page 71110 "HN Config. Facturacion"
{
    Caption = 'Configuración de facturación HN';
    PageType = Card;
    SourceTable = "HN Config. Facturacion";
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            group(Ventas)
            {
                Caption = 'Ventas';
                field(Habilitar; Rec."Ventas habilitadas") { ApplicationArea = All; ToolTip = 'Habilita la emisión con autorizaciones propias de esta extensión.'; }
                field(Facturas; Rec."CAI facturas") { ApplicationArea = All; }
                field(Abonos; Rec."CAI abonos") { ApplicationArea = All; }
                field(Nuevos; Rec."Activar documentos nuevos") { ApplicationArea = All; ToolTip = 'Marca documentos creados de forma interactiva. La API debe activar expresamente el recorrido fiscal cuando termine su adaptación.'; }
            }
            group(Compras)
            {
                Caption = 'Compras';
                field(Validar; Rec."Validar compras") { ApplicationArea = All; ToolTip = 'Valida el CAI, proveedor, tipo, fecha de emisión y rango de la factura o abono antes de contabilizar.'; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Autorizaciones)
            {
                Caption = 'Autorizaciones CAI de ventas'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN CAI Authorizations";
                RunPageView = where("Document Type" = filter(Factura | NotaCredito));
            }
            action(Proveedores) { Caption = 'Gestión de CAI de proveedores'; ApplicationArea = All; Image = Vendor; RunObject = page "HN CAI Proveedores"; }
            action(Movimientos) { Caption = 'Movimientos fiscales'; ApplicationArea = All; Image = Ledger; RunObject = page "HN Movimientos Fiscales"; }
        }
    }
    trigger OnOpenPage()
    begin
        if not Rec.Get('') then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;
}
