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

enum 50100 "HN Fiscal Document Type"
{
    Extensible = false;
    value(0; Retention) { Caption = 'Retención'; }
    value(1; "Debit Note") { Caption = 'Nota de débito'; }
    value(2; Factura) { Caption = 'Factura'; }
    value(3; NotaCredito) { Caption = 'Nota de crédito'; }
    value(4; BoletaCompra) { Caption = 'Boleta de compra'; }
}
enum 50101 "HN Retention Status"
{
    Extensible = false;
    value(0; Draft) { Caption = 'Borrador'; }
    value(1; Posted) { Caption = 'Registrado'; }
    value(2; Cancelled) { Caption = 'Anulada'; }
}
enum 50102 "HN Retention Base"
{
    Extensible = false;
    value(0; Net) { Caption = 'Importe sin impuesto'; }
    value(1; VAT) { Caption = 'Importe de impuesto'; }
}
