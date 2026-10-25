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

permissionset 50100 "HN LOCALIZATION"
{
    Assignable = true;
    Caption = 'Localización Honduras V2';
    Permissions =
        tabledata "HN Config. Facturacion" = RIMD,
        tabledata "HN CAI Proveedor" = RIMD,
        tabledata "HN Movimiento Fiscal" = RI,
        table "HN Config. Facturacion" = X,
        table "HN CAI Proveedor" = X,
        table "HN Movimiento Fiscal" = X,
        page "HN Config. Facturacion" = X,
        page "HN CAI Proveedores" = X,
        page "HN Movimientos Fiscales" = X,
        page "HN Centro Informes" = X,
        codeunit "HN Gestion Facturacion" = X,
        codeunit "HN Gestion CAI Proveedor" = X,
        codeunit "HN Trazabilidad Fiscal" = X,
        tabledata "HN Localization Setup" = RIMD,
        tabledata "HN CAI Authorization" = RIMD,
        tabledata "HN Retention Header" = RIMD,
        tabledata "HN Retention Line" = RIMD,
        tabledata "HN Retention Rule" = RIMD,
        tabledata "HN Retention Invoice" = RIMD,
        table "HN Retention Invoice" = X,
        page "HN Retention Invoices" = X,
        page "HN Cancel Retention" = X,
        codeunit "HN Retention Cancellation" = X,
        codeunit "HN POS Metadata Transfer" = X,
        table "HN Localization Setup" = X,
        table "HN CAI Authorization" = X,
        table "HN Retention Header" = X,
        table "HN Retention Line" = X,
        table "HN Retention Rule" = X,
        codeunit "HN CAI Management" = X,
        codeunit "HN Retention Management" = X,
        codeunit "HN Debit Note Management" = X,
        codeunit "HN Purchase Integration" = X,
        codeunit "HN Retention Preview" = X,
        codeunit "HN Setup Management" = X,
        page "HN Localization Setup" = X,
        page "HN CAI Setup Part" = X,
        page "HN CAI Authorizations" = X,
        page "HN Debit Fiscal Data" = X,
        page "HN Retentions" = X,
        page "HN Retention Card" = X,
        page "HN Retention Lines" = X,
        page "HN Retention Rules" = X,
        page "HN Posted Retentions" = X,
        page "HN Debit Notes" = X,
        page "HN Debit Note Card" = X,
        page "HN Posted Debit Notes" = X,
        page "HN Posted Debit Note" = X,
        report "HN Retention Certificate" = X,
        report "HN Debit Note Certificate" = X,
        report "HN Factura Venta" = X,
        report "HN Nota Credito Venta" = X,
        report "HN Comprobante Compra" = X,
        report "HN Comprobante Abono Compra" = X,
        report "HN Borrador Venta" = X,
        report "HN Borrador Compra" = X,
        report "HN Borrador Retencion" = X,
        report "HN Movimientos Contables" = X,
        report "HN Movimientos Proveedor" = X,
        report "HN Movimientos Cliente" = X,
        report "HN Inf. Movimientos Fiscales" = X,
        report "HN Listado CAI Ventas" = X,
        report "HN Listado CAI Proveedores" = X,
        report "HN Det. Aplicacion Proveedor" = X,
        report "HN Det. Aplicacion Cliente" = X,
        report "HN Movimientos ISV" = X;
}
