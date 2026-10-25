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

report 50100 "HN Retention Certificate"
{
    Caption = 'Comprobante de retención HN';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = Certificate;
    dataset
    {
        dataitem(Header; "HN Retention Header")
        {
            RequestFilterFields = "No.";
            column(Document_No; "No.") { }
            column(Fiscal_No; "Fiscal No.") { }
            column(Issue_Date; Format("Posting Date")) { }
            column(Party_Name; "Vendor Name") { }
            column(Party_RTN; "Vendor RTN") { }
            column(Source_No; "Vendor Invoice No.") { }
            column(Source_CAI; "Invoice CAI") { }
            column(CAI_Value; CAI) { }
            column(CAI_Range; "CAI Starting No." + ' / ' + "CAI Ending No.") { }
            column(CAI_Expiration; Format("CAI Valid Until")) { }
            column(Currency_Code; "Currency Code") { }
            column(Issuer_Name; "Issuer Name") { }
            column(Issuer_RTN; "Issuer RTN") { }
            column(Issuer_Address; "Issuer Address") { }
            column(Total_Amount; Amount) { }
            column(Cancellation_Label; CancellationLabel) { }
            column(Cancellation_Reason; "Cancellation Reason") { }
            column(Cancellation_Date; Format("Cancellation Date")) { }
            dataitem(Line; "HN Retention Line")
            {
                DataItemLink = "Document No." = field("No.");
                column(Line_Invoice; "Vendor Invoice No.") { }
                column(Line_Invoice_CAI; "Invoice CAI") { }
                column(Line_Invoice_Date; Format("Invoice Date")) { }
                column(Line_Description; Description) { }
                column(Line_Base; Base) { }
                column(Line_Rate; Percentage) { }
                column(Line_Amount; Amount) { }
            }
            trigger OnAfterGetRecord()
            begin
                if Status = Status::Draft then
                    Error('No se puede imprimir un borrador como comprobante fiscal.');
                Clear(CancellationLabel);
                if Status = Status::Cancelled then
                    CancellationLabel := 'ANULADA';
                CalcFields(Amount);
            end;
        }
    }
    rendering
    {
        layout(Certificate) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/Retencion.rdlc'; Caption = 'Comprobante de retención HN'; }
    }
    var
        CancellationLabel: Text[20];
}
report 50101 "HN Debit Note Certificate"
{
    Caption = 'Nota de débito HN';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = Certificate;
    dataset
    {
        dataitem(Header; "Sales Invoice Header")
        {
            DataItemTableView = where("HN Debit Note" = const(true));
            RequestFilterFields = "No.";
            column(Document_No; "No.") { }
            column(Fiscal_No; "HN Fiscal No.") { }
            column(Issue_Date; Format("Posting Date")) { }
            column(Party_Name; "Bill-to Name") { }
            column(Party_RTN; "VAT Registration No.") { }
            column(Source_No; "HN Source Fiscal No.") { }
            column(Source_CAI; "HN Source CAI") { }
            column(Source_Date; Format("HN Original Invoice Date")) { }
            column(Reason; "HN Debit Reason") { }
            column(CAI_Value; "HN CAI") { }
            column(CAI_Range; "HN CAI Starting No." + ' / ' + "HN CAI Ending No.") { }
            column(CAI_Expiration; Format("HN CAI Valid Until")) { }
            column(Currency_Code; "Currency Code") { }
            column(Issuer_Name; "HN Issuer Name") { }
            column(Issuer_RTN; "HN Issuer RTN") { }
            column(Issuer_Address; "HN Issuer Address") { }
            column(Subtotal_Amount; Amount) { }
            column(Tax_Amount; "Amount Including VAT" - Amount) { }
            column(Party_Address; "Bill-to Address" + ' ' + "Bill-to Address 2" + ' ' + "Bill-to City") { }
            column(Total_Amount; "Amount Including VAT") { }
            dataitem(Line; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = field("No.");
                column(Line_Quantity; Quantity) { }
                column(Line_Unit_Price; "Unit Price") { }
                column(Line_Description; Description) { }
                column(Line_Base; Amount) { }
                column(Line_Rate; "VAT %") { }
                column(Line_Amount; "Amount Including VAT") { }
            }
            trigger OnAfterGetRecord()
            begin
                CalcFields(Amount, "Amount Including VAT");
                if not "HN Debit Note" then
                    Error('Este comprobante corresponde únicamente a notas de débito registradas por esta extensión.');
            end;
        }
    }
    rendering
    {
        layout(Certificate) { Type = RDLC; LayoutFile = 'src/Informes/Disenos/NotaDebito.rdlc'; Caption = 'Nota de débito HN'; }
    }
}
