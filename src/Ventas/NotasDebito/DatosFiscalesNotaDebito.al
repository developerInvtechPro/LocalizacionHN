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

page 50112 "HN Debit Fiscal Data"
{
    PageType = Card;
    SourceTable = "Sales Header";
    SourceTableView = where("Document Type" = const(Invoice), "HN Debit Note" = const(true));
    Caption = 'Datos fiscales de la nota de débito HN';
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            group(Original)
            {
                Caption = 'Factura origen';
                field(Invoice; Rec."HN Original Invoice No.") { ApplicationArea = All; Editable = false; }
                field(FiscalNo; Rec."HN Source Fiscal No.") { ApplicationArea = All; }
                field(CAI; Rec."HN Source CAI") { ApplicationArea = All; }
            }
            group(Issue)
            {
                Caption = 'Emisión de la nota de débito';
                field(Authorization; Rec."HN CAI Code") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ConfigureCAI)
            {
                Caption = 'Configurar CAI'; ApplicationArea = All; Image = Setup;
                RunObject = page "HN CAI Authorizations";
                RunPageView = where("Document Type" = const("Debit Note"));
            }
        }
    }
}
