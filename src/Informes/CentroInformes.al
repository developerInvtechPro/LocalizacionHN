namespace INVTECH.Honduras;
page 71113 "HN Centro Informes"
{
    Caption = 'Centro de informes de localización HN';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    layout
    {
        area(Content)
        {
            group(Indicaciones)
            {
                Caption = 'Informes y comprobantes';
                label(Informacion) { ApplicationArea = All; Caption = 'Seleccione un informe en Acciones. Filtre por documento, tercero y fecha antes de imprimir. Los borradores son documentos de trabajo. La boleta registrada es un comprobante fiscal emitido con CAI propio.'; }
            }
        }
    }
    actions
    {
        area(Reporting)
        {
            action(Boleta) { Caption = 'Boleta de compra'; ApplicationArea = All; Image = Print; RunObject = report "HN Boleta Compra"; }
            action(BorradorBoleta) { Caption = 'Borrador de boleta'; ApplicationArea = All; Image = Print; RunObject = report "HN Borrador Boleta"; }
            action(AplicacionesProveedores) { Caption = 'Aplicaciones y desliquidaciones de proveedores'; ApplicationArea = All; Image = Print; RunObject = report "HN Det. Aplicacion Proveedor"; }
            action(AplicacionesClientes) { Caption = 'Aplicaciones y desliquidaciones de clientes'; ApplicationArea = All; Image = Print; RunObject = report "HN Det. Aplicacion Cliente"; }
            action(MovimientosISV) { Caption = 'Movimientos del impuesto sobre ventas'; ApplicationArea = All; Image = Print; RunObject = report "HN Movimientos ISV"; }
            action(Informe0) { Caption = 'Comprobante de retención'; ApplicationArea = All; Image = Print; RunObject = report "HN Retention Certificate"; }
            action(Informe1) { Caption = 'Comprobante de nota de débito'; ApplicationArea = All; Image = Print; RunObject = report "HN Debit Note Certificate"; }
            action(Informe2) { Caption = 'Factura de venta'; ApplicationArea = All; Image = Print; RunObject = report "HN Factura Venta"; }
            action(Informe3) { Caption = 'Nota de crédito de venta'; ApplicationArea = All; Image = Print; RunObject = report "HN Nota Credito Venta"; }
            action(Informe4) { Caption = 'Comprobante interno de compra'; ApplicationArea = All; Image = Print; RunObject = report "HN Comprobante Compra"; }
            action(Informe5) { Caption = 'Comprobante interno de abono de compra'; ApplicationArea = All; Image = Print; RunObject = report "HN Comprobante Abono Compra"; }
            action(Informe6) { Caption = 'Borrador de venta'; ApplicationArea = All; Image = Print; RunObject = report "HN Borrador Venta"; }
            action(Informe7) { Caption = 'Borrador de compra'; ApplicationArea = All; Image = Print; RunObject = report "HN Borrador Compra"; }
            action(Informe8) { Caption = 'Borrador de retención'; ApplicationArea = All; Image = Print; RunObject = report "HN Borrador Retencion"; }
            action(Informe9) { Caption = 'Movimientos contables'; ApplicationArea = All; Image = Print; RunObject = report "HN Movimientos Contables"; }
            action(Informe10) { Caption = 'Movimientos de proveedores'; ApplicationArea = All; Image = Print; RunObject = report "HN Movimientos Proveedor"; }
            action(Informe11) { Caption = 'Movimientos de clientes'; ApplicationArea = All; Image = Print; RunObject = report "HN Movimientos Cliente"; }
            action(Informe12) { Caption = 'Movimientos fiscales y CAI'; ApplicationArea = All; Image = Print; RunObject = report "HN Inf. Movimientos Fiscales"; }
            action(Informe13) { Caption = 'Autorizaciones CAI de ventas'; ApplicationArea = All; Image = Print; RunObject = report "HN Listado CAI Ventas"; }
            action(Informe14) { Caption = 'Autorizaciones CAI de proveedores'; ApplicationArea = All; Image = Print; RunObject = report "HN Listado CAI Proveedores"; }
        }
    }
}
