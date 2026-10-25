namespace INVTECH.Honduras;

// La habilitación por empresa aplica automáticamente al registrar; no reserva números en borradores.
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
        field(6; "Activar documentos nuevos"; Boolean) { Caption = 'Activación anterior (compatibilidad)'; Editable = false; }
        field(7; "Boletas habilitadas"; Boolean) { Caption = 'Habilitar boletas de compra HN'; }
        field(8; "CAI boletas"; Code[20]) { Caption = 'Autorización de boletas de compra'; TableRelation = "HN CAI Authorization" where("Document Type" = const(BoletaCompra)); }
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
            }
            group(Compras)
            {
                Caption = 'Compras';
                field(HabilitarBoletas; Rec."Boletas habilitadas") { ApplicationArea = All; }
                field(AutorizacionBoletas; Rec."CAI boletas") { ApplicationArea = All; }
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
            action(CAIBoletas)
            {
                Caption = 'CAI de boletas de compra'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN CAI Authorizations";
                RunPageView = where("Document Type" = const(BoletaCompra));
            }
            action(Boletas) { Caption = 'Boletas de compra HN'; ApplicationArea = All; Image = Purchase; RunObject = page "HN Boletas Compra"; }
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
