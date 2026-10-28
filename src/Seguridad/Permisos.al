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
        tabledata "HN Ref Catalogo 60450" = R, table "HN Ref Catalogo 60450" = X, page "HN Ref Lista 60450" = X,
        tabledata "HN Ref Catalogo 60489" = R, table "HN Ref Catalogo 60489" = X, page "HN Ref Lista 60489" = X,
        tabledata "HN Ref Catalogo 60451" = R, table "HN Ref Catalogo 60451" = X, page "HN Ref Lista 60451" = X,
        tabledata "HN Ref Catalogo 60452" = R, table "HN Ref Catalogo 60452" = X, page "HN Ref Lista 60452" = X,
        tabledata "HN Ref Catalogo 60459" = R, table "HN Ref Catalogo 60459" = X, page "HN Ref Lista 60459" = X,
        tabledata "HN Ref Catalogo 60510" = R, table "HN Ref Catalogo 60510" = X, page "HN Ref Lista 60510" = X,
        tabledata "HN Ref Catalogo 60477" = R, table "HN Ref Catalogo 60477" = X, page "HN Ref Lista 60477" = X,
        tabledata "HN Ref Catalogo 60457" = R, table "HN Ref Catalogo 60457" = X, page "HN Ref Lista 60457" = X,
        table "HN Valor Referencia" = X, page "HN Valores Referencia" = X, codeunit "HN Consultar Referencias" = X,
        codeunit "HN Migration Field Map" = X, table "HN Migration Field" = X,
        table "HN Opcion RTN Proveedor" = X, page "HN Elegir RTN Proveedor" = X, codeunit "HN Gestion RTN Proveedor" = X,
        tabledata "HN Seleccion Ret. Factura" = RIMD, table "HN Seleccion Ret. Factura" = X, page "HN Conceptos Factura Ret." = X,
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
        report "HN Movimientos ISV" = X,
        codeunit "HN Gestion Boletas" = X,
        codeunit "HN Importe En Letras" = X,
        codeunit "HN Datos Formatos" = X,
        page "HN Boletas Compra" = X,
        page "HN Boleta Compra" = X,
        page "HN Boletas Registradas" = X,
        report "HN Boleta Compra" = X,
        report "HN Borrador Boleta" = X;
}
